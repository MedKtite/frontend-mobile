import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../app/routes.dart';
import '../core/widgets/app_snackbar.dart';
import '../providers/annotations_provider.dart';
import '../providers/home_provider.dart';
import 'glass_nav_bar.dart';

class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.shell});

  final StatefulNavigationShell shell;

  /// Branch order — must match the branches in routes.dart.
  static const _tabs = [NavTab.home, NavTab.search, NavTab.library];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      extendBody: true, // tab content scrolls beneath the glass bar
      bottomNavigationBar: GlassNavBar(
        current: _tabs[shell.currentIndex],
        onSelect: (tab) {
          switch (tab) {
            case NavTab.home || NavTab.search || NavTab.library:
              final index = _tabs.indexOf(tab);
              // Returning to Home refreshes it in place — reading progress
              // and library changes made on other screens show up without
              // a loading flash (the tab keeps its content while fetching).
              if (tab == NavTab.home && index != shell.currentIndex) {
                ref.read(homeProvider.notifier).load(silent: true);
              }
              // Returning to Search re-fetches the Tags/Notes/Saved tabs so
              // highlights made in the reader appear without a restart.
              // (Providers keep their old value while refreshing — no flash.)
              if (tab == NavTab.search && index != shell.currentIndex) {
                refreshAnnotations(ref);
              }
              // Re-tapping the active tab pops it back to its root.
              shell.goBranch(index,
                  initialLocation: index == shell.currentIndex);
            case NavTab.profile:
              context.push(Routes.settings);
            case NavTab.insights:
              showAppSnack(context, 'Insights — coming soon');
          }
        },
      ),
      body: shell,
    );
  }
}
