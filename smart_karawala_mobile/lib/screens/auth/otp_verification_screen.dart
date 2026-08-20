import 'package:flutter/material.dart';
import '../../core/localization/app_localizations.dart';
import '../../widgets/language_switcher_button.dart';
import 'account_verified_screen.dart';
import '../../widgets/auth/auth_background.dart';
import '../../widgets/auth/auth_card.dart';
import '../../widgets/auth/auth_logo.dart';
import '../../services/auth_service.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String email;

  const OtpVerificationScreen({
    super.key,
    required this.email,
  });

  @override
  State<OtpVerificationScreen> createState() =>
      _OtpVerificationScreenState();
}

class _OtpVerificationScreenState
    extends State<OtpVerificationScreen> {
  final List<TextEditingController> controllers =
      List.generate(6, (_) => TextEditingController());

  final List<FocusNode> focusNodes =
      List.generate(6, (_) => FocusNode());

  bool loading = false;

  @override
  void dispose() {
    for (final c in controllers) {
      c.dispose();
    }

    for (final f in focusNodes) {
      f.dispose();
    }

    super.dispose();
  }

  String get otp =>
      controllers.map((e) => e.text).join();

  @override
  Widget build(BuildContext context) {
    return AuthBackground(
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: AuthCard(
              child: Column(
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
                    context.tr('otp_verification').toUpperCase(),
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff1E4E7B),
                    ),
                  ),

                  const SizedBox(height: 15),

                  Text(
                    context.tr('otp_sent_to'),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey.shade700,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    widget.email,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 35),

                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceEvenly,
                    children: List.generate(
                      6,
                      (index) => SizedBox(
                        width: 45,
                        child: TextField(
                          controller: controllers[index],
                          focusNode: focusNodes[index],
                          textAlign: TextAlign.center,
                          keyboardType:
                              TextInputType.number,
                          maxLength: 1,
                          decoration:
                              const InputDecoration(
                            counterText: "",
                          ),
                          onChanged: (value) {
                            if (value.isNotEmpty &&
                                index < 5) {
                              focusNodes[index + 1]
                                  .requestFocus();
                            }

                            if (value.isEmpty &&
                                index > 0) {
                              focusNodes[index - 1]
                                  .requestFocus();
                            }
                          },
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 35),

                  SizedBox(
                    width: 180,
                    height: 45,
                    child: ElevatedButton(
                      onPressed:
                          loading ? null : verifyOTP,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff0A5B8E),
                        shape: const StadiumBorder(),
                      ),
                      child: loading
                          ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                          : Text(
                              context.tr('verify_otp'),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  TextButton(
                    onPressed: resendOTP,
                    child: Text(
                      context.tr('resend_code'),
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

Future<void> verifyOTP() async {
  if (otp.length != 6) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Please enter the 6-digit OTP"),
      ),
    );
    return;
  }

  setState(() {
    loading = true;
  });

  try {
    final response = await AuthService.verifyAccount(
      email: widget.email,
      otp: otp,
    );

    if (!mounted) return;

    if (response["success"] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response["message"]),
          backgroundColor: Colors.green,
        ),
      );

      // Wait briefly so the user can see the success message
      await Future.delayed(const Duration(milliseconds: 800));

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const AccountVerifiedScreen(),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            response["message"] ?? "Invalid OTP",
          ),
          backgroundColor: Colors.red,
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

Future<void> resendOTP() async {
  try {
    final response =
        await AuthService.resendVerificationOtp(
      email: widget.email,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(response["message"]),
      ),
    );
  } catch (e) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(e.toString()),
      ),
    );
  }
}
}