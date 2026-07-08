import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../../app/theme/tokens/colors.dart';
import '../../app/theme/tokens/radii.dart';
import '../../app/theme/tokens/spacing.dart';
import '../../app/theme/tokens/typography.dart';
import '../../core/widgets/app_snackbar.dart';
import '../../providers/auth_provider.dart';
import '../../providers/state/auth_state.dart';
import '../../providers/subscription_provider.dart';
import '../../screens/discovery/detail_shared.dart';
import '../../widgets/glass_panel.dart';

/// Marginalia Pro paywall. The purchase runs through the platform store via
/// RevenueCat (the store-legal path for digital goods); entitlement lands in
/// our backend through the RevenueCat webhook, and the app re-reads
/// /me/subscription as the source of truth.
class PaywallScreen extends ConsumerStatefulWidget {
  const PaywallScreen({super.key});

  @override
  ConsumerState<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends ConsumerState<PaywallScreen> {
  Package? _package;
  bool _loading = true;
  bool _buying = false;

  static const _benefits = [
    ('Unlimited library', 'No 3-book cap — shelve everything you read.'),
    ('Custom tags', 'Create your own tags beyond the seven built-ins.'),
    ('Early features', 'New reading tools land on Pro first.'),
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (!ProPurchases.available) {
      setState(() => _loading = false);
      return;
    }
    try {
      final auth = ref.read(authProvider);
      if (auth is AuthAuthenticated) {
        await ProPurchases.configure(auth.user.id);
      }
      final pkg = await ProPurchases.proPackage();
      if (mounted) setState(() => _package = pkg);
    } catch (_) {
      // fall through to the "unavailable" state below
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _buy() async {
    final pkg = _package;
    if (pkg == null) return;
    setState(() => _buying = true);
    try {
      final ok = await ProPurchases.buy(pkg);
      if (!mounted) return;
      if (ok) {
        // Entitlement reaches the backend via webhook — re-read our record.
        ref.invalidate(subscriptionProvider);
        showAppSnack(context, 'Welcome to Marginalia Pro!',
            type: SnackType.success);
        context.pop();
        return;
      }
    } catch (_) {
      if (mounted) {
        showAppSnack(context, 'The purchase didn’t go through — try again.',
            type: SnackType.error);
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
      showAppSnack(context, 'Purchases restored.', type: SnackType.success);
    } catch (_) {
      if (mounted) {
        showAppSnack(context, 'Nothing to restore on this account.',
            type: SnackType.info);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final sub = ref.watch(subscriptionProvider).valueOrNull;
    final isPro = sub?.isPro ?? false;

    return Scaffold(
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: colors.accentSoft,
              borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(AppRadii.xl)),
            ),
            padding: EdgeInsets.fromLTRB(
              AppSpacing.pageHorizontal,
              MediaQuery.paddingOf(context).top + AppSpacing.sm,
              AppSpacing.pageHorizontal,
              AppSpacing.xl,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleIconButton(
                  icon: Icons.chevron_left,
                  onTap: () => context.pop(),
                ),
                const SizedBox(height: AppSpacing.xl),
                Text('MARGINALIA', style: AppTypography.overline(colors.text3)),
                const SizedBox(height: AppSpacing.sm),
                Text('Pro', style: AppTypography.display(colors.text)),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'For readers whose shelves never stop growing.',
                  style: AppTypography.subtitle(colors.text2),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.pageHorizontal),
            child: GlassPanel(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final (title, detail) in _benefits) ...[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.check_circle_rounded,
                            size: 20, color: colors.accent),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(title,
                                  style: AppTypography.label(colors.text)
                                      .copyWith(
                                          fontWeight: FontWeight.w600)),
                              const SizedBox(height: AppSpacing.xs),
                              Text(detail,
                                  style:
                                      AppTypography.caption(colors.text2)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if ((title, detail) != _benefits.last)
                      const SizedBox(height: AppSpacing.lg),
                  ],
                  const SizedBox(height: AppSpacing.xl),
                  if (isPro)
                    Text(
                      'You’re on Pro — thank you for supporting Marginalia.',
                      textAlign: TextAlign.center,
                      style: AppTypography.subtitle(colors.text2),
                    )
                  else if (_loading)
                    Center(
                        child:
                            CircularProgressIndicator(color: colors.accent))
                  else if (!ProPurchases.available || _package == null)
                    Text(
                      'Purchases aren’t available in this build yet — the '
                      'store isn’t configured. (Dev builds need the '
                      'RevenueCat key via --dart-define.)',
                      textAlign: TextAlign.center,
                      style: AppTypography.caption(colors.text3),
                    )
                  else ...[
                    FilledButton(
                      onPressed: _buying ? null : _buy,
                      style: FilledButton.styleFrom(
                        backgroundColor: colors.accent,
                        foregroundColor: colors.bg,
                        padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.md),
                        shape: RoundedRectangleBorder(
                            borderRadius: AppRadii.brMd),
                      ),
                      child: Text(
                        _buying
                            ? 'Opening the store…'
                            : 'Go Pro — ${_package!.storeProduct.priceString}'
                                '/${_package!.packageType == PackageType.annual ? 'year' : 'month'}',
                        style: AppTypography.label(colors.bg)
                            .copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Center(
                      child: GestureDetector(
                        onTap: _restore,
                        child: Text('Restore purchases',
                            style: AppTypography.label(colors.text2)),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
