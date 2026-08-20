import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../app/routes.dart';
import '../app/theme/tokens/colors.dart';
import '../app/theme/tokens/radii.dart';
import '../app/theme/tokens/spacing.dart';
import '../app/theme/tokens/typography.dart';
import '../core/dio_client.dart';
import '../core/widgets/app_snackbar.dart';
import '../models/book.dart';
import '../models/book_create_request.dart';
import '../models/highlight_create_request.dart';
import '../models/note_create_request.dart';
import '../models/presign_upload_request.dart';
import '../providers/book_highlights_provider.dart';
import '../providers/library_provider.dart';
import '../services/backend/book_service.dart';
import '../services/backend/highlight_service.dart';
import '../services/backend/note_service.dart';
import '../services/backend/upload_service.dart';

/// Modal presented when the user shares an EPUB/PDF file to Marginalia from another app.
Future<void> showSharedFileImportSheet(
  BuildContext context, {
  required String filePath,
}) {
  return showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    backgroundColor: context.appColors.surface,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.lg)),
    ),
    builder: (_) => _SharedFileImportSheet(filePath: filePath),
  );
}

class _SharedFileImportSheet extends ConsumerStatefulWidget {
  const _SharedFileImportSheet({required this.filePath});

  final String filePath;

  @override
  ConsumerState<_SharedFileImportSheet> createState() =>
      _SharedFileImportSheetState();
}

class _SharedFileImportSheetState
    extends ConsumerState<_SharedFileImportSheet> {
  bool _busy = false;
  late final TextEditingController _titleController;
  late final String _ext;
  late final int _fileSize;

  @override
  void initState() {
    super.initState();
    final file = File(widget.filePath);
    final rawName = file.uri.pathSegments.isNotEmpty
        ? file.uri.pathSegments.last
        : 'Book';
    final dot = rawName.lastIndexOf('.');
    final base = dot > 0 ? rawName.substring(0, dot) : rawName;
    _titleController = TextEditingController(text: base.trim());
    _ext = dot > 0 ? rawName.substring(dot + 1).toLowerCase() : 'epub';
    _fileSize = file.existsSync() ? file.lengthSync() : 0;
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  String? _contentTypeFor(String ext) => switch (ext) {
        'epub' => 'application/epub+zip',
        'pdf' => 'application/pdf',
        _ => null,
      };

  Future<void> _import() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      showAppSnack(context, 'Please enter a title', type: SnackType.error);
      return;
    }
    final contentType = _contentTypeFor(_ext);
    if (contentType == null) {
      showAppSnack(context, 'Unsupported format ($_ext)', type: SnackType.error);
      return;
    }

    final file = File(widget.filePath);
    if (!file.existsSync()) {
      showAppSnack(context, 'File not found on device', type: SnackType.error);
      return;
    }

    setState(() => _busy = true);
    final router = GoRouter.of(context);
    final navigator = Navigator.of(context);

    try {
      final bytes = await file.readAsBytes();
      final upload = ref.read(uploadServiceProvider);
      final presigned = await upload.presign(
        PresignUploadRequest(
          format: _ext,
          contentType: contentType,
          contentLength: bytes.length,
        ),
      );

      await upload.putToStorage(
        uploadUrl: presigned.uploadUrl,
        body: Stream<List<int>>.fromIterable([bytes]),
        contentLength: bytes.length,
        contentType: contentType,
      );

      await ref.read(bookServiceProvider).create(
            BookCreateRequest(
              title: title,
              format: _ext,
              fileKey: presigned.fileKey,
            ),
          );

      ref.invalidate(libraryBooksProvider);
      if (!mounted) return;
      navigator.pop();
      router.go(Routes.library);
      showAppSnack(context, 'Added “$title” to your library', type: SnackType.success);
    } on ApiError catch (e) {
      if (mounted) {
        setState(() => _busy = false);
        showAppSnack(context, e.message, type: SnackType.error);
      }
    } on DioException catch (_) {
      if (mounted) {
        setState(() => _busy = false);
        showAppSnack(context, 'Upload failed — check your network connection', type: SnackType.error);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final sizeKb = (_fileSize / 1024).round();
    final sizeMb = (sizeKb / 1024).toStringAsFixed(1);
    final sizeLabel = sizeKb > 1024 ? '$sizeMb MB' : '$sizeKb KB';

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
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: colors.surface2,
                  borderRadius: AppRadii.brMd,
                ),
                child: Icon(
                  _ext == 'pdf'
                      ? Icons.picture_as_pdf_outlined
                      : Icons.menu_book_rounded,
                  color: colors.accent,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Import Book',
                      style: AppTypography.title3(colors.text),
                    ),
                    Text(
                      '${_ext.toUpperCase()} · $sizeLabel',
                      style: AppTypography.caption(colors.text3),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          TextField(
            controller: _titleController,
            enabled: !_busy,
            style: AppTypography.body(colors.text),
            decoration: InputDecoration(
              labelText: 'Book Title',
              labelStyle: AppTypography.caption(colors.text2),
              filled: true,
              fillColor: colors.surface2,
              border: OutlineInputBorder(
                borderRadius: AppRadii.brMd,
                borderSide: BorderSide(color: colors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: AppRadii.brMd,
                borderSide: BorderSide(color: colors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: AppRadii.brMd,
                borderSide: BorderSide(color: colors.accent, width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          FilledButton.icon(
            onPressed: _busy ? null : _import,
            icon: _busy
                ? SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: colors.bg,
                    ),
                  )
                : const Icon(Icons.download_rounded, size: 20),
            label: Text(
              _busy ? 'Importing & preparing…' : 'Add to Marginalia',
              style: AppTypography.label(colors.bg)
                  .copyWith(fontWeight: FontWeight.w600),
            ),
            style: FilledButton.styleFrom(
              backgroundColor: colors.accent,
              foregroundColor: colors.bg,
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              shape: RoundedRectangleBorder(borderRadius: AppRadii.brMd),
            ),
          ),
        ],
      ),
    );
  }
}

/// Modal presented when the user shares a text quote to Marginalia from another app (browser, news, etc.).
Future<void> showSharedQuoteSheet(
  BuildContext context, {
  required String quoteText,
}) {
  return showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    backgroundColor: context.appColors.surface,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.lg)),
    ),
    builder: (_) => _SharedQuoteSheet(quoteText: quoteText),
  );
}

class _SharedQuoteSheet extends ConsumerStatefulWidget {
  const _SharedQuoteSheet({required this.quoteText});

  final String quoteText;

  @override
  ConsumerState<_SharedQuoteSheet> createState() => _SharedQuoteSheetState();
}

class _SharedQuoteSheetState extends ConsumerState<_SharedQuoteSheet> {
  String _tag = 'revisit';
  Book? _selectedBook;
  late final TextEditingController _noteController;
  bool _busy = false;

  static const _tags = [
    'revisit',
    'gold',
    'question',
    'prose',
    'idea',
    'critique',
    'favorite',
  ];

  @override
  void initState() {
    super.initState();
    _noteController = TextEditingController();
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final book = _selectedBook;
    if (book == null) {
      showAppSnack(context, 'Please select a book for this marginalia', type: SnackType.error);
      return;
    }

    setState(() => _busy = true);
    final navigator = Navigator.of(context);

    try {
      final highlight = await ref.read(highlightServiceProvider).create(
            HighlightCreateRequest(
              bookId: book.id,
              colorTag: _tag,
              passageText: widget.quoteText.trim(),
            ),
          );

      final note = _noteController.text.trim();
      if (note.isNotEmpty) {
        await ref.read(noteServiceProvider).create(
              NoteCreateRequest(
                bookId: book.id,
                bodyMd: note,
                highlightId: highlight.id,
              ),
            );
      }

      ref.invalidate(bookHighlightsProvider(book.id));
      if (!mounted) return;
      navigator.pop();
      showAppSnack(context, 'Saved quote to “${book.title}”', type: SnackType.success);
    } on ApiError catch (e) {
      if (mounted) {
        setState(() => _busy = false);
        showAppSnack(context, e.message, type: SnackType.error);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final booksAsync = ref.watch(libraryBooksProvider);
    final books = booksAsync.valueOrNull ?? const [];

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
            'Save Marginalia Quote',
            style: AppTypography.title2(colors.text),
          ),
          const SizedBox(height: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: colors.surface2,
              borderRadius: AppRadii.brMd,
              border: Border(
                left: BorderSide(
                  color: AppColors.forTag(_tag),
                  width: 3.5,
                ),
              ),
            ),
            child: Text(
              '“${widget.quoteText.trim()}”',
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.bodySerif(colors.text).copyWith(
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('TAG COLOR', style: AppTypography.overline(colors.text3)),
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
          Text('ATTACH TO BOOK', style: AppTypography.overline(colors.text3)),
          const SizedBox(height: AppSpacing.xs),
          DropdownButtonFormField<Book>(
            initialValue: _selectedBook,
            hint: Text(
              books.isEmpty ? 'Loading books…' : 'Select a book',
              style: AppTypography.body(colors.text2),
            ),
            dropdownColor: colors.surface,
            items: books.map((b) {
              return DropdownMenuItem<Book>(
                value: b,
                child: Text(
                  b.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.body(colors.text),
                ),
              );
            }).toList(),
            onChanged: (val) => setState(() => _selectedBook = val),
            decoration: InputDecoration(
              filled: true,
              fillColor: colors.surface2,
              border: OutlineInputBorder(
                borderRadius: AppRadii.brMd,
                borderSide: BorderSide(color: colors.border),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          TextField(
            controller: _noteController,
            style: AppTypography.body(colors.text),
            maxLines: 2,
            decoration: InputDecoration(
              hintText: 'Add an annotation or thought (optional)…',
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
            onPressed: _busy ? null : _save,
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
                    'Save Quote',
                    style: AppTypography.label(colors.bg)
                        .copyWith(fontWeight: FontWeight.w600),
                  ),
          ),
        ],
      ),
    );
  }
}
