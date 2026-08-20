import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_images.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/auth/auth_background.dart';
import '../../widgets/auth/auth_card.dart';
import '../../widgets/auth/auth_textfield.dart';
import '../customer/customer_home.dart';
import '../admin/admin_home_screen.dart';
import 'otp_verification_screen.dart';
import '../../services/auth_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final fullnameController = TextEditingController();
  final emailController = TextEditingController();
  final mobileController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _isGoogleLoading = false;

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

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    if (passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Passwords do not match"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!isStrongPassword(passwordController.text.trim())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Password must contain:\n"
            "• At least 8 characters\n"
            "• One uppercase letter\n"
            "• One lowercase letter\n"
            "• One number\n"
            "• One special character (@\$!%*?&)",
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

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
            response["message"] ?? "Registration successful! Verification code sent.",
          ),
          backgroundColor: Colors.green,
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
          content: Text(e.toString().replaceAll("Exception: ", "")),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isGoogleLoading = true);

    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final success = await auth.googleSignIn();

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle_outline, color: Colors.white),
                SizedBox(width: 10),
                Text("Signed in with Google successfully!"),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );

        if (auth.isAdmin) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const AdminHomeScreen()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const CustomerHome()),
          );
        }
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Google Sign-In Error: ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isGoogleLoading = false);
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
                  // Watermark Background
                  Positioned.fill(
                    child: Opacity(
                      opacity: 0.06,
                      child: Image.asset(
                        AppImages.fish,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),

                  // Main Content Form
                  Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 8),

                        // Logo Container
                        Container(
                          height: 72,
                          width: 72,
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

                        const SizedBox(height: 16),

                        // Title & Subtitle
                        const Text(
                          "Create Account",
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Color(0xff0A5B8E),
                            letterSpacing: -0.4,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          "Join Smart Karawala for quality assurance & tracking",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xff5A7C99),
                            fontWeight: FontWeight.w500,
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Full Name Field
                        AuthTextField(
                          controller: fullnameController,
                          label: "Full Name",
                          hint: "Enter your full name",
                          prefixIcon: Icons.person_outline_rounded,
                          textInputAction: TextInputAction.next,
                          validator: (v) => v == null || v.trim().isEmpty
                              ? "Please enter your full name"
                              : null,
                        ),

                        const SizedBox(height: 14),

                        // Email Field
                        AuthTextField(
                          controller: emailController,
                          label: "Email Address",
                          hint: "Enter your email address",
                          prefixIcon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return "Please enter your email";
                            }
                            if (!v.contains('@') || !v.contains('.')) {
                              return "Please enter a valid email address";
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 14),

                        // Mobile Number Field
                        AuthTextField(
                          controller: mobileController,
                          label: "Mobile Number",
                          hint: "Enter your phone number",
                          prefixIcon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                          textInputAction: TextInputAction.next,
                          validator: (v) => v == null || v.trim().isEmpty
                              ? "Please enter your mobile number"
                              : null,
                        ),

                        const SizedBox(height: 14),

                        // Password Field
                        AuthTextField(
                          controller: passwordController,
                          label: "Password",
                          hint: "Create a password",
                          isPassword: true,
                          prefixIcon: Icons.lock_outline_rounded,
                          textInputAction: TextInputAction.next,
                          validator: (v) => v == null || v.trim().isEmpty
                              ? "Please enter a password"
                              : null,
                        ),

                        const SizedBox(height: 14),

                        // Confirm Password Field
                        AuthTextField(
                          controller: confirmPasswordController,
                          label: "Confirm Password",
                          hint: "Re-enter your password",
                          isPassword: true,
                          prefixIcon: Icons.lock_outline_rounded,
                          textInputAction: TextInputAction.done,
                          validator: (v) => v == null || v.trim().isEmpty
                              ? "Please confirm your password"
                              : null,
                        ),

                        const SizedBox(height: 24),

                        // Create Account Primary Button
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleRegister,
                            style: ElevatedButton.styleFrom(
                              elevation: 3,
                              backgroundColor: const Color(0xff0A5B8E),
                              foregroundColor: Colors.white,
                              shadowColor: const Color(0xff0A5B8E).withOpacity(0.4),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "Create Account",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Icon(
                                        Icons.arrow_forward_rounded,
                                        size: 18,
                                        color: Colors.white,
                                      ),
                                    ],
                                  ),
                          ),
                        ),

                        const SizedBox(height: 22),

                        // "OR" Divider Line
                        Row(
                          children: [
                            Expanded(child: Divider(color: Colors.grey.shade300, thickness: 1)),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: Text(
                                "OR CONTINUE WITH",
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade600,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            Expanded(child: Divider(color: Colors.grey.shade300, thickness: 1)),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Google Sign In Button
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: OutlinedButton(
                            onPressed: _isGoogleLoading ? null : _handleGoogleSignIn,
                            style: OutlinedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xff1E293B),
                              side: BorderSide(color: Colors.grey.shade300, width: 1.2),
                              elevation: 1,
                              shadowColor: Colors.black.withOpacity(0.04),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: _isGoogleLoading
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: Color(0xff4285F4),
                                    ),
                                  )
                                : const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      GoogleLogoWidget(size: 22),
                                      SizedBox(width: 12),
                                      Text(
                                        "Sign up with Google",
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xff1E293B),
                                          letterSpacing: 0.2,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),

                        const SizedBox(height: 22),

                        // Already Have an Account Link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Already have an account ? ",
                              style: TextStyle(
                                color: Color(0xff4A6B8A),
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: const Text(
                                "Sign In",
                                style: TextStyle(
                                  color: Color(0xff0A5B8E),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Terms Note
                        Text(
                          "By signing up, you agree to Smart Karawala's\nTerms of Service and Privacy Policy.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade500,
                            height: 1.3,
                          ),
                        ),

                        const SizedBox(height: 8),
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

/// Custom Vector Google G Logo Widget
class GoogleLogoWidget extends StatelessWidget {
  final double size;

  const GoogleLogoWidget({super.key, this.size = 24});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _GoogleLogoPainter(),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double center = size.width / 2;
    final double radius = size.width / 2;

    final Paint paint = Paint()..style = PaintingStyle.fill;

    // Blue Segment
    paint.color = const Color(0xFF4285F4);
    final Path bluePath = Path()
      ..moveTo(center, center)
      ..lineTo(size.width, center)
      ..arcTo(
        Rect.fromCircle(center: Offset(center, center), radius: radius),
        0,
        -1.3,
        false,
      )
      ..close();
    canvas.drawPath(bluePath, paint);

    // Red Segment
    paint.color = const Color(0xFFEA4335);
    final Path redPath = Path()
      ..moveTo(center, center)
      ..arcTo(
        Rect.fromCircle(center: Offset(center, center), radius: radius),
        -1.3,
        -1.4,
        false,
      )
      ..close();
    canvas.drawPath(redPath, paint);

    // Yellow Segment
    paint.color = const Color(0xFFFBBC05);
    final Path yellowPath = Path()
      ..moveTo(center, center)
      ..arcTo(
        Rect.fromCircle(center: Offset(center, center), radius: radius),
        -2.7,
        -1.0,
        false,
      )
      ..close();
    canvas.drawPath(yellowPath, paint);

    // Green Segment
    paint.color = const Color(0xFF34A853);
    final Path greenPath = Path()
      ..moveTo(center, center)
      ..arcTo(
        Rect.fromCircle(center: Offset(center, center), radius: radius),
        -3.7,
        -1.2,
        false,
      )
      ..close();
    canvas.drawPath(greenPath, paint);

    // Inner Cutout Circle for G shape
    paint.color = Colors.white;
    canvas.drawCircle(Offset(center, center), radius * 0.52, paint);

    // Right Bar of Google G
    paint.color = const Color(0xFF4285F4);
    final Rect barRect = Rect.fromLTRB(
      center - radius * 0.1,
      center - radius * 0.22,
      size.width - radius * 0.05,
      center + radius * 0.22,
    );
    canvas.drawRect(barRect, paint);

    // Small inner cutout for bar
    paint.color = Colors.white;
    canvas.drawCircle(Offset(center, center), radius * 0.32, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}