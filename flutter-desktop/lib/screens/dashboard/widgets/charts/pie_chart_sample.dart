import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_getx_app/controllers/dashboard_controller.dart';
import 'package:flutter_getx_app/screens/dashboard/widgets/charts/pie_chart_widget.dart';
import 'package:get/get.dart';

class PieChartSample extends StatefulWidget {
  const PieChartSample({super.key});

  @override
  State<PieChartSample> createState() => _PieChartSampleState();
}

class _PieChartSampleState extends State<PieChartSample> {
  int touchedIndex = -1;

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
                'Health Issues',
                style: TextStyle(
                  fontSize: 18,
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
                initialValue: "This Week",
                onChanged: (period, {DateTime? startDate, DateTime? endDate}) {
                  controller.changeHealthPeriod(period,
                      startDate: startDate, endDate: endDate);
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Obx(() {
              if (controller.isLoadingHealthIssues.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.healthIssuesByReason.isEmpty) {
                return const Center(
                  child: Text(
                    'No health issues data',
                    style: TextStyle(
                      color: Color(0xFF858789),
                      fontSize: 14,
                    ),
                  ),
                );
              }

              return PieChart(
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
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                  sections: _buildSections(controller),
                ),
              );
            }),
          ),
          const SizedBox(height: 16),
          Obx(() => _buildLegend(controller)),
          const SizedBox(height: 16),
          Obx(() => Padding(
                padding: const EdgeInsets.only(left: 10.0),
                child: Text(
                  'Total: ${controller.healthIssuesTotal.value}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2D2E2E),
                  ),
                ),
              )),
        ],
      ),
    );
  }

  List<PieChartSectionData> _buildSections(DashboardController controller) {
    final items = controller.healthIssuesByReason;
    if (items.isEmpty) return [];

    final sections = <PieChartSectionData>[];
    for (int i = 0; i < items.length; i++) {
      final item = items[i];
      final percentage = (item['percentage'] as num?)?.toDouble() ?? 0;
      if (percentage <= 0) continue;

      final isTouched = sections.length == touchedIndex;
      final radius = isTouched ? 60.0 : 50.0;

      sections.add(PieChartSectionData(
        color: controller.getColorForReason(i),
        value: percentage,
        title: '${percentage.round()}%',
        radius: radius,
        titleStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ));
    }
    return sections;
  }

  Widget _buildLegend(DashboardController controller) {
    if (controller.healthIssuesByReason.isEmpty) {
      return const SizedBox.shrink();
    }

    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children:
          controller.healthIssuesByReason.asMap().entries.map((entry) {
        final i = entry.key;
        final item = entry.value;
        final reason = item['reason'] as String? ?? '';
        final count = item['count'] as num? ?? 0;
        return _Indicator(
          color: controller.getColorForReason(i),
          text: '$reason ($count)',
          isSquare: false,
        );
      }).toList(),
    );
  }
}

class _Indicator extends StatelessWidget {
  final Color color;
  final String text;
  final bool isSquare;
  final double size;

  const _Indicator({
    required this.color,
    required this.text,
    this.isSquare = false,
    this.size = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
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
      ],
    );
  }
}
