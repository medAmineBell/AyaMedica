import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TreeConnectorPainter extends CustomPainter {
  final bool isFirst;
  final bool isLast;

  TreeConnectorPainter({
    required this.isFirst,
    required this.isLast,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFE0E0E0)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final isRTL = Get.locale?.languageCode == 'ar';
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final radius = 6.0; // Corner radius

    final path = Path();

    if (isRTL) {
      // RTL Layout: Tree connector on the right side
      
      // Draw vertical line (if not the last item)
      if (!isLast) {
        path.moveTo(centerX, centerY);
        path.lineTo(centerX, size.height);
      }

      // Draw vertical line from top (if not the first item)
      if (!isFirst) {
        path.moveTo(centerX, 0);
        path.lineTo(centerX, centerY - radius);
      }

      // Draw curved corner and horizontal line (going left)
      path.moveTo(centerX, centerY - radius);
      path.quadraticBezierTo(
        centerX, centerY, // control point
        centerX - radius, centerY, // end point (going left)
      );
      path.lineTo(0, centerY); // Line goes to the left edge
    } else {
      // LTR Layout: Tree connector on the left side
      
      // Draw vertical line (if not the last item)
      if (!isLast) {
        path.moveTo(centerX, centerY);
        path.lineTo(centerX, size.height);
      }

      // Draw vertical line from top (if not the first item)
      if (!isFirst) {
        path.moveTo(centerX, 0);
        path.lineTo(centerX, centerY - radius);
      }

      // Draw curved corner and horizontal line (going right)
      path.moveTo(centerX, centerY - radius);
      path.quadraticBezierTo(
        centerX, centerY, // control point
        centerX + radius, centerY, // end point (going right)
      );
      path.lineTo(size.width, centerY); // Line goes to the right edge
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}