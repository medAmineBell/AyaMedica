import 'package:flutter/material.dart';
import 'package:flutter_getx_app/controllers/reports_controller.dart';
import 'package:flutter_getx_app/models/report.dart';
import 'package:flutter_getx_app/screens/appointmentScheduling/widgets/custom_dropdown.dart';
import 'package:flutter_getx_app/screens/reports/widgets/generating_report_dialog.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class GenerateReportDialog extends StatefulWidget {
  const GenerateReportDialog({Key? key}) : super(key: key);

  @override
  State<GenerateReportDialog> createState() => _GenerateReportDialogState();
}

class _GenerateReportDialogState extends State<GenerateReportDialog> {
  String _selectedTemplate = 'Vaccination';
  DateTime? _dateFrom;
  DateTime? _dateTo;
  String? _selectedVaccinationType;
  String? _selectedDoctor;
  String? _selectedGrade;
  String? _selectedClass;
  List<String> _selectedStudents = [];
  final Set<String> _selectedAdditionalData = {'Body Mass index - BMI'};

  final List<String> _vaccinationTypes = [
    'Body Mass index - BMI',
    'Type A',
    'Type B',
  ];

  final List<String> _doctors = [
    'Dr. Salem Said Al Ali',
    'Dr. Ahmad Samir',
    'Doctor name goes here',
  ];

  final List<String> _grades = ['G4', 'G5', 'G6', 'G7', 'G8'];
  final List<String> _classes = [
    'Lion Class',
    'Tiger Class',
    'Eagle Class',
    'Bear Class'
  ];
  final List<String> _additionalDataOptions = [
    'Body Mass index - BMI',
  ];

  @override
  void initState() {
    super.initState();
    _dateFrom = DateTime.now();
    _dateTo = DateTime.now();
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  Future<void> _pickDateFrom() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dateFrom ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _dateFrom = picked);
    }
  }

  Future<void> _pickDateTo() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dateTo ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _dateTo = picked);
    }
  }

  void _showStudentSelectionDialog() {
    showDialog(
      context: context,
      builder: (context) => _StudentSelectionDialog(
        selectedStudents: _selectedStudents,
        onSelectionChanged: (students) {
          setState(() => _selectedStudents = students);
        },
      ),
    );
  }

  Future<void> _generateReport() async {
    // Validate required fields
    if (_dateFrom == null || _dateTo == null) {
      Get.snackbar(
        'Error',
        'Please select date range',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // Vaccination type is only required for Vaccination template
    if (_selectedTemplate == 'Vaccination' && _selectedVaccinationType == null) {
      Get.snackbar(
        'Error',
        'Please select vaccination type',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (_selectedDoctor == null) {
      Get.snackbar(
        'Error',
        'Please select doctor name',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (_selectedGrade == null) {
      Get.snackbar(
        'Error',
        'Please select grade',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (_selectedClass == null) {
      Get.snackbar(
        'Error',
        'Please select class',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // Close the generate dialog first - ensure it closes for all templates
    Get.back();

    // Get or create reports controller
    ReportsController reportsController;
    if (Get.isRegistered<ReportsController>()) {
      reportsController = Get.find<ReportsController>();
    } else {
      reportsController = Get.put(ReportsController());
    }

    // Calculate records count (from selected students or default)
    final recordsCount =
        _selectedStudents.isEmpty ? 23 : _selectedStudents.length;

    // Clean up any existing progress controller first
    if (Get.isRegistered<GeneratingReportController>()) {
      Get.delete<GeneratingReportController>();
    }

    // Create progress controller before showing dialog
    final progressController = Get.put(GeneratingReportController());
    progressController.setDate(_dateFrom!);
    progressController.updateRecords(0);
    progressController.updateProgress(0.0);

    // Show generating dialog
    Get.dialog(
      GeneratingReportDialog(
        reportDate: _dateFrom!,
        totalRecords: recordsCount,
      ),
      barrierDismissible: false,
    );

    // Wait a bit for the dialog to build
    await Future.delayed(const Duration(milliseconds: 100));

    // Simulate progress updates - ensure this works for all templates
    const totalSteps = 10;
    try {
      for (int i = 1; i <= totalSteps; i++) {
        await Future.delayed(const Duration(milliseconds: 200));
        if (Get.isRegistered<GeneratingReportController>()) {
          final controller = Get.find<GeneratingReportController>();
          controller.updateProgress(i / totalSteps);
          controller.updateRecords((recordsCount * i / totalSteps).round());
        }
      }

      // Create the report
      // Format grades like "G4, G3" as shown in Figma
      final gradesAndClasses = _selectedGrade != null
          ? '$_selectedGrade, ${_selectedGrade}' // Show format like "G4, G3"
          : 'N/A';

      final report = Report(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        reportType: '${_selectedTemplate} report',
        gradesAndClasses: gradesAndClasses,
        records: recordsCount,
        dateTime: DateTime.now(),
        studentCount: recordsCount,
      );

      // Add report to controller
      reportsController.addReport(report);

      // Wait a moment to show 100%
      await Future.delayed(const Duration(milliseconds: 300));

      // Close the generating dialog when progress reaches 100% - ensure it closes for all templates
      if (Get.isDialogOpen == true) {
        Get.back();
      }
    } catch (e) {
      // If any error occurs, still try to close the dialog
      if (Get.isDialogOpen == true) {
        Get.back();
      }
      rethrow;
    } finally {
      // Clean up progress controller - ensure cleanup happens for all templates
      if (Get.isRegistered<GeneratingReportController>()) {
        Get.delete<GeneratingReportController>();
      }
    }

    Get.snackbar(
      'Success',
      'Report generated successfully',
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 800,
        constraints:
            BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.9),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Generate a new reports',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Select from reports templates or create your custom ones.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => Get.back(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Select from available templates
                    _buildSectionTitle('Select from available templates'),
                    const SizedBox(height: 8),
                    _buildTemplateCards(),
                    const SizedBox(height: 24),

                    // Date range & details
                    _buildSectionTitle('Date range & details'),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _buildDateField(
                              'Date from', _dateFrom, _pickDateFrom),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child:
                              _buildDateField('Date To', _dateTo, _pickDateTo),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              RichText(
                                text: const TextSpan(
                                  text: 'Vaccination type',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF374151),
                                  ),
                                  children: [
                                    TextSpan(
                                      text: '*',
                                      style:
                                          TextStyle(color: Color(0xFFDC2626)),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                              CustomDropdown<String>(
                                hint: 'Vaccination type',
                                value: _selectedVaccinationType,
                                items: DropdownHelper.createStringItems(
                                    _vaccinationTypes),
                                onChanged: (val) => setState(
                                    () => _selectedVaccinationType = val),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              RichText(
                                text: const TextSpan(
                                  text: 'Doctor name',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF374151),
                                  ),
                                  children: [
                                    TextSpan(
                                      text: '*',
                                      style:
                                          TextStyle(color: Color(0xFFDC2626)),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                              CustomDropdown<String>(
                                hint: 'Disease type',
                                value: _selectedDoctor,
                                items:
                                    DropdownHelper.createStringItems(_doctors),
                                onChanged: (val) =>
                                    setState(() => _selectedDoctor = val),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Grades, classes and students
                    _buildSectionTitle('Grades, classes and students'),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              RichText(
                                text: const TextSpan(
                                  text: 'Grade',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF374151),
                                  ),
                                  children: [
                                    TextSpan(
                                      text: '*',
                                      style:
                                          TextStyle(color: Color(0xFFDC2626)),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                              CustomDropdown<String>(
                                hint: 'Grade',
                                value: _selectedGrade,
                                items:
                                    DropdownHelper.createStringItems(_grades),
                                onChanged: (val) =>
                                    setState(() => _selectedGrade = val),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              RichText(
                                text: const TextSpan(
                                  text: 'Class',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF374151),
                                  ),
                                  children: [
                                    TextSpan(
                                      text: '*',
                                      style:
                                          TextStyle(color: Color(0xFFDC2626)),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                              CustomDropdown<String>(
                                hint: 'Class name',
                                value: _selectedClass,
                                items:
                                    DropdownHelper.createStringItems(_classes),
                                onChanged: (val) =>
                                    setState(() => _selectedClass = val),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: const TextSpan(
                              text: 'Students (Multi selection)',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF374151),
                              ),
                              children: [
                                TextSpan(
                                  text: '*',
                                  style: TextStyle(color: Color(0xFFDC2626)),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildStudentMultiSelectField(),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Additional data
                    _buildSectionTitle('Additional data'),
                    const SizedBox(height: 8),
                    ..._additionalDataOptions
                        .map((option) => _buildCheckbox(option)),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Get.back(),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: const BorderSide(color: Color(0xFFD1D5DB)),
                      ),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF374151),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _generateReport,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0066FF),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Generate report',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: Color(0xFF374151),
      ),
    );
  }

  Widget _buildTemplateCards() {
    final templates = [
      {
        'label': 'Vaccination',
        'icon': Icons.vaccines,
        'description': 'Description here'
      },
      {
        'label': 'Chronic diseases',
        'icon': Icons.settings,
        'description': 'Description here'
      },
      {'label': 'Hygiene', 'icon': Icons.person, 'description': 'Description'},
      {
        'label': 'General report',
        'icon': Icons.add,
        'description': 'Description'
      },
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: templates.map((template) {
        final isSelected = _selectedTemplate == template['label'];
        return _buildTemplateCard(
          template['label'] as String,
          template['icon'] as IconData,
          template['description'] as String,
          isSelected,
        );
      }).toList(),
    );
  }

  Widget _buildTemplateCard(
      String label, IconData icon, String description, bool isSelected) {
    return InkWell(
      onTap: () => setState(() => _selectedTemplate = label),
      child: Container(
        width: 163,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0066FF) : const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
                isSelected ? const Color(0xFF0066FF) : const Color(0xFFE5E7EB),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFFCDFF1F)
                    : const Color(0xFFDCE0E4),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected
                    ? const Color(0xFF0066FF)
                    : const Color(0xFF747677),
                size: 18,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : const Color(0xFF2D2E2E),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? Colors.white70 : const Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateField(String label, DateTime? date, VoidCallback onTap) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF374151),
            ),
            children: const [
              TextSpan(
                text: '*',
                style: TextStyle(color: Color(0xFFDC2626)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFFBFCFD),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE9E9E9)),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today,
                    size: 20, color: Color(0xFF9CA3AF)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    date != null ? _formatDate(date) : 'Select date',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF374151),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStudentMultiSelectField() {
    final displayText = _selectedStudents.isEmpty
        ? 'All students'
        : _selectedStudents.length == 1
            ? _selectedStudents.first
            : '${_selectedStudents.length} students';

    final displayValue = _selectedStudents.isEmpty ? null : displayText;

    return GestureDetector(
      onTap: _showStudentSelectionDialog,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: const Color(0xFFFBFCFD),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFE9E9E9),
            width: 0,
          ),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: displayValue,
            hint: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'All students',
                style: TextStyle(
                  color: const Color(0xFF9CA3AF),
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            items: [],
            onChanged: (_) => _showStudentSelectionDialog(),
            isExpanded: true,
            icon: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Icon(
                Icons.arrow_drop_down,
                color: const Color(0xFF0066FF),
                size: 24,
              ),
            ),
            selectedItemBuilder: (BuildContext context) {
              return [
                Container(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    displayText,
                    style: TextStyle(
                      color: const Color(0xFF374151),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ];
            },
            dropdownColor: Colors.white,
            elevation: 8,
            borderRadius: BorderRadius.circular(12),
            menuMaxHeight: 300,
          ),
        ),
      ),
    );
  }

  Widget _buildCheckbox(String label) {
    final isChecked = _selectedAdditionalData.contains(label);
    return CheckboxListTile(
      title: Text(label),
      value: isChecked,
      onChanged: (value) {
        setState(() {
          if (value == true) {
            _selectedAdditionalData.add(label);
          } else {
            _selectedAdditionalData.remove(label);
          }
        });
      },
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: EdgeInsets.zero,
    );
  }
}

class _StudentSelectionDialog extends StatefulWidget {
  final List<String> selectedStudents;
  final Function(List<String>) onSelectionChanged;

  const _StudentSelectionDialog({
    required this.selectedStudents,
    required this.onSelectionChanged,
  });

  @override
  State<_StudentSelectionDialog> createState() =>
      _StudentSelectionDialogState();
}

class _StudentSelectionDialogState extends State<_StudentSelectionDialog> {
  late List<String> _selectedStudents;
  final TextEditingController _searchController = TextEditingController();
  final List<String> _allStudents =
      List.generate(23, (index) => 'Student ${index + 1}');
  List<String> _filteredStudents = [];

  @override
  void initState() {
    super.initState();
    _selectedStudents = List<String>.from(widget.selectedStudents);
    _filteredStudents = _allStudents;
    _searchController.addListener(_filterStudents);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterStudents() {
    setState(() {
      if (_searchController.text.isEmpty) {
        _filteredStudents = _allStudents;
      } else {
        _filteredStudents = _allStudents
            .where((student) => student
                .toLowerCase()
                .contains(_searchController.text.toLowerCase()))
            .toList();
      }
    });
  }

  void _toggleStudent(String student) {
    setState(() {
      if (_selectedStudents.contains(student)) {
        _selectedStudents.remove(student);
      } else {
        _selectedStudents.add(student);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: 500,
        height: 600,
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Select Students',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search students...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: const Color(0xFFF9FAFB),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _filteredStudents.length,
                itemBuilder: (context, index) {
                  final student = _filteredStudents[index];
                  final isSelected = _selectedStudents.contains(student);
                  return ListTile(
                    title: Text(student),
                    trailing: Checkbox(
                      value: isSelected,
                      onChanged: (_) => _toggleStudent(student),
                      activeColor: const Color(0xFF0066FF),
                    ),
                    onTap: () => _toggleStudent(student),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      widget.onSelectionChanged(_selectedStudents);
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0066FF),
                    ),
                    child: const Text('Done'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
