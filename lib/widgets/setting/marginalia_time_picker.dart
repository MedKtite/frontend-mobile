import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../app/theme/tokens/colors.dart';
import '../../app/theme/tokens/radii.dart';
import '../../app/theme/tokens/spacing.dart';
import '../../app/theme/tokens/typography.dart';

/// Shows a bespoke Marginalia-styled time picker bottom sheet that perfectly matches
/// the app's literary aesthetic, typography, and warm paper/night palette.
Future<TimeOfDay?> showMarginaliaTimePicker(
  BuildContext context, {
  required TimeOfDay initialTime,
  String title = 'Select Time',
  String? subtitle,
}) {
  return showModalBottomSheet<TimeOfDay>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => _MarginaliaTimePickerSheet(
      initialTime: initialTime,
      title: title,
      subtitle: subtitle,
    ),
  );
}

class _MarginaliaTimePickerSheet extends StatefulWidget {
  final TimeOfDay initialTime;
  final String title;
  final String? subtitle;

  const _MarginaliaTimePickerSheet({
    required this.initialTime,
    required this.title,
    this.subtitle,
  });

  @override
  State<_MarginaliaTimePickerSheet> createState() => _MarginaliaTimePickerSheetState();
}

class _MarginaliaTimePickerSheetState extends State<_MarginaliaTimePickerSheet> {
  late int _hour; // 1 - 12
  late int _minute; // 0 - 59
  late bool _isPm;

  @override
  void initState() {
    super.initState();
    final h = widget.initialTime.hour;
    _isPm = h >= 12;
    _hour = h == 0 ? 12 : (h > 12 ? h - 12 : h);
    _minute = widget.initialTime.minute;
  }

  TimeOfDay get _selectedTime {
    int h = _hour;
    if (_isPm) {
      if (h != 12) h += 12;
    } else {
      if (h == 12) h = 0;
    }
    return TimeOfDay(hour: h, minute: _minute);
  }

  void _applyPreset(int hour24, int minute) {
    setState(() {
      _isPm = hour24 >= 12;
      _hour = hour24 == 0 ? 12 : (hour24 > 12 ? hour24 - 12 : hour24);
      _minute = minute;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

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

            // Header Title & Subtitle
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: GoogleFonts.sourceSerif4(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: colors.text,
                          letterSpacing: -0.3,
                        ),
                      ),
                      if (widget.subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          widget.subtitle!,
                          style: AppTypography.sans(
                            TextStyle(
                              fontSize: 13,
                              color: colors.text3,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close_rounded, color: colors.text3, size: 22),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.lg),

            // Time Display Card (Large Serif Numbers + AM/PM Toggle)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: colors.bg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: colors.border.withValues(alpha: 0.1),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Hour display
                  Text(
                    _hour.toString().padLeft(2, '0'),
                    style: GoogleFonts.sourceSerif4(
                      fontSize: 48,
                      fontWeight: FontWeight.w500,
                      color: colors.text,
                      letterSpacing: -1,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      ':',
                      style: GoogleFonts.sourceSerif4(
                        fontSize: 44,
                        fontWeight: FontWeight.w400,
                        color: colors.gilt,
                      ),
                    ),
                  ),
                  // Minute display
                  Text(
                    _minute.toString().padLeft(2, '0'),
                    style: GoogleFonts.sourceSerif4(
                      fontSize: 48,
                      fontWeight: FontWeight.w500,
                      color: colors.text,
                      letterSpacing: -1,
                    ),
                  ),

                  const SizedBox(width: 24),

                  // AM / PM Segmented Selector
                  Container(
                    decoration: BoxDecoration(
                      color: colors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: colors.border.withValues(alpha: 0.12),
                        width: 1,
                      ),
                    ),
                    padding: const EdgeInsets.all(3),
                    child: Column(
                      children: [
                        _PeriodButton(
                          label: 'AM',
                          isSelected: !_isPm,
                          onTap: () => setState(() => _isPm = false),
                        ),
                        const SizedBox(height: 3),
                        _PeriodButton(
                          label: 'PM',
                          isSelected: _isPm,
                          onTap: () => setState(() => _isPm = true),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // Hour Grid (1 to 12)
            Text(
              'HOUR',
              style: AppTypography.sans(
                TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.4,
                  color: colors.text3,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.spaceBetween,
              children: List.generate(12, (index) {
                final hourVal = index + 1;
                final isSelected = _hour == hourVal;

                return GestureDetector(
                  onTap: () => setState(() => _hour = hourVal),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: (MediaQuery.of(context).size.width - 48 - 40) / 6,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isSelected ? colors.gilt : colors.bg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? colors.gilt
                            : colors.border.withValues(alpha: 0.1),
                        width: 1,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '$hourVal',
                      style: GoogleFonts.sourceSerif4(
                        fontSize: 16,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        color: isSelected ? Colors.white : colors.text,
                      ),
                    ),
                  ),
                );
              }),
            ),

            const SizedBox(height: AppSpacing.md),

            // Minute Selector Chips (:00, :15, :30, :45)
            Text(
              'MINUTE',
              style: AppTypography.sans(
                TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.4,
                  color: colors.text3,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [0, 15, 30, 45].map((minVal) {
                final isSelected = _minute == minVal;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: GestureDetector(
                      onTap: () => setState(() => _minute = minVal),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        height: 38,
                        decoration: BoxDecoration(
                          color: isSelected ? colors.gilt : colors.bg,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? colors.gilt
                                : colors.border.withValues(alpha: 0.1),
                            width: 1,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          ':${minVal.toString().padLeft(2, '0')}',
                          style: AppTypography.sans(
                            TextStyle(
                              fontSize: 14,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                              color: isSelected ? Colors.white : colors.text,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: AppSpacing.lg),

            // Quick Presets Row
            Text(
              'QUICK PRESETS',
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
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _PresetChip(
                    label: 'Morning (8:00 AM)',
                    onTap: () => _applyPreset(8, 0),
                  ),
                  _PresetChip(
                    label: 'Afternoon (2:00 PM)',
                    onTap: () => _applyPreset(14, 0),
                  ),
                  _PresetChip(
                    label: 'Evening (7:00 PM)',
                    onTap: () => _applyPreset(19, 0),
                  ),
                  _PresetChip(
                    label: 'Night (10:00 PM)',
                    onTap: () => _applyPreset(22, 0),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.xl),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colors.text,
                      side: BorderSide(color: colors.border.withValues(alpha: 0.2)),
                      shape: const RoundedRectangleBorder(borderRadius: AppRadii.brFull),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text('Cancel', style: AppTypography.label(colors.text)),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: FilledButton(
                    onPressed: () => Navigator.of(context).pop(_selectedTime),
                    style: FilledButton.styleFrom(
                      backgroundColor: colors.text,
                      foregroundColor: colors.bg,
                      shape: const RoundedRectangleBorder(borderRadius: AppRadii.brFull),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(
                      'Confirm Time',
                      style: AppTypography.label(colors.bg).copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PeriodButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _PeriodButton({
    required this.label,
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
        width: 48,
        height: 28,
        decoration: BoxDecoration(
          color: isSelected ? colors.gilt : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: AppTypography.sans(
            TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? Colors.white : colors.text2,
            ),
          ),
        ),
      ),
    );
  }
}

class _PresetChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _PresetChip({
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ActionChip(
        label: Text(
          label,
          style: AppTypography.sans(
            TextStyle(fontSize: 12, color: colors.text2),
          ),
        ),
        backgroundColor: colors.bg,
        side: BorderSide(color: colors.border.withValues(alpha: 0.1)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        onPressed: onTap,
      ),
    );
  }
}
