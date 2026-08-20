import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import '../app/theme/tokens/colors.dart';
import '../app/theme/tokens/radii.dart';
import '../app/theme/tokens/spacing.dart';
import '../app/theme/tokens/typography.dart';
import '../core/dio_client.dart';
import '../core/widgets/app_snackbar.dart';
import '../models/highlight_create_request.dart';
import '../models/note_create_request.dart';
import '../providers/book_highlights_provider.dart';
import '../services/backend/highlight_service.dart';
import '../services/backend/note_service.dart';

/// Modal sheet to record a spoken voice memo attached to a reading or audio timestamp.
Future<void> showVoiceMemoSheet(
  BuildContext context, {
  required String bookId,
  required String bookTitle,
  double? audioStartSec,
  String? textChapterRef,
}) {
  return showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    backgroundColor: context.appColors.surface,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.lg)),
    ),
    builder: (_) => _VoiceMemoSheet(
      bookId: bookId,
      bookTitle: bookTitle,
      audioStartSec: audioStartSec,
      textChapterRef: textChapterRef,
    ),
  );
}

class _VoiceMemoSheet extends ConsumerStatefulWidget {
  const _VoiceMemoSheet({
    required this.bookId,
    required this.bookTitle,
    this.audioStartSec,
    this.textChapterRef,
  });

  final String bookId;
  final String bookTitle;
  final double? audioStartSec;
  final String? textChapterRef;

  @override
  ConsumerState<_VoiceMemoSheet> createState() => _VoiceMemoSheetState();
}

class _VoiceMemoSheetState extends ConsumerState<_VoiceMemoSheet> {
  late final AudioRecorder _audioRecorder;
  late final TextEditingController _noteController;

  bool _isRecording = false;
  String? _recordedFilePath;
  int _recordDurationSec = 0;
  Timer? _timer;
  String _tag = 'idea';
  bool _busy = false;

  static const _tags = [
    'idea',
    'gold',
    'revisit',
    'question',
    'prose',
    'critique',
    'favorite',
  ];

  @override
  void initState() {
    super.initState();
    _audioRecorder = AudioRecorder();
    _noteController = TextEditingController();
    _startRecording();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _audioRecorder.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        final dir = await getTemporaryDirectory();
        final path =
            '${dir.path}/voice_memo_${DateTime.now().millisecondsSinceEpoch}.m4a';

        await _audioRecorder.start(
          const RecordConfig(encoder: AudioEncoder.aacLc),
          path: path,
        );

        setState(() {
          _isRecording = true;
          _recordDurationSec = 0;
          _recordedFilePath = null;
        });

        _timer = Timer.periodic(const Duration(seconds: 1), (_) {
          if (mounted) {
            setState(() => _recordDurationSec++);
          }
        });
      } else {
        if (mounted) {
          showAppSnack(context, 'Microphone permission denied',
              type: SnackType.error);
        }
      }
    } catch (e) {
      if (mounted) {
        showAppSnack(context, 'Could not start recording',
            type: SnackType.error);
      }
    }
  }

  Future<void> _stopRecording() async {
    _timer?.cancel();
    final path = await _audioRecorder.stop();
    setState(() {
      _isRecording = false;
      _recordedFilePath = path;
    });
  }

  String _formatTimer(int totalSec) {
    final m = totalSec ~/ 60;
    final s = totalSec % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  Future<void> _save() async {
    setState(() => _busy = true);
    final navigator = Navigator.of(context);

    try {
      final highlight = await ref.read(highlightServiceProvider).create(
            HighlightCreateRequest(
              bookId: widget.bookId,
              colorTag: _tag,
              audioStartSec: widget.audioStartSec,
              textChapterRef: widget.textChapterRef,
              passageText: 'Voice reflection (${_formatTimer(_recordDurationSec)})',
            ),
          );

      final userText = _noteController.text.trim();
      final body = userText.isNotEmpty
          ? '🎙️ Voice Memo: $userText'
          : '🎙️ Spoken reflection (${_formatTimer(_recordDurationSec)})';

      await ref.read(noteServiceProvider).create(
            NoteCreateRequest(
              bookId: widget.bookId,
              bodyMd: body,
              highlightId: highlight.id,
            ),
          );

      ref.invalidate(bookHighlightsProvider(widget.bookId));
      if (!mounted) return;
      navigator.pop();
      showAppSnack(context, 'Voice memo saved to “${widget.bookTitle}”',
          type: SnackType.success);
    } on ApiError catch (e) {
      if (mounted) {
        setState(() => _busy = false);
        showAppSnack(context, e.message, type: SnackType.error);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _busy = false);
        showAppSnack(context, 'Could not save voice memo',
            type: SnackType.error);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.pageHorizontal,
        AppSpacing.lg,
        AppSpacing.pageHorizontal,
        MediaQuery.viewInsetsOf(context).bottom + AppSpacing.xl,
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
          Text(
            'Record Voice Memo',
            style: AppTypography.title2(colors.text),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            widget.audioStartSec != null
                ? 'Attached to audio moment at ${widget.audioStartSec!.round()}s'
                : 'Spoken reflection for ${widget.bookTitle}',
            style: AppTypography.caption(colors.text3),
          ),
          const SizedBox(height: AppSpacing.xl),

          // Recording Visualizer & Status
          Container(
            padding: const EdgeInsets.symmetric(
              vertical: AppSpacing.xxl,
              horizontal: AppSpacing.lg,
            ),
            decoration: BoxDecoration(
              color: colors.surface2,
              borderRadius: AppRadii.brLg,
              border: Border.all(color: colors.border),
            ),
            child: Column(
              children: [
                GestureDetector(
                  onTap: _isRecording ? _stopRecording : _startRecording,
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: _isRecording
                          ? const Color(0xFFEF5350)
                          : colors.accent,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: (_isRecording
                                  ? const Color(0xFFEF5350)
                                  : colors.accent)
                              .withValues(alpha: 0.35),
                          blurRadius: 20,
                          spreadRadius: _isRecording ? 4 : 1,
                        ),
                      ],
                    ),
                    child: Icon(
                      _isRecording ? Icons.stop_rounded : Icons.mic_rounded,
                      color: Colors.white,
                      size: 36,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  _formatTimer(_recordDurationSec),
                  style: AppTypography.display(colors.text).copyWith(
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  _isRecording
                      ? 'Recording… Tap red button to stop'
                      : _recordedFilePath != null
                          ? 'Memo recorded. Ready to save.'
                          : 'Tap microphone to start recording',
                  style: AppTypography.caption(
                    _isRecording ? const Color(0xFFEF5350) : colors.text2,
                  ).copyWith(fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Tag Color Chips
          Text('TAG CATEGORY', style: AppTypography.overline(colors.text3)),
          const SizedBox(height: AppSpacing.sm),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _tags.map((t) {
                final active = _tag == t;
                final tagColor = AppColors.forTag(t);
                return Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.sm),
                  child: ChoiceChip(
                    label: Text(t),
                    selected: active,
                    selectedColor: tagColor.withValues(alpha: 0.2),
                    side: BorderSide(
                      color: active ? tagColor : colors.border,
                    ),
                    labelStyle: AppTypography.caption(
                      active ? tagColor : colors.text2,
                    ).copyWith(fontWeight: FontWeight.w600),
                    onSelected: (selected) {
                      if (selected) setState(() => _tag = t);
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Optional Text Note
          TextField(
            controller: _noteController,
            style: AppTypography.body(colors.text),
            decoration: InputDecoration(
              hintText: 'Add an optional note or title…',
              hintStyle: AppTypography.body(colors.text3),
              filled: true,
              fillColor: colors.surface2,
              border: OutlineInputBorder(
                borderRadius: AppRadii.brMd,
                borderSide: BorderSide(color: colors.border),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          FilledButton(
            onPressed: _busy || _isRecording ? null : _save,
            style: FilledButton.styleFrom(
              backgroundColor: colors.accent,
              foregroundColor: colors.bg,
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              shape: RoundedRectangleBorder(borderRadius: AppRadii.brMd),
            ),
            child: _busy
                ? SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: colors.bg,
                    ),
                  )
                : Text(
                    'Save Voice Memo',
                    style: AppTypography.label(colors.bg)
                        .copyWith(fontWeight: FontWeight.w600),
                  ),
          ),
        ],
      ),
    );
  }
}
