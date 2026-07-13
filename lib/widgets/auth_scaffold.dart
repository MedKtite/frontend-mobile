import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../app/theme/tokens/colors.dart';
import '../app/theme/tokens/spacing.dart';
import '../app/theme/tokens/typography.dart';

/// Shared shell for the auth screens: back chevron, serif title, italic
/// subtitle, the form [body], and an optional [footer] pinned to the bottom.
///
/// The form scrolls when the keyboard shrinks the viewport; the footer stays
/// anchored at the bottom otherwise (scroll + min-height + Spacer pattern).
class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    super.key,
    this.title,
    this.subtitle,
    required this.body,
    this.footer,
    this.onBack,
  });

  /// Rendered above [body] when set; leave null to place the heading inside
  /// the body instead (e.g. within the glass form card).
  final String? title;
  final String? subtitle;
  final Widget body;
  final Widget? footer;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Scaffold(
      // Transparent (theme default) — the shared token background is the page
      // surface behind the glass form.
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.pageHorizontal,
          ),
          child: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AuthBackButton(onPressed: onBack),
                      const SizedBox(height: AppSpacing.xl),
                      if (title != null) ...[
                        Text(title!, style: AppTypography.title1(colors.text)),
                        const SizedBox(height: AppSpacing.sm),
                      ],
                      if (subtitle != null)
                        Text(subtitle!,
                            style: AppTypography.subtitle(colors.text2)),
                      if (title != null || subtitle != null)
                        const SizedBox(height: AppSpacing.xxxl),
                      // Twin spacers center the form between the back chevron
                      // and the footer; they collapse when the keyboard
                      // shrinks the viewport and the scroll view takes over.
                      const Spacer(),
                      body,
                      const Spacer(),
                      if (footer != null) ...[
                        const SizedBox(height: AppSpacing.xl),
                        footer!,
                      ],
                      const SizedBox(height: AppSpacing.md),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Flush-left back chevron with a 44×44 tap target.
class AuthBackButton extends StatelessWidget {
  const AuthBackButton({super.key, this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Align(
      alignment: Alignment.centerLeft,
      child: IconButton(
        onPressed: onPressed,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
        alignment: Alignment.centerLeft,
        icon: Icon(Icons.arrow_back_ios_new, size: 20, color: colors.text),
      ),
    );
  }
}

/// Single centered tappable link. [muted] renders it as inactive (`text3`) —
/// e.g. a "Resend in 30s" countdown before it becomes active.
class AuthTextLink extends StatelessWidget {
  const AuthTextLink({
    super.key,
    required this.label,
    this.onTap,
    this.muted = false,
  });

  final String label;
  final VoidCallback? onTap;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Center(
      child: GestureDetector(
        onTap: onTap,
        child: Text(
          label,
          style: AppTypography.label(muted ? colors.text3 : colors.accent)
              .copyWith(fontWeight: muted ? FontWeight.w500 : FontWeight.w600),
        ),
      ),
    );
  }
}

/// "─── OR ───" separator between the primary CTA and social sign-in.
class OrDivider extends StatelessWidget {
  const OrDivider({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Row(
      children: [
        Expanded(child: Divider(color: colors.border, height: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Text('OR', style: AppTypography.overline(colors.text3)),
        ),
        Expanded(child: Divider(color: colors.border, height: 1)),
      ],
    );
  }
}


class SocialAuthButton extends StatelessWidget {
  const SocialAuthButton({
    super.key,
    required this.glyph,
    required this.label,
    this.onPressed,
    this.monochrome = true,
  });

  final String glyph;
  final String label;
  final VoidCallback? onPressed;

  /// Monochrome brands (X) are tinted to ink so they adapt to dark mode;
  /// multicolor brands (Google's four-color G) render untouched — the brand
  /// mark is what makes the button read as a social sign-in.
  final bool monochrome;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onPressed,
        // Solid surface backing so the button reads as a card even over the
        // glassy auth backdrop.
        style: OutlinedButton.styleFrom(backgroundColor: colors.surface),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              'assets/icons/social/$glyph.svg',
              width: 18,
              height: 18,
              colorFilter: monochrome
                  ? ColorFilter.mode(colors.text, BlendMode.srcIn)
                  : null,
            ),
            const SizedBox(width: AppSpacing.md),
            Text(
              label,
              style: AppTypography.label(colors.text)
                  .copyWith(fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}

/// Full-width inverted-ink CTA; shows a spinner (and disables) while [loading].
class AuthPrimaryButton extends StatelessWidget {
  const AuthPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: loading ? null : onPressed,
        child: loading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: colors.bg,
                ),
              )
            : Text(label),
      ),
    );
  }
}

/// Centered "prompt action" footer, e.g. "Don't have an account? Register".
class AuthFooterLink extends StatelessWidget {
  const AuthFooterLink({
    super.key,
    required this.prompt,
    required this.action,
    required this.onTap,
  });

  final String prompt;
  final String action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('$prompt ', style: AppTypography.label(colors.text2)),
        GestureDetector(
          onTap: onTap,
          child: Text(
            action,
            style: AppTypography.label(colors.accent)
                .copyWith(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
