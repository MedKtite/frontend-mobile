// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'highlight.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Highlight _$HighlightFromJson(Map<String, dynamic> json) {
  return _Highlight.fromJson(json);
}

/// @nodoc
mixin _$Highlight {
  String get id => throw _privateConstructorUsedError;
  String get bookId => throw _privateConstructorUsedError;
  String? get textChapterRef => throw _privateConstructorUsedError;
  int? get textStartOffset => throw _privateConstructorUsedError;
  int? get textEndOffset => throw _privateConstructorUsedError;
  String? get passageText => throw _privateConstructorUsedError;
  double? get audioStartSec => throw _privateConstructorUsedError;
  double? get audioEndSec => throw _privateConstructorUsedError;
  String? get colorTag => throw _privateConstructorUsedError;
  bool get isSaved => throw _privateConstructorUsedError;
  String? get createdAt => throw _privateConstructorUsedError;

  /// Serializes this Highlight to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Highlight
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $HighlightCopyWith<Highlight> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HighlightCopyWith<$Res> {
  factory $HighlightCopyWith(Highlight value, $Res Function(Highlight) then) =
      _$HighlightCopyWithImpl<$Res, Highlight>;
  @useResult
  $Res call({
    String id,
    String bookId,
    String? textChapterRef,
    int? textStartOffset,
    int? textEndOffset,
    String? passageText,
    double? audioStartSec,
    double? audioEndSec,
    String? colorTag,
    bool isSaved,
    String? createdAt,
  });
}

/// @nodoc
class _$HighlightCopyWithImpl<$Res, $Val extends Highlight>
    implements $HighlightCopyWith<$Res> {
  _$HighlightCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Highlight
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? bookId = null,
    Object? textChapterRef = freezed,
    Object? textStartOffset = freezed,
    Object? textEndOffset = freezed,
    Object? passageText = freezed,
    Object? audioStartSec = freezed,
    Object? audioEndSec = freezed,
    Object? colorTag = freezed,
    Object? isSaved = null,
    Object? createdAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            bookId: null == bookId
                ? _value.bookId
                : bookId // ignore: cast_nullable_to_non_nullable
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
            colorTag: freezed == colorTag
                ? _value.colorTag
                : colorTag // ignore: cast_nullable_to_non_nullable
                      as String?,
            isSaved: null == isSaved
                ? _value.isSaved
                : isSaved // ignore: cast_nullable_to_non_nullable
                      as bool,
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$HighlightImplCopyWith<$Res>
    implements $HighlightCopyWith<$Res> {
  factory _$$HighlightImplCopyWith(
    _$HighlightImpl value,
    $Res Function(_$HighlightImpl) then,
  ) = __$$HighlightImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String bookId,
    String? textChapterRef,
    int? textStartOffset,
    int? textEndOffset,
    String? passageText,
    double? audioStartSec,
    double? audioEndSec,
    String? colorTag,
    bool isSaved,
    String? createdAt,
  });
}

/// @nodoc
class __$$HighlightImplCopyWithImpl<$Res>
    extends _$HighlightCopyWithImpl<$Res, _$HighlightImpl>
    implements _$$HighlightImplCopyWith<$Res> {
  __$$HighlightImplCopyWithImpl(
    _$HighlightImpl _value,
    $Res Function(_$HighlightImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Highlight
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? bookId = null,
    Object? textChapterRef = freezed,
    Object? textStartOffset = freezed,
    Object? textEndOffset = freezed,
    Object? passageText = freezed,
    Object? audioStartSec = freezed,
    Object? audioEndSec = freezed,
    Object? colorTag = freezed,
    Object? isSaved = null,
    Object? createdAt = freezed,
  }) {
    return _then(
      _$HighlightImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        bookId: null == bookId
            ? _value.bookId
            : bookId // ignore: cast_nullable_to_non_nullable
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
        colorTag: freezed == colorTag
            ? _value.colorTag
            : colorTag // ignore: cast_nullable_to_non_nullable
                  as String?,
        isSaved: null == isSaved
            ? _value.isSaved
            : isSaved // ignore: cast_nullable_to_non_nullable
                  as bool,
        createdAt: freezed == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$HighlightImpl implements _Highlight {
  const _$HighlightImpl({
    required this.id,
    required this.bookId,
    this.textChapterRef,
    this.textStartOffset,
    this.textEndOffset,
    this.passageText,
    this.audioStartSec,
    this.audioEndSec,
    this.colorTag,
    this.isSaved = false,
    this.createdAt,
  });

  factory _$HighlightImpl.fromJson(Map<String, dynamic> json) =>
      _$$HighlightImplFromJson(json);

  @override
  final String id;
  @override
  final String bookId;
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
  @override
  final double? audioEndSec;
  @override
  final String? colorTag;
  @override
  @JsonKey()
  final bool isSaved;
  @override
  final String? createdAt;

  @override
  String toString() {
    return 'Highlight(id: $id, bookId: $bookId, textChapterRef: $textChapterRef, textStartOffset: $textStartOffset, textEndOffset: $textEndOffset, passageText: $passageText, audioStartSec: $audioStartSec, audioEndSec: $audioEndSec, colorTag: $colorTag, isSaved: $isSaved, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HighlightImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.bookId, bookId) || other.bookId == bookId) &&
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
                other.audioEndSec == audioEndSec) &&
            (identical(other.colorTag, colorTag) ||
                other.colorTag == colorTag) &&
            (identical(other.isSaved, isSaved) || other.isSaved == isSaved) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    bookId,
    textChapterRef,
    textStartOffset,
    textEndOffset,
    passageText,
    audioStartSec,
    audioEndSec,
    colorTag,
    isSaved,
    createdAt,
  );

  /// Create a copy of Highlight
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$HighlightImplCopyWith<_$HighlightImpl> get copyWith =>
      __$$HighlightImplCopyWithImpl<_$HighlightImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$HighlightImplToJson(this);
  }
}

abstract class _Highlight implements Highlight {
  const factory _Highlight({
    required final String id,
    required final String bookId,
    final String? textChapterRef,
    final int? textStartOffset,
    final int? textEndOffset,
    final String? passageText,
    final double? audioStartSec,
    final double? audioEndSec,
    final String? colorTag,
    final bool isSaved,
    final String? createdAt,
  }) = _$HighlightImpl;

  factory _Highlight.fromJson(Map<String, dynamic> json) =
      _$HighlightImpl.fromJson;

  @override
  String get id;
  @override
  String get bookId;
  @override
  String? get textChapterRef;
  @override
  int? get textStartOffset;
  @override
  int? get textEndOffset;
  @override
  String? get passageText;
  @override
  double? get audioStartSec;
  @override
  double? get audioEndSec;
  @override
  String? get colorTag;
  @override
  bool get isSaved;
  @override
  String? get createdAt;

  /// Create a copy of Highlight
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$HighlightImplCopyWith<_$HighlightImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
