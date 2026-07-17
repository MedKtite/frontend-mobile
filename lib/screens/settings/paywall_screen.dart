import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app/theme/tokens/colors.dart';
import '../../app/theme/tokens/radii.dart';
import '../../app/theme/tokens/spacing.dart';
import '../../app/theme/tokens/typography.dart';
import '../../core/widgets/app_snackbar.dart';
import '../../models/subscription.dart';
import '../../providers/auth_provider.dart';
import '../../providers/state/auth_state.dart';
import '../../providers/subscription_provider.dart';

/// Subscription management and Marginalia Pro purchase screen.
///
/// Store purchases are handled by RevenueCat; our backend subscription remains
/// the source of truth after its webhook updates the user's entitlement.
class PaywallScreen extends ConsumerStatefulWidget {
  const PaywallScreen({super.key});

  @override
  ConsumerState<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends ConsumerState<PaywallScreen> {
  Package? _package;
  bool _hasSevenDayTrial = false;
  bool _loading = true;
  bool _buying = false;

  @override
  void initState() {
    super.initState();
    _loadOffering();
  }

  Future<void> _loadOffering() async {
    if (!ProPurchases.available) {
      if (mounted) setState(() => _loading = false);
      return;
    }
    try {
      final auth = ref.read(authProvider);
      if (auth is AuthAuthenticated) {
        await ProPurchases.configure(auth.user.id);
      }
      final package = await ProPurchases.proPackage();
      final hasTrial = package != null &&
          await ProPurchases.hasEligibleSevenDayTrial(package);
      if (mounted) {
        setState(() {
          _package = package;
          _hasSevenDayTrial = hasTrial;
        });
      }
    } catch (_) {
      // The screen keeps its management state when the store is unavailable.
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _buy() async {
    final package = _package;
    if (package == null || _buying) return;
    setState(() => _buying = true);
    try {
      final purchased = await ProPurchases.buy(package);
      if (!mounted) return;
      if (purchased) {
        ref.invalidate(subscriptionProvider);
        showAppSnack(
          context,
          _hasSevenDayTrial
              ? 'Your seven-day Marginalia Pro trial has started.'
              : 'Welcome to Marginalia Pro!',
          type: SnackType.success,
        );
      }
    } catch (_) {
      if (mounted) {
        showAppSnack(
          context,
          'The purchase didn’t go through — try again.',
          type: SnackType.error,
        );
      }
    } finally {
      if (mounted) setState(() => _buying = false);
    }
  }

  Future<void> _restore() async {
    try {
      await ProPurchases.restore();
      if (!mounted) return;
      ref.invalidate(subscriptionProvider);
      showAppSnack(
        context,
        'Purchases restored.',
        type: SnackType.success,
      );
    } catch (_) {
      if (mounted) {
        showAppSnack(
          context,
          'Nothing to restore on this account.',
          type: SnackType.info,
        );
      }
    }
  }

  Future<void> _openStoreManagement() async {
    try {
      final rawUrl = await ProPurchases.managementUrl();
      final uri = rawUrl == null ? null : Uri.tryParse(rawUrl);
      final opened = uri == null
          ? false
          : await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!opened && mounted) {
        showAppSnack(
          context,
          'Subscription management isn’t available for this account yet.',
          type: SnackType.info,
        );
      }
    } catch (_) {
      if (mounted) {
        showAppSnack(
          context,
          'Couldn’t open subscription management.',
          type: SnackType.error,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final subscription = ref.watch(subscriptionProvider).valueOrNull;
    final isPro = subscription?.isPro ?? false;
    final inTrial = _isActiveTrial(subscription);

    return Scaffold(
      backgroundColor: colors.bg,
      body: SafeArea(
        child: Column(
          children: [
            _SubscriptionTopBar(onBack: () => context.pop()),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.readingHorizontal,
                  AppSpacing.xl,
                  AppSpacing.readingHorizontal,
                  AppSpacing.xxxl,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _PlanCard(
                      planLabel: _planLabel(subscription, inTrial),
                      renewalLabel: _renewalLabel(
                        subscription,
                        isPro,
                        inTrial,
                      ),
                      renewalValue: _renewalValue(
                        subscription,
                        isPro,
                        inTrial,
                      ),
                      price: _priceText,
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    Padding(
                      padding: const EdgeInsets.only(left: AppSpacing.lg),
                      child: Text(
                        isPro ? 'MANAGE' : 'SUBSCRIPTION',
                        style: AppTypography.overline(colors.text3),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _ActionGroup(
                      children: [
                        if (isPro)
                          _SubscriptionAction(
                            title: 'Change plan',
                            subtitle: 'Switch to monthly or a different tier',
                            onTap: _openStoreManagement,
                          )
                        else
                          _SubscriptionAction(
                            title: _buying
                                ? 'Opening the store…'
                                : _hasSevenDayTrial
                                    ? 'Start seven-day free trial'
                                    : 'Start Pro',
                            subtitle: _purchaseSubtitle,
                            onTap: _canPurchase ? _buy : null,
                          ),
                        _SubscriptionAction(
                          title: 'Restore purchases',
                          subtitle: 'Reactivate a previous purchase',
                          onTap: _restore,
                        ),
                        _SubscriptionAction(
                          title: 'Manage in $_storeName',
                          subtitle: '$_storeName-managed billing controls',
                          onTap: _openStoreManagement,
                        ),
                        if (isPro)
                          _SubscriptionAction(
                            title: 'Cancel subscription',
                            destructive: true,
                            onTap: _openStoreManagement,
                          ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    Text(
                      isPro
                          ? inTrial
                              ? 'Your trial becomes a paid subscription unless '
                                  'cancelled before it ends.'
                              : 'Your subscription auto-renews until cancelled.\n'
                                  'We’ll remind you 7 days before renewal.'
                          : 'Your subscription renews automatically.\n'
                              'Cancel anytime in $_storeName.',
                      textAlign: TextAlign.center,
                      style: AppTypography.serif(
                        AppTypography.caption(colors.text3).copyWith(
                          fontStyle: FontStyle.italic,
                          height: 1.6,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool get _canPurchase =>
      !_loading && !_buying && ProPurchases.available && _package != null;

  String get _storeName => switch (defaultTargetPlatform) {
        TargetPlatform.iOS => 'App Store',
        TargetPlatform.macOS => 'App Store',
        TargetPlatform.android => 'Google Play',
        _ => 'Store',
      };

  String get _billingPeriod => switch (_package?.packageType) {
        PackageType.annual => 'year',
        PackageType.monthly => 'month',
        _ => 'period',
      };

  String get _priceText {
    final package = _package;
    return package == null
        ? 'Store managed'
        : '${package.storeProduct.priceString} / $_billingPeriod';
  }

  String get _purchaseSubtitle {
    if (_loading) return 'Checking store availability';
    if (!ProPurchases.available || _package == null) {
      return 'Store offering unavailable in this build';
    }
    final price = '${_package!.storeProduct.priceString} / $_billingPeriod';
    return _hasSevenDayTrial ? 'Free for 7 days, then $price' : price;
  }

  bool _isActiveTrial(Subscription? subscription) {
    final end = DateTime.tryParse(subscription?.trialEnd ?? '');
    return subscription?.isPro == true &&
        end != null &&
        end.isAfter(DateTime.now());
  }

  String _planLabel(Subscription? subscription, bool inTrial) {
    if (inTrial) return 'Seven-day free trial';
    final product = subscription?.productId?.toLowerCase() ?? '';
    final type = _package?.packageType;
    if (type == PackageType.monthly || product.contains('month')) {
      return 'Monthly plan';
    }
    if (type == PackageType.annual ||
        product.contains('annual') ||
        product.contains('year')) {
      return 'Annual plan';
    }
    return subscription?.isPro ?? false ? 'Active plan' : 'Choose your plan';
  }

  String _renewalLabel(
    Subscription? subscription,
    bool isPro,
    bool inTrial,
  ) {
    if (!isPro) return 'CURRENT PLAN';
    if (inTrial) return 'TRIAL ENDS';
    return subscription?.cancelAt == null ? 'NEXT RENEWAL' : 'ACCESS UNTIL';
  }

  String _renewalValue(
    Subscription? subscription,
    bool isPro,
    bool inTrial,
  ) {
    if (!isPro) return 'Free';
    final rawDate = inTrial
        ? subscription?.trialEnd
        : subscription?.cancelAt ?? subscription?.currentPeriodEnd;
    final date = DateTime.tryParse(rawDate ?? '');
    return date == null
        ? 'Store managed'
        : DateFormat('MMMM d, y').format(date.toLocal());
  }
}

class _SubscriptionTopBar extends StatelessWidget {
  const _SubscriptionTopBar({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return SizedBox(
      height: AppSpacing.xxxl + AppSpacing.lg,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: AppSpacing.md),
              child: IconButton(
                onPressed: onBack,
                icon: Icon(
                  Icons.chevron_left,
                  size: AppSpacing.xxl,
                  color: colors.text,
                ),
              ),
            ),
          ),
          Text('Subscription', style: AppTypography.title3(colors.text)),
        ],
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.planLabel,
    required this.renewalLabel,
    required this.renewalValue,
    required this.price,
  });

  final String planLabel;
  final String renewalLabel;
  final String renewalValue;
  final String price;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border.all(color: colors.accent),
        borderRadius: AppRadii.brXl,
        boxShadow: [
          BoxShadow(
            color: colors.borderStrong,
            blurRadius: AppSpacing.xxl,
            offset: const Offset(0, AppSpacing.sm),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: colors.accent,
              borderRadius: AppRadii.brFull,
            ),
            child: Text(
              'PRO',
              style: AppTypography.overline(colors.bg),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text('Marginalia Pro', style: AppTypography.title2(colors.text)),
          const SizedBox(height: AppSpacing.xs),
          Text(
            planLabel,
            style: AppTypography.serif(
              AppTypography.label(colors.text2).copyWith(
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Divider(height: 1, color: colors.border),
          const SizedBox(height: AppSpacing.lg),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _PlanDatum(
                  label: renewalLabel,
                  value: renewalValue,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _PlanDatum(
                  label: 'PRICE',
                  value: price,
                  alignEnd: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PlanDatum extends StatelessWidget {
  const _PlanDatum({
    required this.label,
    required this.value,
    this.alignEnd = false,
  });

  final String label;
  final String value;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Column(
      crossAxisAlignment:
          alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.overline(colors.text3)),
        const SizedBox(height: AppSpacing.xs),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: alignEnd ? TextAlign.end : TextAlign.start,
          style: AppTypography.label(colors.text).copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _ActionGroup extends StatelessWidget {
  const _ActionGroup({required this.children});

  final List<_SubscriptionAction> children;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border.all(color: colors.border),
        borderRadius: AppRadii.brLg,
      ),
      child: Column(
        children: [
          for (var index = 0; index < children.length; index++) ...[
            children[index],
            if (index < children.length - 1)
              Padding(
                padding: const EdgeInsets.only(left: AppSpacing.lg),
                child: Divider(height: 1, color: colors.border),
              ),
          ],
        ],
      ),
    );
  }
}

class _SubscriptionAction extends StatelessWidget {
  const _SubscriptionAction({
    required this.title,
    this.subtitle,
    this.destructive = false,
    this.onTap,
  });

  final String title;
  final String? subtitle;
  final bool destructive;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final enabled = onTap != null;
    final titleColor = destructive
        ? colors.danger
        : enabled
            ? colors.text
            : colors.text3;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            children: [
              Expanded(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    minHeight: AppSpacing.xxxl,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTypography.label(titleColor).copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          subtitle!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.serif(
                            AppTypography.caption(colors.text3).copyWith(
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Icon(
                Icons.chevron_right,
                size: AppSpacing.xl,
                color: enabled ? colors.text3 : colors.border,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
