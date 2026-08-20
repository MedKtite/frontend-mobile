import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app/theme/tokens/colors.dart';
import '../app/theme/tokens/radii.dart';
import '../app/theme/tokens/spacing.dart';
import '../app/theme/tokens/typography.dart';
import '../providers/audio_player_provider.dart';
import '../providers/sleep_timer_provider.dart';

/// Bottom sheet allowing users to set a sleep timer with Shake-to-Extend support.
Future<void> showSleepTimerSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    backgroundColor: context.appColors.surface,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.lg)),
    ),
    builder: (_) => const _SleepTimerSheet(),
  );
}

class _SleepTimerSheet extends ConsumerWidget {
  const _SleepTimerSheet();

  String _fmtRemaining(Duration d) {
    final m = d.inMinutes;
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final sleepState = ref.watch(sleepTimerProvider);
    final isRunning = sleepState != null;
    final ctrl = ref.read(sleepTimerProvider.notifier);

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.pageHorizontal,
        AppSpacing.lg,
        AppSpacing.pageHorizontal,
        MediaQuery.paddingOf(context).bottom + AppSpacing.xl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: colors.border,
                borderRadius: AppRadii.brFull,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: colors.surface2,
                  borderRadius: AppRadii.brMd,
                ),
                child: Icon(
                  Icons.bedtime_outlined,
                  color: colors.accent,
                  size: 22,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Sleep Timer',
                        style: AppTypography.title2(colors.text)),
                    Text(
                      isRunning
                          ? '${_fmtRemaining(sleepState.remaining)} remaining'
                          : 'Stops audio automatically',
                      style: AppTypography.caption(
                        isRunning ? colors.accent : colors.text3,
                      ).copyWith(fontWeight: isRunning ? FontWeight.w600 : null),
                    ),
                  ],
                ),
              ),
              if (isRunning)
                TextButton(
                  onPressed: () {
                    ctrl.cancel();
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'Turn Off',
                    style: AppTypography.label(const Color(0xFFEF5350)),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),

          // Presets Grid
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.md,
            children: [
              _presetChip(
                context,
                ref,
                label: '15 min',
                duration: const Duration(minutes: 15),
              ),
              _presetChip(
                context,
                ref,
                label: '30 min',
                duration: const Duration(minutes: 30),
              ),
              _presetChip(
                context,
                ref,
                label: '45 min',
                duration: const Duration(minutes: 45),
              ),
              _presetChip(
                context,
                ref,
                label: '60 min',
                duration: const Duration(minutes: 60),
              ),
              _endOfChapterChip(context, ref),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),

          // Shake to extend info tile
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: colors.surface2,
              borderRadius: AppRadii.brMd,
              border: Border.all(color: colors.border),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.vibration_rounded,
                  size: 22,
                  color: colors.accent,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Shake to Extend (+15 min)',
                        style: AppTypography.label(colors.text)
                            .copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Gently shake your phone while audio is fading to extend without opening your screen.',
                        style: AppTypography.caption(colors.text2),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _presetChip(
    BuildContext context,
    WidgetRef ref, {
    required String label,
    required Duration duration,
  }) {
    final colors = context.appColors;
    final sleepState = ref.watch(sleepTimerProvider);
    final active = sleepState != null &&
        !sleepState.isEndOfChapter &&
        sleepState.initialDuration == duration;

    return ActionChip(
      label: Text(label),
      backgroundColor: active ? colors.text : colors.surface2,
      side: BorderSide(color: active ? colors.text : colors.border),
      labelStyle: AppTypography.label(
        active ? colors.bg : colors.text,
      ).copyWith(fontWeight: FontWeight.w600),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      onPressed: () {
        ref.read(sleepTimerProvider.notifier).start(duration);
        Navigator.of(context).pop();
      },
    );
  }

  Widget _endOfChapterChip(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final sleepState = ref.watch(sleepTimerProvider);
    final active = sleepState != null && sleepState.isEndOfChapter;
    final audioSession = ref.watch(audioPlayerProvider);

    return ActionChip(
      label: const Text('End of Chapter'),
      backgroundColor: active ? colors.text : colors.surface2,
      side: BorderSide(color: active ? colors.text : colors.border),
      labelStyle: AppTypography.label(
        active ? colors.bg : colors.text,
      ).copyWith(fontWeight: FontWeight.w600),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      onPressed: () {
        // Calculate remaining seconds in current LibriVox track or default 20m
        var chapterSecs = 1200; // 20 min default fallback
        if (audioSession?.librivox != null) {
          final player = ref.read(audioPlayerProvider.notifier).player;
          final duration = player.duration ?? const Duration(minutes: 20);
          final pos = player.position;
          chapterSecs = (duration - pos).inSeconds.clamp(10, 7200);
        }

        ref.read(sleepTimerProvider.notifier).start(
              Duration(seconds: chapterSecs),
              isEndOfChapter: true,
            );
        Navigator.of(context).pop();
      },
    );
  }
}
