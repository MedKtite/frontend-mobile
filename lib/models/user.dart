import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

/// Mirrors the backend's UserResponse DTO (dto/auth/UserResponse.java).
@freezed
class User with _$User {
  const factory User({
    required String id,
    required String email,
    required String displayName,
    String? shortName,
    String? avatarInitial,
    String? authProvider, // "password" | "google" | "x" | …
    @Default('UTC') String timezone,
    @Default(false) bool emailVerified,
    String? createdAt,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}
