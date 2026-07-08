import 'package:flutter/material.dart';

class TraceabilityInfoCard extends StatelessWidget {
  const TraceabilityInfoCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xffE8F3FF),
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.verified_user,
            color: Color(0xff214E77),
          ),

          SizedBox(width: 12),

          Expanded(
            child: Text(
              "All records are securely stored and can be used for traceability and compliance.",
              style: TextStyle(
                fontSize: 13,
                color: Color(0xff214E77),
              ),
            ),
          ),
        ],
      ),
    );
  }
}