import 'package:flutter/material.dart';

import '../../core/localization/app_localizations.dart';
import '../../widgets/auth/auth_background.dart';
import '../../widgets/auth/auth_card.dart';
import '../../widgets/auth/auth_logo.dart';
import '../../widgets/language_switcher_button.dart';

class AccountVerifiedScreen extends StatelessWidget {
  const AccountVerifiedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthBackground(
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
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

                  const SizedBox(height: 25),

                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      children: [
                        Text(
                          context.tr('account_verified'),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xff28406B),
                          ),
                        ),

                        const SizedBox(height: 15),

                        Text(
                          context.tr('account_verified_desc'),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  SizedBox(
                    width: 140,
                    height: 45,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/login',
                          (route) => false,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff0A5B8E),
                        shape: const StadiumBorder(),
                      ),
                      child: Text(
                        context.tr('sign_in'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}