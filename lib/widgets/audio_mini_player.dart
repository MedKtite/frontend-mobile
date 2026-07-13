import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:just_audio/just_audio.dart';

import '../app/routes.dart';
import '../app/theme/tokens/colors.dart';
import '../app/theme/tokens/radii.dart';
import '../app/theme/tokens/spacing.dart';
import '../app/theme/tokens/typography.dart';
import '../providers/audio_player_provider.dart';
import '../widgets/book_cover.dart';

/// Audio mini player (Figma 296:83) — docked by AppShell just above the glass
/// nav bar while a session is active. Cover · title · chapter/time · pause,
/// with a thin accent progress line along the top edge. Tap → the full
/// player; swipe it away → stop the session.
class AudioMiniPlayer extends ConsumerWidget {
  const AudioMiniPlayer({super.key});

  static const double _height = 58; // Figma 296:83
  static const double _cover = 44;
  static const double _disc = 36;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(audioPlayerProvider);
    if (session == null) return const SizedBox.shrink();

    final colors = context.appColors;
    final ctrl = ref.read(audioPlayerProvider.notifier);
    final book = session.book;

    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.sm),
      child: Dismissible(
        key: ValueKey('mini-${book.id}'),
        direction: DismissDirection.horizontal,
        onDismissed: (_) => ctrl.stop(),
        child: GestureDetector(
          onTap: () =>
              context.push(Routes.listeningPath(book.id), extra: book),
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
                // Thin accent progress line hugging the top edge (Figma).
                StreamBuilder<Duration>(
                  stream: ctrl.player.positionStream,
                  builder: (context, snap) {
                    final sec = ctrl.globalSec(snap.data ?? Duration.zero);
                    final fraction = session.totalSecs <= 0
                        ? 0.0
                        : (sec / session.totalSecs).clamp(0.0, 1.0);
                    return Align(
                      alignment: Alignment.topLeft,
                      child: FractionallySizedBox(
                        widthFactor: fraction,
                        child: Container(height: 2, color: colors.accent),
                      ),
                    );
                  },
                ),
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.sm - 1), // Figma 7
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
                            StreamBuilder<Duration>(
                              stream: ctrl.player.positionStream,
                              builder: (context, snap) {
                                final sec = ctrl
                                    .globalSec(snap.data ?? Duration.zero);
                                final chapter = ctrl.sectionTitle();
                                return Text(
                                  (chapter != null && chapter.isNotEmpty)
                                      ? chapter
                                      : '${_fmt(sec)} of ${_fmt(session.totalSecs)}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTypography.caption(colors.text3)
                                      .copyWith(fontSize: 11),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      StreamBuilder<PlayerState>(
                        stream: ctrl.player.playerStateStream,
                        builder: (context, snap) {
                          final playing = snap.data?.playing ?? false;
                          return GestureDetector(
                            onTap: ctrl.toggle,
                            child: Container(
                              width: _disc,
                              height: _disc,
                              decoration: BoxDecoration(
                                color: colors.text,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                playing
                                    ? Icons.pause_rounded
                                    : Icons.play_arrow_rounded,
                                size: 20,
                                color: colors.bg,
                              ),
                            ),
                          );
                        },
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

  static String _fmt(double sec) {
    final d = Duration(milliseconds: (sec * 1000).round());
    final h = d.inHours;
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return h > 0 ? '$h:$m:$s' : '$m:$s';
  }
}

/// 44×44 cover thumb — image when we have one, tinted initial panel when not
/// (BookCover is 2:3-fixed, too tall for the square slot the Figma uses).
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
