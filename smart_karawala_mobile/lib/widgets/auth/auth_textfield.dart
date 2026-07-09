import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

class AuthTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final bool isPassword;
  final TextInputType? keyboardType;

  const AuthTextField({
    super.key,
    required this.controller,
    required this.hint,
    this.isPassword = false,
    this.keyboardType,
  });

  @override
  State<AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField> {
  bool hide = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,

      decoration: BoxDecoration(
        color: const Color(0xffD9F0FF),

        borderRadius: BorderRadius.circular(4),
      ),

      child: TextField(
        controller: widget.controller,
        keyboardType: widget.keyboardType,

        obscureText: widget.isPassword ? hide : false,

        decoration: InputDecoration(
          hintText: widget.hint,

          hintStyle: const TextStyle(
            color: Color(0xff355C7D),
          ),

          border: InputBorder.none,

          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 12,
          ),

          suffixIcon: widget.isPassword
              ? IconButton(
                  icon: Icon(
                    hide
                        ? Icons.visibility
                        : Icons.visibility_off,
                    color: AppColors.primary,
                  ),
                  onPressed: () {
                    setState(() {
                      hide = !hide;
                    });
                  },
                )
              : null,
        ),
      ),
    );
  }
}