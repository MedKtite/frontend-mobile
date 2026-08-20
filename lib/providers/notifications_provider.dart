import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/notification_model.dart';
import '../services/backend/notification_service.dart';

class NotificationsState {
  final String activeTab; // 'all', 'unread', 'activity'
  final List<NotificationItemModel> items;
  final int unreadCount;
  final bool isLoading;
  final String? errorMessage;

  NotificationsState({
    required this.activeTab,
    required this.items,
    required this.unreadCount,
    required this.isLoading,
    this.errorMessage,
  });

  factory NotificationsState.initial() {
    return NotificationsState(
      activeTab: 'all',
      items: const [],
      unreadCount: 0,
      isLoading: false,
    );
  }

  NotificationsState copyWith({
    String? activeTab,
    List<NotificationItemModel>? items,
    int? unreadCount,
    bool? isLoading,
    String? errorMessage,
  }) {
    return NotificationsState(
      activeTab: activeTab ?? this.activeTab,
      items: items ?? this.items,
      unreadCount: unreadCount ?? this.unreadCount,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class NotificationsNotifier extends StateNotifier<NotificationsState> {
  final NotificationService _service;

  NotificationsNotifier(this._service) : super(NotificationsState.initial()) {
    load();
  }

  Future<void> load({String? tab}) async {
    final targetTab = tab ?? state.activeTab;
    state = state.copyWith(isLoading: true, activeTab: targetTab, errorMessage: null);

    try {
      final items = await _service.getNotifications(tab: targetTab);
      final unreadCount = await _service.getUnreadCount();
      state = state.copyWith(
        items: items,
        unreadCount: unreadCount,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> setTab(String tab) async {
    if (state.activeTab == tab) return;
    await load(tab: tab);
  }

  Future<void> markAsRead(String id) async {
    final oldItems = state.items;
    final updatedItems = oldItems.map((item) {
      if (item.id == id && item.isUnread) {
        return item.copyWith(isUnread: false, readAt: DateTime.now());
      }
      return item;
    }).toList();

    final newUnreadCount = (state.unreadCount - 1).clamp(0, 999);
    state = state.copyWith(items: updatedItems, unreadCount: newUnreadCount);

    try {
      await _service.markAsRead(id);
    } catch (_) {
      // Revert if failed
      state = state.copyWith(items: oldItems);
    }
  }

  Future<void> markAllAsRead() async {
    final oldItems = state.items;
    final updatedItems = oldItems.map((item) {
      return item.copyWith(isUnread: false, readAt: DateTime.now());
    }).toList();

    state = state.copyWith(items: updatedItems, unreadCount: 0);

    try {
      await _service.markAllAsRead();
    } catch (_) {
      state = state.copyWith(items: oldItems);
    }
  }

  Future<void> deleteNotification(String id) async {
    final oldItems = state.items;
    final updatedItems = oldItems.where((item) => item.id != id).toList();
    state = state.copyWith(items: updatedItems);

    try {
      await _service.deleteNotification(id);
    } catch (_) {
      state = state.copyWith(items: oldItems);
    }
  }
}

final notificationsProvider =
    StateNotifierProvider<NotificationsNotifier, NotificationsState>((ref) {
  return NotificationsNotifier(ref.watch(notificationServiceProvider));
});
