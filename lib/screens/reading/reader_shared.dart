import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes.dart';
import '../../app/theme/tokens/colors.dart';
import '../../app/theme/tokens/radii.dart';
import '../../app/theme/tokens/spacing.dart';
import '../../app/theme/tokens/typography.dart';
import '../../widgets/tag_picker_sheet.dart';
import '../../widgets/setting/typography_sheet.dart';

/// Platform-neutral reader pieces shared by the mobile reader
/// (reading_screen.dart, WebView host) and the web reader
/// (reading_screen_web.dart, iframe host). NO dart:io in here.

/// What the progress bar shows: a fraction (0–100) and a left-hand label.
class ReaderProgress {
  const ReaderProgress(this.pct, this.label);
  final double pct;
  final String label;
}

/// Back · centered book title · "Aa" type control. Title is centered with a
/// Stack so the asymmetric side controls don't push it off-axis.
class ReaderTopBar extends StatelessWidget {
  const ReaderTopBar({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.pageHorizontal,
        vertical: AppSpacing.sm,
      ),
      child: SizedBox(
        height: 36,
        child: Stack(
          children: [
            // Inset past the side controls so a long title ellipsizes between
            // them instead of running underneath the back arrow / "Aa".
            Align(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: AppSpacing.xxxl),
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: AppTypography.label(colors.text2),
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => context.canPop()
                    ? context.pop()
                    : context.go(Routes.library),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xs),
                  child: Icon(
                    Icons.arrow_back_ios_new,
                    size: 18,
                    color: colors.text,
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => showTypographySheet(context),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xs),
                  child: Text('Aa', style: AppTypography.title3(colors.text)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Footer navigation for the paginated EPUB reader: ‹ prev · chapter progress
/// bar + "Chapter X/Y" + N% · next ›.
class PagedNavBar extends StatelessWidget {
  const PagedNavBar({
    super.key,
    required this.pct,
    required this.label,
    required this.onPrev,
    required this.onNext,
  });

  final double pct;
  final String label;
  final VoidCallback? onPrev;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.lg,
      ),
      child: Row(
        children: [
          _NavArrow(icon: Icons.chevron_left, onTap: onPrev),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: AppRadii.brFull,
                    child: SizedBox(
                      height: 2,
                      child: Stack(
                        children: [
                          Positioned.fill(
                              child: ColoredBox(color: colors.border)),
                          FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: (pct / 100).clamp(0, 1).toDouble(),
                            child: ColoredBox(color: colors.accent),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.caption(colors.text3),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text('${pct.round()}%',
                          style: AppTypography.caption(colors.text3)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          _NavArrow(icon: Icons.chevron_right, onTap: onNext),
        ],
      ),
    );
  }
}

/// A round page-turn button; dimmed + inert until the book is ready.
class _NavArrow extends StatelessWidget {
  const _NavArrow({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final enabled = onTap != null;
    return Material(
      color: colors.surface2,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Icon(
            icon,
            size: 24,
            color: enabled ? colors.text : colors.text3,
          ),
        ),
      ),
    );
  }
}

/// Floating highlight palette (Figma 237:17): dark inverted-ink pill with five
/// quick-tag color dots (the first five system tags) · hairline divider ·
/// Note / Tag / Copy. One dot tap = highlight saved with that tag, no sheet.
class HighlightPalette extends StatelessWidget {
  const HighlightPalette({
    super.key,
    required this.onQuickTag,
    required this.onNote,
    required this.onTag,
    required this.onCopy,
  });

  static const double height = 60; // Figma: 22px dots + 19px top/bottom

  final ValueChanged<String> onQuickTag;
  final VoidCallback onNote;
  final VoidCallback onTag;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      decoration: BoxDecoration(
        color: colors.text, // inverted ink, same trick as the primary button
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final tag in kTagNames.take(5)) ...[
            GestureDetector(
              onTap: () => onQuickTag(tag),
              child: Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: AppColors.forTag(tag),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            const SizedBox(width: 6), // Figma: 28px pitch on 22px dots
          ],
          const SizedBox(width: AppSpacing.sm),
          Container(width: 1, height: 24, color: colors.bg),
          const SizedBox(width: AppSpacing.xs),
          _PaletteAction(label: 'Note', onTap: onNote),
          _PaletteAction(label: 'Tag', onTap: onTag),
          _PaletteAction(label: 'Copy', onTap: onCopy),
        ],
      ),
    );
  }
}

class _PaletteAction extends StatelessWidget {
  const _PaletteAction({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.md,
        ),
        // Figma 237:24-26 — Inter Medium 13 in the page (bg) color.
        child: Text(
          label,
          style: AppTypography.sans(TextStyle(
            color: colors.bg,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          )),
        ),
      ),
    );
  }
}

/// Icon + one-liner center state (load failures, unsupported formats…).
class ReaderMessage extends StatelessWidget {
  const ReaderMessage({super.key, required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Center(
      child: Padding(
        padding:
            const EdgeInsets.symmetric(horizontal: AppSpacing.pageHorizontal),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 40, color: colors.text3),
            const SizedBox(height: AppSpacing.lg),
            Text(text,
                textAlign: TextAlign.center,
                style: AppTypography.subtitle(colors.text2)),
          ],
        ),
      ),
    );
  }
}

/// Center error state with retry.
class ReaderError extends StatelessWidget {
  const ReaderError({super.key, required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pageHorizontal),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_outlined, size: 40, color: colors.text3),
            const SizedBox(height: AppSpacing.lg),
            Text("Couldn't open this book.",
                textAlign: TextAlign.center,
                style: AppTypography.title3(colors.text)),
            const SizedBox(height: AppSpacing.sm),
            Text(message,
                textAlign: TextAlign.center,
                style: AppTypography.caption(colors.text2)),
            const SizedBox(height: AppSpacing.xl),
            OutlinedButton(onPressed: onRetry, child: const Text('Try again')),
          ],
        ),
      ),
    );
  }
}

/// A [Color] as an opaque CSS `#rrggbb` for epub.js theme overrides.
String cssHex(Color c) =>
    '#${(c.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}';

// ── Cursor (reading position) helpers ───────────────────────────────────────
// The backend stores `cursor` as opaque JSONB; we own the shape per format.

Map<String, dynamic>? decodeCursor(String? raw) {
  if (raw == null || raw.isEmpty) return null;
  try {
    final v = jsonDecode(raw);
    return v is Map<String, dynamic> ? v : null;
  } catch (_) {
    return null;
  }
}

int cursorPage(String? cursor) {
  final p = decodeCursor(cursor)?['page'];
  if (p is num && p >= 1) return p.toInt();
  return 1;
}

String? cursorCfi(String? cursor) {
  final m = decodeCursor(cursor);
  // Only resume from CFIs we minted with epub.js. Old `{"type":"epub"}`
  // cursors came from epub_view, whose CFI generator differs — feeding one to
  // epub.js can crash its parser mid-display.
  if (m?['type'] != 'epubjs') return null;
  final c = m?['cfi'];
  return (c is String && c.isNotEmpty) ? c : null;
}
