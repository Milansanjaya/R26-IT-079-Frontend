import 'package:flutter/material.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: const [
            Text(
              "More",
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),

            ListTile(
              leading: Icon(Icons.account_balance),
              title: Text("Our Heritage"),
              trailing: Icon(Icons.chevron_right),
            ),

            ListTile(
              leading: Icon(Icons.photo_library),
              title: Text("Our Gallery"),
              trailing: Icon(Icons.chevron_right),
            ),

            ListTile(
              leading: Icon(Icons.headset_mic),
              title: Text("Contact Us"),
              trailing: Icon(Icons.chevron_right),
            ),

            ListTile(
              leading: Icon(Icons.privacy_tip),
              title: Text("Privacy Policy"),
              trailing: Icon(Icons.chevron_right),
            ),

            ListTile(
              leading: Icon(Icons.help),
              title: Text("Help & Support"),
              trailing: Icon(Icons.chevron_right),
            ),

            ListTile(
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