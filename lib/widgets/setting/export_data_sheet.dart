import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import '../../app/theme/tokens/colors.dart';
import '../../app/theme/tokens/radii.dart';
import '../../app/theme/tokens/spacing.dart';
import '../../app/theme/tokens/typography.dart';
import '../../core/widgets/app_snackbar.dart';
import '../../providers/data_sync_provider.dart';
import '../../services/backend/data_sync_service.dart';
import '../app_progress_bar.dart';

/// User-friendly Export Data bottom sheet for everyday readers.
/// Supports clean printable PDF reports and Spreadsheet (CSV) exports.
Future<void> showExportDataSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => const _ExportDataSheet(),
  );
}

class _ExportDataSheet extends ConsumerStatefulWidget {
  const _ExportDataSheet();

  @override
  ConsumerState<_ExportDataSheet> createState() => _ExportDataSheetState();
}

class _ExportDataSheetState extends ConsumerState<_ExportDataSheet> {
  String _selectedFormat = 'pdf'; // 'pdf' | 'csv'
  bool _isExporting = false;

  Future<void> _handleExport() async {
    setState(() => _isExporting = true);

    try {
      final service = ref.read(dataSyncServiceProvider);
      final bytes = await service.downloadExportBytes(format: _selectedFormat);

      if (bytes.isEmpty) {
        if (mounted) showAppSnack(context, 'No highlights or notes to export.');
        setState(() => _isExporting = false);
        return;
      }

      final dir = await getApplicationDocumentsDirectory();
      final ext = _selectedFormat == 'csv' ? 'csv' : 'pdf';
      final fileName = 'Marginalia_Highlights_Export.$ext';
      final file = File('${dir.path}/$fileName');
      await file.writeAsBytes(bytes);

      if (mounted) {
        Navigator.of(context).pop();
        showAppSnack(context, 'Export saved: $fileName');
      }
    } catch (e) {
      if (mounted) {
        showAppSnack(context, 'Export failed: ${e.toString()}');
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final syncState = ref.watch(dataSyncProvider);
    final summary = syncState.exportSummary;

    final highlightsCount = summary['highlights_count'] ?? 0;
    final booksCount = summary['books_count'] ?? 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(
          top: BorderSide(color: colors.border.withValues(alpha: 0.1), width: 1),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.border.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Export Your Notes',
                      style: AppTypography.serif(
                        TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: colors.text,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$highlightsCount highlights across $booksCount books ready',
                      style: AppTypography.sans(
                        TextStyle(fontSize: 13, color: colors.text3),
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: Icon(Icons.close_rounded, color: colors.text3, size: 22),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.lg),

            // Format Selection Options
            _FormatOptionCard(
              title: 'PDF Document (.pdf)',
              subtitle: 'Formatted, printable document with books, quotes, tags & notes',
              icon: Icons.picture_as_pdf_outlined,
              isSelected: _selectedFormat == 'pdf',
              onTap: () => setState(() => _selectedFormat = 'pdf'),
            ),

            const SizedBox(height: AppSpacing.sm),

            _FormatOptionCard(
              title: 'Spreadsheet (.csv)',
              subtitle: 'Opens in Excel, Google Sheets, or Apple Numbers as a clean table',
              icon: Icons.table_chart_outlined,
              isSelected: _selectedFormat == 'csv',
              onTap: () => setState(() => _selectedFormat = 'csv'),
            ),

            const SizedBox(height: AppSpacing.xl),

            // Export Button
            FilledButton(
              onPressed: _isExporting ? null : _handleExport,
              style: FilledButton.styleFrom(
                backgroundColor: colors.text,
                foregroundColor: colors.bg,
                shape: const RoundedRectangleBorder(borderRadius: AppRadii.brFull),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isExporting
                  ? AppProgressRing(
                      size: 18,
                      strokeWidth: 1.5,
                      fillColor: colors.bg,
                      trackColor: colors.bg.withValues(alpha: 0.3),
                    )
                  : Text(
                      'Download ${_selectedFormat.toUpperCase()} Export',
                      style: AppTypography.label(colors.bg).copyWith(fontWeight: FontWeight.w600),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FormatOptionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _FormatOptionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? colors.gilt.withValues(alpha: 0.08) : colors.bg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? colors.gilt : colors.border.withValues(alpha: 0.1),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? colors.gilt : colors.surface,
                border: Border.all(
                  color: isSelected ? colors.gilt : colors.border.withValues(alpha: 0.15),
                ),
              ),
              child: Center(
                child: Icon(
                  icon,
                  size: 20,
                  color: isSelected ? Colors.white : colors.gilt,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.serif(
                      TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: colors.text,
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTypography.sans(
                      TextStyle(fontSize: 12.5, color: colors.text3, height: 1.3),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              isSelected ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
              color: isSelected ? colors.gilt : colors.text3,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}
