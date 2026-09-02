import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/backend/data_sync_service.dart';

class DataSyncState {
  final bool isSyncing;
  final DateTime? lastSyncedAt;
  final String currentDeviceName;
  final List<Map<String, dynamic>> devices;
  final Map<String, dynamic> exportSummary;
  final int cacheSizeBytes;
  final String? errorMessage;

  DataSyncState({
    required this.isSyncing,
    this.lastSyncedAt,
    required this.currentDeviceName,
    required this.devices,
    required this.exportSummary,
    required this.cacheSizeBytes,
    this.errorMessage,
  });

  factory DataSyncState.initial() {
    return DataSyncState(
      isSyncing: false,
      lastSyncedAt: DateTime.now(),
      currentDeviceName: 'This Device',
      devices: const [],
      exportSummary: const {},
      cacheSizeBytes: 0,
    );
  }

  DataSyncState copyWith({
    bool? isSyncing,
    DateTime? lastSyncedAt,
    String? currentDeviceName,
    List<Map<String, dynamic>>? devices,
    Map<String, dynamic>? exportSummary,
    int? cacheSizeBytes,
    String? errorMessage,
  }) {
    return DataSyncState(
      isSyncing: isSyncing ?? this.isSyncing,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      currentDeviceName: currentDeviceName ?? this.currentDeviceName,
      devices: devices ?? this.devices,
      exportSummary: exportSummary ?? this.exportSummary,
      cacheSizeBytes: cacheSizeBytes ?? this.cacheSizeBytes,
      errorMessage: errorMessage,
    );
  }
}

class DataSyncNotifier extends StateNotifier<DataSyncState> {
  final DataSyncService _service;

  DataSyncNotifier(this._service) : super(DataSyncState.initial()) {
    refresh();
  }

  Future<void> refresh() async {
    try {
      final currentName = await _service.getCurrentDeviceName();
      final devices = await _service.getDevices();
      final summary = await _service.getExportSummary();
      final cacheSize = await _service.estimateCacheSizeBytes();

      state = state.copyWith(
        currentDeviceName: currentName,
        devices: devices,
        exportSummary: summary,
        cacheSizeBytes: cacheSize,
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  Future<void> triggerSync() async {
    state = state.copyWith(isSyncing: true, errorMessage: null);
    try {
      await _service.triggerSync();
      state = state.copyWith(isSyncing: false, lastSyncedAt: DateTime.now());
    } catch (e) {
      state = state.copyWith(isSyncing: false, errorMessage: e.toString());
    }
  }

  Future<void> removeDevice(String deviceId) async {
    try {
      await _service.removeDevice(deviceId);
      final updated = state.devices.where((d) => d['id'] != deviceId).toList();
      state = state.copyWith(devices: updated);
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  Future<void> clearCache() async {
    await _service.clearLocalCache();
    final newSize = await _service.estimateCacheSizeBytes();
    state = state.copyWith(cacheSizeBytes: newSize);
  }
}

final dataSyncProvider = StateNotifierProvider<DataSyncNotifier, DataSyncState>(
  (ref) {
    return DataSyncNotifier(ref.watch(dataSyncServiceProvider));
  },
);
