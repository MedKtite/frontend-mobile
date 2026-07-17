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
import '../core/widgets/adaptive_modal.dart';
import '../core/widgets/app_snackbar.dart';
import '../models/book_create_request.dart';
import '../models/presign_upload_request.dart';
import '../providers/library_provider.dart';
import '../services/backend/book_service.dart';
import '../services/backend/upload_service.dart';
import 'glass_panel.dart';

/// Presents the "Add to library" modal sheet (frames 287:2 / 287:181).
Future<void> showAddToLibrarySheet(BuildContext context) {
  return showAdaptiveModal<void>(
    context: context,
    backgroundColor: Colors.transparent,
    // Light scrim: the sheet is frosted GLASS — it needs bright content
    // behind it to transmit. The default black54 turns the frost muddy.
    barrierColor: Colors.black.withValues(alpha: 0.18),
    isScrollControlled: true, // size to content, not the default half-screen cap
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
        'm4b' => 'audio/mp4',
        'mp3' => 'audio/mpeg',
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
      allowedExtensions: const ['epub', 'pdf', 'm4b', 'mp3'],
      withData: true, // we PUT the bytes straight to S3
    );
    if (result == null || result.files.isEmpty) return; // cancelled

    final picked = result.files.single;
    final bytes = picked.bytes;
    final ext = (picked.extension ?? '').toLowerCase();
    final contentType = _contentTypeFor(ext);
    if (bytes == null || contentType == null) {
      _toast('Unsupported file — pick an EPUB, PDF, M4B or MP3.');
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
      final presigned = await upload.presign(PresignUploadRequest(
        format: ext,
        contentType: contentType,
        contentLength: bytes.length,
      ));
      await upload.putToStorage(
        uploadUrl: presigned.uploadUrl,
        bytes: bytes,
        contentType: contentType,
      );
      await ref.read(bookServiceProvider).create(BookCreateRequest(
            title: title,
            format: ext,
            // Audio files land straight on the Listening shelf.
            status: (ext == 'm4b' || ext == 'mp3') ? 'listening' : null,
            fileKey: presigned.fileKey,
          ));
      ref.invalidate(libraryBooksProvider);
      if (!mounted) return;
      navigator.pop(); // close the sheet
      router.go(Routes.library);
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(appSnackBar('Added “$title”', SnackType.success));
    } on ApiError catch (e) {
      if (!mounted) return;
      setState(() => _busy = false);
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(appSnackBar(e.message, SnackType.error));
    } on DioException catch (_) {
      if (!mounted) return;
      setState(() => _busy = false);
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(appSnackBar(
            'Upload failed — check your connection.', SnackType.error));
    }
  }

  void _toast(String message) =>
      showAppSnack(context, message, type: SnackType.warning);

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    // Same glass material as the nav pill and auth cards; top-only rounding
    // since the sheet is flush with the screen bottom.
    return GlassPanel(
      radius: AppRadii.xl,
      borderRadius: adaptiveModalBorderRadius(context),
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
              AdaptiveModalHandle(color: colors.border),
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
        CircularProgressIndicator(color: colors.accent),
        const SizedBox(height: AppSpacing.lg),
        Text(
          'Uploading your book…',
          style: AppTypography.subtitle(colors.text2),
        ),
        const SizedBox(height: AppSpacing.xxxl),
      ];

  List<Widget> _options(AppColorsExtension colors) => [
        Text('Add to library', style: AppTypography.title2(colors.text)),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Bring your own books.',
          style: AppTypography.subtitle(colors.text2),
        ),
        const SizedBox(height: AppSpacing.xl),
        
        _AddOption(
          icon: Icons.file_upload_outlined,
          title: 'Upload a file',
          subtitle: 'EPUB · PDF · M4B · MP3',
          onTap: _pickAndUpload,
        ),
        const SizedBox(height: AppSpacing.md),
        _AddOption(
          icon: Icons.qr_code_scanner,
          title: 'Scan an ISBN',
          subtitle: 'Point your camera at the back cover',
          onTap: () => _stub('ISBN scan'),
        ),
        const SizedBox(height: AppSpacing.md),
        _AddOption(
          icon: Icons.menu_book_outlined,
          title: 'Log a physical book',
          subtitle: 'Track a book you read on paper',
          onTap: () => _stub('Logging a physical book'),
        ),

      ];

  // The remaining add flows aren't built yet — close the sheet and acknowledge.
  void _stub(String what) {
    final messenger = ScaffoldMessenger.of(context);
    Navigator.of(context).pop();
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(appSnackBar('$what — coming soon', SnackType.info));
  }
}

class _AddOption extends StatelessWidget {
  const _AddOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    // Transparent row — an opaque card would punch a hole in the glass sheet.
    return Material(
      color: Colors.transparent,
      borderRadius: AppRadii.brLg,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadii.brLg,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            borderRadius: AppRadii.brLg,
          
          ),
          child: Row(
            children: [
              // Translucent accent tint, not an opaque surface — the glass
              // continues through the chip (same vocabulary as the nav bar's
              // active-tab pill: soft accent wash = tappable).
              Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: colors.accentSoft,
                  borderRadius: AppRadii.brMd,
                ),
                child: Icon(icon, size: 22, color: colors.accent),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: AppTypography.body(colors.text)
                          .copyWith(fontWeight: FontWeight.w600),
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
