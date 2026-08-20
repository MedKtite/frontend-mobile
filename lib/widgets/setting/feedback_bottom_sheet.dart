import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../app/theme/tokens/colors.dart';
import '../../app/theme/tokens/radii.dart';
import '../../app/theme/tokens/spacing.dart';
import '../../app/theme/tokens/typography.dart';
import '../../core/widgets/app_snackbar.dart';
import '../../providers/auth_provider.dart';
import '../../providers/state/auth_state.dart';
import '../../services/backend/data_sync_service.dart';
import '../../services/backend/support_service.dart';

Future<void> showFeedbackBottomSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => const _FeedbackBottomSheet(),
  );
}

class _FeedbackBottomSheet extends ConsumerStatefulWidget {
  const _FeedbackBottomSheet();

  @override
  ConsumerState<_FeedbackBottomSheet> createState() => _FeedbackBottomSheetState();
}

class _FeedbackBottomSheetState extends ConsumerState<_FeedbackBottomSheet> {
  final _controller = TextEditingController();
  String _selectedCategory = 'Bug Report';
  bool _includeDiagnostics = true;
  bool _isSubmitting = false;

  final List<String> _categories = [
    'Bug Report',
    'Feature Request',
    'Book Issue',
    'General Question',
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      showAppSnack(context, 'Please describe your feedback or issue.');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final auth = ref.read(authProvider);
      final user = auth is AuthAuthenticated ? auth.user : null;
      final syncService = ref.read(dataSyncServiceProvider);
      final deviceName = await syncService.getCurrentDeviceName();

      String appVersion = '1.0.0';
      try {
        final pkg = await PackageInfo.fromPlatform();
        appVersion = '${pkg.version} (${pkg.buildNumber})';
      } catch (_) {}

      final supportService = ref.read(supportServiceProvider);
      await supportService.submitFeedback(
        category: _selectedCategory,
        message: text,
        email: user?.email,
        appVersion: _includeDiagnostics ? appVersion : null,
        deviceModel: _includeDiagnostics ? deviceName : null,
        osVersion: _includeDiagnostics ? (kIsWeb ? 'Web' : Platform.operatingSystemVersion) : null,
      );

      if (mounted) {
        Navigator.of(context).pop();
        showAppSnack(context, 'Thank you! Your feedback has been received.');
      }
    } catch (e) {
      if (mounted) {
        showAppSnack(context, 'Could not send feedback. Please try again.');
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(24, 20, 24, 20 + bottomInset),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(
          top: BorderSide(color: colors.border.withValues(alpha: 0.1), width: 1),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Handle Bar
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
                        'Send Feedback & Support',
                        style: AppTypography.serif(
                          TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.w600,
                            color: colors.text,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'We read and appreciate every reader message.',
                        style: AppTypography.sans(
                          TextStyle(fontSize: 12.5, color: colors.text3),
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

              // Category Selector Chips
              Text(
                'FEEDBACK TOPIC',
                style: AppTypography.sans(
                  TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.4,
                    color: colors.text3,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _categories.map((cat) {
                  final isSelected = _selectedCategory == cat;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedCategory = cat),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                      decoration: BoxDecoration(
                        color: isSelected ? colors.gilt : colors.bg,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? colors.gilt
                              : colors.border.withValues(alpha: 0.12),
                        ),
                      ),
                      child: Text(
                        cat,
                        style: AppTypography.sans(
                          TextStyle(
                            fontSize: 12.5,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                            color: isSelected ? Colors.white : colors.text2,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: AppSpacing.lg),

              // Description text field
              Text(
                'YOUR MESSAGE',
                style: AppTypography.sans(
                  TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.4,
                    color: colors.text3,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              TextField(
                controller: _controller,
                maxLines: 4,
                style: AppTypography.body(colors.text),
                decoration: InputDecoration(
                  hintText: 'Describe what happened, or share an idea that would make your reading better...',
                  hintStyle: AppTypography.body(colors.text3),
                  filled: true,
                  fillColor: colors.bg,
                  contentPadding: const EdgeInsets.all(14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: colors.border.withValues(alpha: 0.1)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: colors.border.withValues(alpha: 0.1)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: colors.gilt, width: 1.5),
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              // Diagnostics checkbox switch
              GestureDetector(
                onTap: () => setState(() => _includeDiagnostics = !_includeDiagnostics),
                child: Row(
                  children: [
                    Icon(
                      _includeDiagnostics
                          ? Icons.check_box_rounded
                          : Icons.check_box_outline_blank_rounded,
                      color: _includeDiagnostics ? colors.gilt : colors.text3,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Attach device model & app version to help resolve issues faster',
                        style: AppTypography.sans(
                          TextStyle(fontSize: 12, color: colors.text3),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              // Send Button
              FilledButton(
                onPressed: _isSubmitting ? null : _submit,
                style: FilledButton.styleFrom(
                  backgroundColor: colors.text,
                  foregroundColor: colors.bg,
                  shape: const RoundedRectangleBorder(borderRadius: AppRadii.brFull),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isSubmitting
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: colors.bg,
                        ),
                      )
                    : Text(
                        'Send Feedback',
                        style: AppTypography.label(colors.bg).copyWith(fontWeight: FontWeight.w600),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
