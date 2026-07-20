import 'package:flutter/material.dart';
import 'package:marginalia/app/theme/tokens/colors.dart';
import 'package:marginalia/app/theme/tokens/spacing.dart';
import 'package:marginalia/app/theme/tokens/typography.dart';
import 'package:marginalia/widgets/auth_scaffold.dart';

// 1. Define a basic model for your notification data
class AppNotification {
  final String title;
  final String message;
  final String time;
  final IconData icon;
  final bool isUnread;

  AppNotification({
    required this.title,
    required this.message,
    required this.time,
    required this.icon,
    this.isUnread = true,
  });
}

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<AppNotification> notifications = [
      AppNotification(
        title: 'New Audiobook Added',
        message: 'Frankenstein by Mary Shelley is now available.',
        time: '2h ago',
        icon: Icons.headphones,
      ),
      AppNotification(
        title: 'Note Review',
        message: 'Review your recent tags from Chapter 4.',
        time: '1d ago',
        icon: Icons.bookmark_outline,
        isUnread: false,
      ),
      AppNotification(
        title: 'Note Review',
        message: 'Review your recent tags from Chapter 4.',
        time: '1d ago',
        icon: Icons.bookmark_outline,
        isUnread: false,
      ),
      AppNotification(
        title: 'Note Review',
        message: 'Review your recent tags from Chapter 4.',
        time: '1d ago',
        icon: Icons.bookmark_outline,
        isUnread: false,
      ),
      AppNotification(
        title: 'Note Review',
        message: 'Review your recent tags from Chapter 4.',
        time: '1d ago',
        icon: Icons.bookmark_outline,
        isUnread: false,
      ),
      AppNotification(
        title: 'Note Review',
        message: 'Review your recent tags from Chapter 4.',
        time: '1d ago',
        icon: Icons.bookmark_outline,
        isUnread: false,
      ),
    ];
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _TopBar(
              title: 'Notifications',
              onBack: () => Navigator.of(context).pop(),
            ),

            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.pageHorizontal,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const SizedBox(height: AppSpacing.md),
                     Container(
                        decoration: BoxDecoration(
                          color: context.appColors.surface,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: notifications.length,
                          itemBuilder: (context, index) {
                            final notification = notifications[index];
                            return ListTile(
                              leading: Icon(notification.icon),
                              title: Text(notification.title),
                              subtitle: Text(notification.message),
                              trailing: Text(notification.time),
                              tileColor: notification.isUnread
                                  // ignore: deprecated_member_use
                                  ? context.appColors.accent.withOpacity(0.1)
                                  : null,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
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
  const _TopBar({required this.title, required this.onBack});

  final String title;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.pageHorizontal,
      ),
      child: Row(
        children: [
          AuthBackButton(onPressed: onBack),
          Expanded(
            child: Center(
              child: Text(title, style: AppTypography.title2(colors.text)),
            ),
          ),
          const SizedBox(width: 44), // balances the back button
        ],
      ),
    );
  }
}
