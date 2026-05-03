import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_getx_app/controllers/dashboard_controller.dart';
import 'package:flutter_getx_app/screens/dashboard/widgets/charts/pie_chart_widget.dart';
import 'package:get/get.dart';

class BarChartWidget extends StatelessWidget {
  const BarChartWidget({Key? key}) : super(key: key);

  static const List<Color> _palette = [
    Color(0xFF1339FF),
    Color(0xFFD6A100),
    Color(0xFF1397FF),
    Color(0xFF01C448),
    Color(0xFFFF6B6B),
  ];

  Color _colorFor(int index) => _palette[index % _palette.length];

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
          Row(
            children: [
              const Text(
                'Complaints',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D2E2E),
                ),
              ),
              const Spacer(),
              CustomDateFilterDropdown(
                options: const [
                  "This Week",
                  "Last Week",
                  "This Month",
                  "Last Month",
                  "This Year",
                  "Last Year",
                  "Custom Date",
                ],
                initialValue: controller.selectedComplaintsPeriod.value,
                onChanged: (period, {DateTime? startDate, DateTime? endDate}) {
                  controller.changeComplaintsPeriod(period,
                      startDate: startDate, endDate: endDate);
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Obx(() {
              if (controller.isLoadingComplaints.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.topComplaints.isEmpty) {
                return const Center(
                  child: Text(
                    'No complaints data',
                    style: TextStyle(
                      color: Color(0xFF858789),
                      fontSize: 14,
                    ),
                  ),
                );
              }

              final complaints = controller.topComplaints;
              final maxCount = complaints
                  .map((c) => (c['count'] as num?)?.toDouble() ?? 0)
                  .fold<double>(0, (a, b) => a > b ? a : b);
              final maxY = (maxCount * 1.2)
                  .ceilToDouble()
                  .clamp(5.0, double.infinity)
                  .toDouble();
              final interval = (maxY / 5)
                  .ceilToDouble()
                  .clamp(1.0, double.infinity)
                  .toDouble();

              return BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  minY: 0,
                  maxY: maxY,
                  barTouchData: BarTouchData(
                    enabled: true,
                    handleBuiltInTouches: false,
                    touchTooltipData: BarTouchTooltipData(
                      tooltipBgColor: Colors.transparent,
                      tooltipPadding: EdgeInsets.zero,
                      tooltipMargin: 4,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        return BarTooltipItem(
                          rod.toY.toInt().toString(),
                          const TextStyle(
                            color: Color(0xFF2D2E2E),
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: interval,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Text(
                              value.toInt().toString(),
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
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index < 0 || index >= complaints.length) {
                            return const SizedBox();
                          }
                          final name =
                              complaints[index]['name']?.toString() ?? '';
                          final shortName = name.length > 10
                              ? '${name.substring(0, 10)}…'
                              : name;
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              shortName,
                              style: const TextStyle(
                                fontSize: 12,
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
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: interval,
                    getDrawingHorizontalLine: (value) {
                      return const FlLine(
                        color: Color(0xFFE5E5E5),
                        strokeWidth: 1,
                      );
                    },
                  ),
                  barGroups: List.generate(complaints.length, (i) {
                    final count =
                        (complaints[i]['count'] as num?)?.toDouble() ?? 0;
                    return BarChartGroupData(
                      x: i,
                      showingTooltipIndicators: [0],
                      barRods: [
                        BarChartRodData(
                          toY: count,
                          width: 20,
                          color: _colorFor(i),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(4),
                            topRight: Radius.circular(4),
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              );
            }),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 16.0),
            child: Obx(() {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Total: ${controller.complaintsTotal.value}",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF2D2E2E),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Wrap(
                      alignment: WrapAlignment.end,
                      spacing: 12,
                      runSpacing: 8,
                      children: List.generate(
                        controller.topComplaints.length,
                        (i) => _buildLegendItem(
                          _colorFor(i),
                          controller.topComplaints[i]['name']?.toString() ?? '',
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
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
