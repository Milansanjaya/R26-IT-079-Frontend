import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

class AuthTitle extends StatelessWidget {

  final String title;

  const AuthTitle({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {

    return Text(

      title.toUpperCase(),

      style: const TextStyle(

        fontSize: 38,

        fontWeight: FontWeight.bold,

        color: AppColors.primary,

        letterSpacing: 1,

      ),

      textAlign: TextAlign.center,

    );

  }

}