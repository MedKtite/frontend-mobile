import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../app/routes.dart';
import '../app/theme/tokens/spacing.dart';
import '../providers/annotations_provider.dart';
import '../providers/author_provider.dart';
import '../providers/home_provider.dart';
import '../providers/recommendations_provider.dart';
import '../providers/trending_provider.dart';
import 'audio_mini_player.dart';
import 'glass_nav_bar.dart';
import 'reading_mini_bar.dart';
import 'tablet_sidebar.dart';

class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.shell});

  final StatefulNavigationShell shell;

  /// Branch order — must match the branches in routes.dart.
  static const _tabs = [
    NavTab.home,
    NavTab.discovery,
    NavTab.library,
    NavTab.margins,
    NavTab.insights,
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    void onSelect(NavTab tab) {
      switch (tab) {
        case NavTab.home ||
              NavTab.discovery ||
              NavTab.library ||
              NavTab.margins ||
              NavTab.insights:
          final index = _tabs.indexOf(tab);
          // Returning to Home refreshes it in place — reading progress and
          // library changes made on other screens show up without a flash.
          if (tab == NavTab.home && index != shell.currentIndex) {
            ref.read(homeProvider.notifier).load(silent: true);
            ref.invalidate(recommendedBooksProvider);
            if (ref.read(trendingBooksProvider).hasError) {
              ref.invalidate(trendingBooksProvider);
            }
            if (ref.read(topAuthorsProvider).hasError) {
              ref.invalidate(topAuthorsProvider);
            }
          }
          // Returning to Margins refreshes highlights made in the reader.
          if (tab == NavTab.margins && index != shell.currentIndex) {
            refreshAnnotations(ref);
          }
          shell.goBranch(index, initialLocation: index == shell.currentIndex);
        case NavTab.profile:
          context.push(Routes.settings);
      }
    }

    final isTablet = MediaQuery.sizeOf(context).shortestSide >= 600;
    if (isTablet) {
      return LayoutBuilder(
        builder: (context, constraints) {
          final expanded =
              constraints.maxWidth >= AppSpacing.tabletSidebarBreakpoint;
          return Scaffold(
            body: Row(
              children: [
                TabletSidebar(
                  current: _tabs[shell.currentIndex],
                  expanded: expanded,
                  onSelect: onSelect,
                ),
                Expanded(
                  child: Column(
                    children: [
                      Expanded(child: shell),
                      const ReadingMiniBar(),
                      const AudioMiniPlayer(),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      );
    }

    return Scaffold(
      extendBody: true, // tab content scrolls beneath the glass bar
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Docked while a book is mid-read / audio plays — survive tab
          // switches. Both can stack (reading above listening).
          const ReadingMiniBar(),
          const AudioMiniPlayer(),
          GlassNavBar(current: _tabs[shell.currentIndex], onSelect: onSelect),
        ],
      ),
      body: shell,
    );
  }
}
