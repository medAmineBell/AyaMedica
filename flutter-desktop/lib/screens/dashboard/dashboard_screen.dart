import 'package:flutter/material.dart';
import 'package:flutter_getx_app/screens/dashboard/widgets/charts/bar_chart_widget.dart';
import 'package:flutter_getx_app/screens/dashboard/widgets/charts/line_chart_widget.dart';
import 'package:flutter_getx_app/screens/dashboard/widgets/charts/pie_chart_sample.dart';
import 'package:flutter_getx_app/screens/dashboard/widgets/charts/pie_chart_widget.dart';
import 'package:flutter_getx_app/shared/widgets/breadcrumb_widget.dart';
import 'package:flutter_svg/svg.dart';


class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return 
    Container(
      color: const Color(0xFFFBFCFD),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height - 80, // Subtract navbar height
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Dashboard',
                        style: TextStyle(
                          color: Color(0xFF2D2E2E) /* Text-Text-100 */,
                          fontSize: 20,
                          fontFamily: 'IBM Plex Sans Arabic',
                          fontWeight: FontWeight.w700,
                          height: 1.40,
                        ),
                      ),
                      const BreadcrumbWidget(
                        items: [
                          BreadcrumbItem(label: 'Ayamedica portal'),
                          BreadcrumbItem(label: 'Dashboard'),
                        ],
                      ),
                    ],
                  ),
                  OutlineButton(
                    text: 'Export data',
                    icon: SvgPicture.asset(
                      'assets/svg/download.svg',
                      width: 18,
                      height: 18,
                      color: const Color(0xFF7A7A7A),
                    ),
                    onPressed: () {
                      print('Export data pressed');
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // First row: 1/3 + 2/3

              SizedBox(
                height: 350,
                child: Row(
                  children: const [
                    Expanded(
                      flex: 1,
                      child: PieChartWidget(),
                    ),
                    Expanded(
                      flex: 2,
                      child: LineChartWidget(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Second row: 2/3 + 1/3
              SizedBox(
                height: 350, // Fixed height for second row
                child: Row(
                  children: const [
                    Expanded(
                      flex: 2,
                      child: BarChartWidget(),
                    ),
                    Expanded(
                      flex: 1,
                      child: PieChartSample(
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
class OutlineButton extends StatelessWidget {
  final String text;
  final SvgPicture? icon;
  final VoidCallback? onPressed;
  final Color borderColor;
  final Color textColor;
  final Color iconColor;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final double fontSize;
  final FontWeight fontWeight;

  const OutlineButton({
    super.key,
    required this.text,
    this.icon,
    this.onPressed,
    this.borderColor = const Color(0xFFB8B8B8),
    this.textColor = const Color(0xFF7A7A7A),
    this.iconColor = const Color(0xFF7A7A7A),
    this.borderRadius = 12.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    this.fontSize = 16.0,
    this.fontWeight = FontWeight.w500,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        side: BorderSide(
          color: borderColor,
          width: 1.5,

        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        padding: padding,
        backgroundColor: Colors.transparent,
        foregroundColor: textColor,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
           icon!,
            const SizedBox(width: 8),
          ],
          Text(
            text,
            style: TextStyle(
              color: textColor,
              fontSize: fontSize,
              fontWeight: fontWeight,
            ),
          ),
        ],
      ),
    );
  }
}

// Custom download icon to match the image
class DownloadIcon extends StatelessWidget {
  final Color color;
  final double size;

  const DownloadIcon({
    super.key,
    this.color = const Color(0xFF7A7A7A),
    this.size = 18.0,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: DownloadIconPainter(color: color),
    );
  }
}

class DownloadIconPainter extends CustomPainter {
  final Color color;

  DownloadIconPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);
    
    // Draw vertical line (arrow body)
    canvas.drawLine(
      Offset(center.dx, size.height * 0.2),
      Offset(center.dx, size.height * 0.75),
      paint,
    );
    
    // Draw arrow head
    canvas.drawLine(
      Offset(center.dx - size.width * 0.15, size.height * 0.6),
      Offset(center.dx, size.height * 0.75),
      paint,
    );
    
    canvas.drawLine(
      Offset(center.dx + size.width * 0.15, size.height * 0.6),
      Offset(center.dx, size.height * 0.75),
      paint,
    );
    
    // Draw base line
    canvas.drawLine(
      Offset(size.width * 0.25, size.height * 0.85),
      Offset(size.width * 0.75, size.height * 0.85),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}