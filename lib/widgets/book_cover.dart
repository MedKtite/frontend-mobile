import 'package:flutter/material.dart';

import '../app/theme/tokens/colors.dart';
import '../app/theme/tokens/radii.dart';
import '../app/theme/tokens/typography.dart';
import '../core/dio_client.dart';

/// A book cover. Shows the real cover image when [coverUrl] is given; otherwise
/// (or while loading / on error) falls back to a flat color panel with centered
/// type (design-system.md §8). `bg`/`fg` are per-book content colors; internal
/// metrics scale with [width] since the cover is artwork.
///
/// The cover helpers that feed this widget — [proxiedCoverUrl] for the image URL
/// and [coverColorFromHex] / [coverFgFor] for the fallback colors — live in this
/// same file so the whole cover concern sits in one place.
class BookCover extends StatelessWidget {
  const BookCover({
    super.key,
    required this.title,
    required this.author,
    required this.bg,
    required this.fg,
    this.coverUrl,
    this.width = 88,
    this.bookmarked = false,
  });

  final String title;
  final String author;
  final Color bg;
  final Color fg;
  final String? coverUrl;
  final double width;
  final bool bookmarked;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final hasUrl = coverUrl != null && coverUrl!.isNotEmpty;

    final cover = Container(
      width: width,
      height: width * 1.5,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: AppRadii.brXs,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: hasUrl
          ? Image.network(
              coverUrl!,
              width: width,
              height: width * 1.5,
              fit: BoxFit.cover,
              // While downloading: just the quiet bg panel (no text flash);
              // the real cover fades in on arrival. The type panel is
              // reserved for covers that genuinely don't exist (error).
              frameBuilder: (_, child, frame, wasSync) => wasSync
                  ? child
                  : AnimatedOpacity(
                      opacity: frame == null ? 0 : 1,
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOut,
                      child: child,
                    ),
              errorBuilder: (_, __, ___) => _typePanel(),
            )
          : _typePanel(),
    );

    if (!bookmarked) return cover;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        cover,
        Positioned(
          top: 8,
          right: 8,
          child: Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: colors.surface,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.bookmark_outline, size: 14, color: colors.text),
          ),
        ),
      ],
    );
  }

  Widget _typePanel() => Padding(
        padding: EdgeInsets.all(width * 0.12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.serif(TextStyle(
                color: fg,
                fontSize: width * 0.19,
                height: 1.1,
                fontWeight: FontWeight.w500,
                fontStyle: FontStyle.italic,
              )),
            ),
            SizedBox(height: width * 0.06),
            Text(
              author,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.serif(TextStyle(
                color: fg.withValues(alpha: 0.82),
                fontSize: width * 0.12,
                fontStyle: FontStyle.italic,
              )),
            ),
          ],
        ),
      );
}

/// Wraps a raw book-cover URL in the backend cover proxy (`/covers?url=`) so the
/// device loads it via the server, which can reach Google's image hosts even if
/// the device can't. Returns null when there's no URL.
String? proxiedCoverUrl(String? raw) {
  if (raw == null || raw.isEmpty) return null;
  return '${DioFactory.defaultBaseUrl}/covers?url=${Uri.encodeQueryComponent(raw)}';
}

/// Parses a backend `coverDominantColor` (#RRGGBB) into a [Color], falling back
/// to a neutral navy. Cover colors are per-book content, not design tokens.
Color coverColorFromHex(String? hex) {
  if (hex == null) return const Color(0xFF34507A);
  var h = hex.replaceFirst('#', '');
  if (h.length == 6) h = 'FF$h';
  final value = int.tryParse(h, radix: 16);
  return value == null ? const Color(0xFF34507A) : Color(value);
}

/// A readable foreground (deep ink or cream) for a cover [hex] background.
Color coverFgFor(String? hex) => coverColorFromHex(hex).computeLuminance() > 0.5
    ? const Color(0xFF2A2618)
    : const Color(0xFFEDE9E0);
