// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'insights_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$InsightsResponseImpl _$$InsightsResponseImplFromJson(
  Map<String, dynamic> json,
) => _$InsightsResponseImpl(
  summary: InsightsSummary.fromJson(json['summary'] as Map<String, dynamic>),
  tagBreakdown:
      (json['tagBreakdown'] as List<dynamic>?)
          ?.map((e) => TagBreakdownEntry.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <TagBreakdownEntry>[],
);

Map<String, dynamic> _$$InsightsResponseImplToJson(
  _$InsightsResponseImpl instance,
) => <String, dynamic>{
  'summary': instance.summary,
  'tagBreakdown': instance.tagBreakdown,
};

_$InsightsSummaryImpl _$$InsightsSummaryImplFromJson(
  Map<String, dynamic> json,
) => _$InsightsSummaryImpl(
  booksReadThisYear: (json['booksReadThisYear'] as num).toInt(),
  highlightsCount: (json['highlightsCount'] as num).toInt(),
  minutesReadThisWeek: (json['minutesReadThisWeek'] as num).toInt(),
  currentStreakDays: (json['currentStreakDays'] as num).toInt(),
);

Map<String, dynamic> _$$InsightsSummaryImplToJson(
  _$InsightsSummaryImpl instance,
) => <String, dynamic>{
  'booksReadThisYear': instance.booksReadThisYear,
  'highlightsCount': instance.highlightsCount,
  'minutesReadThisWeek': instance.minutesReadThisWeek,
  'currentStreakDays': instance.currentStreakDays,
};

_$TagBreakdownEntryImpl _$$TagBreakdownEntryImplFromJson(
  Map<String, dynamic> json,
) => _$TagBreakdownEntryImpl(
  name: json['name'] as String,
  colorHex: json['colorHex'] as String,
  count: (json['count'] as num).toInt(),
);

Map<String, dynamic> _$$TagBreakdownEntryImplToJson(
  _$TagBreakdownEntryImpl instance,
) => <String, dynamic>{
  'name': instance.name,
  'colorHex': instance.colorHex,
  'count': instance.count,
};
