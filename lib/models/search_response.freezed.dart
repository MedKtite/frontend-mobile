// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'search_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

SearchResponse _$SearchResponseFromJson(Map<String, dynamic> json) {
  return _SearchResponse.fromJson(json);
}

/// @nodoc
mixin _$SearchResponse {
  String? get query => throw _privateConstructorUsedError;
  String? get scope => throw _privateConstructorUsedError;
  int get totalHits => throw _privateConstructorUsedError;
  SearchCounts get counts => throw _privateConstructorUsedError;
  List<SearchHit> get results => throw _privateConstructorUsedError;

  /// Serializes this SearchResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SearchResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SearchResponseCopyWith<SearchResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SearchResponseCopyWith<$Res> {
  factory $SearchResponseCopyWith(
    SearchResponse value,
    $Res Function(SearchResponse) then,
  ) = _$SearchResponseCopyWithImpl<$Res, SearchResponse>;
  @useResult
  $Res call({
    String? query,
    String? scope,
    int totalHits,
    SearchCounts counts,
    List<SearchHit> results,
  });

  $SearchCountsCopyWith<$Res> get counts;
}

/// @nodoc
class _$SearchResponseCopyWithImpl<$Res, $Val extends SearchResponse>
    implements $SearchResponseCopyWith<$Res> {
  _$SearchResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SearchResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? query = freezed,
    Object? scope = freezed,
    Object? totalHits = null,
    Object? counts = null,
    Object? results = null,
  }) {
    return _then(
      _value.copyWith(
            query: freezed == query
                ? _value.query
                : query // ignore: cast_nullable_to_non_nullable
                      as String?,
            scope: freezed == scope
                ? _value.scope
                : scope // ignore: cast_nullable_to_non_nullable
                      as String?,
            totalHits: null == totalHits
                ? _value.totalHits
                : totalHits // ignore: cast_nullable_to_non_nullable
                      as int,
            counts: null == counts
                ? _value.counts
                : counts // ignore: cast_nullable_to_non_nullable
                      as SearchCounts,
            results: null == results
                ? _value.results
                : results // ignore: cast_nullable_to_non_nullable
                      as List<SearchHit>,
          )
          as $Val,
    );
  }

  /// Create a copy of SearchResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SearchCountsCopyWith<$Res> get counts {
    return $SearchCountsCopyWith<$Res>(_value.counts, (value) {
      return _then(_value.copyWith(counts: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$SearchResponseImplCopyWith<$Res>
    implements $SearchResponseCopyWith<$Res> {
  factory _$$SearchResponseImplCopyWith(
    _$SearchResponseImpl value,
    $Res Function(_$SearchResponseImpl) then,
  ) = __$$SearchResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String? query,
    String? scope,
    int totalHits,
    SearchCounts counts,
    List<SearchHit> results,
  });

  @override
  $SearchCountsCopyWith<$Res> get counts;
}

/// @nodoc
class __$$SearchResponseImplCopyWithImpl<$Res>
    extends _$SearchResponseCopyWithImpl<$Res, _$SearchResponseImpl>
    implements _$$SearchResponseImplCopyWith<$Res> {
  __$$SearchResponseImplCopyWithImpl(
    _$SearchResponseImpl _value,
    $Res Function(_$SearchResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SearchResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? query = freezed,
    Object? scope = freezed,
    Object? totalHits = null,
    Object? counts = null,
    Object? results = null,
  }) {
    return _then(
      _$SearchResponseImpl(
        query: freezed == query
            ? _value.query
            : query // ignore: cast_nullable_to_non_nullable
                  as String?,
        scope: freezed == scope
            ? _value.scope
            : scope // ignore: cast_nullable_to_non_nullable
                  as String?,
        totalHits: null == totalHits
            ? _value.totalHits
            : totalHits // ignore: cast_nullable_to_non_nullable
                  as int,
        counts: null == counts
            ? _value.counts
            : counts // ignore: cast_nullable_to_non_nullable
                  as SearchCounts,
        results: null == results
            ? _value._results
            : results // ignore: cast_nullable_to_non_nullable
                  as List<SearchHit>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SearchResponseImpl implements _SearchResponse {
  const _$SearchResponseImpl({
    this.query,
    this.scope,
    this.totalHits = 0,
    this.counts = const SearchCounts(),
    final List<SearchHit> results = const <SearchHit>[],
  }) : _results = results;

  factory _$SearchResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$SearchResponseImplFromJson(json);

  @override
  final String? query;
  @override
  final String? scope;
  @override
  @JsonKey()
  final int totalHits;
  @override
  @JsonKey()
  final SearchCounts counts;
  final List<SearchHit> _results;
  @override
  @JsonKey()
  List<SearchHit> get results {
    if (_results is EqualUnmodifiableListView) return _results;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_results);
  }

  @override
  String toString() {
    return 'SearchResponse(query: $query, scope: $scope, totalHits: $totalHits, counts: $counts, results: $results)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SearchResponseImpl &&
            (identical(other.query, query) || other.query == query) &&
            (identical(other.scope, scope) || other.scope == scope) &&
            (identical(other.totalHits, totalHits) ||
                other.totalHits == totalHits) &&
            (identical(other.counts, counts) || other.counts == counts) &&
            const DeepCollectionEquality().equals(other._results, _results));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    query,
    scope,
    totalHits,
    counts,
    const DeepCollectionEquality().hash(_results),
  );

  /// Create a copy of SearchResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SearchResponseImplCopyWith<_$SearchResponseImpl> get copyWith =>
      __$$SearchResponseImplCopyWithImpl<_$SearchResponseImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$SearchResponseImplToJson(this);
  }
}

abstract class _SearchResponse implements SearchResponse {
  const factory _SearchResponse({
    final String? query,
    final String? scope,
    final int totalHits,
    final SearchCounts counts,
    final List<SearchHit> results,
  }) = _$SearchResponseImpl;

  factory _SearchResponse.fromJson(Map<String, dynamic> json) =
      _$SearchResponseImpl.fromJson;

  @override
  String? get query;
  @override
  String? get scope;
  @override
  int get totalHits;
  @override
  SearchCounts get counts;
  @override
  List<SearchHit> get results;

  /// Create a copy of SearchResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SearchResponseImplCopyWith<_$SearchResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SearchCounts _$SearchCountsFromJson(Map<String, dynamic> json) {
  return _SearchCounts.fromJson(json);
}

/// @nodoc
mixin _$SearchCounts {
  int get books => throw _privateConstructorUsedError;
  int get highlights => throw _privateConstructorUsedError;
  int get notes => throw _privateConstructorUsedError;

  /// Serializes this SearchCounts to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SearchCounts
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SearchCountsCopyWith<SearchCounts> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SearchCountsCopyWith<$Res> {
  factory $SearchCountsCopyWith(
    SearchCounts value,
    $Res Function(SearchCounts) then,
  ) = _$SearchCountsCopyWithImpl<$Res, SearchCounts>;
  @useResult
  $Res call({int books, int highlights, int notes});
}

/// @nodoc
class _$SearchCountsCopyWithImpl<$Res, $Val extends SearchCounts>
    implements $SearchCountsCopyWith<$Res> {
  _$SearchCountsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SearchCounts
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? books = null,
    Object? highlights = null,
    Object? notes = null,
  }) {
    return _then(
      _value.copyWith(
            books: null == books
                ? _value.books
                : books // ignore: cast_nullable_to_non_nullable
                      as int,
            highlights: null == highlights
                ? _value.highlights
                : highlights // ignore: cast_nullable_to_non_nullable
                      as int,
            notes: null == notes
                ? _value.notes
                : notes // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SearchCountsImplCopyWith<$Res>
    implements $SearchCountsCopyWith<$Res> {
  factory _$$SearchCountsImplCopyWith(
    _$SearchCountsImpl value,
    $Res Function(_$SearchCountsImpl) then,
  ) = __$$SearchCountsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int books, int highlights, int notes});
}

/// @nodoc
class __$$SearchCountsImplCopyWithImpl<$Res>
    extends _$SearchCountsCopyWithImpl<$Res, _$SearchCountsImpl>
    implements _$$SearchCountsImplCopyWith<$Res> {
  __$$SearchCountsImplCopyWithImpl(
    _$SearchCountsImpl _value,
    $Res Function(_$SearchCountsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SearchCounts
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? books = null,
    Object? highlights = null,
    Object? notes = null,
  }) {
    return _then(
      _$SearchCountsImpl(
        books: null == books
            ? _value.books
            : books // ignore: cast_nullable_to_non_nullable
                  as int,
        highlights: null == highlights
            ? _value.highlights
            : highlights // ignore: cast_nullable_to_non_nullable
                  as int,
        notes: null == notes
            ? _value.notes
            : notes // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SearchCountsImpl implements _SearchCounts {
  const _$SearchCountsImpl({
    this.books = 0,
    this.highlights = 0,
    this.notes = 0,
  });

  factory _$SearchCountsImpl.fromJson(Map<String, dynamic> json) =>
      _$$SearchCountsImplFromJson(json);

  @override
  @JsonKey()
  final int books;
  @override
  @JsonKey()
  final int highlights;
  @override
  @JsonKey()
  final int notes;

  @override
  String toString() {
    return 'SearchCounts(books: $books, highlights: $highlights, notes: $notes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SearchCountsImpl &&
            (identical(other.books, books) || other.books == books) &&
            (identical(other.highlights, highlights) ||
                other.highlights == highlights) &&
            (identical(other.notes, notes) || other.notes == notes));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, books, highlights, notes);

  /// Create a copy of SearchCounts
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SearchCountsImplCopyWith<_$SearchCountsImpl> get copyWith =>
      __$$SearchCountsImplCopyWithImpl<_$SearchCountsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SearchCountsImplToJson(this);
  }
}

abstract class _SearchCounts implements SearchCounts {
  const factory _SearchCounts({
    final int books,
    final int highlights,
    final int notes,
  }) = _$SearchCountsImpl;

  factory _SearchCounts.fromJson(Map<String, dynamic> json) =
      _$SearchCountsImpl.fromJson;

  @override
  int get books;
  @override
  int get highlights;
  @override
  int get notes;

  /// Create a copy of SearchCounts
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SearchCountsImplCopyWith<_$SearchCountsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
