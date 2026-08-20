import 'package:flutter/material.dart';
import '../../widgets/Batch/colors.dart';
import '../../services/storage_service.dart';
import '../auth/login_screen.dart';
import 'edit_personal_info_screen.dart';
import 'security_settings_screen.dart';
import 'help_support_screen.dart';

class AdminProfileScreen extends StatefulWidget {
  const AdminProfileScreen({super.key});

  @override
  State<AdminProfileScreen> createState() => _AdminProfileScreenState();
}

class _AdminProfileScreenState extends State<AdminProfileScreen> {
  String adminName = "Sanjaya";
  String adminRole = "System Administrator";
  String adminEmail = "sanjaya@smartkarawala.com";
  String adminPhone = "+94 77 123 4567";
  bool darkMode = false;

  Widget insightItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget menuOption(IconData icon, String title, VoidCallback onTap, {Widget? trailing}) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.background.withOpacity(0.4),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.primary, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.primary),
      ),
      trailing: trailing ?? const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: const Text(
          "Admin Profile",
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            // 1. Profile Summary Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.04),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 36,
                        backgroundImage: AssetImage("assets/images/profile.jpg"),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              adminName,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              adminRole,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              adminEmail,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 2. Profile Insights Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.04),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.insights_rounded, color: AppColors.primary),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          "Your Administrative Insights",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24, color: Color(0xFFF1F3F5)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      insightItem("142", "Batches\nManaged"),
                      insightItem("450 kg", "Waste\nMonitored"),
                      insightItem("3.2%", "Average\nSalt Level"),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 3. Settings List Card
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.04),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // 1. Edit Personal Information
                  menuOption(
                    Icons.person_outline_rounded,
                    "Edit Personal Information",
                    () async {
                      final result = await Navigator.push<Map<String, String>>(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EditPersonalInfoScreen(
                            currentName: adminName,
                            currentRole: adminRole,
                            currentEmail: adminEmail,
                            currentPhone: adminPhone,
                          ),
                        ),
                      );

                      if (result != null && mounted) {
                        setState(() {
                          adminName = result['name'] ?? adminName;
                          adminRole = result['role'] ?? adminRole;
                          adminEmail = result['email'] ?? adminEmail;
                          adminPhone = result['phone'] ?? adminPhone;
                        });
                      }
                    },
                  ),

                  // 2. Security Settings
                  menuOption(
                    Icons.lock_outline_rounded,
                    "Security Settings",
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SecuritySettingsScreen(),
                        ),
                      );
                    },
                  ),

                  // 3. Dark Mode
                  menuOption(
                    Icons.dark_mode_outlined,
                    "Dark Mode",
                    () {
                      setState(() {
                        darkMode = !darkMode;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(darkMode ? "Dark mode enabled" : "Light mode enabled"),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                    trailing: Switch.adaptive(
                      value: darkMode,
                      activeColor: AppColors.primary,
                      onChanged: (val) {
                        setState(() {
                          darkMode = val;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(val ? "Dark mode enabled" : "Light mode enabled"),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      },
                    ),
                  ),

                  // 4. Help & Support
                  menuOption(
                    Icons.help_outline_rounded,
                    "Help & Support",
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const HelpSupportScreen(),
                        ),
                      );
                    },
                  ),

                  const Divider(height: 16, color: Color(0xFFF1F3F5)),

                  // 5. Log Out with Confirmation Dialog
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.logout_rounded, color: Colors.red, size: 20),
                    ),
                    title: const Text(
                      "Log Out",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.red),
                    ),
                    trailing: const Icon(Icons.chevron_right, color: Colors.red),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          title: const Row(
                            children: [
                              Icon(Icons.logout_rounded, color: Colors.red),
                              SizedBox(width: 10),
                              Text("Log Out"),
                            ],
                          ),
                          content: const Text("Are you sure you want to log out of your account?"),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              onPressed: () async {
                                Navigator.pop(ctx);
                                await StorageService.clearToken();
                                if (!mounted) return;
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                                  (route) => false,
                                );
                              },
                              child: const Text("Log Out", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            const Center(
              child: Text(
                "Powered by Smart Karawala",
                style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w500),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
