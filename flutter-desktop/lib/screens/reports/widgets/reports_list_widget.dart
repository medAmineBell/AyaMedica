import 'package:flutter/material.dart';
import 'package:flutter_getx_app/controllers/reports_controller.dart';
import 'package:flutter_getx_app/models/report.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

class ReportsListWidget extends GetView<ReportsController> {
  const ReportsListWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search and Filters
        _buildSearchAndFilters(),
        
        // Table
        Expanded(
          child: Obx(() {
            final filteredReports = controller.filteredReports;
            
            if (filteredReports.isEmpty) {
              return Center(
                child: Text(
                  'No reports found',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              );
            }

            return Container(
              margin: const EdgeInsets.all(16),
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
                  // Table Header
                  _buildTableHeader(),
                  // Table Rows
                  Expanded(
                    child: ListView.builder(
                      itemCount: filteredReports.length,
                      itemBuilder: (context, index) {
                        return _buildReportRow(context, filteredReports[index]);
                      },
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      padding: const EdgeInsets.all(24),
      color: Colors.white,
      child: Row(
        children: [
          const Spacer(),
          // Search bar
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFFBFCFD),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: TextField(
                onChanged: controller.setSearchQuery,
                decoration: InputDecoration(
                  hintText: 'search',
                  hintStyle: TextStyle(color: Colors.grey[500]),
                  prefixIcon: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: SvgPicture.asset(
                      'assets/svg/search-normal.svg',
                      width: 20,
                      height: 20,
                      color: const Color(0xFF7A7A7A),
                    ),
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Filter Button
          Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: InkWell(
              onTap: () {
                // TODO: Show filter dialog
              },
              borderRadius: BorderRadius.circular(12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgPicture.asset(
                    'assets/svg/filter-2.svg',
                    width: 18,
                    height: 18,
                    color: const Color(0xFF7A7A7A),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Filters',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  Obx(() {
                    final filterCount = controller.activeFilterCount.value;
                    if (filterCount == 0) return const SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFC2E53),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          filterCount.toString(),
                          style: const TextStyle(
                            color: Color(0xFFF9F9F9),
                            fontSize: 12,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w700,
                            height: 1.58,
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      child: Row(
        children: [
          Expanded(flex: 2, child: _buildHeaderCell('Report details')),
          Expanded(flex: 1, child: _buildHeaderCell('Report type', showInfo: true)),
          Expanded(flex: 1, child: _buildHeaderCell('Grades and classes', showInfo: true)),
          Expanded(flex: 1, child: _buildHeaderCell('Records')),
          Expanded(flex: 1, child: _buildHeaderCell('Date & time', showInfo: true)),
          Expanded(flex: 1, child: _buildHeaderCell('Actions')),
        ],
      ),
    );
  }

  Widget _buildHeaderCell(String text, {bool showInfo = false}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF374151),
              ),
            ),
            if (showInfo) ...[
              const SizedBox(width: 4),
              Icon(Icons.help_outline, size: 16, color: Colors.grey[600]),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildReportRow(BuildContext context, Report report) {
    final isFirstRow = controller.reports.indexOf(report) == 0;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: isFirstRow ? const Color(0xFFF0FDF4) : Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: _buildReportDetailsCell(report),
            ),
          ),
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Center(
                child: Text(
                  report.reportType,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF374151),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Center(
                child: Text(
                  report.gradesAndClasses,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF374151),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Center(
                child: Text(
                  report.records.toString(),
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF374151),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Center(
                child: Text(
                  controller.formatDateTime(report.dateTime),
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF374151),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Center(
                child: _buildActionsCell(context, report),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportDetailsCell(Report report) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFF0066FF),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.description,
            color: Colors.white,
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Report',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${report.studentCount} students',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionsCell(BuildContext context, Report report) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.delete_outline, size: 20, color: Color(0xFF6B7280)),
          onPressed: () {
            controller.deleteReport(report.id);
          },
        ),
        IconButton(
          icon: const Icon(Icons.visibility_outlined, size: 20, color: Color(0xFF6B7280)),
          onPressed: () {
            // TODO: View report
            print('View report: ${report.id}');
          },
        ),
        _buildDownloadButton(context, report),
      ],
    );
  }

  Widget _buildDownloadButton(BuildContext context, Report report) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.download_outlined, size: 20, color: Color(0xFF6B7280)),
      onSelected: (value) {
        // TODO: Download report in selected format
        print('Download report ${report.id} as $value');
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'PDF',
          child: Text('PDF'),
        ),
        const PopupMenuItem(
          value: 'Excel',
          child: Text('Excel'),
        ),
        const PopupMenuItem(
          value: 'CSV',
          child: Text('CSV'),
        ),
      ],
    );
  }
}

