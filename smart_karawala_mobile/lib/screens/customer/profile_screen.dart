import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../services/user_service.dart';
import '../../providers/auth_provider.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? user;
  bool loading = true;
  bool isDarkMode = false;

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  Future<void> loadUser() async {
    try {
      final response = await UserService.getCurrentUser();
      setState(() {
        user = response["user"];
        loading = false;
      });
    } catch (e) {
      debugPrint(e.toString());
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(
            color: AppColors.primary,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.text),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        centerTitle: true,
        title: const Text(
          "Profile Settings",
          style: TextStyle(
            color: AppColors.text,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 1. Profile Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.primary.withOpacity(0.85)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.white,
                        child: ClipOval(
                          child: Image.asset(
                            "assets/images/profile.jpg",
                            width: 76,
                            height: 76,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: AppColors.background,
                                width: 76,
                                height: 76,
                                child: const Icon(
                                  Icons.person,
                                  size: 40,
                                  color: AppColors.primary,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.edit,
                            size: 14,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?["full_name"] ?? user?["name"] ?? "Guest Customer",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user?["email"] ?? "guest@example.com",
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user?["phone"] ?? "+94 77 123 4567",
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            (user?["role"] ?? "Customer").toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),

            /// 2. Profile Insights Section
            _sectionHeader("Profile Insights"),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                insightItem(
                  icon: Icons.shopping_bag_outlined,
                  label: "Total Orders",
                  value: "12",
                  color: AppColors.primary,
                ),
                insightItem(
                  icon: Icons.star_outline,
                  label: "Loyalty Points",
                  value: "450",
                  color: Colors.orange,
                ),
                insightItem(
                  icon: Icons.rate_review_outlined,
                  label: "Reviews",
                  value: "5",
                  color: AppColors.success,
                ),
              ],
            ),
            const SizedBox(height: 25),

            /// 3. Settings Section
            _sectionHeader("Account Settings"),
            settingTile(
              icon: Icons.person_outline,
              title: "Edit Profile",
              subtitle: "Change username, phone and general details",
              onTap: () {
                _showFeatureComingSoonSnackBar("Edit Profile");
              },
            ),
            settingTile(
              icon: Icons.location_on_outlined,
              title: "My Addresses",
              subtitle: "Manage billing and shipping addresses",
              onTap: () {
                _showFeatureComingSoonSnackBar("My Addresses");
              },
            ),
            settingTile(
              icon: Icons.history,
              title: "Order History",
              subtitle: "View list of past purchases and tracking",
              onTap: () {
                _showFeatureComingSoonSnackBar("Order History");
              },
            ),
            settingTile(
              icon: Icons.notifications_none,
              title: "Notification Settings",
              subtitle: "Toggle alerts and newsletter subscriptions",
              onTap: () {
                _showFeatureComingSoonSnackBar("Notification Settings");
              },
            ),
            const SizedBox(height: 15),

            /// 4. Theme Section
            _sectionHeader("Preferences"),
            settingTile(
              icon: Icons.dark_mode_outlined,
              title: "Dark Theme",
              subtitle: "Switch to high contrast dark styling",
              trailing: Switch(
                value: isDarkMode,
                activeColor: AppColors.primary,
                onChanged: (val) {
                  setState(() {
                    isDarkMode = val;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        val ? "Dark theme enabled (Mock)" : "Light theme enabled (Mock)",
                      ),
                      duration: const Duration(milliseconds: 800),
                    ),
                  );
                },
              ),
              onTap: () {},
            ),
            const SizedBox(height: 15),

            /// 5. Additional Settings
            _sectionHeader("More Options"),
            settingTile(
              icon: Icons.help_outline,
              title: "Help & Support",
              subtitle: "FAQ, live chat and contact information",
              onTap: () {
                _showFeatureComingSoonSnackBar("Help & Support");
              },
            ),
            settingTile(
              icon: Icons.info_outline,
              title: "About Smart Karawala",
              subtitle: "App details, terms and privacy policy",
              onTap: () {
                _showFeatureComingSoonSnackBar("About Smart Karawala");
              },
            ),
            settingTile(
              icon: Icons.logout,
              title: "Log Out",
              subtitle: "Sign out of your active session safely",
              iconColor: AppColors.error,
              textColor: AppColors.error,
              trailing: const SizedBox.shrink(),
              onTap: () {
                _showLogoutConfirmDialog();
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 3,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.black54,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          if (index != 3) {
            Navigator.pop(context, index);
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_view),
            label: "Categories",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag_outlined),
            label: "Orders",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
      ),
    );
  }

  /// Section Header Widget
  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 10),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: AppColors.text,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  /// 6. insightItem helper method
  Widget insightItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.15), width: 1),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 7. settingTile helper method
  Widget settingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    required VoidCallback onTap,
    Color? iconColor,
    Color? textColor,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Colors.grey.shade100, width: 1.5),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: (iconColor ?? AppColors.primary).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: iconColor ?? AppColors.primary,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14.5,
            color: textColor ?? AppColors.text,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(
            color: AppColors.hint,
            fontSize: 12,
          ),
        ),
        trailing: trailing ?? Icon(
          Icons.chevron_right,
          color: AppColors.hint.withOpacity(0.7),
        ),
      ),
    );
  }

  void _showFeatureComingSoonSnackBar(String featureName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("$featureName is coming soon!"),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showLogoutConfirmDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Confirm Logout"),
        content: const Text("Are you sure you want to log out of your session?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Provider.of<AuthProvider>(context, listen: false).logout();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
            child: const Text(
              "Log Out",
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}