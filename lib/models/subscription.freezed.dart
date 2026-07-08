// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'subscription.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Subscription _$SubscriptionFromJson(Map<String, dynamic> json) {
  return _Subscription.fromJson(json);
}

/// @nodoc
mixin _$Subscription {
  String get userId => throw _privateConstructorUsedError;
  String get tier => throw _privateConstructorUsedError; // free | pro
  String? get status =>
      throw _privateConstructorUsedError; // active | in_grace_period | expired | billing_retry | cancelled
  String? get store =>
      throw _privateConstructorUsedError; // app_store | play_store | stripe
  String? get productId => throw _privateConstructorUsedError;
  String? get currentPeriodStart => throw _privateConstructorUsedError;
  String? get currentPeriodEnd => throw _privateConstructorUsedError;
  String? get cancelAt => throw _privateConstructorUsedError;
  String? get trialEnd => throw _privateConstructorUsedError;

  /// Serializes this Subscription to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Subscription
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SubscriptionCopyWith<Subscription> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SubscriptionCopyWith<$Res> {
  factory $SubscriptionCopyWith(
    Subscription value,
    $Res Function(Subscription) then,
  ) = _$SubscriptionCopyWithImpl<$Res, Subscription>;
  @useResult
  $Res call({
    String userId,
    String tier,
    String? status,
    String? store,
    String? productId,
    String? currentPeriodStart,
    String? currentPeriodEnd,
    String? cancelAt,
    String? trialEnd,
  });
}

/// @nodoc
class _$SubscriptionCopyWithImpl<$Res, $Val extends Subscription>
    implements $SubscriptionCopyWith<$Res> {
  _$SubscriptionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Subscription
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? tier = null,
    Object? status = freezed,
    Object? store = freezed,
    Object? productId = freezed,
    Object? currentPeriodStart = freezed,
    Object? currentPeriodEnd = freezed,
    Object? cancelAt = freezed,
    Object? trialEnd = freezed,
  }) {
    return _then(
      _value.copyWith(
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            tier: null == tier
                ? _value.tier
                : tier // ignore: cast_nullable_to_non_nullable
                      as String,
            status: freezed == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String?,
            store: freezed == store
                ? _value.store
                : store // ignore: cast_nullable_to_non_nullable
                      as String?,
            productId: freezed == productId
                ? _value.productId
                : productId // ignore: cast_nullable_to_non_nullable
                      as String?,
            currentPeriodStart: freezed == currentPeriodStart
                ? _value.currentPeriodStart
                : currentPeriodStart // ignore: cast_nullable_to_non_nullable
                      as String?,
            currentPeriodEnd: freezed == currentPeriodEnd
                ? _value.currentPeriodEnd
                : currentPeriodEnd // ignore: cast_nullable_to_non_nullable
                      as String?,
            cancelAt: freezed == cancelAt
                ? _value.cancelAt
                : cancelAt // ignore: cast_nullable_to_non_nullable
                      as String?,
            trialEnd: freezed == trialEnd
                ? _value.trialEnd
                : trialEnd // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SubscriptionImplCopyWith<$Res>
    implements $SubscriptionCopyWith<$Res> {
  factory _$$SubscriptionImplCopyWith(
    _$SubscriptionImpl value,
    $Res Function(_$SubscriptionImpl) then,
  ) = __$$SubscriptionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String userId,
    String tier,
    String? status,
    String? store,
    String? productId,
    String? currentPeriodStart,
    String? currentPeriodEnd,
    String? cancelAt,
    String? trialEnd,
  });
}

/// @nodoc
class __$$SubscriptionImplCopyWithImpl<$Res>
    extends _$SubscriptionCopyWithImpl<$Res, _$SubscriptionImpl>
    implements _$$SubscriptionImplCopyWith<$Res> {
  __$$SubscriptionImplCopyWithImpl(
    _$SubscriptionImpl _value,
    $Res Function(_$SubscriptionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Subscription
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? tier = null,
    Object? status = freezed,
    Object? store = freezed,
    Object? productId = freezed,
    Object? currentPeriodStart = freezed,
    Object? currentPeriodEnd = freezed,
    Object? cancelAt = freezed,
    Object? trialEnd = freezed,
  }) {
    return _then(
      _$SubscriptionImpl(
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        tier: null == tier
            ? _value.tier
            : tier // ignore: cast_nullable_to_non_nullable
                  as String,
        status: freezed == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String?,
        store: freezed == store
            ? _value.store
            : store // ignore: cast_nullable_to_non_nullable
                  as String?,
        productId: freezed == productId
            ? _value.productId
            : productId // ignore: cast_nullable_to_non_nullable
                  as String?,
        currentPeriodStart: freezed == currentPeriodStart
            ? _value.currentPeriodStart
            : currentPeriodStart // ignore: cast_nullable_to_non_nullable
                  as String?,
        currentPeriodEnd: freezed == currentPeriodEnd
            ? _value.currentPeriodEnd
            : currentPeriodEnd // ignore: cast_nullable_to_non_nullable
                  as String?,
        cancelAt: freezed == cancelAt
            ? _value.cancelAt
            : cancelAt // ignore: cast_nullable_to_non_nullable
                  as String?,
        trialEnd: freezed == trialEnd
            ? _value.trialEnd
            : trialEnd // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SubscriptionImpl extends _Subscription {
  const _$SubscriptionImpl({
    required this.userId,
    required this.tier,
    this.status,
    this.store,
    this.productId,
    this.currentPeriodStart,
    this.currentPeriodEnd,
    this.cancelAt,
    this.trialEnd,
  }) : super._();

  factory _$SubscriptionImpl.fromJson(Map<String, dynamic> json) =>
      _$$SubscriptionImplFromJson(json);

  @override
  final String userId;
  @override
  final String tier;
  // free | pro
  @override
  final String? status;
  // active | in_grace_period | expired | billing_retry | cancelled
  @override
  final String? store;
  // app_store | play_store | stripe
  @override
  final String? productId;
  @override
  final String? currentPeriodStart;
  @override
  final String? currentPeriodEnd;
  @override
  final String? cancelAt;
  @override
  final String? trialEnd;

  @override
  String toString() {
    return 'Subscription(userId: $userId, tier: $tier, status: $status, store: $store, productId: $productId, currentPeriodStart: $currentPeriodStart, currentPeriodEnd: $currentPeriodEnd, cancelAt: $cancelAt, trialEnd: $trialEnd)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SubscriptionImpl &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.tier, tier) || other.tier == tier) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.store, store) || other.store == store) &&
            (identical(other.productId, productId) ||
                other.productId == productId) &&
            (identical(other.currentPeriodStart, currentPeriodStart) ||
                other.currentPeriodStart == currentPeriodStart) &&
            (identical(other.currentPeriodEnd, currentPeriodEnd) ||
                other.currentPeriodEnd == currentPeriodEnd) &&
            (identical(other.cancelAt, cancelAt) ||
                other.cancelAt == cancelAt) &&
            (identical(other.trialEnd, trialEnd) ||
                other.trialEnd == trialEnd));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    userId,
    tier,
    status,
    store,
    productId,
    currentPeriodStart,
    currentPeriodEnd,
    cancelAt,
    trialEnd,
  );

  /// Create a copy of Subscription
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SubscriptionImplCopyWith<_$SubscriptionImpl> get copyWith =>
      __$$SubscriptionImplCopyWithImpl<_$SubscriptionImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SubscriptionImplToJson(this);
  }
}

abstract class _Subscription extends Subscription {
  const factory _Subscription({
    required final String userId,
    required final String tier,
    final String? status,
    final String? store,
    final String? productId,
    final String? currentPeriodStart,
    final String? currentPeriodEnd,
    final String? cancelAt,
    final String? trialEnd,
  }) = _$SubscriptionImpl;
  const _Subscription._() : super._();

  factory _Subscription.fromJson(Map<String, dynamic> json) =
      _$SubscriptionImpl.fromJson;

  @override
  String get userId;
  @override
  String get tier; // free | pro
  @override
  String? get status; // active | in_grace_period | expired | billing_retry | cancelled
  @override
  String? get store; // app_store | play_store | stripe
  @override
  String? get productId;
  @override
  String? get currentPeriodStart;
  @override
  String? get currentPeriodEnd;
  @override
  String? get cancelAt;
  @override
  String? get trialEnd;

  /// Create a copy of Subscription
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SubscriptionImplCopyWith<_$SubscriptionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
