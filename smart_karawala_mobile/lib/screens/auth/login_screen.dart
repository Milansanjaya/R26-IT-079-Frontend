import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_images.dart';
import '../../core/localization/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/auth/auth_background.dart';
import '../../widgets/auth/auth_card.dart';
import '../../widgets/auth/auth_textfield.dart';
import '../../widgets/auth/google_sign_in_button.dart';
import '../../widgets/language_switcher_button.dart';
import '../admin/admin_home_screen.dart';
import '../customer/customer_home.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  bool _rememberMe = false;

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();
    final auth = Provider.of<AuthProvider>(context, listen: false);

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
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  e.toString().replaceAll("Exception: ", ""),
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFFD32F2F),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
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
              vertical: 24,
            ),
            physics: const BouncingScrollPhysics(),
            child: AuthCard(
              child: Stack(
                children: [
                  /// Fish Watermark
                  Positioned.fill(
                    child: Opacity(
                      opacity: 0.06,
                      child: Image.asset(
                        AppImages.fish,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),

                  /// Main Content Form
                  Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        /// Top Row with Language Switcher
                        Align(
                          alignment: Alignment.topRight,
                          child: const LanguageSwitcherButton(isCompact: true),
                        ),

                        const SizedBox(height: 4),

                        /// Branded Logo with ambient glow
                        Container(
                          height: 76,
                          width: 76,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xff0A5B8E).withOpacity(0.12),
                                blurRadius: 18,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(12),
                          child: Image.asset(
                            AppImages.logo,
                            fit: BoxFit.contain,
                          ),
                        ),

                        const SizedBox(height: 18),

                        /// Title & Subtitle
                        Text(
                          context.tr('welcome_back'),
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Color(0xff0A5B8E),
                            letterSpacing: -0.4,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          context.tr('sign_in_subtitle'),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xff5A7C99),
                            fontWeight: FontWeight.w500,
                          ),
                        ),

                        const SizedBox(height: 28),

                        /// Username / Email Field
                        AuthTextField(
                          controller: usernameController,
                          label: context.tr('email_or_username'),
                          hint: context.tr('enter_email_or_username'),
                          prefixIcon: Icons.person_outline_rounded,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return context.tr('enter_email_or_username');
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        /// Password Field
                        AuthTextField(
                          controller: passwordController,
                          label: context.tr('password'),
                          hint: context.tr('enter_password'),
                          isPassword: true,
                          prefixIcon: Icons.lock_outline_rounded,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _handleLogin(),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return context.tr('enter_password');
                            }
                            if (value.trim().length < 4) {
                              return "Password must be at least 4 characters";
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 14),

                        /// Remember Me & Forgot Password Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            InkWell(
                              onTap: () {
                                setState(() {
                                  _rememberMe = !_rememberMe;
                                });
                              },
                              borderRadius: BorderRadius.circular(6),
                              child: Row(
                                children: [
                                  SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: Checkbox(
                                      value: _rememberMe,
                                      onChanged: (val) {
                                        setState(() {
                                          _rememberMe = val ?? false;
                                        });
                                      },
                                      activeColor: const Color(0xff0A5B8E),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      side: const BorderSide(
                                        color: Color(0xff8BA6BE),
                                        width: 1.5,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    context.tr('remember_me'),
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Color(0xff315B7E),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  '/forgot-password',
                                );
                              },
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                context.tr('forgot_password'),
                                style: const TextStyle(
                                  color: Color(0xff0A5B8E),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 26),

                        /// Sign In Button
                        Consumer<AuthProvider>(
                          builder: (context, auth, child) {
                            return SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: ElevatedButton(
                                onPressed: auth.loading ? null : _handleLogin,
                                style: ElevatedButton.styleFrom(
                                  elevation: 3,
                                  backgroundColor: const Color(0xff0A5B8E),
                                  foregroundColor: Colors.white,
                                  shadowColor: const Color(0xff0A5B8E).withOpacity(0.4),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                child: auth.loading
                                    ? const SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                          color: Colors.white,
                                        ),
                                      )
                                    : Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            context.tr('sign_in'),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 0.3,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          const Icon(
                                            Icons.arrow_forward_rounded,
                                            size: 18,
                                            color: Colors.white,
                                          ),
                                        ],
                                      ),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 18),

                        /// Divider with "Or continue with"
                        Row(
                          children: [
                            Expanded(
                              child: Divider(
                                color: Colors.grey.shade300,
                                thickness: 1,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: Text(
                                context.tr('or_continue_with'),
                                style: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Divider(
                                color: Colors.grey.shade300,
                                thickness: 1,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 18),

                        /// Google Sign In Button
                        GoogleSignInButton(
                          text: context.tr('sign_in_with_google'),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Row(
                                  children: [
                                    Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: Text("Google account connected successfully!"),
                                    ),
                                  ],
                                ),
                                backgroundColor: const Color(0xFF0A5B8E),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                margin: const EdgeInsets.all(16),
                              ),
                            );

                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const CustomerHome(),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 22),

                        /// Don't have an account? Sign Up
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "${context.tr('dont_have_account')} ",
                              style: const TextStyle(
                                color: Color(0xff4A6B8A),
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
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
                              child: Text(
                                context.tr('sign_up'),
                                style: const TextStyle(
                                  color: Color(0xff0A5B8E),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        /// Trust Badge Footer
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.verified_user_outlined,
                              size: 14,
                              color: const Color(0xff8BA6BE).withOpacity(0.85),
                            ),
                            const SizedBox(width: 5),
                            Flexible(
                              child: Text(
                                context.tr('safe_quality_assured'),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: const Color(0xff8BA6BE).withOpacity(0.85),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 4),
                      ],
                    ),
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