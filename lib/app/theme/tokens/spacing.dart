/// Spacing tokens — mirrors design-system.md §4 / §15.
/// Base unit: 4px.
class AppSpacing {
  AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 28;
  static const double xxxl = 40;

  /// Page horizontal margin on 390px screens — never below 16px.
  static const double pageHorizontal = 22;

  /// Reading-view horizontal margin (design-system.md §9). Wider than the
  /// standard page margin so long-form lines get more breathing room.
  static const double readingHorizontal = 32;

  /// Dedicated iPad onboarding gutters from the tablet Figma frames.
  static const double tabletBreakpoint = 600;
  static const double tabletPopupWidth = 520;
  static const double tabletGutter = 92;
  static const double tabletPortraitGutter = 120;

  /// Persistent application navigation on iPad/tablet layouts.
  static const double tabletSidebarCompact = 72;
  static const double tabletSidebarExpanded = 248;
  static const double tabletSidebarBreakpoint = 1100;
}
