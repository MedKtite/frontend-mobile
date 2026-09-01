import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../app/theme/tokens/colors.dart';
import '../app/theme/tokens/radii.dart';
import '../app/theme/tokens/spacing.dart';
import '../app/theme/tokens/typography.dart';
import '../core/dio_client.dart';
import 'app_progress_ring.dart';


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
    this.processingStatus,
    this.progressPct,
  });

  final String title;
  final String author;
  final Color bg;
  final Color fg;
  final String? coverUrl;
  final double width;
  final bool bookmarked;
  final String? processingStatus;
  final double? progressPct;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final hasUrl = coverUrl != null && coverUrl!.isNotEmpty;
    final isProcessing =
        processingStatus == 'pending' || processingStatus == 'processing';
    final isFailed = processingStatus == 'failed';
    final showProgress =
        progressPct != null && progressPct! > 0 && progressPct! < 100;

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
      child: Stack(
        fit: StackFit.expand,
        children: [
          hasUrl
              ? Image.network(
                  coverUrl!,
                  width: width,
                  height: width * 1.5,
                  fit: BoxFit.cover,
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
          if (isProcessing)
            Container(
              color: Colors.black.withValues(alpha: 0.62),
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AppProgressRing(
                    size: (width * 0.35).clamp(22.0, 36.0),
                    strokeWidth: 1.5,
                    fillColor: Colors.white,
                    trackColor: Colors.white24,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Preparing…',
                    textAlign: TextAlign.center,
                    style: AppTypography.caption(Colors.white).copyWith(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          if (isFailed)
            Container(
              color: Colors.black.withValues(alpha: 0.72),
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline_rounded,
                    color: Color(0xFFEF5350),
                    size: 22,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Failed',
                    textAlign: TextAlign.center,
                    style: AppTypography.caption(const Color(0xFFEF5350))
                        .copyWith(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );

    if (!bookmarked && !showProgress) return cover;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        cover,
        if (bookmarked)
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
        if (showProgress)
          Positioned(
            bottom: 6,
            right: 6,
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: colors.surface.withValues(alpha: 0.92),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: AppProgressRing.fromPercent(
                percent: progressPct,
                size: (width * 0.28).clamp(18.0, 26.0),
                strokeWidth: 1.5,
              ),
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
  if (kIsWeb) {
    return '${DioFactory.defaultBaseUrl}/covers?url=${Uri.encodeQueryComponent(raw)}';
  }
  return raw;
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
