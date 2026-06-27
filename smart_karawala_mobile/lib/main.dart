import 'package:flutter/material.dart';
import 'screens/admin_home_screen.dart';



void main() {
  runApp(const SmartKarawalaApp());
}

class SmartKarawalaApp extends StatelessWidget {
  const SmartKarawalaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AdminHomeScreen(),
    );
  }
}