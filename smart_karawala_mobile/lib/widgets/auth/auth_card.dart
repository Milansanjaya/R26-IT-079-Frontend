import 'dart:ui';

import 'package:flutter/material.dart';

class AuthCard extends StatelessWidget {
  final Widget child;

  const AuthCard({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 12,
            sigmaY: 12,
          ),
          child: Container(
            width: size.width * .92,
            constraints: const BoxConstraints(
              maxWidth: 420,
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 22,
              vertical: 28,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.82),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withOpacity(0.95),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xff0A5B8E).withOpacity(0.08),
                  blurRadius: 30,
                  spreadRadius: 2,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}