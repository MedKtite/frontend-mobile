import 'package:flutter/widgets.dart';

/// Radius tokens — mirrors design-system.md §5 / §15.
class AppRadii {
  AppRadii._();

  static const double xs   = 4;
  static const double sm   = 8;
  static const double md   = 12;
  static const double lg   = 16;
  static const double xl   = 22;
  static const double full = 9999;

  static const BorderRadius brXs   = BorderRadius.all(Radius.circular(xs));
  static const BorderRadius brSm   = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius brMd   = BorderRadius.all(Radius.circular(md));
  static const BorderRadius brLg   = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius brXl   = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius brFull = BorderRadius.all(Radius.circular(full));
}
