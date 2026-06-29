// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'book_create_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

BookCreateRequest _$BookCreateRequestFromJson(Map<String, dynamic> json) {
  return _BookCreateRequest.fromJson(json);
}

/// @nodoc
mixin _$BookCreateRequest {
  String get title => throw _privateConstructorUsedError;
  String get format =>
      throw _privateConstructorUsedError; // epub | pdf | m4b | mp3 | physical
  String? get author => throw _privateConstructorUsedError;
  String? get narrator => throw _privateConstructorUsedError;
  String? get publisher => throw _privateConstructorUsedError;
  int? get publishedYear => throw _privateConstructorUsedError;
  String? get fileKey => throw _privateConstructorUsedError;
  String? get googleId => throw _privateConstructorUsedError;
  String? get isbn13 => throw _privateConstructorUsedError;
  int? get pageCount => throw _privateConstructorUsedError;
  int? get durationSec => throw _privateConstructorUsedError;
  String? get language => throw _privateConstructorUsedError;
  String? get coverUrl => throw _privateConstructorUsedError;
  String? get coverDominantColor => throw _privateConstructorUsedError;
  String? get status => throw _privateConstructorUsedError;

  /// Serializes this BookCreateRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BookCreateRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BookCreateRequestCopyWith<BookCreateRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BookCreateRequestCopyWith<$Res> {
  factory $BookCreateRequestCopyWith(
    BookCreateRequest value,
    $Res Function(BookCreateRequest) then,
  ) = _$BookCreateRequestCopyWithImpl<$Res, BookCreateRequest>;
  @useResult
  $Res call({
    String title,
    String format,
    String? author,
    String? narrator,
    String? publisher,
    int? publishedYear,
    String? fileKey,
    String? googleId,
    String? isbn13,
    int? pageCount,
    int? durationSec,
    String? language,
    String? coverUrl,
    String? coverDominantColor,
    String? status,
  });
}

/// @nodoc
class _$BookCreateRequestCopyWithImpl<$Res, $Val extends BookCreateRequest>
    implements $BookCreateRequestCopyWith<$Res> {
  _$BookCreateRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BookCreateRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? title = null,
    Object? format = null,
    Object? author = freezed,
    Object? narrator = freezed,
    Object? publisher = freezed,
    Object? publishedYear = freezed,
    Object? fileKey = freezed,
    Object? googleId = freezed,
    Object? isbn13 = freezed,
    Object? pageCount = freezed,
    Object? durationSec = freezed,
    Object? language = freezed,
    Object? coverUrl = freezed,
    Object? coverDominantColor = freezed,
    Object? status = freezed,
  }) {
    return _then(
      _value.copyWith(
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            format: null == format
                ? _value.format
                : format // ignore: cast_nullable_to_non_nullable
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
            fileKey: freezed == fileKey
                ? _value.fileKey
                : fileKey // ignore: cast_nullable_to_non_nullable
                      as String?,
            googleId: freezed == googleId
                ? _value.googleId
                : googleId // ignore: cast_nullable_to_non_nullable
                      as String?,
            isbn13: freezed == isbn13
                ? _value.isbn13
                : isbn13 // ignore: cast_nullable_to_non_nullable
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
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$BookCreateRequestImplCopyWith<$Res>
    implements $BookCreateRequestCopyWith<$Res> {
  factory _$$BookCreateRequestImplCopyWith(
    _$BookCreateRequestImpl value,
    $Res Function(_$BookCreateRequestImpl) then,
  ) = __$$BookCreateRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String title,
    String format,
    String? author,
    String? narrator,
    String? publisher,
    int? publishedYear,
    String? fileKey,
    String? googleId,
    String? isbn13,
    int? pageCount,
    int? durationSec,
    String? language,
    String? coverUrl,
    String? coverDominantColor,
    String? status,
  });
}

/// @nodoc
class __$$BookCreateRequestImplCopyWithImpl<$Res>
    extends _$BookCreateRequestCopyWithImpl<$Res, _$BookCreateRequestImpl>
    implements _$$BookCreateRequestImplCopyWith<$Res> {
  __$$BookCreateRequestImplCopyWithImpl(
    _$BookCreateRequestImpl _value,
    $Res Function(_$BookCreateRequestImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of BookCreateRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? title = null,
    Object? format = null,
    Object? author = freezed,
    Object? narrator = freezed,
    Object? publisher = freezed,
    Object? publishedYear = freezed,
    Object? fileKey = freezed,
    Object? googleId = freezed,
    Object? isbn13 = freezed,
    Object? pageCount = freezed,
    Object? durationSec = freezed,
    Object? language = freezed,
    Object? coverUrl = freezed,
    Object? coverDominantColor = freezed,
    Object? status = freezed,
  }) {
    return _then(
      _$BookCreateRequestImpl(
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        format: null == format
            ? _value.format
            : format // ignore: cast_nullable_to_non_nullable
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
        fileKey: freezed == fileKey
            ? _value.fileKey
            : fileKey // ignore: cast_nullable_to_non_nullable
                  as String?,
        googleId: freezed == googleId
            ? _value.googleId
            : googleId // ignore: cast_nullable_to_non_nullable
                  as String?,
        isbn13: freezed == isbn13
            ? _value.isbn13
            : isbn13 // ignore: cast_nullable_to_non_nullable
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
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$BookCreateRequestImpl implements _BookCreateRequest {
  const _$BookCreateRequestImpl({
    required this.title,
    required this.format,
    this.author,
    this.narrator,
    this.publisher,
    this.publishedYear,
    this.fileKey,
    this.googleId,
    this.isbn13,
    this.pageCount,
    this.durationSec,
    this.language,
    this.coverUrl,
    this.coverDominantColor,
    this.status,
  });

  factory _$BookCreateRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$BookCreateRequestImplFromJson(json);

  @override
  final String title;
  @override
  final String format;
  // epub | pdf | m4b | mp3 | physical
  @override
  final String? author;
  @override
  final String? narrator;
  @override
  final String? publisher;
  @override
  final int? publishedYear;
  @override
  final String? fileKey;
  @override
  final String? googleId;
  @override
  final String? isbn13;
  @override
  final int? pageCount;
  @override
  final int? durationSec;
  @override
  final String? language;
  @override
  final String? coverUrl;
  @override
  final String? coverDominantColor;
  @override
  final String? status;

  @override
  String toString() {
    return 'BookCreateRequest(title: $title, format: $format, author: $author, narrator: $narrator, publisher: $publisher, publishedYear: $publishedYear, fileKey: $fileKey, googleId: $googleId, isbn13: $isbn13, pageCount: $pageCount, durationSec: $durationSec, language: $language, coverUrl: $coverUrl, coverDominantColor: $coverDominantColor, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BookCreateRequestImpl &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.format, format) || other.format == format) &&
            (identical(other.author, author) || other.author == author) &&
            (identical(other.narrator, narrator) ||
                other.narrator == narrator) &&
            (identical(other.publisher, publisher) ||
                other.publisher == publisher) &&
            (identical(other.publishedYear, publishedYear) ||
                other.publishedYear == publishedYear) &&
            (identical(other.fileKey, fileKey) || other.fileKey == fileKey) &&
            (identical(other.googleId, googleId) ||
                other.googleId == googleId) &&
            (identical(other.isbn13, isbn13) || other.isbn13 == isbn13) &&
            (identical(other.pageCount, pageCount) ||
                other.pageCount == pageCount) &&
            (identical(other.durationSec, durationSec) ||
                other.durationSec == durationSec) &&
            (identical(other.language, language) ||
                other.language == language) &&
            (identical(other.coverUrl, coverUrl) ||
                other.coverUrl == coverUrl) &&
            (identical(other.coverDominantColor, coverDominantColor) ||
                other.coverDominantColor == coverDominantColor) &&
            (identical(other.status, status) || other.status == status));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    title,
    format,
    author,
    narrator,
    publisher,
    publishedYear,
    fileKey,
    googleId,
    isbn13,
    pageCount,
    durationSec,
    language,
    coverUrl,
    coverDominantColor,
    status,
  );

  /// Create a copy of BookCreateRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BookCreateRequestImplCopyWith<_$BookCreateRequestImpl> get copyWith =>
      __$$BookCreateRequestImplCopyWithImpl<_$BookCreateRequestImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$BookCreateRequestImplToJson(this);
  }
}

abstract class _BookCreateRequest implements BookCreateRequest {
  const factory _BookCreateRequest({
    required final String title,
    required final String format,
    final String? author,
    final String? narrator,
    final String? publisher,
    final int? publishedYear,
    final String? fileKey,
    final String? googleId,
    final String? isbn13,
    final int? pageCount,
    final int? durationSec,
    final String? language,
    final String? coverUrl,
    final String? coverDominantColor,
    final String? status,
  }) = _$BookCreateRequestImpl;

  factory _BookCreateRequest.fromJson(Map<String, dynamic> json) =
      _$BookCreateRequestImpl.fromJson;

  @override
  String get title;
  @override
  String get format; // epub | pdf | m4b | mp3 | physical
  @override
  String? get author;
  @override
  String? get narrator;
  @override
  String? get publisher;
  @override
  int? get publishedYear;
  @override
  String? get fileKey;
  @override
  String? get googleId;
  @override
  String? get isbn13;
  @override
  int? get pageCount;
  @override
  int? get durationSec;
  @override
  String? get language;
  @override
  String? get coverUrl;
  @override
  String? get coverDominantColor;
  @override
  String? get status;

  /// Create a copy of BookCreateRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BookCreateRequestImplCopyWith<_$BookCreateRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
