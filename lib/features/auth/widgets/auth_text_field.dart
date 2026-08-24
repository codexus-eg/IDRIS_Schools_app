import 'package:flutter/material.dart';

class AuthTextField extends StatelessWidget {
  const AuthTextField({
    super.key,
    required this.controller,
    required this.label,
    this.keyboardType,
    this.textDirection,
    this.prefixIcon,
    this.obscureText = false,
  });

  final TextEditingController controller;
  final String label;
  final TextInputType? keyboardType;
  final TextDirection? textDirection;
  final IconData? prefixIcon;
  final bool obscureText;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      textDirection: textDirection,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: prefixIcon == null ? null : Icon(prefixIcon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(18)),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }
}
