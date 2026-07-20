import 'package:flutter/material.dart';

import '../app/theme/tokens/colors.dart';
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
    this.onTap,
    this.onLongPress,
  });

  static const double cardWidth = AppSpacing.xxxl * 2 + AppSpacing.lg;

  final String title;
  final String? author;
  final String? coverUrl;
  final double width;
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
              child: BookCover(
                title: title,
                author: author ?? '',
                bg: colors.accent,
                fg: colors.surface,
                coverUrl: coverUrl,
                width: width,
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
