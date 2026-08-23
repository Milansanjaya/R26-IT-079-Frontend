import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../screens/admin/admin_home_screen.dart';
import '../../screens/customer/customer_home.dart';
import 'google_logo_widget.dart';

class GoogleAccountPicker {
  static Future<void> show(BuildContext context) async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return const _GoogleAccountPickerSheet();
      },
    );
  }
}

class _GoogleAccountPickerSheet extends StatefulWidget {
  const _GoogleAccountPickerSheet();

  @override
  State<_GoogleAccountPickerSheet> createState() => _GoogleAccountPickerSheetState();
}

class _GoogleAccountPickerSheetState extends State<_GoogleAccountPickerSheet> {
  bool _loading = false;
  String? _selectedEmail;

  final List<Map<String, String>> _accounts = [
    {
      "name": "Jayani Kalansooriya",
      "email": "jayanikalansooriya24@gmail.com",
      "role": "admin",
      "avatar": "J",
      "color": "0xFF0A5B8E",
    },
    {
      "name": "Sanjaya Perera",
      "email": "sanjaya@smartkarawala.com",
      "role": "admin",
      "avatar": "S",
      "color": "0xFF1565C0",
    },
    {
      "name": "Customer User",
      "email": "customer@smartkarawala.com",
      "role": "customer",
      "avatar": "C",
      "color": "0xFF2E7D32",
    },
  ];

  Future<void> _selectAccount(Map<String, String> account) async {
    setState(() {
      _loading = true;
      _selectedEmail = account["email"];
    });

    final auth = Provider.of<AuthProvider>(context, listen: false);

    try {
      final success = await auth.googleSignIn(
        email: account["email"],
        name: account["name"],
        role: account["role"],
      );

      if (!mounted) return;
      Navigator.pop(context); // Close bottom sheet

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const GoogleLogoWidget(size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "Signed in as ${account['name']}",
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF1E293B),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
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
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Google Sign-In failed: ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Google Header
          const Row(
            children: [
              GoogleLogoWidget(size: 28),
              SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Choose an account",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    "to continue to Smart Karawala",
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 20),
          const Divider(height: 1),
          const SizedBox(height: 12),

          // Account Items
          ..._accounts.map((account) {
            final isThisSelected = _loading && _selectedEmail == account["email"];
            final colorInt = int.parse(account["color"]!);

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                leading: CircleAvatar(
                  backgroundColor: Color(colorInt),
                  radius: 22,
                  child: Text(
                    account["avatar"]!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                title: Text(
                  account["name"]!,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: Color(0xFF0F172A),
                  ),
                ),
                subtitle: Text(
                  account["email"]!,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF64748B),
                  ),
                ),
                trailing: isThisSelected
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(
                        Icons.chevron_right_rounded,
                        color: Color(0xFF94A3B8),
                      ),
                onTap: _loading ? null : () => _selectAccount(account),
              ),
            );
          }),

          const Divider(height: 16),

          // Add another account option
          ListTile(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            leading: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person_add_alt_outlined,
                color: Color(0xFF475569),
                size: 22,
              ),
            ),
            title: const Text(
              "Use another account",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
                color: Color(0xFF0F172A),
              ),
            ),
            onTap: _loading
                ? null
                : () {
                    _selectAccount({
                      "name": "Google User",
                      "email": "user@gmail.com",
                      "role": "customer",
                    });
                  },
          ),

          const SizedBox(height: 16),

          // Google Privacy Note
          const Text(
            "To continue, Google will share your name, email address, and profile picture with Smart Karawala. See Smart Karawala's Privacy Policy and Terms of Service.",
            style: TextStyle(
              fontSize: 11,
              color: Color(0xFF94A3B8),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
