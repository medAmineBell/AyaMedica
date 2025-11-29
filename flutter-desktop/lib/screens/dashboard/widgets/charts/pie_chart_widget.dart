import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class PieChartWidget extends StatelessWidget {
  const PieChartWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      // margin: const EdgeInsets.only(right: 8),
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Appointments',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D2E2E),
                ),
              ),
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
                sectionsSpace: 0,
                centerSpaceRadius: 40,
                sections: [
                  PieChartSectionData(
                    color: const Color(0xFF1339FF),
                    value: 40,
                    title: '40%',
                    radius: 50,
                    titleStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  PieChartSectionData(
                    color: const Color(0xFFCDFF1F),
                    value: 30,
                    title: '30%',
                    radius: 50,
                    titleStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D2E2E),
                    ),
                  ),
                  PieChartSectionData(
                    color: const Color(0xFFEDF1F5),
                    value: 30,
                    title: '30%',
                    radius: 50,
                    titleStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D2E2E),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          _buildLegend(),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return const Padding(
      padding: EdgeInsets.only(left: 32.0, right: 32.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _LegendItem(
            color: Color(0xFF1339FF),
            label: 'Boys',
            value: '245',
          ),
          SizedBox(width: 16),
          _LegendItem(
            color: Color(0xFFCDFF1F),
            label: 'Girls',
            value: '184',
          ),
          SizedBox(width: 16),
          _LegendItem(
            color: Color(0xFFEDF1F5),
            label: 'Staff',
            value: '184',
          ),
        ],
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

  const CustomDateFilterDropdown({
    super.key,
    required this.options,
    this.initialValue = "This Week",
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
                border: Border.all(color: Color(0xFFE5E7EB)),
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
                              _toggleCustomPanel(); // close
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
          // MAIN DROPDOWN
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

          // RANGE BELOW (only for Custom Date)
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
