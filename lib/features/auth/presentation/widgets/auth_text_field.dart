import 'package:flutter/material.dart';

class AuthTextField extends StatelessWidget {
  const AuthTextField({
    required this.controller,
    required this.label,
    required this.hintText,
    required this.keyboardType,
    super.key,
    this.focusNode,
    this.textInputAction,
    this.onSubmitted,
    this.validator,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.autofillHints,
    this.textDirection,
    this.errorText,
    this.scrollPadding = const EdgeInsets.fromLTRB(0, 24, 0, 180),
  });

  final TextEditingController controller;
  final FocusNode? focusNode;
  final String label;
  final String hintText;
  final TextInputType keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final String? Function(String?)? validator;
  final bool obscureText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final Iterable<String>? autofillHints;
  final TextDirection? textDirection;
  final String? errorText;
  final EdgeInsets scrollPadding;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      obscureText: obscureText,
      validator: validator,
      onFieldSubmitted: onSubmitted,
      autofillHints: autofillHints,
      textDirection: textDirection,
      scrollPadding: scrollPadding,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        errorText: errorText,
      ),
    );
  }
}
