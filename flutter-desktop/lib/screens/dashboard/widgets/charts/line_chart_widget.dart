/*import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_getx_app/screens/dashboard/widgets/charts/pie_chart_widget.dart';
import 'package:flutter_svg/svg.dart';

class LineChartWidget extends StatelessWidget {
  const LineChartWidget({Key? key}) : super(key: key);

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
            child: LineChart(
              /*
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: const FlTitlesData(
                  rightTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: const [
                      FlSpot(1, 3),
                      FlSpot(2.6, 2),
                      FlSpot(4.9, 5),
                      FlSpot(6.8, 2.5),
                      FlSpot(8, 4),
                      FlSpot(9.5, 3),
                      FlSpot(11, 4),
                    ],
                    isCurved: true,
                    color: const Color(0xFF1339FF),
                    barWidth: 2,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    /*belowBarData: BarAreaData(
                      show: true,
                      color: const Color(0xFF1339FF).withOpacity(0.1),
                    ),*/
                  ),
                  LineChartBarData(
                    spots: const [
                      FlSpot(1, 1),
                      FlSpot(2.6, 3.5),
                      FlSpot(4.9, 2),
                      FlSpot(6.8, 4),
                      FlSpot(8, 3),
                      FlSpot(9.5, 4.5),
                      FlSpot(11, 3.5),
                    ],
                    isCurved: true,
                    color: const Color(0xFFD6A100),
                    barWidth: 2,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    dashArray: [4, 4],
                    /*belowBarData: BarAreaData(
                      show: true,
                      color: const Color(0xFFD6A100).withOpacity(0.1),
                    ),*/
                  ),
                ],
              ),
            */
              LineChartData(
                minY: 0,
                maxY: 25000,
                minX: 1,
                maxX: 5,
                gridData: const FlGridData(show: true),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 5000,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: const TextStyle(
                            fontSize: 10,
                            color: Color(0xFF747677),
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        final monthLabels = [
                          "",
                          /*"Jan",
                          "Feb",
                          "Mar",
                          "Apr",*/
                          "May",
                          "Jun",
                          "Jul",
                          "Aug",
                          "Sep",
                          /*"Oct",
                          "Nov",
                          "Dec"*/
                        ];
                        if (value.toInt() >= 1 && value.toInt() <= 12) {
                          return Text(monthLabels[value.toInt()]);
                        }
                        return const SizedBox();
                      },
                    ),
                  ),
                  rightTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: const [
                      FlSpot(1, 5000),
                      FlSpot(2, 8000),
                      FlSpot(3, 12000),
                      FlSpot(4, 9000),
                      FlSpot(5, 14000),
                      FlSpot(6, 10000),
                      FlSpot(7, 16000),
                    ],
                    isCurved: true,
                    color: const Color(0xFF1339FF),
                    barWidth: 2,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    /*belowBarData: BarAreaData(
                      show: true,
                      color: const Color(0xFF1339FF).withOpacity(0.1),
                    ),*/
                  ),
                  LineChartBarData(
                    spots: const [
                      FlSpot(1, 3000),
                      FlSpot(2, 6000),
                      FlSpot(3, 9000),
                      FlSpot(4, 7000),
                      FlSpot(5, 11000),
                      FlSpot(6, 9000),
                      FlSpot(7, 13000),
                    ],
                    isCurved: true,
                    color: const Color(0xFFD6A100),
                    barWidth: 2,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    dashArray: [4, 4],
                    /*belowBarData: BarAreaData(
                      show: true,
                      color: const Color(0xFFD6A100).withOpacity(0.1),
                    ),*/
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 16.0),
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
                Spacer(),
                _buildLegendItem(const Color(0xFF1339FF), 'Product1'),
                const SizedBox(width: 8),
                _buildLegendItem(const Color(0xFFD6A100), 'Product2'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Widget _buildLegendItem(Color color, String label) {
  return Row(
    children: [
      Container(
        width: 16,
        height: 16,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.rectangle,
          borderRadius: const BorderRadius.all(Radius.circular(6)),
        ),
        child: const Icon(
          Icons.check,
          size: 10,
          color: Colors.white,
        ),
      ),
      const SizedBox(width: 8),
      Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Color(0xFF747677),
        ),
      ),
    ],
  );
}
*/

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_getx_app/screens/dashboard/widgets/charts/pie_chart_widget.dart';
import 'package:flutter_svg/svg.dart';

class LineChartWidget extends StatelessWidget {
  const LineChartWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
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
            child: LineChart(
              LineChartData(
                minY: 0,
                maxY: 25000,
                minX: 0,
                maxX: 6,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: true,
                  drawHorizontalLine: true,
                  horizontalInterval: 5000,
                  verticalInterval: 1,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: const Color(0xFFE5E5E5),
                      strokeWidth: 1,
                    );
                  },
                  getDrawingVerticalLine: (value) {
                    return FlLine(
                      color: const Color(0xFFE5E5E5),
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 5000,
                      reservedSize: 50,
                      getTitlesWidget: (value, meta) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Text(
                            '${(value.toInt() ~/ 1000)}k',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF747677),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        final monthLabels = [
                          "Apr",
                          "May",
                          "Jun",
                          "Jul",
                          "Aug",
                          "Sep",
                        ];
                        int index = value.toInt();
                        if (index >= 0 && index < monthLabels.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              monthLabels[index],
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF747677),
                              ),
                            ),
                          );
                        }
                        return const SizedBox();
                      },
                    ),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: const [
                      FlSpot(0, 2000),
                      FlSpot(0.5, 5000),
                      FlSpot(1, 10000),
                      FlSpot(1.5, 15000),
                      FlSpot(2, 16500),
                      FlSpot(2.5, 13000),
                      FlSpot(3, 10000),
                      FlSpot(3.5, 11000),
                      FlSpot(4, 17000),
                      FlSpot(4.5, 18500),
                      FlSpot(5, 19000),
                      FlSpot(5.5, 18000),
                      FlSpot(6, 12000),
                    ],
                    isCurved: true,
                    curveSmoothness: 0.35,
                    color: const Color(0xFF1339FF),
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                  ),
                  LineChartBarData(
                    spots: const [
                      FlSpot(0, 9000),
                      FlSpot(0.5, 6500),
                      FlSpot(1, 5000),
                      FlSpot(1.5, 14000),
                      FlSpot(2, 15000),
                      FlSpot(2.5, 15000),
                      FlSpot(3, 14500),
                      FlSpot(3.5, 11000),
                      FlSpot(4, 10500),
                      FlSpot(4.5, 17000),
                      FlSpot(5, 21500),
                      FlSpot(5.5, 22000),
                      FlSpot(6, 17000),
                    ],
                    isCurved: true,
                    curveSmoothness: 0.35,
                    color: const Color(0xFFD6A100),
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    dashArray: [8, 4],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 16.0),
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
                const SizedBox(width: 8),
                const Text(
                  "-1.5%",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF747677),
                  ),
                ),
                const SizedBox(width: 4),
                Container(
                  width: 20,
                  height: 20,
                  decoration: const BoxDecoration(
                    color: Color(0xFF1339FF),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_downward,
                    size: 12,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                _buildLegendItem(const Color(0xFF1339FF), 'Product 1'),
                const SizedBox(width: 16),
                _buildLegendItem(const Color(0xFFD6A100), 'Product 2'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Widget _buildLegendItem(Color color, String label) {
  return Row(
    children: [
      Container(
        width: 18,
        height: 18,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(4),
        ),
        child: const Icon(
          Icons.check,
          size: 12,
          color: Colors.white,
        ),
      ),
      const SizedBox(width: 8),
      Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Color(0xFF2D2E2E),
        ),
      ),
    ],
  );
}
