import 'package:flutter/material.dart';

class AuthFooter extends StatelessWidget {

  const AuthFooter({super.key});

  @override
  Widget build(BuildContext context) {

    return const Padding(

      padding: EdgeInsets.only(top:25),

      child: Text(

        "Powered by Smart Karawala",

        style: TextStyle(

          color: Colors.black54,
        ),
      ),
    );
  }
}