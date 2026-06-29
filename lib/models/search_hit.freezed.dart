// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'search_hit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

SearchHit _$SearchHitFromJson(Map<String, dynamic> json) {
  return _SearchHit.fromJson(json);
}

/// @nodoc
mixin _$SearchHit {
  String get type => throw _privateConstructorUsedError;
  String get id => throw _privateConstructorUsedError;
  String? get bookId => throw _privateConstructorUsedError;
  String? get highlightId => throw _privateConstructorUsedError;
  String? get bookTitle => throw _privateConstructorUsedError;
  String? get bookAuthor => throw _privateConstructorUsedError;
  String? get title =>
      throw _privateConstructorUsedError; // book title (type=book)
  String? get chapterRef =>
      throw _privateConstructorUsedError; // §47, p. 142 … (type=highlight)
  String? get colorTag => throw _privateConstructorUsedError; // type=highlight
  String? get snippet =>
      throw _privateConstructorUsedError; // <mark>…</mark> matched text (highlight / note)
  double? get rank => throw _privateConstructorUsedError;
  String? get coverUrl => throw _privateConstructorUsedError;
  String? get coverDominantColor => throw _privateConstructorUsedError;
  String? get format => throw _privateConstructorUsedError;
  String? get status => throw _privateConstructorUsedError;

  /// Serializes this SearchHit to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SearchHit
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SearchHitCopyWith<SearchHit> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SearchHitCopyWith<$Res> {
  factory $SearchHitCopyWith(SearchHit value, $Res Function(SearchHit) then) =
      _$SearchHitCopyWithImpl<$Res, SearchHit>;
  @useResult
  $Res call({
    String type,
    String id,
    String? bookId,
    String? highlightId,
    String? bookTitle,
    String? bookAuthor,
    String? title,
    String? chapterRef,
    String? colorTag,
    String? snippet,
    double? rank,
    String? coverUrl,
    String? coverDominantColor,
    String? format,
    String? status,
  });
}

/// @nodoc
class _$SearchHitCopyWithImpl<$Res, $Val extends SearchHit>
    implements $SearchHitCopyWith<$Res> {
  _$SearchHitCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SearchHit
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? id = null,
    Object? bookId = freezed,
    Object? highlightId = freezed,
    Object? bookTitle = freezed,
    Object? bookAuthor = freezed,
    Object? title = freezed,
    Object? chapterRef = freezed,
    Object? colorTag = freezed,
    Object? snippet = freezed,
    Object? rank = freezed,
    Object? coverUrl = freezed,
    Object? coverDominantColor = freezed,
    Object? format = freezed,
    Object? status = freezed,
  }) {
    return _then(
      _value.copyWith(
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as String,
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            bookId: freezed == bookId
                ? _value.bookId
                : bookId // ignore: cast_nullable_to_non_nullable
                      as String?,
            highlightId: freezed == highlightId
                ? _value.highlightId
                : highlightId // ignore: cast_nullable_to_non_nullable
                      as String?,
            bookTitle: freezed == bookTitle
                ? _value.bookTitle
                : bookTitle // ignore: cast_nullable_to_non_nullable
                      as String?,
            bookAuthor: freezed == bookAuthor
                ? _value.bookAuthor
                : bookAuthor // ignore: cast_nullable_to_non_nullable
                      as String?,
            title: freezed == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String?,
            chapterRef: freezed == chapterRef
                ? _value.chapterRef
                : chapterRef // ignore: cast_nullable_to_non_nullable
                      as String?,
            colorTag: freezed == colorTag
                ? _value.colorTag
                : colorTag // ignore: cast_nullable_to_non_nullable
                      as String?,
            snippet: freezed == snippet
                ? _value.snippet
                : snippet // ignore: cast_nullable_to_non_nullable
                      as String?,
            rank: freezed == rank
                ? _value.rank
                : rank // ignore: cast_nullable_to_non_nullable
                      as double?,
            coverUrl: freezed == coverUrl
                ? _value.coverUrl
                : coverUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            coverDominantColor: freezed == coverDominantColor
                ? _value.coverDominantColor
                : coverDominantColor // ignore: cast_nullable_to_non_nullable
                      as String?,
            format: freezed == format
                ? _value.format
                : format // ignore: cast_nullable_to_non_nullable
                      as String?,
            status: freezed == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SearchHitImplCopyWith<$Res>
    implements $SearchHitCopyWith<$Res> {
  factory _$$SearchHitImplCopyWith(
    _$SearchHitImpl value,
    $Res Function(_$SearchHitImpl) then,
  ) = __$$SearchHitImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String type,
    String id,
    String? bookId,
    String? highlightId,
    String? bookTitle,
    String? bookAuthor,
    String? title,
    String? chapterRef,
    String? colorTag,
    String? snippet,
    double? rank,
    String? coverUrl,
    String? coverDominantColor,
    String? format,
    String? status,
  });
}

/// @nodoc
class __$$SearchHitImplCopyWithImpl<$Res>
    extends _$SearchHitCopyWithImpl<$Res, _$SearchHitImpl>
    implements _$$SearchHitImplCopyWith<$Res> {
  __$$SearchHitImplCopyWithImpl(
    _$SearchHitImpl _value,
    $Res Function(_$SearchHitImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SearchHit
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? id = null,
    Object? bookId = freezed,
    Object? highlightId = freezed,
    Object? bookTitle = freezed,
    Object? bookAuthor = freezed,
    Object? title = freezed,
    Object? chapterRef = freezed,
    Object? colorTag = freezed,
    Object? snippet = freezed,
    Object? rank = freezed,
    Object? coverUrl = freezed,
    Object? coverDominantColor = freezed,
    Object? format = freezed,
    Object? status = freezed,
  }) {
    return _then(
      _$SearchHitImpl(
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as String,
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        bookId: freezed == bookId
            ? _value.bookId
            : bookId // ignore: cast_nullable_to_non_nullable
                  as String?,
        highlightId: freezed == highlightId
            ? _value.highlightId
            : highlightId // ignore: cast_nullable_to_non_nullable
                  as String?,
        bookTitle: freezed == bookTitle
            ? _value.bookTitle
            : bookTitle // ignore: cast_nullable_to_non_nullable
                  as String?,
        bookAuthor: freezed == bookAuthor
            ? _value.bookAuthor
            : bookAuthor // ignore: cast_nullable_to_non_nullable
                  as String?,
        title: freezed == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String?,
        chapterRef: freezed == chapterRef
            ? _value.chapterRef
            : chapterRef // ignore: cast_nullable_to_non_nullable
                  as String?,
        colorTag: freezed == colorTag
            ? _value.colorTag
            : colorTag // ignore: cast_nullable_to_non_nullable
                  as String?,
        snippet: freezed == snippet
            ? _value.snippet
            : snippet // ignore: cast_nullable_to_non_nullable
                  as String?,
        rank: freezed == rank
            ? _value.rank
            : rank // ignore: cast_nullable_to_non_nullable
                  as double?,
        coverUrl: freezed == coverUrl
            ? _value.coverUrl
            : coverUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        coverDominantColor: freezed == coverDominantColor
            ? _value.coverDominantColor
            : coverDominantColor // ignore: cast_nullable_to_non_nullable
                  as String?,
        format: freezed == format
            ? _value.format
            : format // ignore: cast_nullable_to_non_nullable
                  as String?,
        status: freezed == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SearchHitImpl implements _SearchHit {
  const _$SearchHitImpl({
    required this.type,
    required this.id,
    this.bookId,
    this.highlightId,
    this.bookTitle,
    this.bookAuthor,
    this.title,
    this.chapterRef,
    this.colorTag,
    this.snippet,
    this.rank,
    this.coverUrl,
    this.coverDominantColor,
    this.format,
    this.status,
  });

  factory _$SearchHitImpl.fromJson(Map<String, dynamic> json) =>
      _$$SearchHitImplFromJson(json);

  @override
  final String type;
  @override
  final String id;
  @override
  final String? bookId;
  @override
  final String? highlightId;
  @override
  final String? bookTitle;
  @override
  final String? bookAuthor;
  @override
  final String? title;
  // book title (type=book)
  @override
  final String? chapterRef;
  // §47, p. 142 … (type=highlight)
  @override
  final String? colorTag;
  // type=highlight
  @override
  final String? snippet;
  // <mark>…</mark> matched text (highlight / note)
  @override
  final double? rank;
  @override
  final String? coverUrl;
  @override
  final String? coverDominantColor;
  @override
  final String? format;
  @override
  final String? status;

  @override
  String toString() {
    return 'SearchHit(type: $type, id: $id, bookId: $bookId, highlightId: $highlightId, bookTitle: $bookTitle, bookAuthor: $bookAuthor, title: $title, chapterRef: $chapterRef, colorTag: $colorTag, snippet: $snippet, rank: $rank, coverUrl: $coverUrl, coverDominantColor: $coverDominantColor, format: $format, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SearchHitImpl &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.bookId, bookId) || other.bookId == bookId) &&
            (identical(other.highlightId, highlightId) ||
                other.highlightId == highlightId) &&
            (identical(other.bookTitle, bookTitle) ||
                other.bookTitle == bookTitle) &&
            (identical(other.bookAuthor, bookAuthor) ||
                other.bookAuthor == bookAuthor) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.chapterRef, chapterRef) ||
                other.chapterRef == chapterRef) &&
            (identical(other.colorTag, colorTag) ||
                other.colorTag == colorTag) &&
            (identical(other.snippet, snippet) || other.snippet == snippet) &&
            (identical(other.rank, rank) || other.rank == rank) &&
            (identical(other.coverUrl, coverUrl) ||
                other.coverUrl == coverUrl) &&
            (identical(other.coverDominantColor, coverDominantColor) ||
                other.coverDominantColor == coverDominantColor) &&
            (identical(other.format, format) || other.format == format) &&
            (identical(other.status, status) || other.status == status));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    type,
    id,
    bookId,
    highlightId,
    bookTitle,
    bookAuthor,
    title,
    chapterRef,
    colorTag,
    snippet,
    rank,
    coverUrl,
    coverDominantColor,
    format,
    status,
  );

  /// Create a copy of SearchHit
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SearchHitImplCopyWith<_$SearchHitImpl> get copyWith =>
      __$$SearchHitImplCopyWithImpl<_$SearchHitImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SearchHitImplToJson(this);
  }
}

abstract class _SearchHit implements SearchHit {
  const factory _SearchHit({
    required final String type,
    required final String id,
    final String? bookId,
    final String? highlightId,
    final String? bookTitle,
    final String? bookAuthor,
    final String? title,
    final String? chapterRef,
    final String? colorTag,
    final String? snippet,
    final double? rank,
    final String? coverUrl,
    final String? coverDominantColor,
    final String? format,
    final String? status,
  }) = _$SearchHitImpl;

  factory _SearchHit.fromJson(Map<String, dynamic> json) =
      _$SearchHitImpl.fromJson;

  @override
  String get type;
  @override
  String get id;
  @override
  String? get bookId;
  @override
  String? get highlightId;
  @override
  String? get bookTitle;
  @override
  String? get bookAuthor;
  @override
  String? get title; // book title (type=book)
  @override
  String? get chapterRef; // §47, p. 142 … (type=highlight)
  @override
  String? get colorTag; // type=highlight
  @override
  String? get snippet; // <mark>…</mark> matched text (highlight / note)
  @override
  double? get rank;
  @override
  String? get coverUrl;
  @override
  String? get coverDominantColor;
  @override
  String? get format;
  @override
  String? get status;

  /// Create a copy of SearchHit
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SearchHitImplCopyWith<_$SearchHitImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
