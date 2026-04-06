import 'package:flutter/material.dart';

class SpecialtyCard extends StatelessWidget {
  final String title;
  final bool isSelected;
  final Color? backgroundColor;
  final Color? textColor;
  final Widget? icon;
  
  const SpecialtyCard({
    super.key,
    required this.title,
    this.isSelected = false,
    this.backgroundColor,
    this.textColor,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? (isSelected 
        ? const Color(0xFF0167FF) 
        : const Color(0xFFF3F4F6));
    
    final txtColor = textColor ?? (isSelected 
        ? const Color(0xFFD8FAE4) 
        : const Color(0xFF111827));
    
    return Container(
      width: 132,
      height: 90,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              color: txtColor,
              fontSize: 14,
              fontWeight: FontWeight.w700,
              height: 1.43,
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: icon ?? const Icon(
              Icons.medical_services,
              color: Color(0xFFD8FAE4),
              size: 24,
            ),
          ),
        ],
      ),
    );
  }
}