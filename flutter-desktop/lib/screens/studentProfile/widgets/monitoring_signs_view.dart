import 'package:flutter/material.dart';
import 'package:flutter_getx_app/models/student.dart';
import 'package:flutter_getx_app/theme/app_theme.dart';
import 'package:get/get.dart';

class MonitoringSignsView extends StatefulWidget {
  final Student student;

  const MonitoringSignsView({
    Key? key,
    required this.student,
  }) : super(key: key);

  @override
  State<MonitoringSignsView> createState() => _MonitoringSignsViewState();
}

class _MonitoringSignsViewState extends State<MonitoringSignsView> {
  String selectedDisease = 'Type 1 Diabetes';
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.colorPalette['neutral']!['30']!),
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
          // Header with filters
          _buildHeader(),
          // Table content
          _buildTableContent(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.colorPalette['neutral']!['10']!,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Column(
        children: [
          // Print button row
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton.icon(
                onPressed: () => _printMonitoringData(),
                icon: Icon(
                  Icons.print,
                  size: 20,
                  color: Colors.white,
                ),
                label: Text(
                  'Print Report',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.colorPalette['info']!['main']!,
                  elevation: 0,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Filters row
          Row(
            children: [
              // Disease dropdown
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: AppTheme.colorPalette['neutral']!['30']!),
                ),
                child: DropdownButton<String>(
                  value: selectedDisease,
                  underline: Container(),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  items: const [
                    DropdownMenuItem(
                        value: 'Type 1 Diabetes',
                        child: Text('Type 1 Diabetes')),
                    DropdownMenuItem(value: 'Asthma', child: Text('Asthma')),
                    DropdownMenuItem(
                        value: 'Hypertension', child: Text('Hypertension')),
                    DropdownMenuItem(
                        value: 'Epilepsy', child: Text('Epilepsy')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        selectedDisease = value;
                      });
                    }
                  },
                ),
              ),
              const SizedBox(width: 16),
              // Search bar
              Expanded(
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: AppTheme.colorPalette['neutral']!['30']!),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 12),
                      Icon(
                        Icons.search,
                        size: 20,
                        color: AppTheme.colorPalette['neutral']!['60']!,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'search',
                            hintStyle: TextStyle(
                              color: AppTheme.colorPalette['neutral']!['60']!,
                              fontSize: 14,
                            ),
                            border: InputBorder.none,
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 8),
                          ),
                          onChanged: (value) {
                            setState(() {
                              searchQuery = value;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Filters button
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: AppTheme.colorPalette['neutral']!['30']!),
                ),
                child: Stack(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => _showFiltersDialog(),
                      icon: Icon(
                        Icons.filter_list,
                        size: 20,
                        color: AppTheme.colorPalette['neutral']!['80']!,
                      ),
                      label: Text(
                        'Filters',
                        style: TextStyle(
                          color: AppTheme.colorPalette['neutral']!['80']!,
                          fontSize: 14,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    // Badge
                    Positioned(
                      top: 4,
                      right: 4,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Center(
                          child: Text(
                            '1',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTableContent() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: constraints.maxWidth,
            ),
            child: DataTable(
              columnSpacing: 32,
              headingRowColor: MaterialStateProperty.all(
                AppTheme.colorPalette['neutral']!['10']!,
              ),
              headingTextStyle: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: AppTheme.colorPalette['neutral']!['90']!,
              ),
              dataTextStyle: TextStyle(
                fontSize: 14,
                color: AppTheme.colorPalette['neutral']!['80']!,
              ),
              columns: const [
                DataColumn(
                  label: Text('Date & time'),
                ),
                DataColumn(
                  label: Text('Blood Glucose'),
                ),
                DataColumn(
                  label: Text('Blood Pressure'),
                ),
                DataColumn(
                  label: Text('Weight'),
                ),
                DataColumn(
                  label: Text('Medication'),
                ),
              ],
              rows: _buildTableRows(),
            ),
          ),
        );
      },
    );
  }

  List<DataRow> _buildTableRows() {
    // Sample monitoring data
    final monitoringData = [
      {
        'date': '27/01/2025 08:38 AM',
        'bloodGlucose': '120 mg/dL',
        'bloodPressure': '120/80 mmHg',
        'weight': '45.2 kg',
        'medication': 'Insulin Regular',
      },
      {
        'date': '28/01/2025 08:38 AM',
        'bloodGlucose': '115 mg/dL',
        'bloodPressure': '118/78 mmHg',
        'weight': '45.1 kg',
        'medication': 'Insulin Regular',
      },
      {
        'date': '29/01/2025 08:38 AM',
        'bloodGlucose': '125 mg/dL',
        'bloodPressure': '122/82 mmHg',
        'weight': '45.3 kg',
        'medication': 'Insulin Regular',
      },
      {
        'date': '30/01/2025 08:38 AM',
        'bloodGlucose': '118 mg/dL',
        'bloodPressure': '119/79 mmHg',
        'weight': '45.0 kg',
        'medication': 'Insulin Regular',
      },
    ];

    return monitoringData.map((data) {
      return DataRow(
        cells: [
          // Date & time
          DataCell(
            Text(
              data['date']!,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          // Blood Glucose
          DataCell(
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _getBloodGlucoseColor(data['bloodGlucose']!)
                    .withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: _getBloodGlucoseColor(data['bloodGlucose']!)),
              ),
              child: Text(
                data['bloodGlucose']!,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: _getBloodGlucoseColor(data['bloodGlucose']!),
                ),
              ),
            ),
          ),
          // Blood Pressure
          DataCell(
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _getBloodPressureColor(data['bloodPressure']!)
                    .withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: _getBloodPressureColor(data['bloodPressure']!)),
              ),
              child: Text(
                data['bloodPressure']!,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: _getBloodPressureColor(data['bloodPressure']!),
                ),
              ),
            ),
          ),
          // Weight
          DataCell(
            Text(
              data['weight']!,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          // Medication
          DataCell(
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.colorPalette['info']!['main']!.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border:
                    Border.all(color: AppTheme.colorPalette['info']!['main']!),
              ),
              child: Text(
                data['medication']!,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: AppTheme.colorPalette['info']!['main']!,
                ),
              ),
            ),
          ),
        ],
      );
    }).toList();
  }

  Color _getBloodGlucoseColor(String value) {
    final glucose = int.tryParse(value.split(' ')[0]) ?? 0;
    if (glucose < 70) return Colors.red; // Low
    if (glucose > 180) return Colors.orange; // High
    return Colors.green; // Normal
  }

  Color _getBloodPressureColor(String value) {
    final parts = value.split('/');
    if (parts.length != 2) return Colors.grey;

    final systolic = int.tryParse(parts[0]) ?? 0;
    final diastolic = int.tryParse(parts[1].split(' ')[0]) ?? 0;

    if (systolic > 140 || diastolic > 90) return Colors.orange; // High
    if (systolic < 90 || diastolic < 60) return Colors.red; // Low
    return Colors.green; // Normal
  }

  void _showFiltersDialog() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.filter_list,
                    size: 24,
                    color: AppTheme.colorPalette['primary']!['main']!,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Monitoring Filters',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.colorPalette['neutral']!['90']!,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildFilterOption('Date Range', 'Last 7 days'),
              _buildFilterOption('Blood Glucose', 'All values'),
              _buildFilterOption('Blood Pressure', 'All values'),
              _buildFilterOption('Medication', 'All medications'),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () => Get.back(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          AppTheme.colorPalette['primary']!['main']!,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Apply'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterOption(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.colorPalette['neutral']!['90']!,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.colorPalette['neutral']!['60']!,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: AppTheme.colorPalette['neutral']!['60']!,
          ),
        ],
      ),
    );
  }

  void _printMonitoringData() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.print,
                    size: 24,
                    color: AppTheme.colorPalette['info']!['main']!,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Print Monitoring Report',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.colorPalette['neutral']!['90']!,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'Student: ${widget.student.name}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.colorPalette['neutral']!['80']!,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Disease: $selectedDisease',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.colorPalette['neutral']!['80']!,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Date Range: Last 7 days',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.colorPalette['neutral']!['80']!,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () {
                      Get.back();
                      Get.snackbar(
                        'Print Report',
                        'Monitoring report is being prepared for printing...',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor:
                            AppTheme.colorPalette['success']!['main']!,
                        colorText: Colors.white,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.colorPalette['info']!['main']!,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Print'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
