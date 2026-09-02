import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/notification_preferences_model.dart';
import '../services/backend/notification_service.dart';

class NotificationPreferencesNotifier
    extends StateNotifier<AsyncValue<NotificationPreferencesModel>> {
  final NotificationService _service;

  NotificationPreferencesNotifier(this._service)
    : super(const AsyncValue.loading()) {
    load();
  }

  Future<void> load() async {
    state = const AsyncValue.loading();
    try {
      final prefs = await _service.getPreferences();
      state = AsyncValue.data(prefs);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> update(NotificationPreferencesModel newPrefs) async {
    state = AsyncValue.data(newPrefs);
    try {
      final updated = await _service.updatePreferences(newPrefs);
      state = AsyncValue.data(updated);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> toggleCategory(String categoryKey, bool value) async {
    final current =
        state.valueOrNull ?? NotificationPreferencesModel.defaults();
    final updatedCats = Map<String, bool>.from(current.categories);
    updatedCats[categoryKey] = value;
    await update(current.copyWith(categories: updatedCats));
  }

  Future<void> setRitualTime(int hour) async {
    final current =
        state.valueOrNull ?? NotificationPreferencesModel.defaults();
    await update(current.copyWith(ritualTimeLocal: hour));
  }

  Future<void> toggleMasterSwitch(bool enabled) async {
    final current =
        state.valueOrNull ?? NotificationPreferencesModel.defaults();
    await update(current.copyWith(enabled: enabled));
  }
}

final notificationPreferencesProvider =
    StateNotifierProvider<
      NotificationPreferencesNotifier,
      AsyncValue<NotificationPreferencesModel>
    >((ref) {
      return NotificationPreferencesNotifier(
        ref.watch(notificationServiceProvider),
      );
    });
