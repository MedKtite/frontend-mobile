// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscription.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SubscriptionImpl _$$SubscriptionImplFromJson(Map<String, dynamic> json) =>
    _$SubscriptionImpl(
      userId: json['userId'] as String,
      tier: json['tier'] as String,
      status: json['status'] as String?,
      store: json['store'] as String?,
      productId: json['productId'] as String?,
      currentPeriodStart: json['currentPeriodStart'] as String?,
      currentPeriodEnd: json['currentPeriodEnd'] as String?,
      cancelAt: json['cancelAt'] as String?,
      trialEnd: json['trialEnd'] as String?,
    );

Map<String, dynamic> _$$SubscriptionImplToJson(_$SubscriptionImpl instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'tier': instance.tier,
      'status': instance.status,
      'store': instance.store,
      'productId': instance.productId,
      'currentPeriodStart': instance.currentPeriodStart,
      'currentPeriodEnd': instance.currentPeriodEnd,
      'cancelAt': instance.cancelAt,
      'trialEnd': instance.trialEnd,
    };
