import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/frontend/shake_detector_service.dart';
import 'audio_player_provider.dart';

class SleepTimerState {
  const SleepTimerState({
    required this.remaining,
    required this.initialDuration,
    this.isEndOfChapter = false,
    this.isFading = false,
  });

  final Duration remaining;
  final Duration initialDuration;
  final bool isEndOfChapter;
  final bool isFading;

  SleepTimerState copyWith({
    Duration? remaining,
    Duration? initialDuration,
    bool? isEndOfChapter,
    bool? isFading,
  }) {
    return SleepTimerState(
      remaining: remaining ?? this.remaining,
      initialDuration: initialDuration ?? this.initialDuration,
      isEndOfChapter: isEndOfChapter ?? this.isEndOfChapter,
      isFading: isFading ?? this.isFading,
    );
  }
}

class SleepTimerController extends StateNotifier<SleepTimerState?> {
  SleepTimerController(this._ref) : super(null);

  final Ref _ref;
  Timer? _timer;
  ShakeDetectorService? _shakeDetector;
  static const double _preFadeVolume = 1.0;

  void start(Duration duration, {bool isEndOfChapter = false}) {
    cancel();
    state = SleepTimerState(
      remaining: duration,
      initialDuration: duration,
      isEndOfChapter: isEndOfChapter,
    );

    _initShakeDetector();

    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      final current = state;
      if (current == null) {
        t.cancel();
        return;
      }

      final nextSec = current.remaining.inSeconds - 1;
      if (nextSec <= 0) {
        _onTimerExpired();
        return;
      }

      final nextDur = Duration(seconds: nextSec);

      // Smooth fade-out in final 30 seconds
      if (nextSec <= 30) {
        final player = _ref.read(audioPlayerProvider.notifier).player;
        final vol = (nextSec / 30.0).clamp(0.0, 1.0);
        player.setVolume(vol);
        state = current.copyWith(remaining: nextDur, isFading: true);
      } else {
        state = current.copyWith(remaining: nextDur, isFading: false);
      }
    });
  }

  void extendBy(Duration extension) {
    final current = state;
    final base = current?.remaining ?? Duration.zero;
    final nextDur = base + extension;

    final player = _ref.read(audioPlayerProvider.notifier).player;
    player.setVolume(_preFadeVolume);

    HapticFeedback.heavyImpact();

    if (current != null) {
      state = current.copyWith(
        remaining: nextDur,
        initialDuration: nextDur,
        isFading: false,
      );
    } else {
      start(nextDur);
    }
  }

  void _initShakeDetector() {
    _shakeDetector?.stopListening();
    _shakeDetector = ShakeDetectorService(
      onShake: () {
        // Shake to extend: adds 15 minutes when shaken
        extendBy(const Duration(minutes: 15));
      },
    );
    _shakeDetector?.startListening();
  }

  void _onTimerExpired() {
    final player = _ref.read(audioPlayerProvider.notifier).player;
    player.pause();
    player.setVolume(1.0);
    cancel();
  }

  void cancel() {
    _timer?.cancel();
    _timer = null;
    _shakeDetector?.stopListening();
    _shakeDetector = null;

    final player = _ref.read(audioPlayerProvider.notifier).player;
    player.setVolume(1.0);
    state = null;
  }

  @override
  void dispose() {
    cancel();
    super.dispose();
  }
}

final sleepTimerProvider =
    StateNotifierProvider<SleepTimerController, SleepTimerState?>(
      (ref) => SleepTimerController(ref),
    );
