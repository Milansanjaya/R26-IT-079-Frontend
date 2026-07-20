import 'package:flutter/material.dart';
import 'heritage_screen.dart';
import 'contact_screen.dart';
import 'privacy_policy_screen.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              "More",
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            ListTile(
              leading: const Icon(Icons.account_balance),
              title: const Text("Our Heritage"),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // Close the drawer first
                Navigator.pop(context);
                // Push the Heritage Screen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const HeritageScreen(),
                  ),
                );
              },
            ),

            const ListTile(
              leading: Icon(Icons.photo_library),
              title: Text("Our Gallery"),
              trailing: Icon(Icons.chevron_right),
            ),

            ListTile(
              leading: const Icon(Icons.headset_mic),
              title: const Text("Contact Us"),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // Close the drawer first
                Navigator.pop(context);
                // Push the Contact Screen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ContactScreen(),
                  ),
                );
              },
            ),

            ListTile(
              leading: const Icon(Icons.privacy_tip),
              title: const Text("Privacy Policy"),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // Close the drawer first
                Navigator.pop(context);
                // Push the Privacy Policy Screen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PrivacyPolicyScreen(),
                  ),
                );
              },
            ),

            const ListTile(
              leading: Icon(Icons.help),
              title: Text("Help & Support"),
              trailing: Icon(Icons.chevron_right),
            ),

            const ListTile(
              leading: Icon(Icons.language),
              title: Text("Language"),
              trailing: Icon(Icons.chevron_right),
            ),
          ],
        ),
      ),
    );
  }
}