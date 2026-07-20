// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'insights_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

InsightsResponse _$InsightsResponseFromJson(Map<String, dynamic> json) {
  return _InsightsResponse.fromJson(json);
}

/// @nodoc
mixin _$InsightsResponse {
  InsightsSummary get summary => throw _privateConstructorUsedError;
  List<TagBreakdownEntry> get tagBreakdown =>
      throw _privateConstructorUsedError;

  /// Serializes this InsightsResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of InsightsResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $InsightsResponseCopyWith<InsightsResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $InsightsResponseCopyWith<$Res> {
  factory $InsightsResponseCopyWith(
    InsightsResponse value,
    $Res Function(InsightsResponse) then,
  ) = _$InsightsResponseCopyWithImpl<$Res, InsightsResponse>;
  @useResult
  $Res call({InsightsSummary summary, List<TagBreakdownEntry> tagBreakdown});

  $InsightsSummaryCopyWith<$Res> get summary;
}

/// @nodoc
class _$InsightsResponseCopyWithImpl<$Res, $Val extends InsightsResponse>
    implements $InsightsResponseCopyWith<$Res> {
  _$InsightsResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of InsightsResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? summary = null, Object? tagBreakdown = null}) {
    return _then(
      _value.copyWith(
            summary: null == summary
                ? _value.summary
                : summary // ignore: cast_nullable_to_non_nullable
                      as InsightsSummary,
            tagBreakdown: null == tagBreakdown
                ? _value.tagBreakdown
                : tagBreakdown // ignore: cast_nullable_to_non_nullable
                      as List<TagBreakdownEntry>,
          )
          as $Val,
    );
  }

  /// Create a copy of InsightsResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $InsightsSummaryCopyWith<$Res> get summary {
    return $InsightsSummaryCopyWith<$Res>(_value.summary, (value) {
      return _then(_value.copyWith(summary: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$InsightsResponseImplCopyWith<$Res>
    implements $InsightsResponseCopyWith<$Res> {
  factory _$$InsightsResponseImplCopyWith(
    _$InsightsResponseImpl value,
    $Res Function(_$InsightsResponseImpl) then,
  ) = __$$InsightsResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({InsightsSummary summary, List<TagBreakdownEntry> tagBreakdown});

  @override
  $InsightsSummaryCopyWith<$Res> get summary;
}

/// @nodoc
class __$$InsightsResponseImplCopyWithImpl<$Res>
    extends _$InsightsResponseCopyWithImpl<$Res, _$InsightsResponseImpl>
    implements _$$InsightsResponseImplCopyWith<$Res> {
  __$$InsightsResponseImplCopyWithImpl(
    _$InsightsResponseImpl _value,
    $Res Function(_$InsightsResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of InsightsResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? summary = null, Object? tagBreakdown = null}) {
    return _then(
      _$InsightsResponseImpl(
        summary: null == summary
            ? _value.summary
            : summary // ignore: cast_nullable_to_non_nullable
                  as InsightsSummary,
        tagBreakdown: null == tagBreakdown
            ? _value._tagBreakdown
            : tagBreakdown // ignore: cast_nullable_to_non_nullable
                  as List<TagBreakdownEntry>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$InsightsResponseImpl implements _InsightsResponse {
  const _$InsightsResponseImpl({
    required this.summary,
    final List<TagBreakdownEntry> tagBreakdown = const <TagBreakdownEntry>[],
  }) : _tagBreakdown = tagBreakdown;

  factory _$InsightsResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$InsightsResponseImplFromJson(json);

  @override
  final InsightsSummary summary;
  final List<TagBreakdownEntry> _tagBreakdown;
  @override
  @JsonKey()
  List<TagBreakdownEntry> get tagBreakdown {
    if (_tagBreakdown is EqualUnmodifiableListView) return _tagBreakdown;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tagBreakdown);
  }

  @override
  String toString() {
    return 'InsightsResponse(summary: $summary, tagBreakdown: $tagBreakdown)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$InsightsResponseImpl &&
            (identical(other.summary, summary) || other.summary == summary) &&
            const DeepCollectionEquality().equals(
              other._tagBreakdown,
              _tagBreakdown,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    summary,
    const DeepCollectionEquality().hash(_tagBreakdown),
  );

  /// Create a copy of InsightsResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$InsightsResponseImplCopyWith<_$InsightsResponseImpl> get copyWith =>
      __$$InsightsResponseImplCopyWithImpl<_$InsightsResponseImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$InsightsResponseImplToJson(this);
  }
}

abstract class _InsightsResponse implements InsightsResponse {
  const factory _InsightsResponse({
    required final InsightsSummary summary,
    final List<TagBreakdownEntry> tagBreakdown,
  }) = _$InsightsResponseImpl;

  factory _InsightsResponse.fromJson(Map<String, dynamic> json) =
      _$InsightsResponseImpl.fromJson;

  @override
  InsightsSummary get summary;
  @override
  List<TagBreakdownEntry> get tagBreakdown;

  /// Create a copy of InsightsResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$InsightsResponseImplCopyWith<_$InsightsResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

InsightsSummary _$InsightsSummaryFromJson(Map<String, dynamic> json) {
  return _InsightsSummary.fromJson(json);
}

/// @nodoc
mixin _$InsightsSummary {
  int get booksReadThisYear => throw _privateConstructorUsedError;
  int get highlightsCount => throw _privateConstructorUsedError;
  int get minutesReadThisWeek => throw _privateConstructorUsedError;
  int get currentStreakDays => throw _privateConstructorUsedError;

  /// Serializes this InsightsSummary to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of InsightsSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $InsightsSummaryCopyWith<InsightsSummary> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $InsightsSummaryCopyWith<$Res> {
  factory $InsightsSummaryCopyWith(
    InsightsSummary value,
    $Res Function(InsightsSummary) then,
  ) = _$InsightsSummaryCopyWithImpl<$Res, InsightsSummary>;
  @useResult
  $Res call({
    int booksReadThisYear,
    int highlightsCount,
    int minutesReadThisWeek,
    int currentStreakDays,
  });
}

/// @nodoc
class _$InsightsSummaryCopyWithImpl<$Res, $Val extends InsightsSummary>
    implements $InsightsSummaryCopyWith<$Res> {
  _$InsightsSummaryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of InsightsSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? booksReadThisYear = null,
    Object? highlightsCount = null,
    Object? minutesReadThisWeek = null,
    Object? currentStreakDays = null,
  }) {
    return _then(
      _value.copyWith(
            booksReadThisYear: null == booksReadThisYear
                ? _value.booksReadThisYear
                : booksReadThisYear // ignore: cast_nullable_to_non_nullable
                      as int,
            highlightsCount: null == highlightsCount
                ? _value.highlightsCount
                : highlightsCount // ignore: cast_nullable_to_non_nullable
                      as int,
            minutesReadThisWeek: null == minutesReadThisWeek
                ? _value.minutesReadThisWeek
                : minutesReadThisWeek // ignore: cast_nullable_to_non_nullable
                      as int,
            currentStreakDays: null == currentStreakDays
                ? _value.currentStreakDays
                : currentStreakDays // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$InsightsSummaryImplCopyWith<$Res>
    implements $InsightsSummaryCopyWith<$Res> {
  factory _$$InsightsSummaryImplCopyWith(
    _$InsightsSummaryImpl value,
    $Res Function(_$InsightsSummaryImpl) then,
  ) = __$$InsightsSummaryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int booksReadThisYear,
    int highlightsCount,
    int minutesReadThisWeek,
    int currentStreakDays,
  });
}

/// @nodoc
class __$$InsightsSummaryImplCopyWithImpl<$Res>
    extends _$InsightsSummaryCopyWithImpl<$Res, _$InsightsSummaryImpl>
    implements _$$InsightsSummaryImplCopyWith<$Res> {
  __$$InsightsSummaryImplCopyWithImpl(
    _$InsightsSummaryImpl _value,
    $Res Function(_$InsightsSummaryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of InsightsSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? booksReadThisYear = null,
    Object? highlightsCount = null,
    Object? minutesReadThisWeek = null,
    Object? currentStreakDays = null,
  }) {
    return _then(
      _$InsightsSummaryImpl(
        booksReadThisYear: null == booksReadThisYear
            ? _value.booksReadThisYear
            : booksReadThisYear // ignore: cast_nullable_to_non_nullable
                  as int,
        highlightsCount: null == highlightsCount
            ? _value.highlightsCount
            : highlightsCount // ignore: cast_nullable_to_non_nullable
                  as int,
        minutesReadThisWeek: null == minutesReadThisWeek
            ? _value.minutesReadThisWeek
            : minutesReadThisWeek // ignore: cast_nullable_to_non_nullable
                  as int,
        currentStreakDays: null == currentStreakDays
            ? _value.currentStreakDays
            : currentStreakDays // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$InsightsSummaryImpl implements _InsightsSummary {
  const _$InsightsSummaryImpl({
    required this.booksReadThisYear,
    required this.highlightsCount,
    required this.minutesReadThisWeek,
    required this.currentStreakDays,
  });

  factory _$InsightsSummaryImpl.fromJson(Map<String, dynamic> json) =>
      _$$InsightsSummaryImplFromJson(json);

  @override
  final int booksReadThisYear;
  @override
  final int highlightsCount;
  @override
  final int minutesReadThisWeek;
  @override
  final int currentStreakDays;

  @override
  String toString() {
    return 'InsightsSummary(booksReadThisYear: $booksReadThisYear, highlightsCount: $highlightsCount, minutesReadThisWeek: $minutesReadThisWeek, currentStreakDays: $currentStreakDays)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$InsightsSummaryImpl &&
            (identical(other.booksReadThisYear, booksReadThisYear) ||
                other.booksReadThisYear == booksReadThisYear) &&
            (identical(other.highlightsCount, highlightsCount) ||
                other.highlightsCount == highlightsCount) &&
            (identical(other.minutesReadThisWeek, minutesReadThisWeek) ||
                other.minutesReadThisWeek == minutesReadThisWeek) &&
            (identical(other.currentStreakDays, currentStreakDays) ||
                other.currentStreakDays == currentStreakDays));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    booksReadThisYear,
    highlightsCount,
    minutesReadThisWeek,
    currentStreakDays,
  );

  /// Create a copy of InsightsSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$InsightsSummaryImplCopyWith<_$InsightsSummaryImpl> get copyWith =>
      __$$InsightsSummaryImplCopyWithImpl<_$InsightsSummaryImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$InsightsSummaryImplToJson(this);
  }
}

abstract class _InsightsSummary implements InsightsSummary {
  const factory _InsightsSummary({
    required final int booksReadThisYear,
    required final int highlightsCount,
    required final int minutesReadThisWeek,
    required final int currentStreakDays,
  }) = _$InsightsSummaryImpl;

  factory _InsightsSummary.fromJson(Map<String, dynamic> json) =
      _$InsightsSummaryImpl.fromJson;

  @override
  int get booksReadThisYear;
  @override
  int get highlightsCount;
  @override
  int get minutesReadThisWeek;
  @override
  int get currentStreakDays;

  /// Create a copy of InsightsSummary
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$InsightsSummaryImplCopyWith<_$InsightsSummaryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

TagBreakdownEntry _$TagBreakdownEntryFromJson(Map<String, dynamic> json) {
  return _TagBreakdownEntry.fromJson(json);
}

/// @nodoc
mixin _$TagBreakdownEntry {
  String get name => throw _privateConstructorUsedError;
  String get colorHex => throw _privateConstructorUsedError;
  int get count => throw _privateConstructorUsedError;

  /// Serializes this TagBreakdownEntry to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TagBreakdownEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TagBreakdownEntryCopyWith<TagBreakdownEntry> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TagBreakdownEntryCopyWith<$Res> {
  factory $TagBreakdownEntryCopyWith(
    TagBreakdownEntry value,
    $Res Function(TagBreakdownEntry) then,
  ) = _$TagBreakdownEntryCopyWithImpl<$Res, TagBreakdownEntry>;
  @useResult
  $Res call({String name, String colorHex, int count});
}

/// @nodoc
class _$TagBreakdownEntryCopyWithImpl<$Res, $Val extends TagBreakdownEntry>
    implements $TagBreakdownEntryCopyWith<$Res> {
  _$TagBreakdownEntryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TagBreakdownEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? colorHex = null,
    Object? count = null,
  }) {
    return _then(
      _value.copyWith(
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            colorHex: null == colorHex
                ? _value.colorHex
                : colorHex // ignore: cast_nullable_to_non_nullable
                      as String,
            count: null == count
                ? _value.count
                : count // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$TagBreakdownEntryImplCopyWith<$Res>
    implements $TagBreakdownEntryCopyWith<$Res> {
  factory _$$TagBreakdownEntryImplCopyWith(
    _$TagBreakdownEntryImpl value,
    $Res Function(_$TagBreakdownEntryImpl) then,
  ) = __$$TagBreakdownEntryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String name, String colorHex, int count});
}

/// @nodoc
class __$$TagBreakdownEntryImplCopyWithImpl<$Res>
    extends _$TagBreakdownEntryCopyWithImpl<$Res, _$TagBreakdownEntryImpl>
    implements _$$TagBreakdownEntryImplCopyWith<$Res> {
  __$$TagBreakdownEntryImplCopyWithImpl(
    _$TagBreakdownEntryImpl _value,
    $Res Function(_$TagBreakdownEntryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TagBreakdownEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? colorHex = null,
    Object? count = null,
  }) {
    return _then(
      _$TagBreakdownEntryImpl(
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        colorHex: null == colorHex
            ? _value.colorHex
            : colorHex // ignore: cast_nullable_to_non_nullable
                  as String,
        count: null == count
            ? _value.count
            : count // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$TagBreakdownEntryImpl implements _TagBreakdownEntry {
  const _$TagBreakdownEntryImpl({
    required this.name,
    required this.colorHex,
    required this.count,
  });

  factory _$TagBreakdownEntryImpl.fromJson(Map<String, dynamic> json) =>
      _$$TagBreakdownEntryImplFromJson(json);

  @override
  final String name;
  @override
  final String colorHex;
  @override
  final int count;

  @override
  String toString() {
    return 'TagBreakdownEntry(name: $name, colorHex: $colorHex, count: $count)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TagBreakdownEntryImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.colorHex, colorHex) ||
                other.colorHex == colorHex) &&
            (identical(other.count, count) || other.count == count));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, name, colorHex, count);

  /// Create a copy of TagBreakdownEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TagBreakdownEntryImplCopyWith<_$TagBreakdownEntryImpl> get copyWith =>
      __$$TagBreakdownEntryImplCopyWithImpl<_$TagBreakdownEntryImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$TagBreakdownEntryImplToJson(this);
  }
}

abstract class _TagBreakdownEntry implements TagBreakdownEntry {
  const factory _TagBreakdownEntry({
    required final String name,
    required final String colorHex,
    required final int count,
  }) = _$TagBreakdownEntryImpl;

  factory _TagBreakdownEntry.fromJson(Map<String, dynamic> json) =
      _$TagBreakdownEntryImpl.fromJson;

  @override
  String get name;
  @override
  String get colorHex;
  @override
  int get count;

  /// Create a copy of TagBreakdownEntry
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TagBreakdownEntryImplCopyWith<_$TagBreakdownEntryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
