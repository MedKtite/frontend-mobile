// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserImpl _$$UserImplFromJson(Map<String, dynamic> json) => _$UserImpl(
  id: json['id'] as String,
  email: json['email'] as String,
  displayName: json['displayName'] as String,
  shortName: json['shortName'] as String?,
  avatarInitial: json['avatarInitial'] as String?,
  authProvider: json['authProvider'] as String?,
  timezone: json['timezone'] as String? ?? 'UTC',
  emailVerified: json['emailVerified'] as bool? ?? false,
  createdAt: json['createdAt'] as String?,
);

Map<String, dynamic> _$$UserImplToJson(_$UserImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'displayName': instance.displayName,
      'shortName': instance.shortName,
      'avatarInitial': instance.avatarInitial,
      'authProvider': instance.authProvider,
      'timezone': instance.timezone,
      'emailVerified': instance.emailVerified,
      'createdAt': instance.createdAt,
    };
