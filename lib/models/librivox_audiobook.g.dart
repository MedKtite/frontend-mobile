// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'librivox_audiobook.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LibrivoxAudiobookImpl _$$LibrivoxAudiobookImplFromJson(
  Map<String, dynamic> json,
) => _$LibrivoxAudiobookImpl(
  librivoxId: (json['librivoxId'] as num?)?.toInt(),
  title: json['title'] as String?,
  author: json['author'] as String?,
  totalTimeSecs: (json['totalTimeSecs'] as num?)?.toInt(),
  sections:
      (json['sections'] as List<dynamic>?)
          ?.map((e) => LibrivoxSection.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <LibrivoxSection>[],
);

Map<String, dynamic> _$$LibrivoxAudiobookImplToJson(
  _$LibrivoxAudiobookImpl instance,
) => <String, dynamic>{
  'librivoxId': instance.librivoxId,
  'title': instance.title,
  'author': instance.author,
  'totalTimeSecs': instance.totalTimeSecs,
  'sections': instance.sections,
};

_$LibrivoxSectionImpl _$$LibrivoxSectionImplFromJson(
  Map<String, dynamic> json,
) => _$LibrivoxSectionImpl(
  title: json['title'] as String?,
  listenUrl: json['listenUrl'] as String,
  playtimeSecs: (json['playtimeSecs'] as num?)?.toInt(),
);

Map<String, dynamic> _$$LibrivoxSectionImplToJson(
  _$LibrivoxSectionImpl instance,
) => <String, dynamic>{
  'title': instance.title,
  'listenUrl': instance.listenUrl,
  'playtimeSecs': instance.playtimeSecs,
};
