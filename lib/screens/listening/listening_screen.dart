import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:just_audio/just_audio.dart';

import '../../app/theme/tokens/colors.dart';
import '../../app/theme/tokens/radii.dart';
import '../../app/theme/tokens/spacing.dart';
import '../../app/theme/tokens/typography.dart';
import '../../core/dio_client.dart';
import '../../core/widgets/app_snackbar.dart';
import '../../models/book.dart';
import '../../models/book_update_request.dart';
import '../../models/highlight_create_request.dart';
import '../../providers/audio_player_provider.dart';
import '../../providers/book_highlights_provider.dart';
import '../../providers/state/audio_state.dart';
import '../../providers/library_provider.dart';
import '../../services/backend/book_service.dart';
import '../../services/backend/highlight_service.dart';
import '../../widgets/book_cover.dart';
import '../../widgets/tag_picker_sheet.dart';


class ListeningScreen extends ConsumerStatefulWidget {
  const ListeningScreen({super.key, required this.bookId, this.initialBook});

  final String bookId;
  final Book? initialBook;

  @override
  ConsumerState<ListeningScreen> createState() => _ListeningScreenState();
}

class _ListeningScreenState extends ConsumerState<ListeningScreen> {
  String? _error;
  late double _speed;
  late bool _muted;

  static const _speeds = [0.8, 1.0, 1.2, 1.5, 2.0];

  AudioPlayerController get _ctrl => ref.read(audioPlayerProvider.notifier);
  AudioPlayer get _player => _ctrl.player;

  @override
  void initState() {
    super.initState();
    _speed = _player.speed;
    _muted = _player.volume == 0;
    // Provider state can't change during the first build — defer the load.
    Future.microtask(_load);
  }

  Future<void> _load() async {
    final err = await _ctrl.load(widget.bookId, widget.initialBook);
    if (mounted && err != null) setState(() => _error = err);
  }

  void _cycleSpeed() {
    final i = _speeds.indexOf(_speed);
    final next = _speeds[(i + 1) % _speeds.length];
    setState(() => _speed = next);
    _player.setSpeed(next);
  }

  Future<void> _tagMoment() async {
    final sec = _ctrl.globalSec(_player.position);
    final stamp = _fmt(_dur(sec));
    final tag =
        await showTagPickerSheet(context, passage: 'Moment at $stamp');
    if (tag == null || !mounted) return;
    try {
      await ref.read(highlightServiceProvider).create(HighlightCreateRequest(
            bookId: widget.bookId,
            colorTag: tag,
            audioStartSec: sec,
          ));
      ref.invalidate(bookHighlightsProvider(widget.bookId));
      if (mounted) {
        showAppSnack(context, 'Moment tagged at $stamp',
            type: SnackType.success);
      }
    } on ApiError catch (e) {
      if (mounted) showAppSnack(context, e.message, type: SnackType.error);
    }
  }

  Future<void> _markFinished() async {
    try {
      await _ctrl.stop();
      await ref.read(bookServiceProvider).update(
          widget.bookId, const BookUpdateRequest(status: 'finished'));
      ref.invalidate(libraryBooksProvider);
      if (mounted) {
        showAppSnack(context, 'Marked as finished', type: SnackType.success);
        context.pop();
      }
    } on ApiError catch (e) {
      if (mounted) showAppSnack(context, e.message, type: SnackType.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final session = ref.watch(audioPlayerProvider);
    final mine = session != null && session.book.id == widget.bookId;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.md,
                AppSpacing.lg,
                0,
              ),
              child: Row(
                children: [
                  // Minimize — playback continues behind the mini player.
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Icon(Icons.keyboard_arrow_down_rounded,
                        size: 28, color: colors.text2),
                  ),
                  Expanded(
                    child: Text(
                      'NOW LISTENING',
                      textAlign: TextAlign.center,
                      style: AppTypography.overline(colors.text3),
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: Icon(Icons.more_horiz,
                        size: 24, color: colors.text2),
                    color: colors.surface,
                    onSelected: (v) {
                      if (v == 'finished') _markFinished();
                    },
                    itemBuilder: (_) => [
                      PopupMenuItem(
                        value: 'finished',
                        child: Text('Mark as finished',
                            style: AppTypography.label(colors.text)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: _error != null
                  ? _message(colors, _error!)
                  : !mine
                      ? Center(
                          child:
                              CircularProgressIndicator(color: colors.accent))
                      : _playerBody(session, colors),
            ),
          ],
        ),
      ),
    );
  }

  Widget _message(AppColorsExtension colors, String text) => Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.pageHorizontal),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.headphones_outlined, size: 40, color: colors.text3),
              const SizedBox(height: AppSpacing.lg),
              Text(text,
                  textAlign: TextAlign.center,
                  style: AppTypography.subtitle(colors.text2)),
            ],
          ),
        ),
      );

  Widget _playerBody(AudioSession session, AppColorsExtension colors) {
    final book = session.book;
    final totalSecs = session.totalSecs;
    final isLibrivox = session.librivox != null;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.pageHorizontal,
        AppSpacing.xl,
        AppSpacing.pageHorizontal,
        AppSpacing.xl,
      ),
      child: Column(
        children: [
          // Large cover with the deep Figma shadow (0 14 30 @22%).
          Container(
            decoration: BoxDecoration(
              borderRadius: AppRadii.brXs,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.22),
                  blurRadius: 30,
                  offset: const Offset(0, 14),
                ),
              ],
            ),
            child: BookCover(
              title: book.title,
              author: book.author ?? '',
              bg: coverColorFromHex(book.coverDominantColor),
              fg: coverFgFor(book.coverDominantColor),
              coverUrl: proxiedCoverUrl(book.coverUrl),
              width: 226,
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          Text(book.title,
              textAlign: TextAlign.center,
              style: AppTypography.title2(colors.text)),
          const SizedBox(height: AppSpacing.sm),
          Text(
            [
              if (book.author != null) book.author!,
              if (book.narrator != null)
                'read by ${book.narrator!}'
              else if (isLibrivox)
                'a free LibriVox recording',
            ].join(' · '),
            textAlign: TextAlign.center,
            style: AppTypography.serif(TextStyle(
              color: colors.text2,
              fontSize: 13,
              fontStyle: FontStyle.italic,
            )),
          ),
          const SizedBox(height: AppSpacing.xs),
          StreamBuilder<Duration>(
            stream: _player.positionStream,
            builder: (context, snap) {
              final sec = _ctrl.globalSec(snap.data ?? Duration.zero);
              final chapter = _ctrl.sectionTitle();
              return Text(
                [
                  if (chapter != null && chapter.isNotEmpty) chapter,
                  '${_fmt(_dur(sec))} of ${_fmt(_dur(totalSecs))}',
                ].join(' — '),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.caption(colors.text3),
              );
            },
          ),
          const SizedBox(height: AppSpacing.xl),
          StreamBuilder<Duration>(
            stream: _player.positionStream,
            builder: (context, snap) {
              final sec = _ctrl.globalSec(snap.data ?? Duration.zero);
              return Column(
                children: [
                  _AudioProgressBar(
                    positionSecs: sec,
                    totalSecs: totalSecs,
                    onSeekSec: (s) {
                      _ctrl.seekGlobal(s);
                      _ctrl.saveProgress();
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_fmt(_dur(sec)),
                          style: AppTypography.caption(colors.text2)),
                      Text('-${_fmt(_dur(max(0, totalSecs - sec)))}',
                          style: AppTypography.caption(colors.text3)),
                    ],
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: AppSpacing.xl),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Speed pill (Figma "1.2×").
              GestureDetector(
                onTap: _cycleSpeed,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.xs + 2,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: AppRadii.brFull,
                    border: Border.all(color: colors.border),
                  ),
                  child: Text(
                    '${_speed % 1 == 0 ? _speed.toStringAsFixed(0) : _speed.toStringAsFixed(1)}×',
                    style: AppTypography.label(colors.text)
                        .copyWith(fontWeight: FontWeight.w500),
                  ),
                ),
              ),
              _SkipButton(
                icon: Icons.replay_rounded,
                label: '15',
                onTap: () => _ctrl.seekBy(-15),
              ),
              // Big play/pause — ink disc with the Figma drop shadow.
              StreamBuilder<PlayerState>(
                stream: _player.playerStateStream,
                builder: (context, snap) {
                  final playing = snap.data?.playing ?? false;
                  return GestureDetector(
                    onTap: _ctrl.toggle,
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: colors.text,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.18),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Icon(
                        playing
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        size: 30,
                        color: colors.bg,
                      ),
                    ),
                  );
                },
              ),
              _SkipButton(
                icon: Icons.refresh_rounded,
                label: '30',
                onTap: () => _ctrl.seekBy(30),
              ),
              GestureDetector(
                onTap: () {
                  setState(() => _muted = !_muted);
                  _player.setVolume(_muted ? 0 : 1);
                },
                child: Icon(
                  _muted
                      ? Icons.volume_off_rounded
                      : Icons.volume_up_rounded,
                  size: 24,
                  color: colors.text2,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xxl),
          GestureDetector(
            onTap: _tagMoment,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: colors.surface,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Center(child: _TagDots()),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text('TAG THIS MOMENT',
              style: AppTypography.overline(colors.text3)),
        ],
      ),
    );
  }
}

String _fmt(Duration d) {
  final h = d.inHours;
  final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
  final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
  return h > 0 ? '$h:$m:$s' : '$m:$s';
}

Duration _dur(double sec) => Duration(milliseconds: (sec * 1000).round());

/// Skip control — circular arrow with the second count beneath (Figma ↺15/↻30).
class _SkipButton extends StatelessWidget {
  const _SkipButton({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 44,
        height: 44,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 24, color: colors.text),
            Text(
              label,
              style: AppTypography.caption(colors.text)
                  .copyWith(fontSize: 9, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

/// 2×2 tag-colored dots — the "tag this moment" glyph (matches the nav icon).
class _TagDots extends StatelessWidget {
  const _TagDots();

  static const _tones = [
    AppColors.tagUrgent,
    AppColors.tagCurious,
    AppColors.tagResonant,
    AppColors.tagReference,
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 22,
      height: 22,
      child: Center(
        child: Wrap(
          spacing: 3,
          runSpacing: 3,
          children: [
            for (final tone in _tones)
              Container(
                width: 8,
                height: 8,
                decoration:
                    BoxDecoration(color: tone, shape: BoxShape.circle),
              ),
          ],
        ),
      ),
    );
  }
}

class _AudioProgressBar extends StatefulWidget {
  const _AudioProgressBar({
    required this.positionSecs,
    required this.totalSecs,
    required this.onSeekSec,
  });

  final double positionSecs;
  final double totalSecs;
  final ValueChanged<double> onSeekSec;

  @override
  State<_AudioProgressBar> createState() => _AudioProgressBarState();
}

class _AudioProgressBarState extends State<_AudioProgressBar> {
  double? _dragValue;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final maxValue = widget.totalSecs > 0 ? widget.totalSecs : 1.0;
    final value =
        (_dragValue ?? widget.positionSecs).clamp(0.0, maxValue).toDouble();

    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        trackHeight: AppSpacing.xs,
        activeTrackColor: colors.accent,
        inactiveTrackColor: colors.surface2,
        thumbColor: colors.accent,
        overlayColor: colors.accentSoft,
        thumbShape: const RoundSliderThumbShape(
          enabledThumbRadius: AppSpacing.sm,
        ),
        overlayShape: const RoundSliderOverlayShape(
          overlayRadius: AppSpacing.xl,
        ),
      ),
      child: Slider(
        min: 0,
        max: maxValue,
        value: value,
        onChanged: widget.totalSecs <= 0
            ? null
            : (next) => setState(() => _dragValue = next),
        onChangeEnd: widget.totalSecs <= 0
            ? null
            : (next) {
                setState(() => _dragValue = null);
                widget.onSeekSec(next);
              },
      ),
    );
  }
}
