import 'package:flutter/material.dart';

import '../../app/theme/tokens/colors.dart';
import '../../app/theme/tokens/radii.dart';
import '../../app/theme/tokens/spacing.dart';
import '../../app/theme/tokens/typography.dart';

/// The one text input for the whole app — auth forms, search bars, filter
/// panels. One shape (brMd), two flavors:
///   • form (default) — 14px label text, bg fill (forms sit on glass)
///   • search         — 16px body text, surface fill (search bars sit on the
///                      page bg, so the fill must contrast the other way)
///
/// Shared behavior: compact height (~42–46px vs Material's 56), hairline
/// border with accent focus ring, danger error ring, validate-on-unfocus,
/// built-in password eye (obscure) and an auto clear button (onClear shows
/// a ✕ only while there is text).
class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    required this.controller,
    required this.hint,
    this.search = false,
    this.validator,
    this.keyboardType,
    this.obscure = false,
    this.textInputAction = TextInputAction.next,
    this.onSubmitted,
    this.onChanged,
    this.onClear,
    this.focusNode,
    this.prefixIcon,
    this.suffix,
    this.fillColor,
    this.autofocus = false,
    this.enabled = true,
    this.textCapitalization = TextCapitalization.none,
    this.autofillHints,
  });

  final TextEditingController controller;
  final String hint;

  /// Search-bar flavor: body-sized text, surface fill — same radius as forms.
  final bool search;

  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final bool obscure;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<String>? onChanged;

  /// When set, a ✕ appears while the field has text; tapping it calls this
  /// (the caller clears the controller and its own state).
  final VoidCallback? onClear;

  final FocusNode? focusNode;
  final IconData? prefixIcon;

  /// Custom suffix — wins over the clear button and the password eye.
  final Widget? suffix;

  /// Defaults by flavor: search → surface, form → bg (forms sit on glass).
  final Color? fillColor;

  final bool autofocus;
  final bool enabled;
  final TextCapitalization textCapitalization;
  final Iterable<String>? autofillHints;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _hidden = widget.obscure;
  late bool _hasText = widget.controller.text.isNotEmpty;

  // sm(8)+2 vertical — ~42px (form) / ~46px (pill) tall: visibly tighter than
  // Material's 56 while staying a comfortable touch target.
  static const double _vPad = AppSpacing.sm + 2;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onText);
  }

  @override
  void didUpdateWidget(AppTextField old) {
    super.didUpdateWidget(old);
    if (old.controller != widget.controller) {
      old.controller.removeListener(_onText);
      widget.controller.addListener(_onText);
      _hasText = widget.controller.text.isNotEmpty;
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onText);
    super.dispose();
  }

  void _onText() {
    final has = widget.controller.text.isNotEmpty;
    if (has != _hasText) setState(() => _hasText = has);
  }

  OutlineInputBorder _border(Color color, {double width = 1}) =>
      OutlineInputBorder(
        borderRadius: AppRadii.brMd,
        borderSide: BorderSide(color: color, width: width),
      );

  Widget? _suffix(AppColorsExtension colors) {
    if (widget.suffix != null) return widget.suffix;
    if (widget.obscure) {
      return IconButton(
        onPressed: () => setState(() => _hidden = !_hidden),
        padding: EdgeInsets.zero,
        icon: Icon(
          _hidden ? Icons.visibility_off_outlined : Icons.visibility_outlined,
          size: 18,
          color: colors.text3,
        ),
      );
    }
    if (widget.onClear != null && _hasText) {
      return IconButton(
        onPressed: widget.onClear,
        padding: EdgeInsets.zero,
        icon: Icon(Icons.close, size: 18, color: colors.text3),
      );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final style = widget.search
        ? AppTypography.body(colors.text)
        : AppTypography.label(colors.text);
    final hintStyle = widget.search
        ? AppTypography.body(colors.text3)
        : AppTypography.label(colors.text3);

    return TextFormField(
      controller: widget.controller,
      focusNode: widget.focusNode,
      validator: widget.validator,
      keyboardType: widget.keyboardType,
      obscureText: _hidden,
      textInputAction: widget.textInputAction,
      onFieldSubmitted: widget.onSubmitted,
      onChanged: widget.onChanged,
      autofocus: widget.autofocus,
      enabled: widget.enabled,
      textCapitalization: widget.textCapitalization,
      autofillHints: widget.autofillHints,
      // Validate when the user LEAVES the field (or submits) — flagging
      // "invalid email" from the first typed character reads as scolding.
      autovalidateMode: AutovalidateMode.onUnfocus,
      style: style,
      decoration: InputDecoration(
        isDense: true,
        filled: true,
        fillColor:
            widget.fillColor ?? (widget.search ? colors.surface : colors.bg),
        hintText: widget.hint,
        hintStyle: hintStyle,
        prefixIcon: widget.prefixIcon == null
            ? null
            : Icon(widget.prefixIcon, size: 20, color: colors.text3),
        prefixIconConstraints:
            const BoxConstraints(minWidth: AppSpacing.xxxl, minHeight: 36),
        suffixIcon: _suffix(colors),
        suffixIconConstraints:
            const BoxConstraints(minWidth: AppSpacing.xxxl, minHeight: 36),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: _vPad,
        ),
        border: _border(colors.border),
        enabledBorder: _border(colors.border),
        focusedBorder: _border(colors.accent, width: 1.5),
        errorBorder: _border(colors.danger),
        focusedErrorBorder: _border(colors.danger, width: 1.5),
        errorStyle: AppTypography.caption(colors.danger),
      ),
    );
  }
}
