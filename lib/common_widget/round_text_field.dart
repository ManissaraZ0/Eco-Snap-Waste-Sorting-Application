import 'package:flutter/material.dart';
import 'package:eco_snap/common/color_extension.dart';

class RoundTextField extends StatelessWidget {
  final String hintText;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? leftIcon;
  final Widget? rightIcon;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final void Function(String?)? onSaved;

  const RoundTextField({
    super.key,
    required this.hintText,
    this.controller,
    this.keyboardType,
    this.obscureText = false,
    this.leftIcon,
    this.rightIcon,
    this.validator,
    this.suffixIcon,
    this.onSaved,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      onSaved: onSaved,
      style: TextStyle(color: TColor.primaryText, fontSize: 16),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: TColor.secondaryText, fontSize: 16),
        prefixIcon:
            leftIcon != null
                ? Padding(padding: const EdgeInsets.all(12.0), child: leftIcon)
                : null,

        suffixIcon: suffixIcon ?? rightIcon,
        filled: true,
        fillColor: TColor.lightGray,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: TColor.tertiary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: TColor.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: TColor.error, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
      ),
    );
  }
}
