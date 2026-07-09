import 'package:flutter/material.dart';

import '../../core/constants/app_images.dart';
import '../../widgets/auth/auth_background.dart';
import '../../widgets/auth/auth_card.dart';
import '../../widgets/auth/auth_logo.dart';
import '../../widgets/auth/auth_textfield.dart';
import 'signup_screen.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../admin/admin_home_screen.dart';
import '../customer/customer_home.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AuthBackground(
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 30,
            ),
            child: AuthCard(
              child: Stack(
                children: [
                  /// Fish Watermark
                  Positioned.fill(
                    child: Opacity(
                      opacity: 0.12,
                      child: Image.asset(
                        AppImages.fish,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),

                  /// Content
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 10),

                      const AuthLogo(),

                      const SizedBox(height: 15),

                      const Text(
                        "SIGN IN",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xff1E4E7B),
                        ),
                      ),

                      const SizedBox(height: 30),

                      AuthTextField(
                        controller: usernameController,
                        hint: "Username",
                      ),

                      const SizedBox(height: 18),

                      AuthTextField(
                        controller: passwordController,
                        hint: "Password",
                        isPassword: true,
                      ),

                      const SizedBox(height: 30),

                     Consumer<AuthProvider>(
  builder: (context, auth, child) {
    return SizedBox(
      width: 130,
      height: 45,
      child: ElevatedButton(
        onPressed: auth.loading
            ? null
            : () async {
                try {
                  final success = await auth.login(
                    email: usernameController.text.trim(),
                    password: passwordController.text.trim(),
                  );

                  if (!mounted) return;

                  if (success) {
                    if (auth.isAdmin) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AdminHomeScreen(),
                        ),
                      );
                    } else {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CustomerHome(),
                        ),
                      );
                    }
                  }
                } catch (e) {
                  if (!mounted) return;

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(e.toString()),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
        style: ElevatedButton.styleFrom(
          elevation: 5,
          backgroundColor: const Color(0xff0A5B8E),
          shape: const StadiumBorder(),
        ),
        child: auth.loading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Text(
                "Sign In",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                ),
              ),
      ),
    );
  },
),

                      const SizedBox(height: 18),

                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            '/forgot-password',
                          );
                        },
                        child: const Text(
                          "Forgot Password ?",
                          style: TextStyle(
                            color: Color(0xff315B7E),
                          ),
                        ),
                      ),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Don't have an account ? ",
                            style: TextStyle(
                              color: Color(0xff315B7E),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const SignupScreen(),
                             ),
                           ); 
                            },
                            child: const Text(
                              "Sign Up",
                              style: TextStyle(
                                color: Color(0xff0A5B8E),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}