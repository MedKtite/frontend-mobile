import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app/theme/tokens/colors.dart';
import '../core/dio_client.dart';
import '../app/theme/tokens/spacing.dart';
import '../app/theme/tokens/typography.dart';
import '../models/book_create_request.dart';
import '../models/catalog_book.dart';
import '../services/backend/catalog_service.dart';
import '../providers/library_provider.dart';
import '../services/backend/book_service.dart';

Future<void> showLogPhysicalBookSheet(BuildContext context) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.appColors.surface,
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
  bool _busy = false;

  @override
  void dispose() {
    _title.dispose();
    _author.dispose();
    _isbn.dispose();
    _pageCount.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _busy = true);
    try {
      final author = _author.text.trim();
      CatalogBook? publicDomain;
      try {
        final matches = await ref
            .read(catalogServiceProvider)
            .search(_title.text.trim());
        for (final match in matches) {
          if (match.isReadable && match.gutenbergId != null) {
            publicDomain = match;
            break;
          }
        }
      } catch (_) {
        // Catalog lookup is optional; save the physical entry if it is unavailable.
      }
      await ref
          .read(bookServiceProvider)
          .create(
            BookCreateRequest(
              title: _title.text.trim(),
              author: author.isEmpty ? null : author,
              isbn13: _isbn.text.trim().isEmpty ? null : _isbn.text.trim(),
              pageCount: int.tryParse(_pageCount.text.trim()),
              gutenbergId: publicDomain?.gutenbergId,
              coverUrl: publicDomain?.thumbnailUrl,
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
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(width: 36, height: 4, color: colors.border),
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
              const SizedBox(height: AppSpacing.xl),
              _field(_title, 'Title', required: true),
              const SizedBox(height: AppSpacing.md),
              _field(_author, 'Author'),
              const SizedBox(height: AppSpacing.md),
              _field(
                _isbn,
                'ISBN-13 (optional)',
                keyboard: TextInputType.number,
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
                child: _busy
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Save to library'),
              ),
            ],
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
    String? Function(String?)? validator,
  }) => TextFormField(
    controller: controller,
    keyboardType: keyboard,
    textInputAction: TextInputAction.next,
    decoration: InputDecoration(labelText: label),
    validator:
        validator ??
        (required
            ? (value) => value == null || value.trim().isEmpty
                  ? 'Title is required'
                  : null
            : null),
  );
}
