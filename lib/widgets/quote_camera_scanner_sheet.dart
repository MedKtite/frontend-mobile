import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';

import '../app/theme/tokens/colors.dart';
import '../app/theme/tokens/radii.dart';
import '../app/theme/tokens/spacing.dart';
import '../app/theme/tokens/typography.dart';
import '../models/book.dart';
import '../models/highlight_create_request.dart';
import '../models/note_create_request.dart';
import '../providers/book_highlights_provider.dart';
import '../services/backend/highlight_service.dart';
import '../services/backend/note_service.dart';

/// Opens the OCR quote extraction bottom sheet for a book.
Future<void> showQuoteCameraScannerSheet({
  required BuildContext context,
  required Book book,
  ImageSource initialSource = ImageSource.camera,
}) {
  return showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    backgroundColor: context.appColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.xl)),
    ),
    builder: (_) => QuoteCameraScannerSheet(book: book, initialSource: initialSource),
  );
}

class QuoteCameraScannerSheet extends ConsumerStatefulWidget {
  const QuoteCameraScannerSheet({
    super.key,
    required this.book,
    this.initialSource = ImageSource.camera,
  });

  final Book book;
  final ImageSource initialSource;

  @override
  ConsumerState<QuoteCameraScannerSheet> createState() =>
      _QuoteCameraScannerSheetState();
}

class _QuoteCameraScannerSheetState
    extends ConsumerState<QuoteCameraScannerSheet> {
  final _picker = ImagePicker();
  final _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

  final _textController = TextEditingController();
  final _pageController = TextEditingController();
  final _noteController = TextEditingController();

  String _selectedTag = 'resonant';
  bool _isProcessingImage = false;
  bool _isSaving = false;

  static const _availableTags = [
    'curious',
    'resonant',
    'beautiful',
    'reference',
    'urgent',
    'disagree',
    'revisit',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _captureAndRecognize(widget.initialSource);
    });
  }

  @override
  void dispose() {
    _textRecognizer.close();
    _textController.dispose();
    _pageController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _captureAndRecognize(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
      );
      if (picked == null) return;

      setState(() {
        _isProcessingImage = true;
      });

      final inputImage = InputImage.fromFilePath(picked.path);
      final recognizedText = await _textRecognizer.processImage(inputImage);

      if (!mounted) return;

      final text = recognizedText.text.trim();
      setState(() {
        _textController.text = text;
        _isProcessingImage = false;
      });

      if (text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No text recognized. Try taking a clearer photo.'),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isProcessingImage = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('OCR failed: $e')),
      );
    }
  }

  Future<void> _save() async {
    final passage = _textController.text.trim();
    if (passage.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select or enter quote text.')),
      );
      return;
    }

    setState(() => _isSaving = true);
    final pageRef = _pageController.text.trim().isNotEmpty
        ? (_pageController.text.trim().startsWith('p.')
            ? _pageController.text.trim()
            : 'p. ${_pageController.text.trim()}')
        : null;

    try {
      final highlight = await ref.read(highlightServiceProvider).create(
            HighlightCreateRequest(
              bookId: widget.book.id,
              colorTag: _selectedTag,
              passageText: passage,
              textChapterRef: pageRef,
            ),
          );

      final noteBody = _noteController.text.trim();
      if (noteBody.isNotEmpty) {
        await ref.read(noteServiceProvider).create(
              NoteCreateRequest(
                bookId: widget.book.id,
                bodyMd: noteBody,
                highlightId: highlight.id,
              ),
            );
      }

      ref.invalidate(bookHighlightsProvider(widget.book.id));

      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Saved to marginalia')),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save highlight: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.pageHorizontal,
          AppSpacing.sm,
          AppSpacing.pageHorizontal,
          MediaQuery.viewInsetsOf(context).bottom + AppSpacing.lg,
        ),
        child: SingleChildScrollView(
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
                    borderRadius: BorderRadius.circular(AppRadii.full),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Scan Page / Add Quote',
                        style: AppTypography.title2(colors.text),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.book.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.caption(colors.text2),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.photo_library_outlined),
                        tooltip: 'Choose from Gallery',
                        onPressed: () =>
                            _captureAndRecognize(ImageSource.gallery),
                      ),
                      IconButton(
                        icon: const Icon(Icons.camera_alt_outlined),
                        tooltip: 'Retake Photo',
                        onPressed: () =>
                            _captureAndRecognize(ImageSource.camera),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              // Processing indicator or text editor
              if (_isProcessingImage) ...[
                Container(
                  padding: const EdgeInsets.all(AppSpacing.xxl),
                  decoration: BoxDecoration(
                    color: colors.surface2,
                    borderRadius: BorderRadius.circular(AppRadii.md),
                  ),
                  child: Column(
                    children: [
                      CircularProgressIndicator(color: colors.accent),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        'Recognizing page text…',
                        style: AppTypography.body(colors.text),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                // Quote text field
                TextFormField(
                  controller: _textController,
                  maxLines: 5,
                  style: AppTypography.bodySerif(colors.text).copyWith(
                    fontStyle: FontStyle.italic,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Extracted Passage',
                    alignLabelWithHint: true,
                    hintText: 'Recognized quote text will appear here…',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadii.md),
                    ),
                  ),
                ),
              ],

              const SizedBox(height: AppSpacing.md),

              // Page reference & Tag selection
              Row(
                children: [
                  SizedBox(
                    width: 130,
                    child: TextFormField(
                      controller: _pageController,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        labelText: 'Page / Ref',
                        hintText: 'e.g. 142',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadii.sm),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _availableTags.map((tag) {
                          final isSelected = _selectedTag == tag;
                          final tagColor = AppColors.forTag(tag);
                          return GestureDetector(
                            onTap: () => setState(() => _selectedTag = tag),
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? tagColor.withValues(alpha: 0.2)
                                    : colors.surface2,
                                border: Border.all(
                                  color: isSelected ? tagColor : colors.border,
                                  width: isSelected ? 2 : 1,
                                ),
                                borderRadius:
                                    BorderRadius.circular(AppRadii.full),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: tagColor,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    tag,
                                    style: AppTypography.caption(
                                      isSelected ? colors.text : colors.text2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.md),

              // Optional Margin Note
              TextFormField(
                controller: _noteController,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: 'Margin Note (optional)',
                  hintText: 'Add your thoughts or reflections…',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadii.sm),
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              // Save button
              FilledButton(
                onPressed: _isSaving ? null : _save,
                style: FilledButton.styleFrom(
                  backgroundColor: colors.text,
                  foregroundColor: colors.bg,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadii.full),
                  ),
                ),
                child: _isSaving
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: colors.bg,
                        ),
                      )
                    : const Text('Save to marginalia'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
