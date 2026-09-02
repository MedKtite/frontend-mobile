import 'package:flutter/material.dart';

import '../app/theme/tokens/colors.dart';
import '../app/theme/tokens/radii.dart';
import '../app/theme/tokens/spacing.dart';
import '../app/theme/tokens/typography.dart';
import 'book_cover.dart';

/// Shared presentation for a book cover and its supporting metadata.
class BookCard extends StatelessWidget {
  const BookCard({
    super.key,
    required this.title,
    this.author,
    this.coverUrl,
    this.width = cardWidth,
    this.processingStatus,
    this.progressPct,
    this.badge,
    this.onTap,
    this.onLongPress,
  });

  static const double cardWidth = AppSpacing.xxxl * 2 + AppSpacing.lg;

  final String title;
  final String? author;
  final String? coverUrl;
  final double width;
  final String? processingStatus;
  final double? progressPct;
  final String? badge;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final hasAuthor = author != null && author!.isNotEmpty;

    return SizedBox(
      width: width,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: width,
            height: width * 1.5,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onTap,
              onLongPress: onLongPress,
              child: Stack(
                children: [
                  BookCover(
                    title: title,
                    author: author ?? '',
                    bg: colors.accent,
                    fg: colors.surface,
                    coverUrl: coverUrl,
                    width: width,
                    processingStatus: processingStatus,
                    progressPct: progressPct,
                  ),
                  if (badge != null && badge!.isNotEmpty)
                    Positioned(
                      top: 6,
                      left: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: colors.text.withValues(alpha: 0.78),
                          borderRadius: BorderRadius.circular(AppRadii.xs),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.16),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.upload_file_rounded,
                              size: 10,
                              color: colors.bg,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              badge!.toUpperCase(),
                              style: AppTypography.caption(colors.bg).copyWith(
                                fontSize: 8.5,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.label(colors.text),
          ),
          if (hasAuthor) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              author!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.caption(colors.text2),
            ),
          ],
        ],
      ),
    );
  }
}
