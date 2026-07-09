import 'package:flutter/material.dart';

import '../../services/storage_service.dart';
import '../admin/admin_home_screen.dart';
import '../customer/customer_home.dart';
import 'login_screen.dart';

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
          builder: (_) => const LoginScreen(),
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

      // Later, replace this with:
      // GET /auth/me
      // if (role == "admin") -> AdminHomeScreen()
      // else -> CustomerHome()
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}