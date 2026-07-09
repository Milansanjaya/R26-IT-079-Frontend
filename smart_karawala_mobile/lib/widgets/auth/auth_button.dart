import 'package:flutter/material.dart';

class AuthButton extends StatelessWidget {

  final String title;
  final VoidCallback onTap;

  const AuthButton({

    super.key,

    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {

    return SizedBox(

      width: double.infinity,

      height: 50,

      child: ElevatedButton(

        onPressed: onTap,

        style: ElevatedButton.styleFrom(

          backgroundColor: const Color(0xff0057B8),

          shape: RoundedRectangleBorder(

            borderRadius: BorderRadius.circular(12),
          ),
        ),

        child: Text(

          title,

          style: const TextStyle(

            fontSize: 18,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}