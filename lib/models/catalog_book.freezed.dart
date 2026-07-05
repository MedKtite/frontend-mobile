// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'catalog_book.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

CatalogBook _$CatalogBookFromJson(Map<String, dynamic> json) {
  return _CatalogBook.fromJson(json);
}

/// @nodoc
mixin _$CatalogBook {
  String get title => throw _privateConstructorUsedError;
  String? get source =>
      throw _privateConstructorUsedError; // GUTENBERG | GOOGLE
  String? get contentAvailability =>
      throw _privateConstructorUsedError; // FULL | METADATA_ONLY
  int? get gutenbergId => throw _privateConstructorUsedError;
  String? get googleId => throw _privateConstructorUsedError;
  String? get author => throw _privateConstructorUsedError;
  String? get publisher => throw _privateConstructorUsedError;
  int? get publishedYear => throw _privateConstructorUsedError;
  String? get isbn13 => throw _privateConstructorUsedError;
  int? get pageCount => throw _privateConstructorUsedError;
  String? get language => throw _privateConstructorUsedError;
  String? get thumbnailUrl => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  double? get averageRating =>
      throw _privateConstructorUsedError; // Google community rating 1–5, if any
  int? get ratingsCount =>
      throw _privateConstructorUsedError; // Google: number of ratings behind averageRating
  int? get downloadCount =>
      throw _privateConstructorUsedError; // Gutenberg: lifetime downloads ("readers" KPI)
  String? get previewUrl => throw _privateConstructorUsedError;

  /// Serializes this CatalogBook to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CatalogBook
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CatalogBookCopyWith<CatalogBook> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CatalogBookCopyWith<$Res> {
  factory $CatalogBookCopyWith(
    CatalogBook value,
    $Res Function(CatalogBook) then,
  ) = _$CatalogBookCopyWithImpl<$Res, CatalogBook>;
  @useResult
  $Res call({
    String title,
    String? source,
    String? contentAvailability,
    int? gutenbergId,
    String? googleId,
    String? author,
    String? publisher,
    int? publishedYear,
    String? isbn13,
    int? pageCount,
    String? language,
    String? thumbnailUrl,
    String? description,
    double? averageRating,
    int? ratingsCount,
    int? downloadCount,
    String? previewUrl,
  });
}

/// @nodoc
class _$CatalogBookCopyWithImpl<$Res, $Val extends CatalogBook>
    implements $CatalogBookCopyWith<$Res> {
  _$CatalogBookCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CatalogBook
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? title = null,
    Object? source = freezed,
    Object? contentAvailability = freezed,
    Object? gutenbergId = freezed,
    Object? googleId = freezed,
    Object? author = freezed,
    Object? publisher = freezed,
    Object? publishedYear = freezed,
    Object? isbn13 = freezed,
    Object? pageCount = freezed,
    Object? language = freezed,
    Object? thumbnailUrl = freezed,
    Object? description = freezed,
    Object? averageRating = freezed,
    Object? ratingsCount = freezed,
    Object? downloadCount = freezed,
    Object? previewUrl = freezed,
  }) {
    return _then(
      _value.copyWith(
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            source: freezed == source
                ? _value.source
                : source // ignore: cast_nullable_to_non_nullable
                      as String?,
            contentAvailability: freezed == contentAvailability
                ? _value.contentAvailability
                : contentAvailability // ignore: cast_nullable_to_non_nullable
                      as String?,
            gutenbergId: freezed == gutenbergId
                ? _value.gutenbergId
                : gutenbergId // ignore: cast_nullable_to_non_nullable
                      as int?,
            googleId: freezed == googleId
                ? _value.googleId
                : googleId // ignore: cast_nullable_to_non_nullable
                      as String?,
            author: freezed == author
                ? _value.author
                : author // ignore: cast_nullable_to_non_nullable
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
            pageCount: freezed == pageCount
                ? _value.pageCount
                : pageCount // ignore: cast_nullable_to_non_nullable
                      as int?,
            language: freezed == language
                ? _value.language
                : language // ignore: cast_nullable_to_non_nullable
                      as String?,
            thumbnailUrl: freezed == thumbnailUrl
                ? _value.thumbnailUrl
                : thumbnailUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            description: freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String?,
            averageRating: freezed == averageRating
                ? _value.averageRating
                : averageRating // ignore: cast_nullable_to_non_nullable
                      as double?,
            ratingsCount: freezed == ratingsCount
                ? _value.ratingsCount
                : ratingsCount // ignore: cast_nullable_to_non_nullable
                      as int?,
            downloadCount: freezed == downloadCount
                ? _value.downloadCount
                : downloadCount // ignore: cast_nullable_to_non_nullable
                      as int?,
            previewUrl: freezed == previewUrl
                ? _value.previewUrl
                : previewUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CatalogBookImplCopyWith<$Res>
    implements $CatalogBookCopyWith<$Res> {
  factory _$$CatalogBookImplCopyWith(
    _$CatalogBookImpl value,
    $Res Function(_$CatalogBookImpl) then,
  ) = __$$CatalogBookImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String title,
    String? source,
    String? contentAvailability,
    int? gutenbergId,
    String? googleId,
    String? author,
    String? publisher,
    int? publishedYear,
    String? isbn13,
    int? pageCount,
    String? language,
    String? thumbnailUrl,
    String? description,
    double? averageRating,
    int? ratingsCount,
    int? downloadCount,
    String? previewUrl,
  });
}

/// @nodoc
class __$$CatalogBookImplCopyWithImpl<$Res>
    extends _$CatalogBookCopyWithImpl<$Res, _$CatalogBookImpl>
    implements _$$CatalogBookImplCopyWith<$Res> {
  __$$CatalogBookImplCopyWithImpl(
    _$CatalogBookImpl _value,
    $Res Function(_$CatalogBookImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CatalogBook
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? title = null,
    Object? source = freezed,
    Object? contentAvailability = freezed,
    Object? gutenbergId = freezed,
    Object? googleId = freezed,
    Object? author = freezed,
    Object? publisher = freezed,
    Object? publishedYear = freezed,
    Object? isbn13 = freezed,
    Object? pageCount = freezed,
    Object? language = freezed,
    Object? thumbnailUrl = freezed,
    Object? description = freezed,
    Object? averageRating = freezed,
    Object? ratingsCount = freezed,
    Object? downloadCount = freezed,
    Object? previewUrl = freezed,
  }) {
    return _then(
      _$CatalogBookImpl(
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        source: freezed == source
            ? _value.source
            : source // ignore: cast_nullable_to_non_nullable
                  as String?,
        contentAvailability: freezed == contentAvailability
            ? _value.contentAvailability
            : contentAvailability // ignore: cast_nullable_to_non_nullable
                  as String?,
        gutenbergId: freezed == gutenbergId
            ? _value.gutenbergId
            : gutenbergId // ignore: cast_nullable_to_non_nullable
                  as int?,
        googleId: freezed == googleId
            ? _value.googleId
            : googleId // ignore: cast_nullable_to_non_nullable
                  as String?,
        author: freezed == author
            ? _value.author
            : author // ignore: cast_nullable_to_non_nullable
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
        pageCount: freezed == pageCount
            ? _value.pageCount
            : pageCount // ignore: cast_nullable_to_non_nullable
                  as int?,
        language: freezed == language
            ? _value.language
            : language // ignore: cast_nullable_to_non_nullable
                  as String?,
        thumbnailUrl: freezed == thumbnailUrl
            ? _value.thumbnailUrl
            : thumbnailUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
        averageRating: freezed == averageRating
            ? _value.averageRating
            : averageRating // ignore: cast_nullable_to_non_nullable
                  as double?,
        ratingsCount: freezed == ratingsCount
            ? _value.ratingsCount
            : ratingsCount // ignore: cast_nullable_to_non_nullable
                  as int?,
        downloadCount: freezed == downloadCount
            ? _value.downloadCount
            : downloadCount // ignore: cast_nullable_to_non_nullable
                  as int?,
        previewUrl: freezed == previewUrl
            ? _value.previewUrl
            : previewUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CatalogBookImpl extends _CatalogBook {
  const _$CatalogBookImpl({
    required this.title,
    this.source,
    this.contentAvailability,
    this.gutenbergId,
    this.googleId,
    this.author,
    this.publisher,
    this.publishedYear,
    this.isbn13,
    this.pageCount,
    this.language,
    this.thumbnailUrl,
    this.description,
    this.averageRating,
    this.ratingsCount,
    this.downloadCount,
    this.previewUrl,
  }) : super._();

  factory _$CatalogBookImpl.fromJson(Map<String, dynamic> json) =>
      _$$CatalogBookImplFromJson(json);

  @override
  final String title;
  @override
  final String? source;
  // GUTENBERG | GOOGLE
  @override
  final String? contentAvailability;
  // FULL | METADATA_ONLY
  @override
  final int? gutenbergId;
  @override
  final String? googleId;
  @override
  final String? author;
  @override
  final String? publisher;
  @override
  final int? publishedYear;
  @override
  final String? isbn13;
  @override
  final int? pageCount;
  @override
  final String? language;
  @override
  final String? thumbnailUrl;
  @override
  final String? description;
  @override
  final double? averageRating;
  // Google community rating 1–5, if any
  @override
  final int? ratingsCount;
  // Google: number of ratings behind averageRating
  @override
  final int? downloadCount;
  // Gutenberg: lifetime downloads ("readers" KPI)
  @override
  final String? previewUrl;

  @override
  String toString() {
    return 'CatalogBook(title: $title, source: $source, contentAvailability: $contentAvailability, gutenbergId: $gutenbergId, googleId: $googleId, author: $author, publisher: $publisher, publishedYear: $publishedYear, isbn13: $isbn13, pageCount: $pageCount, language: $language, thumbnailUrl: $thumbnailUrl, description: $description, averageRating: $averageRating, ratingsCount: $ratingsCount, downloadCount: $downloadCount, previewUrl: $previewUrl)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CatalogBookImpl &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.source, source) || other.source == source) &&
            (identical(other.contentAvailability, contentAvailability) ||
                other.contentAvailability == contentAvailability) &&
            (identical(other.gutenbergId, gutenbergId) ||
                other.gutenbergId == gutenbergId) &&
            (identical(other.googleId, googleId) ||
                other.googleId == googleId) &&
            (identical(other.author, author) || other.author == author) &&
            (identical(other.publisher, publisher) ||
                other.publisher == publisher) &&
            (identical(other.publishedYear, publishedYear) ||
                other.publishedYear == publishedYear) &&
            (identical(other.isbn13, isbn13) || other.isbn13 == isbn13) &&
            (identical(other.pageCount, pageCount) ||
                other.pageCount == pageCount) &&
            (identical(other.language, language) ||
                other.language == language) &&
            (identical(other.thumbnailUrl, thumbnailUrl) ||
                other.thumbnailUrl == thumbnailUrl) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.averageRating, averageRating) ||
                other.averageRating == averageRating) &&
            (identical(other.ratingsCount, ratingsCount) ||
                other.ratingsCount == ratingsCount) &&
            (identical(other.downloadCount, downloadCount) ||
                other.downloadCount == downloadCount) &&
            (identical(other.previewUrl, previewUrl) ||
                other.previewUrl == previewUrl));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    title,
    source,
    contentAvailability,
    gutenbergId,
    googleId,
    author,
    publisher,
    publishedYear,
    isbn13,
    pageCount,
    language,
    thumbnailUrl,
    description,
    averageRating,
    ratingsCount,
    downloadCount,
    previewUrl,
  );

  /// Create a copy of CatalogBook
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CatalogBookImplCopyWith<_$CatalogBookImpl> get copyWith =>
      __$$CatalogBookImplCopyWithImpl<_$CatalogBookImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CatalogBookImplToJson(this);
  }
}

abstract class _CatalogBook extends CatalogBook {
  const factory _CatalogBook({
    required final String title,
    final String? source,
    final String? contentAvailability,
    final int? gutenbergId,
    final String? googleId,
    final String? author,
    final String? publisher,
    final int? publishedYear,
    final String? isbn13,
    final int? pageCount,
    final String? language,
    final String? thumbnailUrl,
    final String? description,
    final double? averageRating,
    final int? ratingsCount,
    final int? downloadCount,
    final String? previewUrl,
  }) = _$CatalogBookImpl;
  const _CatalogBook._() : super._();

  factory _CatalogBook.fromJson(Map<String, dynamic> json) =
      _$CatalogBookImpl.fromJson;

  @override
  String get title;
  @override
  String? get source; // GUTENBERG | GOOGLE
  @override
  String? get contentAvailability; // FULL | METADATA_ONLY
  @override
  int? get gutenbergId;
  @override
  String? get googleId;
  @override
  String? get author;
  @override
  String? get publisher;
  @override
  int? get publishedYear;
  @override
  String? get isbn13;
  @override
  int? get pageCount;
  @override
  String? get language;
  @override
  String? get thumbnailUrl;
  @override
  String? get description;
  @override
  double? get averageRating; // Google community rating 1–5, if any
  @override
  int? get ratingsCount; // Google: number of ratings behind averageRating
  @override
  int? get downloadCount; // Gutenberg: lifetime downloads ("readers" KPI)
  @override
  String? get previewUrl;

  /// Create a copy of CatalogBook
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CatalogBookImplCopyWith<_$CatalogBookImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
