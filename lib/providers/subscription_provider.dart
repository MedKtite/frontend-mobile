import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../models/subscription.dart';
import '../services/backend/subscription_service.dart';

/// The user's current plan, from OUR backend (the RevenueCat webhook is the
/// only writer — the client treats the server as the source of truth).
final subscriptionProvider = FutureProvider<Subscription>(
    (ref) => ref.watch(subscriptionServiceProvider).get());

/// RevenueCat purchase plumbing. Keys arrive via --dart-define so dev builds
/// without store setup degrade to a "not configured" message instead of
/// crashing:
///   flutter run --dart-define=REVENUECAT_ANDROID_KEY=goog_xxx \
///               --dart-define=REVENUECAT_IOS_KEY=appl_xxx
class ProPurchases {
  ProPurchases._();

  static const _androidKey = String.fromEnvironment('REVENUECAT_ANDROID_KEY');
  static const _iosKey = String.fromEnvironment('REVENUECAT_IOS_KEY');
  static bool _configured = false;

  static String get _platformKey {
    if (kIsWeb) return '';
    return switch (defaultTargetPlatform) {
      TargetPlatform.android => _androidKey,
      TargetPlatform.iOS => _iosKey,
      _ => '',
    };
  }

  /// True when purchases can run on this build (mobile + key present).
  static bool get available => !kIsWeb && _platformKey.isNotEmpty;

  /// Must be called with OUR user id — the backend webhook maps
  /// RevenueCat's app_user_id straight to users.id (UUID).
  static Future<void> configure(String userId) async {
    if (!available || _configured) return;
    await Purchases.configure(
      PurchasesConfiguration(_platformKey)..appUserID = userId,
    );
    _configured = true;
  }

  /// The current offering's first package (the Pro subscription), or null
  /// when the store isn't reachable / not configured.
  static Future<Package?> proPackage() async {
    final offerings = await Purchases.getOfferings();
    final current = offerings.current;
    final packages = current?.availablePackages;
    final annual = current?.annual;
    if (annual != null) return annual;
    return (packages == null || packages.isEmpty) ? null : packages.first;
  }

  /// Whether this customer can start the store-configured seven-day trial.
  /// The store remains authoritative and re-checks eligibility at checkout.
  static Future<bool> hasEligibleSevenDayTrial(Package package) async {
    try {
      final product = package.storeProduct;
      if (defaultTargetPlatform == TargetPlatform.android) {
        return product.defaultOption?.freePhase?.billingPeriod?.iso8601 ==
            'P1W';
      }
      if (defaultTargetPlatform != TargetPlatform.iOS) return false;

      final intro = product.introductoryPrice;
      if (intro == null || intro.price != 0 || intro.period != 'P1W') {
        return false;
      }
      final eligibility =
          await Purchases.checkTrialOrIntroductoryPriceEligibility(
        [product.identifier],
      );
      return eligibility[product.identifier]?.status ==
          IntroEligibilityStatus.introEligibilityStatusEligible;
    } on PlatformException {
      return false;
    }
  }

  /// Runs the store purchase sheet. Returns true when the purchase went
  /// through (entitlement flows to our backend via the RevenueCat webhook).
  static Future<bool> buy(Package package) async {
    try {
      await Purchases.purchasePackage(package);
      return true;
    } on PlatformException catch (e) {
      if (PurchasesErrorHelper.getErrorCode(e) ==
          PurchasesErrorCode.purchaseCancelledError) {
        return false; // user closed the store sheet — not an error
      }
      rethrow;
    }
  }

  static Future<void> restore() => Purchases.restorePurchases();

  /// Store-hosted subscription management page for the current customer.
  /// RevenueCat returns the correct App Store / Play Store destination.
  static Future<String?> managementUrl() async {
    if (!available) return null;
    final info = await Purchases.getCustomerInfo();
    return info.managementURL;
  }
}
