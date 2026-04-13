import 'package:flutter/material.dart';
import 'package:flutter_getx_app/controllers/reports_controller.dart';
import 'package:flutter_getx_app/controllers/resources_controller.dart';
import 'package:flutter_getx_app/models/report.dart';
import 'package:flutter_getx_app/screens/reports/widgets/generating_report_dialog.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:flutter_getx_app/utils/app_snackbar.dart';

class GenerateReportDialog extends StatefulWidget {
  const GenerateReportDialog({Key? key}) : super(key: key);

  @override
  State<GenerateReportDialog> createState() => _GenerateReportDialogState();
}

class _GenerateReportDialogState extends State<GenerateReportDialog> {
  final ReportsController reportsController = Get.find<ReportsController>();
  late final ResourcesController resourcesController;

  ReportTemplate? _selectedTemplate;
  String _reportTitle = '';
  DateTime? _dateFrom;
  DateTime? _dateTo;
  String? _selectedVaccinationType;
  String? _selectedDoctor;
  String? _selectedGrade;
  String? _selectedClassId;
  List<String> _selectedStudentIds = [];

  // Additional data options
  bool _includeBMI = false;
  bool _includeHygiene = false;
  bool _includeVaccinations = false;
  bool _includeChronicDiseases = false;

  final List<String> _vaccinationTypes = [
    'Body Mass index - BMI',
    'COVID-19',
    'Influenza',
    'Hepatitis B',
    'MMR',
  ];

  final List<String> _doctors = [
    'Disease type',
    'Dr. Salem Said Al Ali',
    'Dr. Ahmad Samir',
    'Dr. Mohammed Hassan',
  ];

  // Default grades list
  final List<String> _grades = [
    'G1',
    'G2',
    'G3',
    'G4',
    'G5',
    'G6',
  ];

  @override
  void initState() {
    super.initState();

    // Get ResourcesController (registered globally in AppBinding)
    resourcesController = Get.find<ResourcesController>();

    _dateFrom = DateTime(2025, 5, 21);
    _dateTo = DateTime(2025, 5, 21);

    // Set default template if available
    if (reportsController.templates.isNotEmpty) {
      _selectedTemplate = reportsController.templates.first;
    }

    // Load classes on init
    resourcesController.loadClasses();
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

  // Get classes filtered by grade
  List<Map<String, dynamic>> _getClassesByGrade(String? grade) {
    if (grade == null || grade.isEmpty) {
      return resourcesController.classes.cast<Map<String, dynamic>>();
    }
    return resourcesController.classes
        .where((classItem) => classItem['grade'] == grade)
        .cast<Map<String, dynamic>>()
        .toList();
  }

  // Load students when class is selected
  Future<void> _onClassSelected(String classId) async {
    setState(() {
      _selectedClassId = classId;
      _selectedStudentIds.clear();
    });

    // Load class details with students
    await resourcesController.loadClassDetails(classId);
  }

  void _showStudentSelectionDialog() {
    if (_selectedClassId == null) {
      appSnackbar(
        'Info',
        'Please select a class first',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    final classDetails = resourcesController.selectedClassDetails.value;
    final students = classDetails?['students'] as List? ?? [];

    if (students.isEmpty) {
      appSnackbar(
        'Info',
        'No students found in this class',
      );
      return;
    }

    final selectedIds = List<String>.from(_selectedStudentIds);

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: 600,
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: StatefulBuilder(
                  builder: (context, setDialogState) {
                    return ListView(
                      children: [
                        CheckboxListTile(
                          title: const Text(
                            'Select All',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          value: selectedIds.length == students.length,
                          onChanged: (bool? value) {
                            setDialogState(() {
                              if (value == true) {
                                selectedIds.clear();
                                selectedIds.addAll(
                                  students.map((s) => s['id'].toString()),
                                );
                              } else {
                                selectedIds.clear();
                              }
                            });
                          },
                          activeColor: const Color(0xFF0066FF),
                        ),
                        const Divider(),
                        ...students.map((student) {
                          final studentId = student['id'].toString();
                          final studentName = student['name'] is Map
                              ? '${student['name']['given'] ?? ''} ${student['name']['family'] ?? ''}'
                                  .trim()
                              : student['name']?.toString() ?? 'Unknown';

                          return CheckboxListTile(
                            title: Text(studentName),
                            subtitle: Text(
                              'Student ID: ${student['studentId'] ?? 'N/A'}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                            value: selectedIds.contains(studentId),
                            onChanged: (bool? value) {
                              setDialogState(() {
                                if (value == true) {
                                  selectedIds.add(studentId);
                                } else {
                                  selectedIds.remove(studentId);
                                }
                              });
                            },
                            activeColor: const Color(0xFF0066FF),
                          );
                        }).toList(),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _selectedStudentIds = selectedIds;
                        });
                        Get.back();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0066FF),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Confirm'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _generateReport() async {
    // Validate required fields
    if (_selectedTemplate == null) {
      appSnackbar(
        'Error',
        'Please select a report template',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (_dateFrom == null || _dateTo == null) {
      appSnackbar(
        'Error',
        'Please select date range',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // Build report data
    final Map<String, dynamic> reportData = {
      'templateId': _selectedTemplate!.id,
      'reportTitle': _reportTitle.isNotEmpty
          ? _reportTitle
          : '${_selectedTemplate!.name} - ${DateFormat('MMM yyyy').format(DateTime.now())}',
      'dateFrom': DateFormat('yyyy-MM-dd').format(_dateFrom!),
      'dateTo': DateFormat('yyyy-MM-dd').format(_dateTo!),
    };

    // Add optional fields
    if (_selectedVaccinationType != null &&
        _selectedVaccinationType != 'Body Mass index - BMI') {
      reportData['vaccinationType'] = _selectedVaccinationType;
    }
    if (_selectedDoctor != null && _selectedDoctor != 'Disease type') {
      reportData['doctorId'] = _selectedDoctor;
    }
    if (_selectedGrade != null) {
      reportData['grade'] = _selectedGrade;
    }
    if (_selectedClassId != null) {
      reportData['classIds'] = [_selectedClassId];
    }
    if (_selectedStudentIds.isNotEmpty) {
      reportData['studentIds'] = _selectedStudentIds;
    }

    // Add additional data flags
    reportData['includeBMI'] = _includeBMI;
    reportData['includeHygiene'] = _includeHygiene;
    reportData['includeVaccinations'] = _includeVaccinations;
    reportData['includeChronicDiseases'] = _includeChronicDiseases;

    print('📤 Report Data: $reportData');

    // Close dialog
    Get.back();

    // Show generating dialog
    Get.dialog(
      GeneratingReportDialog(
        reportDate: _dateFrom!,
        totalRecords:
            _selectedStudentIds.isEmpty ? 50 : _selectedStudentIds.length,
      ),
      barrierDismissible: false,
    );

    // Simulate progress
    for (int i = 1; i <= 10; i++) {
      await Future.delayed(const Duration(milliseconds: 200));
      if (Get.isRegistered<GeneratingReportController>()) {
        final controller = Get.find<GeneratingReportController>();
        controller.updateProgress(i / 10);
        controller.updateRecords((50 * i / 10).round());
      }
    }

    // Create report via API
    await reportsController.createReport(reportData);

    // Close generating dialog
    if (Get.isDialogOpen == true) {
      Get.back();
    }

    // Clean up
    if (Get.isRegistered<GeneratingReportController>()) {
      Get.delete<GeneratingReportController>();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 800,
        constraints:
            BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.9),
        padding: const EdgeInsets.all(32),
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
                      'Select from reports templates or create your custom ones',
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
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Select from available templates
                    _buildSectionTitle('Select from available templates'),
                    const SizedBox(height: 12),
                    _buildTemplateDropdown(),
                    const SizedBox(height: 24),

                    // Date range & details
                    _buildSectionTitle('Date range & details'),
                    const SizedBox(height: 12),
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

                    // Vaccination type and Doctor name
                    Row(
                      children: [
                        Expanded(
                          child: _buildDropdownField(
                            'Vaccination type',
                            _selectedVaccinationType ?? _vaccinationTypes.first,
                            _vaccinationTypes,
                            (val) =>
                                setState(() => _selectedVaccinationType = val),
                            isRequired: true,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildDropdownField(
                            'Doctor name',
                            _selectedDoctor ?? _doctors.first,
                            _doctors,
                            (val) => setState(() => _selectedDoctor = val),
                            isRequired: true,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Grades, classes and students
                    _buildSectionTitle('Grades, classes and students'),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: _buildGradeDropdown()),
                        const SizedBox(width: 16),
                        Expanded(child: _buildClassDropdown()),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Students (Multi selection)
                    _buildStudentMultiSelectField(),
                    const SizedBox(height: 24),

                    // Additional data
                    _buildSectionTitle('Additional data'),
                    const SizedBox(height: 8),
                    _buildCheckbox('Include Body Mass index - BMI', _includeBMI,
                        (val) {
                      setState(() => _includeBMI = val ?? false);
                    }),
                    _buildCheckbox('Include Hygiene', _includeHygiene, (val) {
                      setState(() => _includeHygiene = val ?? false);
                    }),
                    _buildCheckbox('Include Vaccinations', _includeVaccinations,
                        (val) {
                      setState(() => _includeVaccinations = val ?? false);
                    }),
                    _buildCheckbox(
                        'Include Chronic Diseases', _includeChronicDiseases,
                        (val) {
                      setState(() => _includeChronicDiseases = val ?? false);
                    }),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Get.back(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      side: const BorderSide(color: Color(0xFFD1D5DB)),
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

  Widget _buildTemplateDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: const TextSpan(
            text: 'Available templates',
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
        Obx(() {
          if (reportsController.templates.isEmpty) {
            return Container(
              height: 52,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFFBFCFD),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE9E9E9)),
              ),
              child: const Center(
                child: Text(
                  'Loading templates...',
                  style: TextStyle(color: Color(0xFF9CA3AF)),
                ),
              ),
            );
          }

          return Container(
            height: 52,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFFBFCFD),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE9E9E9)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<ReportTemplate>(
                value: _selectedTemplate,
                isExpanded: true,
                icon:
                    const Icon(Icons.arrow_drop_down, color: Color(0xFF0066FF)),
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF374151),
                  fontWeight: FontWeight.w400,
                ),
                items: reportsController.templates.map((template) {
                  return DropdownMenuItem<ReportTemplate>(
                    value: template,
                    child: Text(template.name),
                  );
                }).toList(),
                onChanged: (ReportTemplate? newValue) {
                  setState(() {
                    _selectedTemplate = newValue;
                  });
                },
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildGradeDropdown() {
    return Column(
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
                style: TextStyle(color: Color(0xFFDC2626)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFFFBFCFD),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE9E9E9)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedGrade,
              hint: const Text('Select Grade'),
              isExpanded: true,
              icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF0066FF)),
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF374151),
                fontWeight: FontWeight.w400,
              ),
              items: _grades.map((grade) {
                return DropdownMenuItem<String>(
                  value: grade,
                  child: Text(grade),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedGrade = newValue;
                  _selectedClassId = null;
                  _selectedStudentIds.clear();
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildClassDropdown() {
    return Column(
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
                style: TextStyle(color: Color(0xFFDC2626)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Obx(() {
          final classes = _getClassesByGrade(_selectedGrade);

          if (resourcesController.isLoading.value) {
            return Container(
              height: 52,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFFBFCFD),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE9E9E9)),
              ),
              child: const Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            );
          }

          if (classes.isEmpty) {
            return Container(
              height: 52,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFFBFCFD),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE9E9E9)),
              ),
              child: Center(
                child: Text(
                  _selectedGrade == null
                      ? 'Select a grade first'
                      : 'No classes available for $_selectedGrade',
                  style: const TextStyle(color: Color(0xFF9CA3AF)),
                ),
              ),
            );
          }

          return Container(
            height: 52,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFFBFCFD),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE9E9E9)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedClassId,
                hint: const Text('Select Class'),
                isExpanded: true,
                icon:
                    const Icon(Icons.arrow_drop_down, color: Color(0xFF0066FF)),
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF374151),
                  fontWeight: FontWeight.w400,
                ),
                items: classes.map((classItem) {
                  final classId = classItem['id']?.toString() ?? '';
                  final className = classItem['name']?.toString() ?? 'Unknown';
                  return DropdownMenuItem<String>(
                    value: classId,
                    child: Text(className),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    _onClassSelected(newValue);
                  }
                },
              ),
            ),
          );
        }),
      ],
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
            height: 52,
            padding: const EdgeInsets.symmetric(horizontal: 16),
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
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
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

  Widget _buildDropdownField(
    String label,
    String value,
    List<String> items,
    Function(String?) onChanged, {
    bool isRequired = false,
  }) {
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
            children: isRequired
                ? const [
                    TextSpan(
                      text: '*',
                      style: TextStyle(color: Color(0xFFDC2626)),
                    ),
                  ]
                : [],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFFFBFCFD),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE9E9E9)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF0066FF)),
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF374151),
                fontWeight: FontWeight.w400,
              ),
              items: items.map((item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(item),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStudentMultiSelectField() {
    return Column(
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
        Obx(() {
          final isLoadingDetails =
              resourcesController.isLoadingClassDetails.value;

          return InkWell(
            onTap: isLoadingDetails ? null : _showStudentSelectionDialog,
            child: Container(
              height: 52,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFFBFCFD),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE9E9E9)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (isLoadingDetails)
                    const Row(
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Loading students...',
                          style: TextStyle(
                            color: Color(0xFF9CA3AF),
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    )
                  else
                    Text(
                      _selectedStudentIds.isEmpty
                          ? _selectedClassId == null
                              ? 'Select a class first'
                              : 'All students'
                          : '${_selectedStudentIds.length} student${_selectedStudentIds.length > 1 ? 's' : ''} selected',
                      style: TextStyle(
                        color: _selectedClassId == null
                            ? const Color(0xFF9CA3AF)
                            : const Color(0xFF374151),
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  if (!isLoadingDetails)
                    const Icon(Icons.arrow_drop_down, color: Color(0xFF0066FF)),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildCheckbox(String label, bool value, Function(bool?) onChanged) {
    return CheckboxListTile(
      title: Text(
        label,
        style: const TextStyle(
          fontSize: 14,
          color: Color(0xFF374151),
        ),
      ),
      value: value,
      onChanged: onChanged,
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: EdgeInsets.zero,
      activeColor: const Color(0xFF0066FF),
      dense: true,
    );
  }
}
