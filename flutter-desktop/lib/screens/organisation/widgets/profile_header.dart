import 'package:flutter/material.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 8, left: 12, right: 16, bottom: 8),
      decoration: ShapeDecoration(
        color: const Color(0xFF1339FF),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(124)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: const ShapeDecoration(
              color: Color(0xFFCDFF1F),
              shape: OvalBorder(),
            ),
            child: const Center(
              child: Text('SD', style: TextStyle(
                color: Color(0xFF1339FF),
                fontSize: 14,
                fontWeight: FontWeight.w700,
              )),
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('John Smith', style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              )),
              Text('AID 6EG2360J25L', style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              )),
            ],
          ),
        ],
      ),
    );
  }
}