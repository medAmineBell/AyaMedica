import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class PieChartSample extends StatefulWidget {
  const PieChartSample({super.key});

  @override
  State<PieChartSample> createState() => _PieChartSampleState();
}

class _PieChartSampleState extends State<PieChartSample> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Appointments Status',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D2E2E),
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: PieChart(
              PieChartData(
                pieTouchData: PieTouchData(
                  touchCallback: (FlTouchEvent event, pieTouchResponse) {
                    setState(() {
                      if (!event.isInterestedForInteractions ||
                          pieTouchResponse == null ||
                          pieTouchResponse.touchedSection == null) {
                        touchedIndex = -1;
                        return;
                      }
                      touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                    });
                  },
                ),
                startDegreeOffset: 180,
                borderData: FlBorderData(show: false),
                sectionsSpace: 1,
                centerSpaceRadius: 0,
                sections: showingSections(),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Column(
            children: [
              _Indicator(
                color: const Color(0xFF1339FF),
                text: 'Completed',
                value: '48%',
                isSquare: false,
              ),
              const SizedBox(height: 8),
              _Indicator(
                color: const Color(0xFFD6A100),
                text: 'Pending',
                value: '32%',
                isSquare: false,
              ),
              const SizedBox(height: 8),
              _Indicator(
                color: const Color(0xFFEDF1F5),
                text: 'Cancelled',
                value: '20%',
                isSquare: false,
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> showingSections() {
    return List.generate(
      3,
      (i) {
        final isTouched = i == touchedIndex;
        final opacity = isTouched ? 1.0 : 0.8;

        switch (i) {
          case 0:
            return PieChartSectionData(
              color: const Color(0xFF1339FF).withOpacity(opacity),
              value: 48,
              title: '',
              radius: 80,
            );
          case 1:
            return PieChartSectionData(
              color: const Color(0xFFD6A100).withOpacity(opacity),
              value: 32,
              title: '',
              radius: 75,
            );
          case 2:
            return PieChartSectionData(
              color: const Color(0xFFEDF1F5).withOpacity(opacity),
              value: 20,
              title: '',
              radius: 70,
            );
          default:
            return PieChartSectionData();
        }
      },
    );
  }
}

class _Indicator extends StatelessWidget {
  final Color color;
  final String text;
  final String value;
  final bool isSquare;
  final double size;

  const _Indicator({
    required this.color,
    required this.text,
    required this.value,
    this.isSquare = false,
    this.size = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: isSquare ? BoxShape.rectangle : BoxShape.circle,
            color: color,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
            color: Color(0xFF595A5B),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFF2D2E2E),
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
