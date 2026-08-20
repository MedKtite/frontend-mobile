import 'dart:async';
import 'dart:math';

import 'package:flutter/services.dart';
import 'package:sensors_plus/sensors_plus.dart';

/// Listens to user device accelerometer events to trigger "Shake to Extend".
class ShakeDetectorService {
  ShakeDetectorService({
    this.shakeThresholdGravity = 2.4,
    this.shakeSlopTimeMs = 800,
    this.shakeCountResetTimeMs = 3000,
    required this.onShake,
  });

  final double shakeThresholdGravity;
  final int shakeSlopTimeMs;
  final int shakeCountResetTimeMs;
  final void Function() onShake;

  StreamSubscription<UserAccelerometerEvent>? _subscription;
  int _shakeTimestamp = 0;

  void startListening() {
    stopListening();
    _subscription = userAccelerometerEventStream().listen(
      (event) {
        final gX = event.x / 9.80665;
        final gY = event.y / 9.80665;
        final gZ = event.z / 9.80665;

        // gForce will be close to 1 when still.
        final gForce = sqrt(gX * gX + gY * gY + gZ * gZ);

        if (gForce > shakeThresholdGravity) {
          final now = DateTime.now().millisecondsSinceEpoch;
          // Ignore shake events too close to each other
          if (_shakeTimestamp + shakeSlopTimeMs > now) {
            return;
          }

          _shakeTimestamp = now;
          HapticFeedback.mediumImpact();
          onShake();
        }
      },
      onError: (_) {},
      cancelOnError: false,
    );
  }

  void stopListening() {
    _subscription?.cancel();
    _subscription = null;
  }
}
