import 'package:flutter/material.dart';
import 'heritage_screen.dart';

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

            const ListTile(
              leading: Icon(Icons.headset_mic),
              title: Text("Contact Us"),
              trailing: Icon(Icons.chevron_right),
            ),

            const ListTile(
              leading: Icon(Icons.privacy_tip),
              title: Text("Privacy Policy"),
              trailing: Icon(Icons.chevron_right),
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