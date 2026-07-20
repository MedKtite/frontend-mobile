import 'dart:io';

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
  String _busyMessage = 'Preparing your book…';

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
    debugPrint('[AddBook] Opening file picker');
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['epub', 'pdf', 'm4b', 'mp3'],
      withData: true,
    );
    if (result == null || result.files.isEmpty) {
      debugPrint('[AddBook] File picker cancelled');
      _toast('No file selected.');
      return;
    }

    final picked = result.files.single;
    final ext = (picked.extension ?? '').toLowerCase();
    debugPrint(
      '[AddBook] Selected name=${picked.name}, extension=$ext, '
      'path=${picked.path != null}, bytes=${picked.bytes?.length ?? 0}',
    );
    final contentType = _contentTypeFor(ext);
    if (contentType == null) {
      _toast('Unsupported file — pick an EPUB, PDF, M4B or MP3.');
      return;
    }
    final bytes = picked.bytes;
    final path = picked.path;
    if ((bytes == null || bytes.isEmpty) && path == null) {
      _toast('Could not read that file. Try downloading it locally first.');
      return;
    }
    if (!mounted) return; // the OS picker is an async gap

    final title = _titleFrom(picked.name);
    setState(() {
      _busy = true;
      _busyMessage = 'Preparing “$title”…';
    });
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);
    final navigator = Navigator.of(context);

    try {
      final file = path == null ? null : File(path);
      final contentLength = file != null
          ? await file.length()
          : bytes!.length;
      debugPrint(
        '[AddBook] Upload source=${file != null ? 'file' : 'memory'}, '
        'length=$contentLength, contentType=$contentType',
      );
      final body = file != null
          ? file.openRead()
          : Stream<List<int>>.fromIterable([bytes!]);
      final upload = ref.read(uploadServiceProvider);
      debugPrint('[AddBook] Requesting presigned upload');
      if (mounted) {
        setState(() => _busyMessage = 'Reserving upload space…');
      }
      final presigned = await upload.presign(
        PresignUploadRequest(
          format: ext,
          contentType: contentType,
          contentLength: contentLength,
        ),
      );
      debugPrint(
        '[AddBook] Presign succeeded, fileKey=${presigned.fileKey}, '
        'method=${presigned.method}',
      );
      if (mounted) {
        setState(() => _busyMessage = 'Uploading “$title”…');
      }
      await upload.putToStorage(
        uploadUrl: presigned.uploadUrl,
        body: body,
        contentLength: contentLength,
        contentType: contentType,
        onSendProgress: (sent, total) {
          if (!mounted || total <= 0) return;
          final percent = (sent / total * 100).round();
          if (percent == 1 || percent % 10 == 0) {
            debugPrint('[AddBook] Storage upload progress=$percent%');
          }
          setState(() => _busyMessage = 'Uploading “$title”… $percent%');
        },
      );
      debugPrint('[AddBook] Storage upload completed');
      if (mounted) {
        setState(() => _busyMessage = 'Saving “$title” to your library…');
      }
      final request = BookCreateRequest(
        title: title,
        format: ext,
        // Audio files land straight on the Listening shelf.
        status: (ext == 'm4b' || ext == 'mp3') ? 'listening' : null,
        fileKey: presigned.fileKey,
      );
      final books = ref.read(bookServiceProvider);
      var createAttempt = 0;
      while (true) {
        try {
          await books.create(request);
          break;
        } on ApiError catch (e) {
          final uploadNotVisible = e.message.toLowerCase().contains(
            'upload not found',
          );
          if (!uploadNotVisible || createAttempt >= 2) rethrow;
          createAttempt++;
          debugPrint(
            '[AddBook] Uploaded object not visible yet; retrying book '
            'creation ($createAttempt/2)',
          );
          await Future<void>.delayed(
            Duration(milliseconds: 500 * createAttempt),
          );
        }
      }
      debugPrint('[AddBook] Book creation completed');
      ref.invalidate(libraryBooksProvider);
      if (!mounted) return;
      navigator.pop(); // close the sheet
      router.go(Routes.library);
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(appSnackBar('Added “$title”', SnackType.success));
    } on ApiError catch (e) {
      debugPrint('[AddBook] API error: ${e.message}');
      if (!mounted) return;
      setState(() => _busy = false);
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(appSnackBar(e.message, SnackType.error));
    } on DioException catch (e) {
      debugPrint(
        '[AddBook] Dio error: type=${e.type}, status=${e.response?.statusCode}, '
        'message=${e.message}',
      );
      if (!mounted) return;
      setState(() => _busy = false);
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(appSnackBar(_uploadErrorMessage(e), SnackType.error));
    } catch (e) {
      debugPrint('[AddBook] Unexpected error: $e');
      if (!mounted) return;
      setState(() => _busy = false);
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          appSnackBar('Upload failed — ${e.toString()}', SnackType.error),
        );
    }
  }

  String _uploadErrorMessage(DioException error) {
    final status = error.response?.statusCode;
    if (status != null) return 'Upload failed — storage returned HTTP $status.';
    return 'Upload failed — check your connection.';
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
      _busyMessage,
      textAlign: TextAlign.center,
      style: AppTypography.subtitle(colors.text2),
    ),
    const SizedBox(height: AppSpacing.xxxl),
  ];

  List<Widget> _options(AppColorsExtension colors) => [
    Text('Add to library', style: AppTypography.title2(colors.text)),
    const SizedBox(height: AppSpacing.xs),
    Text('Bring your own books.', style: AppTypography.subtitle(colors.text2)),
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
      icon: Icons.search,
      title: 'Search for a book',
      subtitle: 'Find titles from Google Books and Gutenberg',
      onTap: _openDiscovery,
    ),
  ];

  void _openDiscovery() {
    final router = GoRouter.of(context);
    Navigator.of(context).pop();
    router.go(Routes.discovery);
  }

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
          decoration: BoxDecoration(borderRadius: AppRadii.brLg),
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
