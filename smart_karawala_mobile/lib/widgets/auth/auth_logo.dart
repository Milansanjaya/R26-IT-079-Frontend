import 'package:flutter/material.dart';

import '../../core/constants/app_images.dart';

class AuthLogo extends StatelessWidget {
  const AuthLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Image.asset(
        AppImages.logo,
        height: 85,
      ),
    );
  }
}