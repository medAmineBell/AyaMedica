import 'package:flutter/material.dart';

class VitalsCard extends StatelessWidget {
  final String title;
  final String value;
  final Widget? leadingIcon;
  final Color backgroundColor;
  final Color borderColor;
  final Color innerBoxColor;

  const VitalsCard({
    Key? key,
    required this.title,
    required this.value,
    this.leadingIcon,
    this.backgroundColor = Colors.white,
    this.borderColor = const Color(0xFFE4E9ED),
    this.innerBoxColor = const Color(0xFFFBFCFD),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      height: 120,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: ShapeDecoration(
        color: backgroundColor,
        shape: RoundedRectangleBorder(
          side: BorderSide(width: 1, color: borderColor),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (leadingIcon != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: SizedBox(width: 24, height: 24, child: leadingIcon),
            ),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFFA6A9AC),
              fontSize: 12,
              fontFamily: 'IBM Plex Sans Arabic',
              fontWeight: FontWeight.w700,
              height: 1.33,
              letterSpacing: 0.36,
            ),
          ),
          const Spacer(),
          Container(
            width: double.infinity,
            height: 40,
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: ShapeDecoration(
              color: innerBoxColor,
              shape: RoundedRectangleBorder(
                side: BorderSide(width: 0.4, color: borderColor),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Center(
              child: Text(
                value,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFFA6A9AC),
                  fontSize: 12,
                  fontFamily: 'IBM Plex Sans Arabic',
                  fontWeight: FontWeight.w500,
                  height: 1.33,
                  letterSpacing: 0.36,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
