import 'dart:ui';
import '../../services/auth_service.dart';
import '../../services/storage_service.dart';
import '../admin/admin_home_screen.dart';
import '../customer/customer_home.dart';

import 'package:flutter/material.dart';

import '../../utils/app_colors.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';
import 'package:flutter/material.dart';

class CustomerHome extends StatelessWidget {
  const CustomerHome({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text("Customer Home"),
      ),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool hidePassword = true;

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      body: Stack(

        children: [

          /// Background

          Positioned.fill(

            child: Image.asset(
              "assets/images/background.jpg",
              fit: BoxFit.cover,
            ),

          ),

          /// Dark overlay

          Positioned.fill(

            child: Container(
              color: Colors.black.withOpacity(.20),
            ),

          ),

          /// Content

          SafeArea(

            child: Center(

              child: SingleChildScrollView(

                padding: const EdgeInsets.all(24),

                child: ClipRRect(

                  borderRadius: BorderRadius.circular(18),

                  child: BackdropFilter(

                    filter: ImageFilter.blur(
                      sigmaX: 10,
                      sigmaY: 10,
                    ),

                    child: Container(

                      width: 360,

                      padding: const EdgeInsets.all(24),

                      decoration: BoxDecoration(

                        color: Colors.white.withOpacity(.25),

                        borderRadius: BorderRadius.circular(18),

                        border: Border.all(
                          color: AppColors.border,
                          width: 2,
                        ),

                      ),

                      child: Column(

                        children: [

                          Image.asset(
                            "assets/images/logo.png",
                            width: 110,
                          ),

                          const SizedBox(height:20),

                          const Text(

                            "SIGN IN",

                            style: TextStyle(

                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: AppColors.text,

                            ),

                          ),

                          const SizedBox(height:35),

                          CustomTextField(

                            controller: emailController,

                            hint: "Email",

                            icon: Icons.email,

                          ),

                          const SizedBox(height:18),

                          CustomTextField(

                            controller: passwordController,

                            hint: "Password",

                            icon: Icons.lock,

                            obscure: hidePassword,

                            suffix: IconButton(

                              onPressed: (){

                                setState(() {

                                  hidePassword = !hidePassword;

                                });

                              },

                              icon: Icon(

                                hidePassword
                                    ? Icons.visibility
                                    : Icons.visibility_off,

                              ),

                            ),

                          ),

                          const SizedBox(height:25),

                          CustomButton(

                            text: "Sign In",

                           onPressed: () async {

  final response = await AuthService.login(
    email: emailController.text.trim(),
    password: passwordController.text.trim(),
  );

  if (response["success"] == true) {

    final token = response["access_token"];

    await StorageService().saveToken(token);

    final role = response["user"]["role"];

    if (!context.mounted) return;

    if (role == "admin") {

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const AdminHomeScreen(),
        ),
      );

    } else {

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const CustomerHome(),
        ),
      );

    }

  } else {

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(response["message"]),
      ),
    );

  }

},

                          ),

                          const SizedBox(height:20),

                          TextButton(

                            onPressed: () {

                            },

                            child: const Text(

                              "Forgot Password ?",

                              style: TextStyle(

                                color: AppColors.text,

                              ),

                            ),

                          ),

                          Row(

                            mainAxisAlignment: MainAxisAlignment.center,

                            children: [

                              const Text(
                                "Don't have an account ?",
                              ),

                              TextButton(

                                onPressed: () {

                                },

                                child: const Text(

                                  "Sign Up",

                                  style: TextStyle(

                                    color: AppColors.primary,

                                    fontWeight: FontWeight.bold,

                                  ),

                                ),

                              )

                            ],

                          )

                        ],

                      ),

                    ),

                  ),

                ),

              ),

            ),

          ),

          /// Bottom

          Positioned(

            bottom:15,

            left:0,

            right:0,

            child: Center(

              child: Text(

                "Powered by Smart Karawala",

                style: TextStyle(

                  color: Colors.white.withOpacity(.9),

                  fontWeight: FontWeight.bold,

                ),

              ),

            ),

          )

        ],

      ),

    );

  }

}