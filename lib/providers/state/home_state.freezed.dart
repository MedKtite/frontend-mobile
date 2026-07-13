// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'home_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$HomeState {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() loading,
    required TResult Function() empty,
    required TResult Function(
      ContinueReading? continueReading,
      HomePassage? passage,
      ListeningItem? listening,
    )
    loaded,
    required TResult Function(String message) error,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? loading,
    TResult? Function()? empty,
    TResult? Function(
      ContinueReading? continueReading,
      HomePassage? passage,
      ListeningItem? listening,
    )?
    loaded,
    TResult? Function(String message)? error,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? loading,
    TResult Function()? empty,
    TResult Function(
      ContinueReading? continueReading,
      HomePassage? passage,
      ListeningItem? listening,
    )?
    loaded,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(HomeLoading value) loading,
    required TResult Function(HomeEmpty value) empty,
    required TResult Function(HomeLoaded value) loaded,
    required TResult Function(HomeError value) error,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(HomeLoading value)? loading,
    TResult? Function(HomeEmpty value)? empty,
    TResult? Function(HomeLoaded value)? loaded,
    TResult? Function(HomeError value)? error,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(HomeLoading value)? loading,
    TResult Function(HomeEmpty value)? empty,
    TResult Function(HomeLoaded value)? loaded,
    TResult Function(HomeError value)? error,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HomeStateCopyWith<$Res> {
  factory $HomeStateCopyWith(HomeState value, $Res Function(HomeState) then) =
      _$HomeStateCopyWithImpl<$Res, HomeState>;
}

/// @nodoc
class _$HomeStateCopyWithImpl<$Res, $Val extends HomeState>
    implements $HomeStateCopyWith<$Res> {
  _$HomeStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of HomeState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$HomeLoadingImplCopyWith<$Res> {
  factory _$$HomeLoadingImplCopyWith(
    _$HomeLoadingImpl value,
    $Res Function(_$HomeLoadingImpl) then,
  ) = __$$HomeLoadingImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$HomeLoadingImplCopyWithImpl<$Res>
    extends _$HomeStateCopyWithImpl<$Res, _$HomeLoadingImpl>
    implements _$$HomeLoadingImplCopyWith<$Res> {
  __$$HomeLoadingImplCopyWithImpl(
    _$HomeLoadingImpl _value,
    $Res Function(_$HomeLoadingImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of HomeState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$HomeLoadingImpl implements HomeLoading {
  const _$HomeLoadingImpl();

  @override
  String toString() {
    return 'HomeState.loading()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$HomeLoadingImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() loading,
    required TResult Function() empty,
    required TResult Function(
      ContinueReading? continueReading,
      HomePassage? passage,
      ListeningItem? listening,
    )
    loaded,
    required TResult Function(String message) error,
  }) {
    return loading();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? loading,
    TResult? Function()? empty,
    TResult? Function(
      ContinueReading? continueReading,
      HomePassage? passage,
      ListeningItem? listening,
    )?
    loaded,
    TResult? Function(String message)? error,
  }) {
    return loading?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? loading,
    TResult Function()? empty,
    TResult Function(
      ContinueReading? continueReading,
      HomePassage? passage,
      ListeningItem? listening,
    )?
    loaded,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(HomeLoading value) loading,
    required TResult Function(HomeEmpty value) empty,
    required TResult Function(HomeLoaded value) loaded,
    required TResult Function(HomeError value) error,
  }) {
    return loading(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(HomeLoading value)? loading,
    TResult? Function(HomeEmpty value)? empty,
    TResult? Function(HomeLoaded value)? loaded,
    TResult? Function(HomeError value)? error,
  }) {
    return loading?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(HomeLoading value)? loading,
    TResult Function(HomeEmpty value)? empty,
    TResult Function(HomeLoaded value)? loaded,
    TResult Function(HomeError value)? error,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading(this);
    }
    return orElse();
  }
}

abstract class HomeLoading implements HomeState {
  const factory HomeLoading() = _$HomeLoadingImpl;
}

/// @nodoc
abstract class _$$HomeEmptyImplCopyWith<$Res> {
  factory _$$HomeEmptyImplCopyWith(
    _$HomeEmptyImpl value,
    $Res Function(_$HomeEmptyImpl) then,
  ) = __$$HomeEmptyImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$HomeEmptyImplCopyWithImpl<$Res>
    extends _$HomeStateCopyWithImpl<$Res, _$HomeEmptyImpl>
    implements _$$HomeEmptyImplCopyWith<$Res> {
  __$$HomeEmptyImplCopyWithImpl(
    _$HomeEmptyImpl _value,
    $Res Function(_$HomeEmptyImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of HomeState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$HomeEmptyImpl implements HomeEmpty {
  const _$HomeEmptyImpl();

  @override
  String toString() {
    return 'HomeState.empty()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$HomeEmptyImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() loading,
    required TResult Function() empty,
    required TResult Function(
      ContinueReading? continueReading,
      HomePassage? passage,
      ListeningItem? listening,
    )
    loaded,
    required TResult Function(String message) error,
  }) {
    return empty();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? loading,
    TResult? Function()? empty,
    TResult? Function(
      ContinueReading? continueReading,
      HomePassage? passage,
      ListeningItem? listening,
    )?
    loaded,
    TResult? Function(String message)? error,
  }) {
    return empty?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? loading,
    TResult Function()? empty,
    TResult Function(
      ContinueReading? continueReading,
      HomePassage? passage,
      ListeningItem? listening,
    )?
    loaded,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (empty != null) {
      return empty();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(HomeLoading value) loading,
    required TResult Function(HomeEmpty value) empty,
    required TResult Function(HomeLoaded value) loaded,
    required TResult Function(HomeError value) error,
  }) {
    return empty(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(HomeLoading value)? loading,
    TResult? Function(HomeEmpty value)? empty,
    TResult? Function(HomeLoaded value)? loaded,
    TResult? Function(HomeError value)? error,
  }) {
    return empty?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(HomeLoading value)? loading,
    TResult Function(HomeEmpty value)? empty,
    TResult Function(HomeLoaded value)? loaded,
    TResult Function(HomeError value)? error,
    required TResult orElse(),
  }) {
    if (empty != null) {
      return empty(this);
    }
    return orElse();
  }
}

abstract class HomeEmpty implements HomeState {
  const factory HomeEmpty() = _$HomeEmptyImpl;
}

/// @nodoc
abstract class _$$HomeLoadedImplCopyWith<$Res> {
  factory _$$HomeLoadedImplCopyWith(
    _$HomeLoadedImpl value,
    $Res Function(_$HomeLoadedImpl) then,
  ) = __$$HomeLoadedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({
    ContinueReading? continueReading,
    HomePassage? passage,
    ListeningItem? listening,
  });

  $ContinueReadingCopyWith<$Res>? get continueReading;
  $HomePassageCopyWith<$Res>? get passage;
  $ListeningItemCopyWith<$Res>? get listening;
}

/// @nodoc
class __$$HomeLoadedImplCopyWithImpl<$Res>
    extends _$HomeStateCopyWithImpl<$Res, _$HomeLoadedImpl>
    implements _$$HomeLoadedImplCopyWith<$Res> {
  __$$HomeLoadedImplCopyWithImpl(
    _$HomeLoadedImpl _value,
    $Res Function(_$HomeLoadedImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of HomeState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? continueReading = freezed,
    Object? passage = freezed,
    Object? listening = freezed,
  }) {
    return _then(
      _$HomeLoadedImpl(
        continueReading: freezed == continueReading
            ? _value.continueReading
            : continueReading // ignore: cast_nullable_to_non_nullable
                  as ContinueReading?,
        passage: freezed == passage
            ? _value.passage
            : passage // ignore: cast_nullable_to_non_nullable
                  as HomePassage?,
        listening: freezed == listening
            ? _value.listening
            : listening // ignore: cast_nullable_to_non_nullable
                  as ListeningItem?,
      ),
    );
  }

  /// Create a copy of HomeState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ContinueReadingCopyWith<$Res>? get continueReading {
    if (_value.continueReading == null) {
      return null;
    }

    return $ContinueReadingCopyWith<$Res>(_value.continueReading!, (value) {
      return _then(_value.copyWith(continueReading: value));
    });
  }

  /// Create a copy of HomeState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $HomePassageCopyWith<$Res>? get passage {
    if (_value.passage == null) {
      return null;
    }

    return $HomePassageCopyWith<$Res>(_value.passage!, (value) {
      return _then(_value.copyWith(passage: value));
    });
  }

  /// Create a copy of HomeState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ListeningItemCopyWith<$Res>? get listening {
    if (_value.listening == null) {
      return null;
    }

    return $ListeningItemCopyWith<$Res>(_value.listening!, (value) {
      return _then(_value.copyWith(listening: value));
    });
  }
}

/// @nodoc

class _$HomeLoadedImpl implements HomeLoaded {
  const _$HomeLoadedImpl({this.continueReading, this.passage, this.listening});

  @override
  final ContinueReading? continueReading;
  @override
  final HomePassage? passage;
  @override
  final ListeningItem? listening;

  @override
  String toString() {
    return 'HomeState.loaded(continueReading: $continueReading, passage: $passage, listening: $listening)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HomeLoadedImpl &&
            (identical(other.continueReading, continueReading) ||
                other.continueReading == continueReading) &&
            (identical(other.passage, passage) || other.passage == passage) &&
            (identical(other.listening, listening) ||
                other.listening == listening));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, continueReading, passage, listening);

  /// Create a copy of HomeState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$HomeLoadedImplCopyWith<_$HomeLoadedImpl> get copyWith =>
      __$$HomeLoadedImplCopyWithImpl<_$HomeLoadedImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() loading,
    required TResult Function() empty,
    required TResult Function(
      ContinueReading? continueReading,
      HomePassage? passage,
      ListeningItem? listening,
    )
    loaded,
    required TResult Function(String message) error,
  }) {
    return loaded(continueReading, passage, listening);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? loading,
    TResult? Function()? empty,
    TResult? Function(
      ContinueReading? continueReading,
      HomePassage? passage,
      ListeningItem? listening,
    )?
    loaded,
    TResult? Function(String message)? error,
  }) {
    return loaded?.call(continueReading, passage, listening);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? loading,
    TResult Function()? empty,
    TResult Function(
      ContinueReading? continueReading,
      HomePassage? passage,
      ListeningItem? listening,
    )?
    loaded,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (loaded != null) {
      return loaded(continueReading, passage, listening);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(HomeLoading value) loading,
    required TResult Function(HomeEmpty value) empty,
    required TResult Function(HomeLoaded value) loaded,
    required TResult Function(HomeError value) error,
  }) {
    return loaded(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(HomeLoading value)? loading,
    TResult? Function(HomeEmpty value)? empty,
    TResult? Function(HomeLoaded value)? loaded,
    TResult? Function(HomeError value)? error,
  }) {
    return loaded?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(HomeLoading value)? loading,
    TResult Function(HomeEmpty value)? empty,
    TResult Function(HomeLoaded value)? loaded,
    TResult Function(HomeError value)? error,
    required TResult orElse(),
  }) {
    if (loaded != null) {
      return loaded(this);
    }
    return orElse();
  }
}

abstract class HomeLoaded implements HomeState {
  const factory HomeLoaded({
    final ContinueReading? continueReading,
    final HomePassage? passage,
    final ListeningItem? listening,
  }) = _$HomeLoadedImpl;

  ContinueReading? get continueReading;
  HomePassage? get passage;
  ListeningItem? get listening;

  /// Create a copy of HomeState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$HomeLoadedImplCopyWith<_$HomeLoadedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$HomeErrorImplCopyWith<$Res> {
  factory _$$HomeErrorImplCopyWith(
    _$HomeErrorImpl value,
    $Res Function(_$HomeErrorImpl) then,
  ) = __$$HomeErrorImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String message});
}

/// @nodoc
class __$$HomeErrorImplCopyWithImpl<$Res>
    extends _$HomeStateCopyWithImpl<$Res, _$HomeErrorImpl>
    implements _$$HomeErrorImplCopyWith<$Res> {
  __$$HomeErrorImplCopyWithImpl(
    _$HomeErrorImpl _value,
    $Res Function(_$HomeErrorImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of HomeState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? message = null}) {
    return _then(
      _$HomeErrorImpl(
        null == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$HomeErrorImpl implements HomeError {
  const _$HomeErrorImpl(this.message);

  @override
  final String message;

  @override
  String toString() {
    return 'HomeState.error(message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HomeErrorImpl &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  /// Create a copy of HomeState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$HomeErrorImplCopyWith<_$HomeErrorImpl> get copyWith =>
      __$$HomeErrorImplCopyWithImpl<_$HomeErrorImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() loading,
    required TResult Function() empty,
    required TResult Function(
      ContinueReading? continueReading,
      HomePassage? passage,
      ListeningItem? listening,
    )
    loaded,
    required TResult Function(String message) error,
  }) {
    return error(message);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? loading,
    TResult? Function()? empty,
    TResult? Function(
      ContinueReading? continueReading,
      HomePassage? passage,
      ListeningItem? listening,
    )?
    loaded,
    TResult? Function(String message)? error,
  }) {
    return error?.call(message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? loading,
    TResult Function()? empty,
    TResult Function(
      ContinueReading? continueReading,
      HomePassage? passage,
      ListeningItem? listening,
    )?
    loaded,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(message);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(HomeLoading value) loading,
    required TResult Function(HomeEmpty value) empty,
    required TResult Function(HomeLoaded value) loaded,
    required TResult Function(HomeError value) error,
  }) {
    return error(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(HomeLoading value)? loading,
    TResult? Function(HomeEmpty value)? empty,
    TResult? Function(HomeLoaded value)? loaded,
    TResult? Function(HomeError value)? error,
  }) {
    return error?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(HomeLoading value)? loading,
    TResult Function(HomeEmpty value)? empty,
    TResult Function(HomeLoaded value)? loaded,
    TResult Function(HomeError value)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(this);
    }
    return orElse();
  }
}

abstract class HomeError implements HomeState {
  const factory HomeError(final String message) = _$HomeErrorImpl;

  String get message;

  /// Create a copy of HomeState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$HomeErrorImplCopyWith<_$HomeErrorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$ContinueReading {
  String get id =>
      throw _privateConstructorUsedError; // book id — opens the reader on resume
  String get title => throw _privateConstructorUsedError;
  String get author => throw _privateConstructorUsedError;
  Color get coverBg => throw _privateConstructorUsedError;
  Color get coverFg => throw _privateConstructorUsedError;
  double get progress => throw _privateConstructorUsedError;

  /// Create a copy of ContinueReading
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ContinueReadingCopyWith<ContinueReading> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ContinueReadingCopyWith<$Res> {
  factory $ContinueReadingCopyWith(
    ContinueReading value,
    $Res Function(ContinueReading) then,
  ) = _$ContinueReadingCopyWithImpl<$Res, ContinueReading>;
  @useResult
  $Res call({
    String id,
    String title,
    String author,
    Color coverBg,
    Color coverFg,
    double progress,
  });
}

/// @nodoc
class _$ContinueReadingCopyWithImpl<$Res, $Val extends ContinueReading>
    implements $ContinueReadingCopyWith<$Res> {
  _$ContinueReadingCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ContinueReading
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? author = null,
    Object? coverBg = null,
    Object? coverFg = null,
    Object? progress = null,
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
            author: null == author
                ? _value.author
                : author // ignore: cast_nullable_to_non_nullable
                      as String,
            coverBg: null == coverBg
                ? _value.coverBg
                : coverBg // ignore: cast_nullable_to_non_nullable
                      as Color,
            coverFg: null == coverFg
                ? _value.coverFg
                : coverFg // ignore: cast_nullable_to_non_nullable
                      as Color,
            progress: null == progress
                ? _value.progress
                : progress // ignore: cast_nullable_to_non_nullable
                      as double,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ContinueReadingImplCopyWith<$Res>
    implements $ContinueReadingCopyWith<$Res> {
  factory _$$ContinueReadingImplCopyWith(
    _$ContinueReadingImpl value,
    $Res Function(_$ContinueReadingImpl) then,
  ) = __$$ContinueReadingImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String title,
    String author,
    Color coverBg,
    Color coverFg,
    double progress,
  });
}

/// @nodoc
class __$$ContinueReadingImplCopyWithImpl<$Res>
    extends _$ContinueReadingCopyWithImpl<$Res, _$ContinueReadingImpl>
    implements _$$ContinueReadingImplCopyWith<$Res> {
  __$$ContinueReadingImplCopyWithImpl(
    _$ContinueReadingImpl _value,
    $Res Function(_$ContinueReadingImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ContinueReading
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? author = null,
    Object? coverBg = null,
    Object? coverFg = null,
    Object? progress = null,
  }) {
    return _then(
      _$ContinueReadingImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        author: null == author
            ? _value.author
            : author // ignore: cast_nullable_to_non_nullable
                  as String,
        coverBg: null == coverBg
            ? _value.coverBg
            : coverBg // ignore: cast_nullable_to_non_nullable
                  as Color,
        coverFg: null == coverFg
            ? _value.coverFg
            : coverFg // ignore: cast_nullable_to_non_nullable
                  as Color,
        progress: null == progress
            ? _value.progress
            : progress // ignore: cast_nullable_to_non_nullable
                  as double,
      ),
    );
  }
}

/// @nodoc

class _$ContinueReadingImpl implements _ContinueReading {
  const _$ContinueReadingImpl({
    required this.id,
    required this.title,
    required this.author,
    required this.coverBg,
    required this.coverFg,
    required this.progress,
  });

  @override
  final String id;
  // book id — opens the reader on resume
  @override
  final String title;
  @override
  final String author;
  @override
  final Color coverBg;
  @override
  final Color coverFg;
  @override
  final double progress;

  @override
  String toString() {
    return 'ContinueReading(id: $id, title: $title, author: $author, coverBg: $coverBg, coverFg: $coverFg, progress: $progress)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ContinueReadingImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.author, author) || other.author == author) &&
            (identical(other.coverBg, coverBg) || other.coverBg == coverBg) &&
            (identical(other.coverFg, coverFg) || other.coverFg == coverFg) &&
            (identical(other.progress, progress) ||
                other.progress == progress));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, id, title, author, coverBg, coverFg, progress);

  /// Create a copy of ContinueReading
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ContinueReadingImplCopyWith<_$ContinueReadingImpl> get copyWith =>
      __$$ContinueReadingImplCopyWithImpl<_$ContinueReadingImpl>(
        this,
        _$identity,
      );
}

abstract class _ContinueReading implements ContinueReading {
  const factory _ContinueReading({
    required final String id,
    required final String title,
    required final String author,
    required final Color coverBg,
    required final Color coverFg,
    required final double progress,
  }) = _$ContinueReadingImpl;

  @override
  String get id; // book id — opens the reader on resume
  @override
  String get title;
  @override
  String get author;
  @override
  Color get coverBg;
  @override
  Color get coverFg;
  @override
  double get progress;

  /// Create a copy of ContinueReading
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ContinueReadingImplCopyWith<_$ContinueReadingImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$HomePassage {
  String get text => throw _privateConstructorUsedError;
  String get source => throw _privateConstructorUsedError;
  String get colorTag => throw _privateConstructorUsedError;

  /// Create a copy of HomePassage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $HomePassageCopyWith<HomePassage> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HomePassageCopyWith<$Res> {
  factory $HomePassageCopyWith(
    HomePassage value,
    $Res Function(HomePassage) then,
  ) = _$HomePassageCopyWithImpl<$Res, HomePassage>;
  @useResult
  $Res call({String text, String source, String colorTag});
}

/// @nodoc
class _$HomePassageCopyWithImpl<$Res, $Val extends HomePassage>
    implements $HomePassageCopyWith<$Res> {
  _$HomePassageCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of HomePassage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? text = null,
    Object? source = null,
    Object? colorTag = null,
  }) {
    return _then(
      _value.copyWith(
            text: null == text
                ? _value.text
                : text // ignore: cast_nullable_to_non_nullable
                      as String,
            source: null == source
                ? _value.source
                : source // ignore: cast_nullable_to_non_nullable
                      as String,
            colorTag: null == colorTag
                ? _value.colorTag
                : colorTag // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$HomePassageImplCopyWith<$Res>
    implements $HomePassageCopyWith<$Res> {
  factory _$$HomePassageImplCopyWith(
    _$HomePassageImpl value,
    $Res Function(_$HomePassageImpl) then,
  ) = __$$HomePassageImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String text, String source, String colorTag});
}

/// @nodoc
class __$$HomePassageImplCopyWithImpl<$Res>
    extends _$HomePassageCopyWithImpl<$Res, _$HomePassageImpl>
    implements _$$HomePassageImplCopyWith<$Res> {
  __$$HomePassageImplCopyWithImpl(
    _$HomePassageImpl _value,
    $Res Function(_$HomePassageImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of HomePassage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? text = null,
    Object? source = null,
    Object? colorTag = null,
  }) {
    return _then(
      _$HomePassageImpl(
        text: null == text
            ? _value.text
            : text // ignore: cast_nullable_to_non_nullable
                  as String,
        source: null == source
            ? _value.source
            : source // ignore: cast_nullable_to_non_nullable
                  as String,
        colorTag: null == colorTag
            ? _value.colorTag
            : colorTag // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$HomePassageImpl implements _HomePassage {
  const _$HomePassageImpl({
    required this.text,
    required this.source,
    required this.colorTag,
  });

  @override
  final String text;
  @override
  final String source;
  @override
  final String colorTag;

  @override
  String toString() {
    return 'HomePassage(text: $text, source: $source, colorTag: $colorTag)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HomePassageImpl &&
            (identical(other.text, text) || other.text == text) &&
            (identical(other.source, source) || other.source == source) &&
            (identical(other.colorTag, colorTag) ||
                other.colorTag == colorTag));
  }

  @override
  int get hashCode => Object.hash(runtimeType, text, source, colorTag);

  /// Create a copy of HomePassage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$HomePassageImplCopyWith<_$HomePassageImpl> get copyWith =>
      __$$HomePassageImplCopyWithImpl<_$HomePassageImpl>(this, _$identity);
}

abstract class _HomePassage implements HomePassage {
  const factory _HomePassage({
    required final String text,
    required final String source,
    required final String colorTag,
  }) = _$HomePassageImpl;

  @override
  String get text;
  @override
  String get source;
  @override
  String get colorTag;

  /// Create a copy of HomePassage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$HomePassageImplCopyWith<_$HomePassageImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$ListeningItem {
  String get id =>
      throw _privateConstructorUsedError; // book id — opens the audio player on play
  String get title => throw _privateConstructorUsedError;
  String get author => throw _privateConstructorUsedError;
  Color get coverBg => throw _privateConstructorUsedError;
  Color get coverFg => throw _privateConstructorUsedError;

  /// Create a copy of ListeningItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ListeningItemCopyWith<ListeningItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ListeningItemCopyWith<$Res> {
  factory $ListeningItemCopyWith(
    ListeningItem value,
    $Res Function(ListeningItem) then,
  ) = _$ListeningItemCopyWithImpl<$Res, ListeningItem>;
  @useResult
  $Res call({
    String id,
    String title,
    String author,
    Color coverBg,
    Color coverFg,
  });
}

/// @nodoc
class _$ListeningItemCopyWithImpl<$Res, $Val extends ListeningItem>
    implements $ListeningItemCopyWith<$Res> {
  _$ListeningItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ListeningItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? author = null,
    Object? coverBg = null,
    Object? coverFg = null,
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
            author: null == author
                ? _value.author
                : author // ignore: cast_nullable_to_non_nullable
                      as String,
            coverBg: null == coverBg
                ? _value.coverBg
                : coverBg // ignore: cast_nullable_to_non_nullable
                      as Color,
            coverFg: null == coverFg
                ? _value.coverFg
                : coverFg // ignore: cast_nullable_to_non_nullable
                      as Color,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ListeningItemImplCopyWith<$Res>
    implements $ListeningItemCopyWith<$Res> {
  factory _$$ListeningItemImplCopyWith(
    _$ListeningItemImpl value,
    $Res Function(_$ListeningItemImpl) then,
  ) = __$$ListeningItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String title,
    String author,
    Color coverBg,
    Color coverFg,
  });
}

/// @nodoc
class __$$ListeningItemImplCopyWithImpl<$Res>
    extends _$ListeningItemCopyWithImpl<$Res, _$ListeningItemImpl>
    implements _$$ListeningItemImplCopyWith<$Res> {
  __$$ListeningItemImplCopyWithImpl(
    _$ListeningItemImpl _value,
    $Res Function(_$ListeningItemImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ListeningItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? author = null,
    Object? coverBg = null,
    Object? coverFg = null,
  }) {
    return _then(
      _$ListeningItemImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        author: null == author
            ? _value.author
            : author // ignore: cast_nullable_to_non_nullable
                  as String,
        coverBg: null == coverBg
            ? _value.coverBg
            : coverBg // ignore: cast_nullable_to_non_nullable
                  as Color,
        coverFg: null == coverFg
            ? _value.coverFg
            : coverFg // ignore: cast_nullable_to_non_nullable
                  as Color,
      ),
    );
  }
}

/// @nodoc

class _$ListeningItemImpl implements _ListeningItem {
  const _$ListeningItemImpl({
    required this.id,
    required this.title,
    required this.author,
    required this.coverBg,
    required this.coverFg,
  });

  @override
  final String id;
  // book id — opens the audio player on play
  @override
  final String title;
  @override
  final String author;
  @override
  final Color coverBg;
  @override
  final Color coverFg;

  @override
  String toString() {
    return 'ListeningItem(id: $id, title: $title, author: $author, coverBg: $coverBg, coverFg: $coverFg)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ListeningItemImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.author, author) || other.author == author) &&
            (identical(other.coverBg, coverBg) || other.coverBg == coverBg) &&
            (identical(other.coverFg, coverFg) || other.coverFg == coverFg));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, id, title, author, coverBg, coverFg);

  /// Create a copy of ListeningItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ListeningItemImplCopyWith<_$ListeningItemImpl> get copyWith =>
      __$$ListeningItemImplCopyWithImpl<_$ListeningItemImpl>(this, _$identity);
}

abstract class _ListeningItem implements ListeningItem {
  const factory _ListeningItem({
    required final String id,
    required final String title,
    required final String author,
    required final Color coverBg,
    required final Color coverFg,
  }) = _$ListeningItemImpl;

  @override
  String get id; // book id — opens the audio player on play
  @override
  String get title;
  @override
  String get author;
  @override
  Color get coverBg;
  @override
  Color get coverFg;

  /// Create a copy of ListeningItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ListeningItemImplCopyWith<_$ListeningItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
