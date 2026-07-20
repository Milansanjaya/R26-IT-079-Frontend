import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import 'customer_home.dart';

class HeritageScreen extends StatelessWidget {
  const HeritageScreen({super.key});

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
                       )

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
                            "Our Heritage",
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: AppColors.text,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 20),

                          /// Paragraph 1
                          const Text(
                            "Smart Karawala was created to support Sri Lanka's traditional dry fish industry using modern digital technology. Dry fish processing has been part of coastal communities for many years, but many producers still depend on manual drying, visual checking, and experience-based decisions.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              height: 1.5,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 20),

                          /// Paragraph 2
                          const Text(
                            "Our system helps improve this traditional process by introducing IoT monitoring, real-time alerts, AI-based quality checking, and batch traceability. It supports better drying conditions, reduces spoilage risk, and helps protect the value of Sri Lankan dry fish products.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              height: 1.5,
                              color: Colors.black87,
                            ),
                          ),
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
}
