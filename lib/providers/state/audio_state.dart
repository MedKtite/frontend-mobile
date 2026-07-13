import 'package:freezed_annotation/freezed_annotation.dart';

import '../../models/book.dart';
import '../../models/librivox_audiobook.dart';

part 'audio_state.freezed.dart';

/// An active audio session — lives in [audioPlayerProvider] so playback
/// survives leaving the player screen (the mini player renders from this).
/// Null provider state = nothing playing, no mini player.
@freezed
class AudioSession with _$AudioSession {
  const factory AudioSession({
    required Book book,
    /// Non-null when streaming a LibriVox playlist instead of an uploaded file.
    LibrivoxAudiobook? librivox,
    /// Global start second of each playlist section (empty for single files).
    @Default(<double>[]) List<double> cumStart,
    required double totalSecs,
  }) = _AudioSession;
}
