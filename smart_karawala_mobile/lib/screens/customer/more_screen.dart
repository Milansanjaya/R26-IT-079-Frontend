import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/localization/app_localizations.dart';
import '../../providers/language_provider.dart';
import '../../widgets/language_selector_sheet.dart';
import 'heritage_screen.dart';
import 'contact_screen.dart';
import 'privacy_policy_screen.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final currentLang = languageProvider.currentLanguage;

    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              context.tr('more'),
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xff0A5B8E),
              ),
            ),
            const SizedBox(height: 20),

            ListTile(
              leading: const Icon(Icons.account_balance, color: Color(0xff0A5B8E)),
              title: Text(context.tr('our_heritage')),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const HeritageScreen(),
                  ),
                );
              },
            ),

            ListTile(
              leading: const Icon(Icons.photo_library, color: Color(0xff0A5B8E)),
              title: Text(context.tr('our_gallery')),
              trailing: const Icon(Icons.chevron_right),
            ),

            ListTile(
              leading: const Icon(Icons.headset_mic, color: Color(0xff0A5B8E)),
              title: Text(context.tr('contact_us')),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ContactScreen(),
                  ),
                );
              },
            ),

            ListTile(
              leading: const Icon(Icons.privacy_tip, color: Color(0xff0A5B8E)),
              title: Text(context.tr('privacy_policy')),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PrivacyPolicyScreen(),
                  ),
                );
              },
            ),

            ListTile(
              leading: const Icon(Icons.help_outline_rounded, color: Color(0xff0A5B8E)),
              title: Text(context.tr('help_and_support')),
              trailing: const Icon(Icons.chevron_right),
            ),

            const Divider(height: 20),

            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xff0A5B8E).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.language, color: Color(0xff0A5B8E), size: 20),
              ),
              title: Text(
                context.tr('language'),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                currentLang.nativeName,
                style: const TextStyle(
                  color: Color(0xff0A5B8E),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xff0A5B8E).withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      currentLang.code.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xff0A5B8E),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.chevron_right),
                ],
              ),
              onTap: () {
                Navigator.pop(context);
                LanguageSelectorSheet.show(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}