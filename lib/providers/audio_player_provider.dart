import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

import '../core/dio_client.dart';
import '../models/book.dart';
import '../models/book_update_request.dart';
import '../services/backend/book_service.dart';
import '../services/backend/catalog_service.dart';
import 'library_provider.dart';
import 'state/audio_state.dart';

/// App-level audio playback. The [AudioPlayer] lives HERE, not in the player
/// screen, so minimizing the screen keeps the book playing and the mini
/// player (in AppShell) can control it. State null = no session.
///
/// Two sources, one global timeline (seconds across the whole book):
///  • uploaded M4B/MP3 — single file from the presigned S3 URL;
///  • LibriVox — free public-domain chapter MP3s as a playlist.
/// Position persists into the book's cursor ({"type":"audio"|"librivox"}).
class AudioPlayerController extends StateNotifier<AudioSession?> {
  AudioPlayerController(this._ref) : super(null);

  final Ref _ref;
  final AudioPlayer player = AudioPlayer();
  Timer? _saveTimer;

  /// Starts (or re-attaches to) a session for [bookId]. Returns an error
  /// message, or null on success. Loading the SAME book is a no-op so the
  /// player screen can reopen over a running session without a restart.
  Future<String?> load(String bookId, Book? initialBook) async {
    if (state?.book.id == bookId) return null;
    await stop(); // save + release the previous book's session

    try {
      final book = initialBook ??
          await _ref.read(bookServiceProvider).getOne(bookId);
      final hasFile = book.format == 'm4b' || book.format == 'mp3';

      if (hasFile) {
        final url = (await _ref.read(bookServiceProvider).downloadUrl(bookId))
            .downloadUrl;
        await player.setUrl(url);
        state = AudioSession(
          book: book,
          totalSecs:
              (player.duration ?? Duration.zero).inMilliseconds / 1000,
        );
      } else {
        // No file — look for a free LibriVox recording (public domain).
        final lv = await _ref.read(catalogServiceProvider).librivox(
              title: book.title,
              author: book.author,
            );
        if (lv == null || lv.sections.isEmpty) {
          return 'No audio for this book yet — no free LibriVox recording '
              'exists, and no M4B/MP3 has been uploaded.';
        }
        var acc = 0.0;
        final starts = <double>[];
        for (final s in lv.sections) {
          starts.add(acc);
          acc += (s.playtimeSecs ?? 0).toDouble();
        }
        await player.setAudioSource(
          ConcatenatingAudioSource(children: [
            for (final s in lv.sections)
              AudioSource.uri(Uri.parse(s.listenUrl)),
          ]),
        );
        state = AudioSession(
          book: book,
          librivox: lv,
          cumStart: starts,
          totalSecs:
              (lv.totalTimeSecs ?? 0) > 0 ? lv.totalTimeSecs!.toDouble() : acc,
        );
      }

      await seekGlobal(_resumeSec(book));
      _saveTimer = Timer.periodic(
          const Duration(seconds: 30), (_) => saveProgress());
      return null;
    } on ApiError catch (e) {
      return e.message;
    } catch (_) {
      return "Couldn't load the audio.";
    }
  }

  /// Saves the position, halts playback and clears the session (mini player
  /// disappears). Safe to call with no session.
  Future<void> stop() async {
    _saveTimer?.cancel();
    _saveTimer = null;
    if (state != null) {
      await saveProgress();
      state = null;
    }
    await player.stop();
  }

  void toggle() {
    if (player.playing) {
      player.pause();
      saveProgress();
    } else {
      player.play();
    }
  }

  // ── Global timeline (spans playlist sections) ────────────────────────────

  double globalSec(Duration itemPos) {
    final s = state;
    final base = (s == null || s.cumStart.isEmpty)
        ? 0.0
        : s.cumStart[
            (player.currentIndex ?? 0).clamp(0, s.cumStart.length - 1)];
    return base + itemPos.inMilliseconds / 1000;
  }

  Future<void> seekGlobal(double sec) async {
    final s = state;
    if (s == null) return;
    final target = sec.clamp(0.0, s.totalSecs > 0 ? s.totalSecs : sec);
    if (s.cumStart.isEmpty) {
      await player.seek(Duration(milliseconds: (target * 1000).round()));
      return;
    }
    var index = 0;
    for (var i = 0; i < s.cumStart.length; i++) {
      if (s.cumStart[i] <= target) index = i;
    }
    await player.seek(
      Duration(milliseconds: ((target - s.cumStart[index]) * 1000).round()),
      index: index,
    );
  }

  void seekBy(double deltaSec) {
    seekGlobal(globalSec(player.position) + deltaSec);
    saveProgress();
  }

  /// Current section title (LibriVox = real chapter names), null otherwise.
  String? sectionTitle() {
    final lv = state?.librivox;
    if (lv == null || lv.sections.isEmpty) return null;
    final i = (player.currentIndex ?? 0).clamp(0, lv.sections.length - 1);
    return lv.sections[i].title;
  }

  // ── Progress persistence ─────────────────────────────────────────────────

  double _resumeSec(Book book) {
    final raw = book.cursor;
    if (raw != null && raw.isNotEmpty) {
      try {
        final m = jsonDecode(raw);
        if (m is Map && (m['type'] == 'audio' || m['type'] == 'librivox')) {
          return (m['sec'] as num?)?.toDouble() ?? 0;
        }
      } catch (_) {/* not audio json — ignore */}
    }
    final pct = book.progressPct;
    final total = state?.totalSecs ?? 0;
    if (pct != null && pct > 0 && total > 0) return total * (pct / 100);
    return 0;
  }

  Future<void> saveProgress() async {
    final s = state;
    if (s == null) return;
    final sec = globalSec(player.position);
    try {
      await _ref.read(bookServiceProvider).update(
            s.book.id,
            BookUpdateRequest(
              progressPct: s.totalSecs <= 0
                  ? null
                  : (sec / s.totalSecs * 100).clamp(0, 100).toDouble(),
              cursor: jsonEncode({
                'type': s.librivox == null ? 'audio' : 'librivox',
                'sec': sec,
              }),
            ),
          );
      _ref.invalidate(libraryBooksProvider); // Home's "Still listening" row
    } catch (_) {/* progress save is best-effort */}
  }
}

final audioPlayerProvider =
    StateNotifierProvider<AudioPlayerController, AudioSession?>(
        (ref) => AudioPlayerController(ref));
