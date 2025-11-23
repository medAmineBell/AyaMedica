import 'package:flutter/material.dart';

class CustomFormField extends StatelessWidget {
  final String label;
  final String value;
  final bool hasDropdown;

  const CustomFormField({
    super.key,
    required this.label,
    required this.value,
    this.hasDropdown = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(
          color: Color(0xFF595A5B),
          fontSize: 14,
          fontWeight: FontWeight.w500,
        )),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFFBFCFD),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE9E9E9))),
          child: Row(
            children: [
              Expanded(child: Text(value, style: const TextStyle(
                color: Color(0xFF2D2E2E),
              ))),
              if(hasDropdown) const Icon(Icons.arrow_drop_down)
            ],
          ),
        ),
      ],
    );
  }
}