import 'package:freezed_annotation/freezed_annotation.dart';

part 'insights_response.freezed.dart';
part 'insights_response.g.dart';

@freezed
class InsightsResponse with _$InsightsResponse {
  const factory InsightsResponse({
    required InsightsSummary summary,
    @Default(<TagBreakdownEntry>[]) List<TagBreakdownEntry> tagBreakdown,
  }) = _InsightsResponse;

  factory InsightsResponse.fromJson(Map<String, dynamic> json) =>
      _$InsightsResponseFromJson(json);
}

@freezed
class InsightsSummary with _$InsightsSummary {
  const factory InsightsSummary({
    required int booksReadThisYear,
    required int highlightsCount,
    required int minutesReadThisWeek,
    required int currentStreakDays,
  }) = _InsightsSummary;

  factory InsightsSummary.fromJson(Map<String, dynamic> json) =>
      _$InsightsSummaryFromJson(json);
}

@freezed
class TagBreakdownEntry with _$TagBreakdownEntry {
  const factory TagBreakdownEntry({
    required String name,
    required String colorHex,
    required int count,
  }) = _TagBreakdownEntry;

  factory TagBreakdownEntry.fromJson(Map<String, dynamic> json) =>
      _$TagBreakdownEntryFromJson(json);
}
