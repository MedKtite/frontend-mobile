import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app/theme/tokens/colors.dart';
import '../app/theme/tokens/radii.dart';
import '../app/theme/tokens/spacing.dart';
import '../app/theme/tokens/typography.dart';
import '../core/dio_client.dart';
import '../models/book_create_request.dart';
import '../models/catalog_book.dart';
import '../providers/library_provider.dart';
import '../services/backend/book_service.dart';
import '../services/frontend/isbn_lookup_service.dart';
import 'app_progress_bar.dart';
import 'isbn_scanner_sheet.dart';

Future<void> showLogPhysicalBookSheet(BuildContext context) =>
    showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: context.appColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.xl)),
      ),
      builder: (_) => const _LogPhysicalBookSheet(),
    );

class _LogPhysicalBookSheet extends ConsumerStatefulWidget {
  const _LogPhysicalBookSheet();
  @override
  ConsumerState<_LogPhysicalBookSheet> createState() =>
      _LogPhysicalBookSheetState();
}

class _LogPhysicalBookSheetState extends ConsumerState<_LogPhysicalBookSheet> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _author = TextEditingController();
  final _isbn = TextEditingController();
  final _pageCount = TextEditingController();

  String? _coverUrl;
  int? _publishedYear;
  bool _busy = false;
  bool _isLookingUpIsbn = false;

  @override
  void dispose() {
    _title.dispose();
    _author.dispose();
    _isbn.dispose();
    _pageCount.dispose();
    super.dispose();
  }

  void _populateFromCatalog(CatalogBook book) {
    setState(() {
      _title.text = book.title;
      if (book.author != null && book.author!.isNotEmpty) {
        _author.text = book.author!;
      }
      if (book.isbn13 != null && book.isbn13!.isNotEmpty) {
        _isbn.text = book.isbn13!;
      }
      if (book.pageCount != null && book.pageCount! > 0) {
        _pageCount.text = book.pageCount.toString();
      }
      _coverUrl = book.thumbnailUrl;
      _publishedYear = book.publishedYear;
    });
  }

  Future<void> _scanBarcode() async {
    final result = await showIsbnScannerSheet(context);
    if (!mounted || result == null) return;

    if (result is CatalogBook) {
      _populateFromCatalog(result);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Found “${result.title}”')),
      );
    } else if (result is String) {
      _isbn.text = result;
      await _lookupIsbn(result);
    }
  }

  Future<void> _lookupIsbn(String rawIsbn) async {
    final clean = IsbnLookupService.cleanIsbn(rawIsbn);
    if (clean.length < 10) return;

    setState(() => _isLookingUpIsbn = true);
    try {
      final lookupService = ref.read(isbnLookupServiceProvider);
      final book = await lookupService.lookup(clean);
      if (!mounted) return;
      if (book != null) {
        _populateFromCatalog(book);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Autofilled “${book.title}”')),
        );
      }
    } catch (_) {
      // Best-effort lookup
    } finally {
      if (mounted) setState(() => _isLookingUpIsbn = false);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _busy = true);
    try {
      final author = _author.text.trim();
      final isbn = _isbn.text.trim();
      final pages = int.tryParse(_pageCount.text.trim());

      await ref
          .read(bookServiceProvider)
          .create(
            BookCreateRequest(
              title: _title.text.trim(),
              author: author.isEmpty ? null : author,
              isbn13: isbn.isEmpty ? null : isbn,
              pageCount: pages,
              coverUrl: _coverUrl,
              publishedYear: _publishedYear,
              format: 'physical',
              status: 'archived',
            ),
          );
      ref.invalidate(libraryBooksProvider);
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Added “${_title.text.trim()}”')));
    } on ApiError catch (e) {
      if (!mounted) return;
      setState(() => _busy = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.message.isEmpty ? 'Could not save this book.' : e.message,
          ),
        ),
      );
    } catch (e) {
      debugPrint('Physical book save failed: $e');
      if (!mounted) return;
      setState(() => _busy = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not save this book. Check your connection.'),
        ),
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
          child: Form(
            key: _formKey,
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
                Text(
                  'Log a physical book',
                  style: AppTypography.title2(colors.text),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Track a book you read on paper',
                  style: AppTypography.subtitle(colors.text2),
                ),
                const SizedBox(height: AppSpacing.lg),

                // Scan barcode action card
                InkWell(
                  onTap: _scanBarcode,
                  borderRadius: BorderRadius.circular(AppRadii.md),
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: colors.surface2,
                      borderRadius: BorderRadius.circular(AppRadii.md),
                      border: Border.all(color: colors.border),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: colors.accent.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.qr_code_scanner_rounded,
                            color: colors.accent,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Scan ISBN barcode',
                                style: AppTypography.body(colors.text).copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                'Auto-fills title, author, and cover',
                                style: AppTypography.caption(colors.text2),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.chevron_right_rounded,
                          color: colors.text3,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.lg),

                // Cover Preview if fetched
                if (_coverUrl != null && _coverUrl!.isNotEmpty) ...[
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(AppRadii.xs),
                        child: Image.network(
                          _coverUrl!,
                          width: 48,
                          height: 72,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Cover matched',
                              style: AppTypography.label(colors.accent),
                            ),
                            Text(
                              _title.text,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.caption(colors.text2),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],

                _field(_title, 'Title', required: true),
                const SizedBox(height: AppSpacing.md),
                _field(_author, 'Author'),
                const SizedBox(height: AppSpacing.md),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _field(
                        _isbn,
                        'ISBN-13 (optional)',
                        keyboard: TextInputType.number,
                        suffixIcon: _isLookingUpIsbn
                            ? const Padding(
                                padding: EdgeInsets.all(12),
                                child: SizedBox(
                                  width: 24,
                                  child: AppProgressBar(height: 2),
                                ),
                              )
                            : IconButton(
                                icon: const Icon(Icons.search, size: 20),
                                tooltip: 'Lookup ISBN',
                                onPressed: () => _lookupIsbn(_isbn.text),
                              ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                _field(
                  _pageCount,
                  'Total pages (optional)',
                  keyboard: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return null;
                    final pages = int.tryParse(value.trim());
                    return pages == null || pages <= 0
                        ? 'Enter a valid page count'
                        : null;
                  },
                ),
                const SizedBox(height: AppSpacing.xl),
                FilledButton(
                  onPressed: _busy ? null : _save,
                  style: FilledButton.styleFrom(
                    backgroundColor: colors.text,
                    foregroundColor: colors.bg,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadii.full),
                    ),
                  ),
                  child: _busy
                      ? SizedBox(
                          width: 32,
                          child: AppProgressBar(
                            height: 3,
                            color: colors.bg,
                            backgroundColor: colors.bg.withValues(alpha: 0.3),
                          ),
                        )
                      : const Text('Save to library'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    bool required = false,
    TextInputType? keyboard,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) => TextFormField(
    controller: controller,
    keyboardType: keyboard,
    textInputAction: TextInputAction.next,
    decoration: InputDecoration(
      labelText: label,
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadii.sm),
      ),
    ),
    validator:
        validator ??
        (required
            ? (value) => value == null || value.trim().isEmpty
                  ? 'Title is required'
                  : null
            : null),
  );
}
