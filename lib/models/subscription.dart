import 'package:freezed_annotation/freezed_annotation.dart';

part 'subscription.freezed.dart';
part 'subscription.g.dart';

/// Mirrors the backend's SubscriptionResponse (dto/subscription/…). Free
/// users get tier="free" with the other fields null — always a full body.
@freezed
class Subscription with _$Subscription {
  const Subscription._();

  const factory Subscription({
    required String userId,
    required String tier, // free | pro
    String? status, // active | in_grace_period | expired | billing_retry | cancelled
    String? store, // app_store | play_store | stripe
    String? productId,
    String? currentPeriodStart,
    String? currentPeriodEnd,
    String? cancelAt,
    String? trialEnd,
  }) = _Subscription;

  factory Subscription.fromJson(Map<String, dynamic> json) =>
      _$SubscriptionFromJson(json);

  bool get isPro =>
      tier == 'pro' &&
      (status == 'active' ||
          status == 'in_grace_period' ||
          status == 'billing_retry');
}
