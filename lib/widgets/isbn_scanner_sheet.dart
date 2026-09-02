import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../app/theme/tokens/colors.dart';
import '../app/theme/tokens/radii.dart';
import '../app/theme/tokens/spacing.dart';
import '../app/theme/tokens/typography.dart';
import '../models/catalog_book.dart';
import '../services/frontend/isbn_lookup_service.dart';
import 'app_progress_bar.dart';

/// Opens the camera barcode scanner modal sheet for physical book cataloging.
/// Returns the resolved [CatalogBook] (if found via metadata lookup) or the
/// raw scanned ISBN string.
Future<dynamic> showIsbnScannerSheet(BuildContext context) {
  return showModalBottomSheet<dynamic>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const IsbnScannerSheet(),
  );
}

class IsbnScannerSheet extends ConsumerStatefulWidget {
  const IsbnScannerSheet({super.key});

  @override
  ConsumerState<IsbnScannerSheet> createState() => _IsbnScannerSheetState();
}

class _IsbnScannerSheetState extends ConsumerState<IsbnScannerSheet> {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    formats: const [
      BarcodeFormat.ean13,
      BarcodeFormat.ean8,
      BarcodeFormat.upcA,
      BarcodeFormat.upcE,
      BarcodeFormat.code128,
    ],
  );

  bool _isProcessing = false;
  bool _isTorchOn = false;
  String? _statusText;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleBarcode(BarcodeCapture capture) async {
    if (_isProcessing) return;
    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final rawValue = barcodes.first.rawValue;
    if (rawValue == null || rawValue.trim().isEmpty) return;

    final cleaned = IsbnLookupService.cleanIsbn(rawValue);
    if (cleaned.length < 10) return; // ignore non-ISBN barcodes

    setState(() {
      _isProcessing = true;
      _statusText = 'Looking up book details…';
    });

    HapticFeedback.mediumImpact();

    try {
      final lookupService = ref.read(isbnLookupServiceProvider);
      final book = await lookupService.lookup(cleaned);

      if (!mounted) return;

      if (book != null) {
        HapticFeedback.lightImpact();
        Navigator.of(context).pop(book);
      } else {
        // Pop with just the raw ISBN so the user doesn't lose the scan
        Navigator.of(context).pop(cleaned);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isProcessing = false;
        _statusText = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lookup error. Try scanning again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final size = MediaQuery.of(context).size;

    return Container(
      height: size.height * 0.85,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppRadii.xl),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            // Handle pill
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.sm),
              child: Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colors.border,
                    borderRadius: BorderRadius.circular(AppRadii.full),
                  ),
                ),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.pageHorizontal,
                AppSpacing.md,
                AppSpacing.pageHorizontal,
                AppSpacing.sm,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Scan ISBN Barcode',
                          style: AppTypography.title2(colors.text),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Point camera at the barcode on the back cover',
                          style: AppTypography.caption(colors.text2),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: colors.text2),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // Scanner Viewport
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadii.lg),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.pageHorizontal,
                      ),
                      child: AspectRatio(
                        aspectRatio: 3 / 4,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            MobileScanner(
                              controller: _controller,
                              onDetect: _handleBarcode,
                            ),
                            // Scanning Reticle Overlay
                            _ScannerOverlay(
                              accentColor: colors.accent,
                              isProcessing: _isProcessing,
                              statusText: _statusText,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Bottom controls: Torch & Camera flip
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.pageHorizontal,
                vertical: AppSpacing.md,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: Icon(
                      _isTorchOn ? Icons.flash_on : Icons.flash_off,
                      color: _isTorchOn ? colors.accent : colors.text2,
                    ),
                    onPressed: () async {
                      await _controller.toggleTorch();
                      setState(() => _isTorchOn = !_isTorchOn);
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.flip_camera_ios, color: colors.text2),
                    onPressed: () => _controller.switchCamera(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScannerOverlay extends StatelessWidget {
  const _ScannerOverlay({
    required this.accentColor,
    required this.isProcessing,
    this.statusText,
  });

  final Color accentColor;
  final bool isProcessing;
  final String? statusText;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.black.withValues(alpha: 0.3),
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(AppRadii.lg),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Target box
          Container(
            width: 240,
            height: 140,
            decoration: BoxDecoration(
              border: Border.all(color: accentColor, width: 2),
              borderRadius: BorderRadius.circular(AppRadii.md),
              color: Colors.black.withValues(alpha: 0.12),
            ),
          ),
          if (isProcessing)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(AppRadii.md),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppProgressRing(
                    size: 28,
                    strokeWidth: 1.5,
                    fillColor: accentColor,
                  ),
                  if (statusText != null) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      statusText!,
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                    ),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }
}
