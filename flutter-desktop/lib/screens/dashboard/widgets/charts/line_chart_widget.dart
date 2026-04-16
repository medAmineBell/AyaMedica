import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:get/get.dart';
import '../../../../controllers/dashboard_controller.dart';

class LineChartWidget extends StatelessWidget {
  const LineChartWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DashboardController>();

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
          const Text(
            'Monthly Trend',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D2E2E),
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Obx(() {
              if (controller.isLoadingMonthlyTrend.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.monthlyTrend.isEmpty) {
                return const Center(
                  child: Text(
                    'No trend data',
                    style: TextStyle(color: Color(0xFF858789), fontSize: 14),
                  ),
                );
              }

              final data = controller.monthlyTrend;
              final maxY = _calcMaxY(data);

              final appointmentSpots = <FlSpot>[];
              final sickLeaveSpots = <FlSpot>[];
              for (int i = 0; i < data.length; i++) {
                final appts =
                    (data[i]['appointments'] as num?)?.toDouble() ?? 0;
                final sick =
                    (data[i]['sickLeaves'] as num?)?.toDouble() ?? 0;
                appointmentSpots.add(FlSpot(i.toDouble(), appts));
                sickLeaveSpots.add(FlSpot(i.toDouble(), sick));
              }

              return LineChart(
                LineChartData(
                  minY: 0,
                  maxY: maxY,
                  minX: 0,
                  maxX: (data.length - 1).toDouble(),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: true,
                    drawHorizontalLine: true,
                    horizontalInterval: maxY / 5,
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
                        interval: maxY / 5,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Text(
                              value.toInt().toString(),
                              style: const TextStyle(
                                fontSize: 11,
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
                          final index = value.toInt();
                          if (index < 0 || index >= data.length) {
                            return const SizedBox();
                          }
                          final month =
                              data[index]['month'] as String? ?? '';
                          // Show short label: "Apr 26" from "April 2026"
                          final label = _shortMonth(month);
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              label,
                              style: const TextStyle(
                                fontSize: 10,
                                color: Color(0xFF747677),
                              ),
                            ),
                          );
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
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipItems: (touchedSpots) {
                        return touchedSpots.map((spot) {
                          final color = spot.bar.color ?? Colors.blue;
                          final label = spot.barIndex == 0
                              ? 'Appointments'
                              : 'Sick Leaves';
                          return LineTooltipItem(
                            '$label: ${spot.y.toInt()}',
                            TextStyle(
                              color: color,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          );
                        }).toList();
                      },
                    ),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: appointmentSpots,
                      isCurved: true,
                      curveSmoothness: 0.35,
                      color: const Color(0xFF1339FF),
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: false),
                    ),
                    LineChartBarData(
                      spots: sickLeaveSpots,
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
              );
            }),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 16.0),
            child: Row(
              children: [
                const Spacer(),
                _buildLegendItem(const Color(0xFF1339FF), 'Appointments'),
                const SizedBox(width: 16),
                _buildLegendItem(const Color(0xFFD6A100), 'Sick Leaves'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  double _calcMaxY(List<Map<String, dynamic>> data) {
    double max = 10;
    for (final item in data) {
      final appts = (item['appointments'] as num?)?.toDouble() ?? 0;
      final sick = (item['sickLeaves'] as num?)?.toDouble() ?? 0;
      if (appts > max) max = appts;
      if (sick > max) max = sick;
    }
    // Round up to a nice number
    return (max * 1.2).ceilToDouble();
  }

  String _shortMonth(String month) {
    // "April 2026" -> "Apr 26"
    final parts = month.split(' ');
    if (parts.length == 2) {
      final m = parts[0].length > 3 ? parts[0].substring(0, 3) : parts[0];
      final y = parts[1].length == 4 ? parts[1].substring(2) : parts[1];
      return '$m $y';
    }
    return month;
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
}
