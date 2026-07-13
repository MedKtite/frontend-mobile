// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'highlight_create_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

HighlightCreateRequest _$HighlightCreateRequestFromJson(
  Map<String, dynamic> json,
) {
  return _HighlightCreateRequest.fromJson(json);
}

/// @nodoc
mixin _$HighlightCreateRequest {
  String get bookId => throw _privateConstructorUsedError;
  String get colorTag =>
      throw _privateConstructorUsedError; // curious|resonant|beautiful|reference|urgent|disagree|revisit
  String? get textChapterRef => throw _privateConstructorUsedError;
  int? get textStartOffset => throw _privateConstructorUsedError;
  int? get textEndOffset => throw _privateConstructorUsedError;
  String? get passageText => throw _privateConstructorUsedError;
  double? get audioStartSec =>
      throw _privateConstructorUsedError; // audio bookmark timestamp — null for text highlights
  double? get audioEndSec => throw _privateConstructorUsedError;

  /// Serializes this HighlightCreateRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of HighlightCreateRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $HighlightCreateRequestCopyWith<HighlightCreateRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HighlightCreateRequestCopyWith<$Res> {
  factory $HighlightCreateRequestCopyWith(
    HighlightCreateRequest value,
    $Res Function(HighlightCreateRequest) then,
  ) = _$HighlightCreateRequestCopyWithImpl<$Res, HighlightCreateRequest>;
  @useResult
  $Res call({
    String bookId,
    String colorTag,
    String? textChapterRef,
    int? textStartOffset,
    int? textEndOffset,
    String? passageText,
    double? audioStartSec,
    double? audioEndSec,
  });
}

/// @nodoc
class _$HighlightCreateRequestCopyWithImpl<
  $Res,
  $Val extends HighlightCreateRequest
>
    implements $HighlightCreateRequestCopyWith<$Res> {
  _$HighlightCreateRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of HighlightCreateRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? bookId = null,
    Object? colorTag = null,
    Object? textChapterRef = freezed,
    Object? textStartOffset = freezed,
    Object? textEndOffset = freezed,
    Object? passageText = freezed,
    Object? audioStartSec = freezed,
    Object? audioEndSec = freezed,
  }) {
    return _then(
      _value.copyWith(
            bookId: null == bookId
                ? _value.bookId
                : bookId // ignore: cast_nullable_to_non_nullable
                      as String,
            colorTag: null == colorTag
                ? _value.colorTag
                : colorTag // ignore: cast_nullable_to_non_nullable
                      as String,
            textChapterRef: freezed == textChapterRef
                ? _value.textChapterRef
                : textChapterRef // ignore: cast_nullable_to_non_nullable
                      as String?,
            textStartOffset: freezed == textStartOffset
                ? _value.textStartOffset
                : textStartOffset // ignore: cast_nullable_to_non_nullable
                      as int?,
            textEndOffset: freezed == textEndOffset
                ? _value.textEndOffset
                : textEndOffset // ignore: cast_nullable_to_non_nullable
                      as int?,
            passageText: freezed == passageText
                ? _value.passageText
                : passageText // ignore: cast_nullable_to_non_nullable
                      as String?,
            audioStartSec: freezed == audioStartSec
                ? _value.audioStartSec
                : audioStartSec // ignore: cast_nullable_to_non_nullable
                      as double?,
            audioEndSec: freezed == audioEndSec
                ? _value.audioEndSec
                : audioEndSec // ignore: cast_nullable_to_non_nullable
                      as double?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$HighlightCreateRequestImplCopyWith<$Res>
    implements $HighlightCreateRequestCopyWith<$Res> {
  factory _$$HighlightCreateRequestImplCopyWith(
    _$HighlightCreateRequestImpl value,
    $Res Function(_$HighlightCreateRequestImpl) then,
  ) = __$$HighlightCreateRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String bookId,
    String colorTag,
    String? textChapterRef,
    int? textStartOffset,
    int? textEndOffset,
    String? passageText,
    double? audioStartSec,
    double? audioEndSec,
  });
}

/// @nodoc
class __$$HighlightCreateRequestImplCopyWithImpl<$Res>
    extends
        _$HighlightCreateRequestCopyWithImpl<$Res, _$HighlightCreateRequestImpl>
    implements _$$HighlightCreateRequestImplCopyWith<$Res> {
  __$$HighlightCreateRequestImplCopyWithImpl(
    _$HighlightCreateRequestImpl _value,
    $Res Function(_$HighlightCreateRequestImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of HighlightCreateRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? bookId = null,
    Object? colorTag = null,
    Object? textChapterRef = freezed,
    Object? textStartOffset = freezed,
    Object? textEndOffset = freezed,
    Object? passageText = freezed,
    Object? audioStartSec = freezed,
    Object? audioEndSec = freezed,
  }) {
    return _then(
      _$HighlightCreateRequestImpl(
        bookId: null == bookId
            ? _value.bookId
            : bookId // ignore: cast_nullable_to_non_nullable
                  as String,
        colorTag: null == colorTag
            ? _value.colorTag
            : colorTag // ignore: cast_nullable_to_non_nullable
                  as String,
        textChapterRef: freezed == textChapterRef
            ? _value.textChapterRef
            : textChapterRef // ignore: cast_nullable_to_non_nullable
                  as String?,
        textStartOffset: freezed == textStartOffset
            ? _value.textStartOffset
            : textStartOffset // ignore: cast_nullable_to_non_nullable
                  as int?,
        textEndOffset: freezed == textEndOffset
            ? _value.textEndOffset
            : textEndOffset // ignore: cast_nullable_to_non_nullable
                  as int?,
        passageText: freezed == passageText
            ? _value.passageText
            : passageText // ignore: cast_nullable_to_non_nullable
                  as String?,
        audioStartSec: freezed == audioStartSec
            ? _value.audioStartSec
            : audioStartSec // ignore: cast_nullable_to_non_nullable
                  as double?,
        audioEndSec: freezed == audioEndSec
            ? _value.audioEndSec
            : audioEndSec // ignore: cast_nullable_to_non_nullable
                  as double?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$HighlightCreateRequestImpl implements _HighlightCreateRequest {
  const _$HighlightCreateRequestImpl({
    required this.bookId,
    required this.colorTag,
    this.textChapterRef,
    this.textStartOffset,
    this.textEndOffset,
    this.passageText,
    this.audioStartSec,
    this.audioEndSec,
  });

  factory _$HighlightCreateRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$HighlightCreateRequestImplFromJson(json);

  @override
  final String bookId;
  @override
  final String colorTag;
  // curious|resonant|beautiful|reference|urgent|disagree|revisit
  @override
  final String? textChapterRef;
  @override
  final int? textStartOffset;
  @override
  final int? textEndOffset;
  @override
  final String? passageText;
  @override
  final double? audioStartSec;
  // audio bookmark timestamp — null for text highlights
  @override
  final double? audioEndSec;

  @override
  String toString() {
    return 'HighlightCreateRequest(bookId: $bookId, colorTag: $colorTag, textChapterRef: $textChapterRef, textStartOffset: $textStartOffset, textEndOffset: $textEndOffset, passageText: $passageText, audioStartSec: $audioStartSec, audioEndSec: $audioEndSec)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HighlightCreateRequestImpl &&
            (identical(other.bookId, bookId) || other.bookId == bookId) &&
            (identical(other.colorTag, colorTag) ||
                other.colorTag == colorTag) &&
            (identical(other.textChapterRef, textChapterRef) ||
                other.textChapterRef == textChapterRef) &&
            (identical(other.textStartOffset, textStartOffset) ||
                other.textStartOffset == textStartOffset) &&
            (identical(other.textEndOffset, textEndOffset) ||
                other.textEndOffset == textEndOffset) &&
            (identical(other.passageText, passageText) ||
                other.passageText == passageText) &&
            (identical(other.audioStartSec, audioStartSec) ||
                other.audioStartSec == audioStartSec) &&
            (identical(other.audioEndSec, audioEndSec) ||
                other.audioEndSec == audioEndSec));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    bookId,
    colorTag,
    textChapterRef,
    textStartOffset,
    textEndOffset,
    passageText,
    audioStartSec,
    audioEndSec,
  );

  /// Create a copy of HighlightCreateRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$HighlightCreateRequestImplCopyWith<_$HighlightCreateRequestImpl>
  get copyWith =>
      __$$HighlightCreateRequestImplCopyWithImpl<_$HighlightCreateRequestImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$HighlightCreateRequestImplToJson(this);
  }
}

abstract class _HighlightCreateRequest implements HighlightCreateRequest {
  const factory _HighlightCreateRequest({
    required final String bookId,
    required final String colorTag,
    final String? textChapterRef,
    final int? textStartOffset,
    final int? textEndOffset,
    final String? passageText,
    final double? audioStartSec,
    final double? audioEndSec,
  }) = _$HighlightCreateRequestImpl;

  factory _HighlightCreateRequest.fromJson(Map<String, dynamic> json) =
      _$HighlightCreateRequestImpl.fromJson;

  @override
  String get bookId;
  @override
  String get colorTag; // curious|resonant|beautiful|reference|urgent|disagree|revisit
  @override
  String? get textChapterRef;
  @override
  int? get textStartOffset;
  @override
  int? get textEndOffset;
  @override
  String? get passageText;
  @override
  double? get audioStartSec; // audio bookmark timestamp — null for text highlights
  @override
  double? get audioEndSec;

  /// Create a copy of HighlightCreateRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$HighlightCreateRequestImplCopyWith<_$HighlightCreateRequestImpl>
  get copyWith => throw _privateConstructorUsedError;
}
