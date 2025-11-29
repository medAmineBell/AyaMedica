import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_getx_app/screens/dashboard/widgets/charts/pie_chart_widget.dart';
import 'package:flutter_svg/svg.dart';

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
      // margin: const EdgeInsets.only(left: 8),
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
          const Row(
            children: [
              Text(
                'Title',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D2E2E),
                ),
              ),
              Spacer(),
              CustomDateFilterDropdown(
                options: [
                  "This Week",
                  "Last Week",
                  "This Month",
                  "Last Month",
                  "This Year",
                  "Last Year",
                  "Custom Date",
                ],
                initialValue: "This Week",
              )
            ],
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
                      touchedIndex =
                          pieTouchResponse.touchedSection!.touchedSectionIndex;
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
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _Indicator(
                color: const Color(0xFF1339FF),
                text: 'Product1',
                value: '25%',
                isSquare: false,
              ),
              SizedBox(height: 8),
              _Indicator(
                color: const Color(0xFF1397FF),
                text: 'Product2',
                value: '25%',
                isSquare: false,
              ),
              SizedBox(height: 8),
              _Indicator(
                color: Color(0xFF01C448),
                text: 'Product3',
                value: '25%',
                isSquare: false,
              ),
              SizedBox(height: 8),
              _Indicator(
                color: Color(0xFFD6A100),
                text: 'Product4',
                value: '25%',
                isSquare: false,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.only(left: 10.0),
            child: Row(
              children: [
                const Text(
                  "\$20 678.89 ",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2D2E2E),
                  ),
                ),
                const SizedBox(
                  width: 8,
                ),
                const Text(
                  "-1.5%",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF747677),
                  ),
                ),
                const SizedBox(
                  width: 4,
                ),
                SvgPicture.asset(
                  'assets/svg/trend_arrow.svg',
                  width: 16,
                  height: 16,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> showingSections() {
    return List.generate(
      4,
      (i) {
        final isTouched = i == touchedIndex;
        final opacity = isTouched ? 1.0 : 0.8;

        switch (i) {
          case 0:
            return PieChartSectionData(
              color: const Color(0xFF1339FF).withOpacity(opacity),
              value: 25,
              title: '',
              radius: 25,
            );
          case 1:
            return PieChartSectionData(
              color: const Color(0xFF01C448).withOpacity(opacity),
              value: 25,
              title: '',
              radius: 50,
            );
          case 2:
            return PieChartSectionData(
              color: const Color(0xFF1397FF).withOpacity(opacity),
              value: 25,
              title: '',
              radius: 60,
            );
          case 3:
            return PieChartSectionData(
              color: const Color(0xFFD6A100).withOpacity(opacity),
              value: 25,
              title: '',
              radius: 75,
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
    this.size = 12,
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
        /*const Spacer(),
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFF2D2E2E),
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),*/
      ],
    );
  }
}
