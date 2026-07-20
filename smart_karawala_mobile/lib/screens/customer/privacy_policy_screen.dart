import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import 'customer_home.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          /// 1. Background Image with Dark Overlay
          Positioned.fill(
            child: Image.asset(
              "assets/images/background.jpg",
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: AppColors.background,
                );
              },
            ),
          ),
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.55),
            ),
          ),

          /// 2. Top-Left Close (Menu) Button
          Positioned(
            top: 40,
            left: 20,
            child: GestureDetector(
              onTap: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const CustomerHome()),
                  (route) => false,
                );
              },
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.menu,
                  color: AppColors.text,
                  size: 24,
                ),
              ),
            ),
          ),

          /// 3. Scrollable Content container to prevent overflows on small screens
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    /// Centered Glassmorphic Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.88),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.4),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.25),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          /// Logo
                          Image.asset(
                            "assets/images/logo.png",
                            width: 90,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.set_meal,
                                size: 50,
                                color: AppColors.primary,
                              );
                            },
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            "Smart",
                            style: TextStyle(
                              fontFamily: "Poppins",
                              fontSize: 18,
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.bold,
                              color: AppColors.text,
                            ),
                          ),
                          const Text(
                            "කරවල",
                            style: TextStyle(
                              fontFamily: "Poppins",
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.text,
                            ),
                          ),
                          const SizedBox(height: 25),

                          /// Heading
                          const Text(
                            "Privacy Policy",
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: AppColors.text,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 25),

                          /// Bullet List
                          _bulletPoint("Smart Karawala is committed to protecting your privacy and ensuring that your data is handled securely and responsibly."),
                          _bulletPoint("We collect only the necessary information required to operate the system effectively. This may include user details, batch records, sensor data (such as temperature and humidity), and system usage information. All collected data is used strictly for improving drying processes, monitoring quality, and providing accurate system insights."),
                          _bulletPoint("Your data will not be shared with third parties without your consent, except where required for system functionality or legal compliance. We implement appropriate security measures to protect your information from unauthorized access, loss, or misuse."),
                          _bulletPoint("Users have full control over their data, and access is managed through secure authentication and role-based permissions. Our goal is to ensure transparency, trust, and safe usage of the Smart Karawala platform."),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),

                    /// Footer text
                    Text(
                      "Powered by Smart Karawala",
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.9),
                        fontWeight: FontWeight.w500,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.5),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Custom bullet widget helper
  Widget _bulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 4.0),
            child: Icon(
              Icons.brightness_1,
              size: 6,
              color: Colors.black87,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                height: 1.45,
                color: Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
