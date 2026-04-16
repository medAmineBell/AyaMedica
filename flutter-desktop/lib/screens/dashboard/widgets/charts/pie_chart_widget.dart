import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:get/get.dart';
import '../../../../controllers/dashboard_controller.dart';

class PieChartWidget extends StatelessWidget {
  const PieChartWidget({Key? key}) : super(key: key);

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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Appointments',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D2E2E),
                ),
              ),
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
                  controller.changePeriod(period,
                      startDate: startDate, endDate: endDate);
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Obx(() {
              if (controller.isLoadingAppointments.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.appointmentsByType.isEmpty) {
                return const Center(
                  child: Text(
                    'No appointment data',
                    style: TextStyle(
                      color: Color(0xFF858789),
                      fontSize: 14,
                    ),
                  ),
                );
              }

              return PieChart(
                PieChartData(
                  sectionsSpace: 0,
                  centerSpaceRadius: 40,
                  sections: controller.appointmentsByType.map((item) {
                    final type = item['type'] as String? ?? '';
                    final percentage =
                        (item['percentage'] as num?)?.toDouble() ?? 0;
                    return PieChartSectionData(
                      color: controller.getColorForType(type),
                      value: percentage,
                      title: '${percentage.round()}%',
                      radius: 50,
                      titleStyle: controller.getTitleStyleForType(type),
                    );
                  }).toList(),
                ),
              );
            }),
          ),
          const SizedBox(height: 24),
          Obx(() => _buildLegend(controller)),
        ],
      ),
    );
  }

  Widget _buildLegend(DashboardController controller) {
    if (controller.appointmentsByType.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(left: 32.0, right: 32.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: controller.appointmentsByType.map((item) {
          final type = item['type'] as String? ?? '';
          final count = item['count'] as num? ?? 0;
          return _LegendItem(
            color: controller.getColorForType(type),
            label: controller.getLabelForType(type),
            value: count.toString(),
          );
        }).toList(),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final String value;

  const _LegendItem({
    required this.color,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '$label ($value)',
          style: const TextStyle(
            color: Color(0xFF595A5B),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class CustomDateFilterDropdown extends StatefulWidget {
  final List<String> options;
  final String initialValue;
  final void Function(String period, {DateTime? startDate, DateTime? endDate})?
      onChanged;

  const CustomDateFilterDropdown({
    super.key,
    required this.options,
    this.initialValue = "This Week",
    this.onChanged,
  });

  @override
  State<CustomDateFilterDropdown> createState() =>
      _CustomDateFilterDropdownState();
}

class _CustomDateFilterDropdownState extends State<CustomDateFilterDropdown> {
  late String selectedValue;

  DateTime? startDate;
  DateTime? endDate;

  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    selectedValue = widget.initialValue;
  }

  void _toggleCustomPanel() {
    if (_overlayEntry == null) {
      _overlayEntry = _createOverlay();
      Overlay.of(context).insert(_overlayEntry!);
    } else {
      _overlayEntry?.remove();
      _overlayEntry = null;
    }
  }

  OverlayEntry _createOverlay() {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    Size size = renderBox.size;

    return OverlayEntry(
      builder: (context) => Positioned(
        width: size.width + 60,
        child: CompositedTransformFollower(
          link: _layerLink,
          offset: Offset(-40, size.height + 6),
          showWhenUnlinked: false,
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildDateSelector(
                    label: "Start Date",
                    date: startDate,
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setState(() => startDate = picked);
                        _overlayEntry?.markNeedsBuild();
                      }
                    },
                  ),
                  const SizedBox(height: 10),
                  _buildDateSelector(
                    label: "End Date",
                    date: endDate,
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: startDate ?? DateTime.now(),
                        firstDate: startDate ?? DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setState(() => endDate = picked);
                        _overlayEntry?.markNeedsBuild();
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: startDate != null && endDate != null
                          ? () {
                              setState(() {
                                selectedValue = "Custom Date";
                              });
                              _toggleCustomPanel();
                              widget.onChanged?.call(
                                "Custom Date",
                                startDate: startDate,
                                endDate: endDate,
                              );
                            }
                          : null,
                      child: const Text("Apply"),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _overlayEntry?.remove();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            height: 36,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedValue,
                icon: const Icon(Icons.arrow_drop_down,
                    size: 16, color: Colors.black),
                style: const TextStyle(color: Colors.black, fontSize: 14),
                dropdownColor: Colors.white,
                onChanged: (value) {
                  if (value == "Custom Date") {
                    setState(() {
                      selectedValue = value!;
                    });
                    _toggleCustomPanel();
                  } else {
                    _overlayEntry?.remove();
                    _overlayEntry = null;

                    setState(() {
                      selectedValue = value!;
                      startDate = null;
                      endDate = null;
                    });
                    widget.onChanged?.call(value!);
                  }
                },
                items: widget.options
                    .map((item) => DropdownMenuItem(
                          value: item,
                          child: Text(item),
                        ))
                    .toList(),
              ),
            ),
          ),
          if (selectedValue == "Custom Date" &&
              startDate != null &&
              endDate != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                "${startDate!.toString().split(" ")[0]} → ${endDate!.toString().split(" ")[0]}",
                style: const TextStyle(fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDateSelector({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12)),
        const SizedBox(height: 4),
        InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Text(
              date == null ? "Select date" : date.toString().split(" ")[0],
              style: const TextStyle(color: Colors.black),
            ),
          ),
        )
      ],
    );
  }
}
