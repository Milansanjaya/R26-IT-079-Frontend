import 'package:flutter/material.dart';

import '../../core/constants/app_images.dart';
import '../../widgets/auth/auth_background.dart';
import '../../widgets/auth/auth_card.dart';
import '../../widgets/auth/auth_logo.dart';
import '../../widgets/auth/auth_textfield.dart';
import 'otp_verification_screen.dart';
import '../../services/auth_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final fullnameController = TextEditingController();
  final emailController = TextEditingController();
  final mobileController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool isStrongPassword(String password) {
    final regex = RegExp(
      r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[@\$!%*?&]).{8,}$',
    );

    return regex.hasMatch(password);
  }

  @override
  void dispose() {
    fullnameController.dispose();
    emailController.dispose();
    mobileController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
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
              vertical: 25,
            ),
            child: AuthCard(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Opacity(
                      opacity: .12,
                      child: Image.asset(
                        AppImages.fish,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),

                  Column(
                    children: [
                      const SizedBox(height: 10),

                      const AuthLogo(),

                      const SizedBox(height: 10),

                      const Text(
                        "SIGN UP",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xff1E4E7B),
                        ),
                      ),

                      const SizedBox(height: 25),

                      AuthTextField(
                        controller: fullnameController,
                        hint: "Full Name",
                      ),

                      const SizedBox(height: 15),

                      AuthTextField(
                        controller: emailController,
                        hint: "Email",
                      ),

                      const SizedBox(height: 15),

                      AuthTextField(
                        controller: mobileController,
                        hint: "Mobile Number",
                      ),

                      const SizedBox(height: 15),

                      AuthTextField(
                        controller: passwordController,
                        hint: "Password",
                        isPassword: true,
                      ),

                      const SizedBox(height: 15),

                      AuthTextField(
                        controller: confirmPasswordController,
                        hint: "Confirm Password",
                        isPassword: true,
                      ),

                      const SizedBox(height: 25),

                      SizedBox(
                        width: 170,
                        height: 45,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (passwordController.text !=
                                confirmPasswordController.text) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Passwords do not match"),
                                ),
                              );
                              return;
                            }

                            if (!isStrongPassword(
                              passwordController.text.trim(),
                            )) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "Password must contain:\n"
                                    "• At least 8 characters\n"
                                    "• One uppercase letter\n"
                                    "• One lowercase letter\n"
                                    "• One number\n"
                                    "• One special character",
                                  ),
                                ),
                              );
                              return;
                            }

                            try {
                              final response = await AuthService.register(
                                fullName: fullnameController.text.trim(),
                                email: emailController.text.trim(),
                                phone: mobileController.text.trim(),
                                password: passwordController.text.trim(),
                              );

                              if (!mounted) return;

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    response["message"] ??
                                        "Registration successful",
                                  ),
                                ),
                              );

                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => OtpVerificationScreen(
                                    email: emailController.text.trim(),
                                  ),
                                ),
                              );
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
                            backgroundColor: const Color(0xff0A5B8E),
                            shape: const StadiumBorder(),
                          ),
                          child: const Text(
                            "Create Account",
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 18),

                      Wrap(
                        alignment: WrapAlignment.center,
                        children: [
                          const Text(
                            "Already have an account ? ",
                            style: TextStyle(
                              color: Color(0xff315B7E),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: const Text(
                              "Sign In",
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