// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'book.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Book _$BookFromJson(Map<String, dynamic> json) {
  return _Book.fromJson(json);
}

/// @nodoc
mixin _$Book {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String? get author => throw _privateConstructorUsedError;
  String? get narrator => throw _privateConstructorUsedError;
  String? get publisher => throw _privateConstructorUsedError;
  int? get publishedYear => throw _privateConstructorUsedError;
  String? get isbn13 => throw _privateConstructorUsedError;
  String? get googleId =>
      throw _privateConstructorUsedError; // Google Books volume id — enables free public-domain reading
  int? get pageCount => throw _privateConstructorUsedError;
  int? get durationSec => throw _privateConstructorUsedError;
  String? get language => throw _privateConstructorUsedError;
  String? get format =>
      throw _privateConstructorUsedError; // epub | pdf | m4b | mp3 | physical
  String? get coverUrl => throw _privateConstructorUsedError;
  String? get coverDominantColor =>
      throw _privateConstructorUsedError; // #RRGGBB
  String? get status =>
      throw _privateConstructorUsedError; // reading | listening | finished | archived
  double? get progressPct => throw _privateConstructorUsedError; // 0–100
  String? get cursor =>
      throw _privateConstructorUsedError; // opaque JSONB reading position
  String? get lastOpenedAt => throw _privateConstructorUsedError;
  String? get finishedAt => throw _privateConstructorUsedError;
  String? get createdAt => throw _privateConstructorUsedError;
  String? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this Book to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Book
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BookCopyWith<Book> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BookCopyWith<$Res> {
  factory $BookCopyWith(Book value, $Res Function(Book) then) =
      _$BookCopyWithImpl<$Res, Book>;
  @useResult
  $Res call({
    String id,
    String title,
    String? author,
    String? narrator,
    String? publisher,
    int? publishedYear,
    String? isbn13,
    String? googleId,
    int? pageCount,
    int? durationSec,
    String? language,
    String? format,
    String? coverUrl,
    String? coverDominantColor,
    String? status,
    double? progressPct,
    String? cursor,
    String? lastOpenedAt,
    String? finishedAt,
    String? createdAt,
    String? updatedAt,
  });
}

/// @nodoc
class _$BookCopyWithImpl<$Res, $Val extends Book>
    implements $BookCopyWith<$Res> {
  _$BookCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Book
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? author = freezed,
    Object? narrator = freezed,
    Object? publisher = freezed,
    Object? publishedYear = freezed,
    Object? isbn13 = freezed,
    Object? googleId = freezed,
    Object? pageCount = freezed,
    Object? durationSec = freezed,
    Object? language = freezed,
    Object? format = freezed,
    Object? coverUrl = freezed,
    Object? coverDominantColor = freezed,
    Object? status = freezed,
    Object? progressPct = freezed,
    Object? cursor = freezed,
    Object? lastOpenedAt = freezed,
    Object? finishedAt = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            author: freezed == author
                ? _value.author
                : author // ignore: cast_nullable_to_non_nullable
                      as String?,
            narrator: freezed == narrator
                ? _value.narrator
                : narrator // ignore: cast_nullable_to_non_nullable
                      as String?,
            publisher: freezed == publisher
                ? _value.publisher
                : publisher // ignore: cast_nullable_to_non_nullable
                      as String?,
            publishedYear: freezed == publishedYear
                ? _value.publishedYear
                : publishedYear // ignore: cast_nullable_to_non_nullable
                      as int?,
            isbn13: freezed == isbn13
                ? _value.isbn13
                : isbn13 // ignore: cast_nullable_to_non_nullable
                      as String?,
            googleId: freezed == googleId
                ? _value.googleId
                : googleId // ignore: cast_nullable_to_non_nullable
                      as String?,
            pageCount: freezed == pageCount
                ? _value.pageCount
                : pageCount // ignore: cast_nullable_to_non_nullable
                      as int?,
            durationSec: freezed == durationSec
                ? _value.durationSec
                : durationSec // ignore: cast_nullable_to_non_nullable
                      as int?,
            language: freezed == language
                ? _value.language
                : language // ignore: cast_nullable_to_non_nullable
                      as String?,
            format: freezed == format
                ? _value.format
                : format // ignore: cast_nullable_to_non_nullable
                      as String?,
            coverUrl: freezed == coverUrl
                ? _value.coverUrl
                : coverUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            coverDominantColor: freezed == coverDominantColor
                ? _value.coverDominantColor
                : coverDominantColor // ignore: cast_nullable_to_non_nullable
                      as String?,
            status: freezed == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String?,
            progressPct: freezed == progressPct
                ? _value.progressPct
                : progressPct // ignore: cast_nullable_to_non_nullable
                      as double?,
            cursor: freezed == cursor
                ? _value.cursor
                : cursor // ignore: cast_nullable_to_non_nullable
                      as String?,
            lastOpenedAt: freezed == lastOpenedAt
                ? _value.lastOpenedAt
                : lastOpenedAt // ignore: cast_nullable_to_non_nullable
                      as String?,
            finishedAt: freezed == finishedAt
                ? _value.finishedAt
                : finishedAt // ignore: cast_nullable_to_non_nullable
                      as String?,
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as String?,
            updatedAt: freezed == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$BookImplCopyWith<$Res> implements $BookCopyWith<$Res> {
  factory _$$BookImplCopyWith(
    _$BookImpl value,
    $Res Function(_$BookImpl) then,
  ) = __$$BookImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String title,
    String? author,
    String? narrator,
    String? publisher,
    int? publishedYear,
    String? isbn13,
    String? googleId,
    int? pageCount,
    int? durationSec,
    String? language,
    String? format,
    String? coverUrl,
    String? coverDominantColor,
    String? status,
    double? progressPct,
    String? cursor,
    String? lastOpenedAt,
    String? finishedAt,
    String? createdAt,
    String? updatedAt,
  });
}

/// @nodoc
class __$$BookImplCopyWithImpl<$Res>
    extends _$BookCopyWithImpl<$Res, _$BookImpl>
    implements _$$BookImplCopyWith<$Res> {
  __$$BookImplCopyWithImpl(_$BookImpl _value, $Res Function(_$BookImpl) _then)
    : super(_value, _then);

  /// Create a copy of Book
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? author = freezed,
    Object? narrator = freezed,
    Object? publisher = freezed,
    Object? publishedYear = freezed,
    Object? isbn13 = freezed,
    Object? googleId = freezed,
    Object? pageCount = freezed,
    Object? durationSec = freezed,
    Object? language = freezed,
    Object? format = freezed,
    Object? coverUrl = freezed,
    Object? coverDominantColor = freezed,
    Object? status = freezed,
    Object? progressPct = freezed,
    Object? cursor = freezed,
    Object? lastOpenedAt = freezed,
    Object? finishedAt = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _$BookImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        author: freezed == author
            ? _value.author
            : author // ignore: cast_nullable_to_non_nullable
                  as String?,
        narrator: freezed == narrator
            ? _value.narrator
            : narrator // ignore: cast_nullable_to_non_nullable
                  as String?,
        publisher: freezed == publisher
            ? _value.publisher
            : publisher // ignore: cast_nullable_to_non_nullable
                  as String?,
        publishedYear: freezed == publishedYear
            ? _value.publishedYear
            : publishedYear // ignore: cast_nullable_to_non_nullable
                  as int?,
        isbn13: freezed == isbn13
            ? _value.isbn13
            : isbn13 // ignore: cast_nullable_to_non_nullable
                  as String?,
        googleId: freezed == googleId
            ? _value.googleId
            : googleId // ignore: cast_nullable_to_non_nullable
                  as String?,
        pageCount: freezed == pageCount
            ? _value.pageCount
            : pageCount // ignore: cast_nullable_to_non_nullable
                  as int?,
        durationSec: freezed == durationSec
            ? _value.durationSec
            : durationSec // ignore: cast_nullable_to_non_nullable
                  as int?,
        language: freezed == language
            ? _value.language
            : language // ignore: cast_nullable_to_non_nullable
                  as String?,
        format: freezed == format
            ? _value.format
            : format // ignore: cast_nullable_to_non_nullable
                  as String?,
        coverUrl: freezed == coverUrl
            ? _value.coverUrl
            : coverUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        coverDominantColor: freezed == coverDominantColor
            ? _value.coverDominantColor
            : coverDominantColor // ignore: cast_nullable_to_non_nullable
                  as String?,
        status: freezed == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String?,
        progressPct: freezed == progressPct
            ? _value.progressPct
            : progressPct // ignore: cast_nullable_to_non_nullable
                  as double?,
        cursor: freezed == cursor
            ? _value.cursor
            : cursor // ignore: cast_nullable_to_non_nullable
                  as String?,
        lastOpenedAt: freezed == lastOpenedAt
            ? _value.lastOpenedAt
            : lastOpenedAt // ignore: cast_nullable_to_non_nullable
                  as String?,
        finishedAt: freezed == finishedAt
            ? _value.finishedAt
            : finishedAt // ignore: cast_nullable_to_non_nullable
                  as String?,
        createdAt: freezed == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as String?,
        updatedAt: freezed == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$BookImpl implements _Book {
  const _$BookImpl({
    required this.id,
    required this.title,
    this.author,
    this.narrator,
    this.publisher,
    this.publishedYear,
    this.isbn13,
    this.googleId,
    this.pageCount,
    this.durationSec,
    this.language,
    this.format,
    this.coverUrl,
    this.coverDominantColor,
    this.status,
    this.progressPct,
    this.cursor,
    this.lastOpenedAt,
    this.finishedAt,
    this.createdAt,
    this.updatedAt,
  });

  factory _$BookImpl.fromJson(Map<String, dynamic> json) =>
      _$$BookImplFromJson(json);

  @override
  final String id;
  @override
  final String title;
  @override
  final String? author;
  @override
  final String? narrator;
  @override
  final String? publisher;
  @override
  final int? publishedYear;
  @override
  final String? isbn13;
  @override
  final String? googleId;
  // Google Books volume id — enables free public-domain reading
  @override
  final int? pageCount;
  @override
  final int? durationSec;
  @override
  final String? language;
  @override
  final String? format;
  // epub | pdf | m4b | mp3 | physical
  @override
  final String? coverUrl;
  @override
  final String? coverDominantColor;
  // #RRGGBB
  @override
  final String? status;
  // reading | listening | finished | archived
  @override
  final double? progressPct;
  // 0–100
  @override
  final String? cursor;
  // opaque JSONB reading position
  @override
  final String? lastOpenedAt;
  @override
  final String? finishedAt;
  @override
  final String? createdAt;
  @override
  final String? updatedAt;

  @override
  String toString() {
    return 'Book(id: $id, title: $title, author: $author, narrator: $narrator, publisher: $publisher, publishedYear: $publishedYear, isbn13: $isbn13, googleId: $googleId, pageCount: $pageCount, durationSec: $durationSec, language: $language, format: $format, coverUrl: $coverUrl, coverDominantColor: $coverDominantColor, status: $status, progressPct: $progressPct, cursor: $cursor, lastOpenedAt: $lastOpenedAt, finishedAt: $finishedAt, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BookImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.author, author) || other.author == author) &&
            (identical(other.narrator, narrator) ||
                other.narrator == narrator) &&
            (identical(other.publisher, publisher) ||
                other.publisher == publisher) &&
            (identical(other.publishedYear, publishedYear) ||
                other.publishedYear == publishedYear) &&
            (identical(other.isbn13, isbn13) || other.isbn13 == isbn13) &&
            (identical(other.googleId, googleId) ||
                other.googleId == googleId) &&
            (identical(other.pageCount, pageCount) ||
                other.pageCount == pageCount) &&
            (identical(other.durationSec, durationSec) ||
                other.durationSec == durationSec) &&
            (identical(other.language, language) ||
                other.language == language) &&
            (identical(other.format, format) || other.format == format) &&
            (identical(other.coverUrl, coverUrl) ||
                other.coverUrl == coverUrl) &&
            (identical(other.coverDominantColor, coverDominantColor) ||
                other.coverDominantColor == coverDominantColor) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.progressPct, progressPct) ||
                other.progressPct == progressPct) &&
            (identical(other.cursor, cursor) || other.cursor == cursor) &&
            (identical(other.lastOpenedAt, lastOpenedAt) ||
                other.lastOpenedAt == lastOpenedAt) &&
            (identical(other.finishedAt, finishedAt) ||
                other.finishedAt == finishedAt) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
    runtimeType,
    id,
    title,
    author,
    narrator,
    publisher,
    publishedYear,
    isbn13,
    googleId,
    pageCount,
    durationSec,
    language,
    format,
    coverUrl,
    coverDominantColor,
    status,
    progressPct,
    cursor,
    lastOpenedAt,
    finishedAt,
    createdAt,
    updatedAt,
  ]);

  /// Create a copy of Book
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BookImplCopyWith<_$BookImpl> get copyWith =>
      __$$BookImplCopyWithImpl<_$BookImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BookImplToJson(this);
  }
}

abstract class _Book implements Book {
  const factory _Book({
    required final String id,
    required final String title,
    final String? author,
    final String? narrator,
    final String? publisher,
    final int? publishedYear,
    final String? isbn13,
    final String? googleId,
    final int? pageCount,
    final int? durationSec,
    final String? language,
    final String? format,
    final String? coverUrl,
    final String? coverDominantColor,
    final String? status,
    final double? progressPct,
    final String? cursor,
    final String? lastOpenedAt,
    final String? finishedAt,
    final String? createdAt,
    final String? updatedAt,
  }) = _$BookImpl;

  factory _Book.fromJson(Map<String, dynamic> json) = _$BookImpl.fromJson;

  @override
  String get id;
  @override
  String get title;
  @override
  String? get author;
  @override
  String? get narrator;
  @override
  String? get publisher;
  @override
  int? get publishedYear;
  @override
  String? get isbn13;
  @override
  String? get googleId; // Google Books volume id — enables free public-domain reading
  @override
  int? get pageCount;
  @override
  int? get durationSec;
  @override
  String? get language;
  @override
  String? get format; // epub | pdf | m4b | mp3 | physical
  @override
  String? get coverUrl;
  @override
  String? get coverDominantColor; // #RRGGBB
  @override
  String? get status; // reading | listening | finished | archived
  @override
  double? get progressPct; // 0–100
  @override
  String? get cursor; // opaque JSONB reading position
  @override
  String? get lastOpenedAt;
  @override
  String? get finishedAt;
  @override
  String? get createdAt;
  @override
  String? get updatedAt;

  /// Create a copy of Book
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BookImplCopyWith<_$BookImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
