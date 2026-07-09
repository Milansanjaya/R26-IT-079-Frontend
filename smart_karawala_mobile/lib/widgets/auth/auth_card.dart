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
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 4,
            sigmaY: 4,
          ),
          child: Container(
            width: size.width * .90,

            constraints: const BoxConstraints(
              maxWidth: 380,
              minHeight: 620,
            ),

            padding: const EdgeInsets.all(20),

            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.45),

              borderRadius: BorderRadius.circular(20),

              border: Border.all(
                color: Colors.blue.shade100,
              ),
            ),

            child: child,
          ),
        ),
      ),
    );
  }
}