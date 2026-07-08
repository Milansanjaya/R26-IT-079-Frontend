import 'package:flutter/material.dart';

class TestImage extends StatelessWidget {
  const TestImage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [

          Positioned.fill(
            child: Image.asset(
              "assets/images/background.jpg",
              fit: BoxFit.cover,
            ),
          ),

          Center(
            child: Image.asset(
              "assets/images/logo.png",
              width: 170,
            ),
          ),
        ],
      ),
    );
  }
}