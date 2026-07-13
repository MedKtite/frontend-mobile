import 'package:freezed_annotation/freezed_annotation.dart';

part 'librivox_audiobook.freezed.dart';
part 'librivox_audiobook.g.dart';

/// Mirrors the backend's LibrivoxBookResponse (dto/catalog/…) — a free
/// public-domain audiobook from LibriVox, played as a playlist of chapter
/// MP3s hosted on the Internet Archive.
@freezed
class LibrivoxAudiobook with _$LibrivoxAudiobook {
  const factory LibrivoxAudiobook({
    int? librivoxId,
    String? title,
    String? author,
    int? totalTimeSecs,
    @Default(<LibrivoxSection>[]) List<LibrivoxSection> sections,
  }) = _LibrivoxAudiobook;

  factory LibrivoxAudiobook.fromJson(Map<String, dynamic> json) =>
      _$LibrivoxAudiobookFromJson(json);
}

@freezed
class LibrivoxSection with _$LibrivoxSection {
  const factory LibrivoxSection({
    String? title,
    required String listenUrl,
    int? playtimeSecs,
  }) = _LibrivoxSection;

  factory LibrivoxSection.fromJson(Map<String, dynamic> json) =>
      _$LibrivoxSectionFromJson(json);
}
