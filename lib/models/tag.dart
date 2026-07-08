import 'package:freezed_annotation/freezed_annotation.dart';

part 'tag.freezed.dart';
part 'tag.g.dart';

/// Mirrors the backend's TagResponse DTO (dto/tag/TagResponse.java) —
/// the 7 seeded system tags plus the user's custom (Pro) tags.
@freezed
class Tag with _$Tag {
  const factory Tag({
    required String id,
    required String name,
    String? colorHex,
    @Default(false) bool isSystem,
  }) = _Tag;

  factory Tag.fromJson(Map<String, dynamic> json) => _$TagFromJson(json);
}
