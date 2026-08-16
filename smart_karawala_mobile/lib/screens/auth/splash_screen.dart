import 'package:flutter/material.dart';

import '../../core/constants/app_images.dart';
import '../../core/localization/app_localizations.dart';
import '../../services/storage_service.dart';
import '../../widgets/auth/auth_background.dart';
import '../admin/admin_home_screen.dart';
import '../customer/customer_home.dart';
import 'welcome_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    checkLogin();
  }

  Future<void> checkLogin() async {
    await Future.delayed(const Duration(seconds: 2));

    final token = await StorageService.getToken();

    if (!mounted) return;

    if (token == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const WelcomeScreen(),
        ),
      );
    } else {
      // Temporary: go to Customer until /auth/me is connected.
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const CustomerHome(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthBackground(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 100,
              width: 100,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xff0A5B8E).withOpacity(0.15),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Image.asset(
                AppImages.logo,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              context.tr('app_name'),
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Color(0xff0A5B8E),
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              context.tr('app_tagline'),
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xff5A7C99),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 40),
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: Color(0xff0A5B8E),
              ),
            ),
          ],
        ),
      ),
    );
  }
}