import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../app/theme/tokens/colors.dart';
import '../../app/theme/tokens/radii.dart';
import '../../app/theme/tokens/spacing.dart';
import '../../app/theme/tokens/typography.dart';
import '../../core/widgets/app_snackbar.dart';
import '../../providers/data_sync_provider.dart';
import '../../widgets/auth_scaffold.dart';
import '../../widgets/setting/export_data_sheet.dart';

class DataSyncScreen extends ConsumerWidget {
  const DataSyncScreen({super.key});

  String _formatBytes(int bytes) {
    if (bytes <= 0) return '0 KB';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  String _formatRelativeTime(DateTime? time) {
    if (time == null) return 'Never';
    final diff = DateTime.now().difference(time);
    if (diff.inSeconds < 45) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} hours ago';
    return DateFormat('MMM d, h:mm a').format(time);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final state = ref.watch(dataSyncProvider);
    final notifier = ref.read(dataSyncProvider.notifier);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _TopBar(
              title: 'Data & Sync',
              onBack: () => Navigator.of(context).pop(),
            ),
            Expanded(
              child: RefreshIndicator(
                color: colors.gilt,
                backgroundColor: colors.surface,
                onRefresh: () => notifier.refresh(),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.pageHorizontal,
                    AppSpacing.sm,
                    AppSpacing.pageHorizontal,
                    AppSpacing.xxxl,
                  ),
                  children: [
                    // 1. Live Sync Status Card
                    _SyncStatusCard(
                      isSyncing: state.isSyncing,
                      lastSyncedText: _formatRelativeTime(state.lastSyncedAt),
                      onSyncNow: () async {
                        await notifier.triggerSync();
                        if (context.mounted) {
                          showAppSnack(context, 'Sync completed. Library is up to date.');
                        }
                      },
                    ),

                    const SizedBox(height: AppSpacing.xl),

                    // 2. Data Export Section
                    _SectionHeader(title: 'DATA EXPORT (NO LOCK-IN)'),
                    const SizedBox(height: AppSpacing.xs),
                    _CardContainer(
                      child: InkWell(
                        onTap: () => showExportDataSheet(context),
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: colors.gilt.withValues(alpha: 0.1),
                                  border: Border.all(
                                    color: colors.gilt.withValues(alpha: 0.3),
                                  ),
                                ),
                                child: Center(
                                  child: Icon(
                                    Icons.download_rounded,
                                    color: colors.gilt,
                                    size: 22,
                                  ),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Export Highlights & Notes',
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
                                      'Download as Formatted PDF or Spreadsheet (CSV)',
                                      style: AppTypography.sans(
                                        TextStyle(fontSize: 12.5, color: colors.text3),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.chevron_right_rounded,
                                color: colors.text3,
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: AppSpacing.xl),

                    // 3. Connected Devices Section
                    _SectionHeader(title: 'CONNECTED DEVICES'),
                    const SizedBox(height: AppSpacing.xs),
                    _CardContainer(
                      children: [
                        // Current Device Row (Always first)
                        _CurrentDeviceRow(
                          deviceName: state.currentDeviceName,
                        ),

                        // Other Synced Devices
                        for (var i = 0; i < state.devices.length; i++) ...[
                          Divider(
                            height: 1,
                            color: colors.border.withValues(alpha: 0.08),
                            indent: 56,
                          ),
                          _DeviceRow(
                            device: state.devices[i],
                            onRemove: () => notifier.removeDevice(state.devices[i]['id'].toString()),
                          ),
                        ],
                      ],
                    ),

                    const SizedBox(height: AppSpacing.xl),

                    // 4. Offline Storage & Cache Management
                    _SectionHeader(title: 'STORAGE & OFFLINE CACHE'),
                    const SizedBox(height: AppSpacing.xs),
                    _CardContainer(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Local Cache Size',
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
                                        'Downloaded book copies, audio & covers',
                                        style: AppTypography.sans(
                                          TextStyle(fontSize: 12.5, color: colors.text3),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                Text(
                                  _formatBytes(state.cacheSizeBytes),
                                  style: AppTypography.sans(
                                    TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: colors.gilt,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.md),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                icon: Icon(Icons.cleaning_services_outlined, size: 16, color: colors.text2),
                                label: Text(
                                  'Clear Offline Cache',
                                  style: AppTypography.label(colors.text2),
                                ),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: colors.text,
                                  side: BorderSide(color: colors.border.withValues(alpha: 0.2)),
                                  shape: const RoundedRectangleBorder(borderRadius: AppRadii.brFull),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                                onPressed: () async {
                                  await notifier.clearCache();
                                  if (context.mounted) {
                                    showAppSnack(context, 'Offline cache cleared safely.');
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final String title;
  final VoidCallback onBack;

  const _TopBar({required this.title, required this.onBack});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.pageHorizontal,
        vertical: AppSpacing.xs,
      ),
      child: Row(
        children: [
          AuthBackButton(onPressed: onBack),
          Expanded(
            child: Center(
              child: Text(
                title,
                style: AppTypography.serif(
                  TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w500,
                    color: colors.text,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 44),
        ],
      ),
    );
  }
}

class _SyncStatusCard extends StatelessWidget {
  final bool isSyncing;
  final String lastSyncedText;
  final VoidCallback onSyncNow;

  const _SyncStatusCard({
    required this.isSyncing,
    required this.lastSyncedText,
    required this.onSyncNow,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colors.border.withValues(alpha: 0.08),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.015),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSyncing ? colors.warning : colors.success,
                  boxShadow: [
                    BoxShadow(
                      color: (isSyncing ? colors.warning : colors.success).withValues(alpha: 0.4),
                      blurRadius: 4,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                isSyncing ? 'Syncing with Marginalia Cloud...' : 'Library Up to Date',
                style: AppTypography.serif(
                  TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: colors.text,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Last synchronized: $lastSyncedText',
            style: AppTypography.sans(
              TextStyle(fontSize: 13, color: colors.text3),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: isSyncing ? null : onSyncNow,
              icon: isSyncing
                  ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: colors.bg),
                    )
                  : const Icon(Icons.sync_rounded, size: 18),
              label: Text(
                isSyncing ? 'Syncing...' : 'Sync Now',
                style: AppTypography.label(colors.bg).copyWith(fontWeight: FontWeight.w600),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: colors.text,
                foregroundColor: colors.bg,
                shape: const RoundedRectangleBorder(borderRadius: AppRadii.brFull),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CurrentDeviceRow extends StatelessWidget {
  final String deviceName;

  const _CurrentDeviceRow({required this.deviceName});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colors.gilt.withValues(alpha: 0.1),
            ),
            child: Center(
              child: Icon(Icons.phone_android_rounded, color: colors.gilt, size: 20),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        deviceName,
                        style: AppTypography.serif(
                          TextStyle(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w600,
                            color: colors.text,
                          ),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: colors.gilt.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'This Device',
                        style: AppTypography.sans(
                          TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                            color: colors.gilt,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: colors.success,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Active now · Marginalia Cloud Synced',
                      style: AppTypography.caption(colors.text3),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DeviceRow extends StatelessWidget {
  final Map<String, dynamic> device;
  final VoidCallback onRemove;

  const _DeviceRow({required this.device, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final platform = (device['platform'] as String? ?? 'device').toLowerCase();
    final name = device['device_name'] as String? ?? (platform == 'ios' ? 'Apple Device' : 'Android Device');

    IconData icon = Icons.phone_android_rounded;
    if (platform == 'ios') icon = Icons.phone_iphone_rounded;
    if (platform == 'web') icon = Icons.laptop_rounded;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: colors.text3, size: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AppTypography.serif(
                    TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: colors.text,
                    ),
                  ),
                ),
                Text(
                  'Connected via Marginalia Sync',
                  style: AppTypography.caption(colors.text3),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.delete_outline_rounded, color: colors.text3, size: 20),
            onPressed: onRemove,
            tooltip: 'Unlink device',
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Padding(
      padding: const EdgeInsets.only(left: AppSpacing.sm, bottom: AppSpacing.xs),
      child: Text(
        title,
        style: AppTypography.sans(
          TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.4,
            color: colors.text3,
          ),
        ),
      ),
    );
  }
}

class _CardContainer extends StatelessWidget {
  final Widget? child;
  final List<Widget>? children;

  const _CardContainer({this.child, this.children});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colors.border.withValues(alpha: 0.08),
          width: 1,
        ),
      ),
      child: child ?? Column(mainAxisSize: MainAxisSize.min, children: children ?? []),
    );
  }
}
