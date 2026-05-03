import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/clinic_visits_controller.dart';
import 'widgets/clinic_visits_table_widget.dart';

class ClinicVisitsScreen extends StatelessWidget {
  const ClinicVisitsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ClinicVisitsController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTitleSection(controller),
          _buildTabsAndFiltersRow(controller),
          Expanded(
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                      child: _buildContent(controller),
                    ),
                  ),
                  _buildPaginationBar(controller),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(ClinicVisitsController controller) {
    return Obx(() {
                  if (controller.state.value == ClinicVisitsState.loading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (controller.state.value == ClinicVisitsState.error) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline,
                              size: 64, color: Colors.red.shade400),
                          const SizedBox(height: 16),
                          const Text(
                            'Failed to load visits',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 8),
                          TextButton.icon(
                            onPressed: controller.refreshAppointments,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Try Again'),
                          ),
                        ],
                      ),
                    );
                  }

                  if (controller.state.value == ClinicVisitsState.empty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.calendar_today_outlined,
                              size: 64, color: Colors.grey.shade400),
                          const SizedBox(height: 16),
                          const Text(
                            'No appointment records',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'There is no available appointment records, please refresh or\ncontact school appointments manager',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    );
                  }

                  return const ClinicVisitsTableWidget();
                });
  }

  Widget _buildPaginationBar(ClinicVisitsController controller) {
    return Obx(() {
      if (controller.totalPages.value <= 1 &&
          controller.allRows.isEmpty) {
        return const SizedBox.shrink();
      }

      final current = controller.currentPage.value;
      final total = controller.totalPages.value;

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: Color(0xFFE5E7EB)),
          ),
        ),
        child: Row(
          children: [
            _buildPrevNextButton(
              label: 'Previous',
              icon: Icons.arrow_back,
              iconLeading: true,
              enabled: current > 1,
              onTap: controller.previousPage,
            ),
            const Spacer(),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: _buildPageNumbers(current, total, controller),
            ),
            const Spacer(),
            _buildPrevNextButton(
              label: 'Next',
              icon: Icons.arrow_forward,
              iconLeading: false,
              enabled: current < total,
              onTap: controller.nextPage,
            ),
          ],
        ),
      );
    });
  }

  Widget _buildPrevNextButton({
    required String label,
    required IconData icon,
    required bool iconLeading,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    final color = enabled ? const Color(0xFF1F2937) : const Color(0xFF9CA3AF);
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFE5E7EB)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: iconLeading
              ? [
                  Icon(icon, size: 16, color: color),
                  const SizedBox(width: 6),
                  Text(label,
                      style: TextStyle(
                          color: color, fontSize: 13, fontWeight: FontWeight.w500)),
                ]
              : [
                  Text(label,
                      style: TextStyle(
                          color: color, fontSize: 13, fontWeight: FontWeight.w500)),
                  const SizedBox(width: 6),
                  Icon(icon, size: 16, color: color),
                ],
        ),
      ),
    );
  }

  List<Widget> _buildPageNumbers(
      int current, int total, ClinicVisitsController controller) {
    if (total <= 1) {
      return [_buildPageChip(1, isActive: true, onTap: null)];
    }

    final List<Widget> chips = [];
    const int window = 1; // neighbors to show around current

    final pages = <int>{1, total, current - window, current, current + window};
    final sorted = pages.where((p) => p >= 1 && p <= total).toList()..sort();

    int? prev;
    for (final p in sorted) {
      if (prev != null && p - prev > 1) {
        chips.add(const Padding(
          padding: EdgeInsets.symmetric(horizontal: 6),
          child: Text('...',
              style: TextStyle(color: Color(0xFF6B7280), fontSize: 14)),
        ));
      }
      chips.add(_buildPageChip(
        p,
        isActive: p == current,
        onTap: p == current ? null : () => controller.goToPage(p),
      ));
      prev = p;
    }
    return chips;
  }

  Widget _buildPageChip(int page,
      {required bool isActive, required VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          width: 32,
          height: 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFFDBEAFE) : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            '$page',
            style: TextStyle(
              color: isActive
                  ? const Color(0xFF1339FF)
                  : const Color(0xFF374151),
              fontSize: 13,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitleSection(ClinicVisitsController controller) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
      child: Row(
        children: [
          const Text(
            'Visits',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(width: 12),
          Builder(builder: (ctx) {
            return Obx(() {
              final count = controller.accessibleBranches.length;
              final selectedName = controller.selectedBranchName;
              final label =
                  count > 1 ? '$count branches' : selectedName;
              return InkWell(
                onTap: () => _showBranchMenu(ctx, controller),
                borderRadius: BorderRadius.circular(6),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        label,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1339FF),
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.arrow_drop_down,
                          color: Color(0xFF1339FF), size: 22),
                    ],
                  ),
                ),
              );
            });
          }),
        ],
      ),
    );
  }

  void _showBranchMenu(
      BuildContext context, ClinicVisitsController controller) {
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(Offset.zero, ancestor: overlay),
        button.localToGlobal(button.size.bottomRight(Offset.zero),
            ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );

    showMenu<String>(
      context: context,
      position: position,
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      items: controller.accessibleBranches.map((b) {
        final isSelected = b.id == controller.selectedBranchId.value;
        return PopupMenuItem<String>(
          value: b.id,
          child: Row(
            children: [
              if (isSelected)
                const Icon(Icons.check,
                    size: 16, color: Color(0xFF1339FF))
              else
                const SizedBox(width: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  b.name,
                  style: TextStyle(
                    fontSize: 14,
                    color: isSelected
                        ? const Color(0xFF1339FF)
                        : const Color(0xFF374151),
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    ).then((id) {
      if (id != null) controller.changeBranch(id);
    });
  }

  Widget _buildTabsAndFiltersRow(ClinicVisitsController controller) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Row(
        children: [
          const Spacer(),
          _buildSearchField(controller),
          const SizedBox(width: 12),
          _buildFiltersButton(controller),
        ],
      ),
    );
  }

  Widget _buildSearchField(ClinicVisitsController controller) {
    return Container(
      width: 200,
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: TextField(
        onChanged: controller.searchAppointments,
        decoration: const InputDecoration(
          hintText: 'search',
          hintStyle: TextStyle(
            color: Color(0xFF9CA3AF),
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: Icon(Icons.search, color: Color(0xFF9CA3AF), size: 20),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        style: const TextStyle(fontSize: 16, color: Color(0xFF111827)),
      ),
    );
  }

  Widget _buildFiltersButton(ClinicVisitsController controller) {
    return Obx(() {
      final filterCount = controller.activeFilterCount;
      return InkWell(
        onTap: () => _showFiltersDialog(controller),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.tune, color: Color(0xFF6B7280), size: 20),
              const SizedBox(width: 8),
              const Text(
                'Filters',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF6B7280),
                ),
              ),
              if (filterCount > 0) ...[
                const SizedBox(width: 6),
                Container(
                  width: 20,
                  height: 20,
                  decoration: const BoxDecoration(
                    color: Color(0xFFEF4444),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '$filterCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    });
  }

  void _showFiltersDialog(ClinicVisitsController controller) {
    Get.dialog(
      _ClinicVisitsFiltersDialog(controller: controller),
      barrierDismissible: true,
    );
  }
}

class _ClinicVisitsFiltersDialog extends StatefulWidget {
  final ClinicVisitsController controller;
  const _ClinicVisitsFiltersDialog({required this.controller});

  @override
  State<_ClinicVisitsFiltersDialog> createState() =>
      _ClinicVisitsFiltersDialogState();
}

class _ClinicVisitsFiltersDialogState
    extends State<_ClinicVisitsFiltersDialog> {
  late DateTime _startDate;
  late DateTime _endDate;

  @override
  void initState() {
    super.initState();
    _startDate = widget.controller.startDate.value;
    _endDate = widget.controller.endDate.value;
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Filter Visits',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 20),
            const Text(
              'Start date',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 8),
            _buildDateField(
                _startDate, () => _pickDate(context, isStart: true)),
            const SizedBox(height: 16),
            const Text(
              'End date',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 8),
            _buildDateField(_endDate, () => _pickDate(context, isStart: false)),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      _startDate = DateTime.now();
                      _endDate = DateTime.now();
                    });
                  },
                  child: const Text('Clear'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    Get.back();
                    widget.controller.changeDateRange(_startDate, _endDate);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1339FF),
                  ),
                  child: const Text('Apply',
                      style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateField(DateTime date, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFD1D5DB)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today,
                color: Color(0xFF1339FF), size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _formatDate(date),
                style: const TextStyle(color: Color(0xFF111827), fontSize: 14),
              ),
            ),
            const Icon(Icons.keyboard_arrow_down,
                color: Color(0xFF6B7280), size: 20),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate(BuildContext context, {required bool isStart}) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : _endDate,
      firstDate: isStart ? DateTime(2020) : _startDate,
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF1339FF),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Color(0xFF111827),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          if (_endDate.isBefore(_startDate)) _endDate = _startDate;
        } else {
          _endDate = picked;
        }
      });
    }
  }
}
