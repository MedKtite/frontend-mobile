import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../app/routes.dart';
import '../app/theme/tokens/colors.dart';
import '../app/theme/tokens/radii.dart';
import '../app/theme/tokens/spacing.dart';
import '../app/theme/tokens/typography.dart';
import '../core/dio_client.dart';
import '../models/book_create_request.dart';
import '../models/presign_upload_request.dart';
import '../providers/library_provider.dart';
import '../services/backend/book_service.dart';
import '../services/backend/upload_service.dart';
import 'app_progress_bar.dart';
import 'log_physical_book_sheet.dart';

/// Presents the "Add to library" modal sheet (frames 287:2 / 287:181).
Future<void> showAddToLibrarySheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    backgroundColor: context.appColors.surface,
    isScrollControlled:
        true, // size to content, not the default half-screen cap
    builder: (_) => const _AddToLibrarySheet(),
  );
}

class _AddToLibrarySheet extends ConsumerStatefulWidget {
  const _AddToLibrarySheet();

  @override
  ConsumerState<_AddToLibrarySheet> createState() => _AddToLibrarySheetState();
}

class _AddToLibrarySheetState extends ConsumerState<_AddToLibrarySheet> {
  bool _busy = false;

  static String? _contentTypeFor(String ext) => switch (ext) {
    'epub' => 'application/epub+zip',
    'pdf' => 'application/pdf',
    _ => null,
  };

  static String _titleFrom(String fileName) {
    final dot = fileName.lastIndexOf('.');
    final base = dot > 0 ? fileName.substring(0, dot) : fileName;
    final trimmed = base.trim();
    return trimmed.isEmpty ? 'Untitled' : trimmed;
  }

  Future<void> _pickAndUpload() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['epub', 'pdf'],
      withData: true, // we PUT the bytes straight to S3
    );
    if (result == null || result.files.isEmpty) return; // cancelled

    final picked = result.files.single;
    final bytes = picked.bytes;
    final ext = (picked.extension ?? '').toLowerCase();
    final contentType = _contentTypeFor(ext);
    if (bytes == null || contentType == null) {
      _toast('Unsupported file — pick an EPUB or PDF.');
      return;
    }
    if (!mounted) return; // the OS picker is an async gap

    setState(() => _busy = true);
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);
    final navigator = Navigator.of(context);
    final title = _titleFrom(picked.name);

    try {
      final upload = ref.read(uploadServiceProvider);
      final presigned = await upload.presign(
        PresignUploadRequest(
          format: ext,
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
      await ref
          .read(bookServiceProvider)
          .create(
            BookCreateRequest(
              title: title,
              format: ext,
              fileKey: presigned.fileKey,
            ),
          );
      ref.invalidate(libraryBooksProvider);
      if (!mounted) return;
      navigator.pop(); // close the sheet
      router.go(Routes.library);
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text('Added “$title”')));
    } on ApiError catch (e) {
      if (!mounted) return;
      setState(() => _busy = false);
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(e.message)));
    } on DioException catch (_) {
      if (!mounted) return;
      setState(() => _busy = false);
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Upload failed — check your connection.'),
          ),
        );
    }
  }

  void _toast(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppRadii.xl),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.pageHorizontal,
            AppSpacing.sm,
            AppSpacing.pageHorizontal,
            AppSpacing.lg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(
                  top: AppSpacing.sm,
                  bottom: AppSpacing.xl,
                ),
                decoration: BoxDecoration(
                  color: colors.border,
                  borderRadius: AppRadii.brFull,
                ),
              ),
              if (_busy) ..._uploading(colors) else ..._options(colors),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _uploading(AppColorsExtension colors) => [
    Text('Add to library', style: AppTypography.title2(colors.text)),
    const SizedBox(height: AppSpacing.xxxl),
    const AppProgressLoading(width: 180),
    const SizedBox(height: AppSpacing.lg),
    Text('Uploading your book…', style: AppTypography.subtitle(colors.text2)),
    const SizedBox(height: AppSpacing.xxxl),
  ];

  List<Widget> _options(AppColorsExtension colors) => [
    Text('Add to library', style: AppTypography.title2(colors.text)),
    const SizedBox(height: AppSpacing.xs),
    Text('Bring your own books.', style: AppTypography.subtitle(colors.text2)),
    const SizedBox(height: AppSpacing.xl),
    _AddOption(
      icon: Icons.search,
      title: 'Search the catalog',
      subtitle: 'Find by title or author',
      highlighted: true,
      onTap: () {
        final router = GoRouter.of(context);
        Navigator.of(context).pop();
        // Catalog search lives in the Discovery tab — land there with
        // the search field focused (extra → autofocusSearch).
        router.go(Routes.discovery, extra: true);
      },
    ),
    const SizedBox(height: AppSpacing.md),
    _AddOption(
      icon: Icons.file_upload_outlined,
      title: 'Upload a file',
      subtitle: 'EPUB · PDF',
      onTap: _pickAndUpload,
    ),

    const SizedBox(height: AppSpacing.md),
    _AddOption(
      icon: Icons.menu_book_outlined,
      title: 'Log a physical book',
      subtitle: 'Track a book you read on paper',
      onTap: () {
        Navigator.of(context).pop();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) showLogPhysicalBookSheet(context);
        });
      },
    ),
  ];
}

class _AddOption extends StatelessWidget {
  const _AddOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.highlighted = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Material(
      color: colors.surface,
      borderRadius: AppRadii.brLg,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadii.brLg,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            borderRadius: AppRadii.brLg,
            border: Border.all(
              color: colors.border,
              width: highlighted ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: colors.surface2,
                  borderRadius: AppRadii.brMd,
                ),
                child: Icon(icon, size: 22, color: colors.text2),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: AppTypography.body(
                        colors.text,
                      ).copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(subtitle, style: AppTypography.caption(colors.text2)),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, size: 20, color: colors.text3),
            ],
          ),
        ),
      ),
    );
  }
}
