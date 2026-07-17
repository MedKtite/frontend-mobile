import 'package:flutter/material.dart';

import '../../app/theme/tokens/radii.dart';
import '../../app/theme/tokens/spacing.dart';

/// Presents content as a bottom sheet on phones and a centered popup on
/// tablets. Modal content can read [AdaptiveModalScope.isPopup] to adjust
/// sheet-only chrome such as drag handles and top-only corner rounding.
Future<T?> showAdaptiveModal<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  Color? backgroundColor,
  Color? barrierColor,
  bool isScrollControlled = false,
}) {
  final isTablet =
      MediaQuery.sizeOf(context).shortestSide >= AppSpacing.tabletBreakpoint;

  if (!isTablet) {
    return showModalBottomSheet<T>(
      context: context,
      useRootNavigator: true,
      backgroundColor: backgroundColor,
      barrierColor: barrierColor,
      isScrollControlled: isScrollControlled,
      shape: backgroundColor == Colors.transparent
          ? null
          : const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(AppRadii.xl),
              ),
            ),
      builder: (modalContext) => AdaptiveModalScope(
        isPopup: false,
        child: builder(modalContext),
      ),
    );
  }

  return showDialog<T>(
    context: context,
    useRootNavigator: true,
    barrierColor: barrierColor,
    builder: (modalContext) {
      final availableHeight = MediaQuery.sizeOf(modalContext).height -
          AppSpacing.xxxl * 2;
      return Dialog(
        backgroundColor: backgroundColor,
        clipBehavior: Clip.antiAlias,
        insetPadding: const EdgeInsets.all(AppSpacing.xxl),
        shape: const RoundedRectangleBorder(borderRadius: AppRadii.brXl),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: AppSpacing.tabletPopupWidth,
            maxHeight: availableHeight,
          ),
          child: SingleChildScrollView(
            child: AdaptiveModalScope(
              isPopup: true,
              child: builder(modalContext),
            ),
          ),
        ),
      );
    },
  );
}

class AdaptiveModalScope extends InheritedWidget {
  const AdaptiveModalScope({
    super.key,
    required this.isPopup,
    required super.child,
  });

  final bool isPopup;

  static bool isPopupOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AdaptiveModalScope>()
          ?.isPopup ??
      false;

  @override
  bool updateShouldNotify(AdaptiveModalScope oldWidget) =>
      isPopup != oldWidget.isPopup;
}

BorderRadius adaptiveModalBorderRadius(BuildContext context) {
  return AdaptiveModalScope.isPopupOf(context)
      ? AppRadii.brXl
      : const BorderRadius.vertical(top: Radius.circular(AppRadii.xl));
}

class AdaptiveModalHandle extends StatelessWidget {
  const AdaptiveModalHandle({super.key, required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    if (AdaptiveModalScope.isPopupOf(context)) {
      return const SizedBox(height: AppSpacing.lg);
    }
    return Container(
      width: 36,
      height: AppSpacing.xs,
      margin: const EdgeInsets.only(
        top: AppSpacing.sm,
        bottom: AppSpacing.xl,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: AppRadii.brFull,
      ),
    );
  }
}
