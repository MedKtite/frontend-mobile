import 'package:flutter/material.dart';

import '../app/theme/tokens/colors.dart';
import '../app/theme/tokens/typography.dart';

/// Outlined text field for the auth forms. Decoration (border, radius, focus,
/// hint color) comes from the app's [InputDecorationTheme] — this only adds the
/// hint, the entered-text style, and an optional show/hide toggle for passwords.
class AuthTextField extends StatefulWidget {
  const AuthTextField({
    super.key,
    required this.controller,
    required this.hint,
    this.validator,
    this.keyboardType,
    this.obscure = false,
    this.textInputAction = TextInputAction.next,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String hint;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;

  /// When true the field starts obscured and shows an eye toggle (passwords).
  final bool obscure;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onSubmitted;

  @override
  State<AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField> {
  late bool _hidden = widget.obscure;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return TextFormField(  
      controller: widget.controller,
      validator: widget.validator,
      keyboardType: widget.keyboardType,
      obscureText: _hidden,
      textInputAction: widget.textInputAction,
      onFieldSubmitted: widget.onSubmitted,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      style: AppTypography.label(colors.text),
      
      decoration: InputDecoration(
        // adjust vertical/horizontal padding to control the field height
        isDense: true,
        border: const OutlineInputBorder(),
        filled: true,
        fillColor: colors.bg,
        hintText: widget.hint,
        hintStyle: AppTypography.label(colors.text3),
        suffixIcon: widget.obscure
            ? IconButton(
                onPressed: () => setState(() => _hidden = !_hidden),
                icon: Icon(
                  _hidden
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  size: 16,
                  color: colors.text3,
                ),
              )
            : null,
      ),
    );
  }
}
