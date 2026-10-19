import '../../services/Batch/batch_workflow_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_images.dart';
import '../../providers/auth_provider.dart';
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
    try {
      await Future.delayed(const Duration(seconds: 2));

      final token = await StorageService.getToken();
      final role = await StorageService.getRole();

      if (!mounted) return;

      try {
        await Provider.of<AuthProvider>(context, listen: false).loadUserFromStorage();
      } catch (e) {
        debugPrint("Could not load user from storage: $e");
      }

      if (!mounted) return;

      if (token == null || token.isEmpty) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const WelcomeScreen(),
          ),
        );
      } else if (role == 'admin') {
        Map<String, dynamic>? activeBatch;
        try {
          activeBatch = await BatchWorkflowService.getActiveBatch().timeout(
            const Duration(seconds: 3),
            onTimeout: () => null,
          );
        } catch (_) {}

        if (!mounted) return;
        if (activeBatch != null && activeBatch['isActive'] == true) {
          BatchWorkflowService.navigateToActiveStage(context, activeBatch);
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => const AdminHomeScreen(),
            ),
          );
        }
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const CustomerHome(),
          ),
        );
      }
    } catch (e, stack) {
      debugPrint("Error in checkLogin: $e\n$stack");
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const WelcomeScreen(),
          ),
        );
      }
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
            const Text(
              "Smart Karawala",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Color(0xff0A5B8E),
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Quality Dry Fish Management",
              style: TextStyle(
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
