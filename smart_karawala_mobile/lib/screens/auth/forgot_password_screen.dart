import 'package:flutter/material.dart';

import '../../core/localization/app_localizations.dart';
import '../../services/auth_service.dart';
import '../../widgets/auth/auth_background.dart';
import '../../widgets/auth/auth_card.dart';
import '../../widgets/auth/auth_logo.dart';
import '../../widgets/auth/auth_textfield.dart';
import '../../widgets/language_switcher_button.dart';
import 'reset_password_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState
    extends State<ForgotPasswordScreen> {
  final emailController = TextEditingController();

  bool loading = false;

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  Future<void> sendResetOTP() async {
    if (emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.tr('enter_email')),
        ),
      );
      return;
    }

    setState(() {
      loading = true;
    });

    try {
      final response = await AuthService.forgotPassword(
        email: emailController.text.trim(),
      );

      if (!mounted) return;

      if (response["success"] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response["message"] ?? context.tr('success')),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ResetPasswordScreen(
              email: emailController.text.trim(),
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              response["message"] ??
                  "Unable to send OTP",
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  /// Top Language Switcher
                  Align(
                    alignment: Alignment.topRight,
                    child: const LanguageSwitcherButton(isCompact: true),
                  ),

                  const SizedBox(height: 4),

                  const AuthLogo(),

                  const SizedBox(height: 20),

                  Text(
                    context.tr('forgot_password_title'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff1E4E7B),
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    context.tr('forgot_password_desc'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xff5A7C99),
                    ),
                  ),

                  const SizedBox(height: 24),

                  AuthTextField(
                    controller: emailController,
                    hint: context.tr('email'),
                    keyboardType: TextInputType.emailAddress,
                  ),

                  const SizedBox(height: 28),

                  SizedBox(
                    width: 180,
                    height: 45,
                    child: ElevatedButton(
                      onPressed:
                          loading ? null : sendResetOTP,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color(0xff0A5B8E),
                        shape:
                            const StadiumBorder(),
                      ),
                      child: loading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child:
                                  CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              context.tr('send_otp'),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      context.tr('continue_to_login'),
                      style: const TextStyle(
                        color: Color(0xff0A5B8E),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}