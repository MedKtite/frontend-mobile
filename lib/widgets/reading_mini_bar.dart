import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../app/routes.dart';
import '../app/theme/tokens/colors.dart';
import '../app/theme/tokens/radii.dart';
import '../app/theme/tokens/spacing.dart';
import '../app/theme/tokens/typography.dart';
import '../providers/reading_mini_provider.dart';
import '../widgets/book_cover.dart';

/// "Continue reading" mini bar — the text sibling of the audio mini player
/// (same material: surface bar, cover, title, progress line along the top).
/// Appears when the reader is left mid-book; tap → back to the page, swipe
/// sideways → dismiss.
class ReadingMiniBar extends ConsumerWidget {
  const ReadingMiniBar({super.key});

  static const double _height = 58;
  static const double _cover = 44;
  static const double _disc = 36;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(readingMiniProvider);
    if (session == null) return const SizedBox.shrink();

    final colors = context.appColors;
    final book = session.book;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.sm),
      child: Dismissible(
        key: ValueKey('reading-mini-${book.id}'),
        direction: DismissDirection.horizontal,
        onDismissed: (_) =>
            ref.read(readingMiniProvider.notifier).state = null,
        child: GestureDetector(
          onTap: () => context.push(Routes.readingPath(book.id), extra: book),
          child: Container(
            height: _height,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: AppRadii.brLg,
              border: Border.all(color: colors.border),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.16),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: FractionallySizedBox(
                    widthFactor: (session.pct / 100).clamp(0.0, 1.0),
                    child: Container(height: 2, color: colors.accent),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.sm - 1),
                  child: Row(
                    children: [
                      SizedBox(
                        width: _cover,
                        height: _cover,
                        child: ClipRRect(
                          borderRadius: AppRadii.brXs,
                          child: _MiniCover(
                            title: book.title,
                            coverUrl: proxiedCoverUrl(book.coverUrl),
                            bg: coverColorFromHex(book.coverDominantColor),
                            fg: coverFgFor(book.coverDominantColor),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              book.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.label(colors.text)
                                  .copyWith(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${session.label} · ${session.pct.round()}%',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.caption(colors.text3)
                                  .copyWith(fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Container(
                        width: _disc,
                        height: _disc,
                        decoration: BoxDecoration(
                          color: colors.text,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.menu_book_rounded,
                            size: 18, color: colors.bg),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 44×44 cover thumb — image when we have one, tinted initial panel when not.
class _MiniCover extends StatelessWidget {
  const _MiniCover({
    required this.title,
    required this.coverUrl,
    required this.bg,
    required this.fg,
  });

  final String title;
  final String? coverUrl;
  final Color bg;
  final Color fg;

  @override
  Widget build(BuildContext context) {
    final fallback = ColoredBox(
      color: bg,
      child: Center(
        child: Text(
          title.isEmpty ? '?' : title[0].toUpperCase(),
          style: AppTypography.serif(TextStyle(
            color: fg,
            fontSize: 16,
            fontStyle: FontStyle.italic,
          )),
        ),
      ),
    );
    if (coverUrl == null || coverUrl!.isEmpty) return fallback;
    return Image.network(
      coverUrl!,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => fallback,
    );
  }
}
