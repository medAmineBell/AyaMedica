import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_getx_app/config/app_config.dart';
import 'package:flutter_getx_app/models/appointment.dart';
import 'package:flutter_getx_app/models/appointment_models.dart';
import 'package:flutter_getx_app/models/student.dart';
import 'package:flutter_getx_app/models/vital_signs_data.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../../controllers/appointment_history_controller.dart';
import '../../../controllers/appointment_scheduling_controller.dart';
import '../../../utils/storage_service.dart';

enum _VitalSignsType { diabetes, bloodPressure, cardiovascular, bmi }

class VitalSignsTableWidget extends StatefulWidget {
  final Appointment appointment;
  final VoidCallback? onBack;

  const VitalSignsTableWidget({
    Key? key,
    required this.appointment,
    this.onBack,
  }) : super(key: key);

  @override
  State<VitalSignsTableWidget> createState() => _VitalSignsTableWidgetState();
}

class _VitalSignsTableWidgetState extends State<VitalSignsTableWidget> {
  final _searchController = TextEditingController();
  final _searchQuery = ''.obs;
  final _activeFilter = 'All'.obs; // BMI filter
  late final AppointmentSchedulingController controller;

  // Drug search
  final RxList<Map<String, dynamic>> _drugResults =
      <Map<String, dynamic>>[].obs;
  final RxBool _isLoadingDrugs = false.obs;
  Timer? _drugDebounce;

  // Per-student text controllers: key = '{studentId}_{fieldName}'
  final Map<String, TextEditingController> _textControllers = {};

  Appointment get appointment => widget.appointment;

  _VitalSignsType get _type {
    switch (appointment.disease.toLowerCase()) {
      case 'diabetes':
        return _VitalSignsType.diabetes;
      case 'blood pressure':
        return _VitalSignsType.bloodPressure;
      case 'cardiovascular':
        return _VitalSignsType.cardiovascular;
      case 'bmi':
        return _VitalSignsType.bmi;
      default:
        return _VitalSignsType.diabetes;
    }
  }

  static const _administrationFormOptions = [
    'Sublingual',
    'Oral',
    'Intramuscular injection',
    'Subcutaneous',
    'Intravenous injection',
    'Inhalation',
  ];

  static const _unitOptions = ['mg', 'ml', 'IU', 'mcg', 'g'];
  static const _presenceOptions = ['Present', 'Absent'];

  @override
  void initState() {
    super.initState();
    controller = Get.find<AppointmentSchedulingController>();
    // Pre-initialize vital signs data for all students so we don't mutate during build
    for (final student in appointment.selectedStudents) {
      controller.getOrCreateVitalSignsData(_key(student));
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _drugDebounce?.cancel();
    for (final c in _textControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  // ─── helpers ──────────────────────────────────────────────────────────

  String _key(Student student) => '${appointment.id}_${student.id}';

  bool _isStudentDone(Student student) {
    final data = controller.getVitalSignsData(_key(student));
    if (data == null) return false;
    return data.isDone(appointment.disease);
  }

  int _getDoneCount() =>
      appointment.selectedStudents.where((s) => _isStudentDone(s)).length;

  int _getNotDoneCount() =>
      appointment.selectedStudents.length - _getDoneCount();

  String _getBmiCategory(Student student) {
    final data = controller.getVitalSignsData(_key(student));
    if (data == null) return '';
    if (data.presence.toLowerCase() == 'absent') return 'Absent';
    final bmi = data.calculateBmi();
    if (bmi == null) return '';
    return VitalSignsData.bmiCategory(bmi);
  }

  Map<String, int> _getBmiCategoryCounts() {
    final counts = <String, int>{
      'All': appointment.selectedStudents.length,
      'Normal': 0,
      'Overweight': 0,
      'Obesity': 0,
      'Underweight': 0,
      'Absent': 0,
    };
    for (final s in appointment.selectedStudents) {
      final cat = _getBmiCategory(s);
      if (counts.containsKey(cat)) {
        counts[cat] = counts[cat]! + 1;
      }
    }
    return counts;
  }

  List<Student> _getFilteredStudents() {
    final query = _searchQuery.value.toLowerCase();
    var students = appointment.selectedStudents.where((s) {
      if (query.isEmpty) return true;
      return s.name.toLowerCase().contains(query) ||
          (s.aid ?? s.id).toLowerCase().contains(query);
    }).toList();

    // Apply BMI filter
    if (_type == _VitalSignsType.bmi && _activeFilter.value != 'All') {
      students = students.where((s) {
        return _getBmiCategory(s) == _activeFilter.value;
      }).toList();
    }

    return students;
  }

  TextEditingController _getTextController(
      String studentId, String fieldName, String initialValue) {
    final ctrlKey = '${studentId}_$fieldName';
    if (!_textControllers.containsKey(ctrlKey)) {
      _textControllers[ctrlKey] = TextEditingController(text: initialValue);
    }
    return _textControllers[ctrlKey]!;
  }

  void _syncIfComplete(Student student) {
    final data = controller.getVitalSignsData(_key(student));
    if (data == null) return;
    if (!data.isDone(appointment.disease)) return;

    controller.updatePatientVitalSigns(
      sessionId: appointment.id!,
      patientAid: student.aid ?? student.id,
      studentId: student.id,
      data: data,
    );
  }

  // ─── Drug search ──────────────────────────────────────────────────────

  Future<void> _fetchDrugs(String search) async {
    try {
      _isLoadingDrugs.value = true;
      final storageService = Get.find<StorageService>();
      final accessToken = storageService.getAccessToken();
      if (accessToken == null) return;

      final branchData = storageService.getSelectedBranchData();
      final country = branchData?['country'] as String? ?? 'EG';

      var urlStr =
          '${AppConfig.newBackendUrl}/api/lookups/drugs?country=$country';
      if (search.isNotEmpty) {
        urlStr += '&search=${Uri.encodeComponent(search)}';
      }

      final response = await http.get(
        Uri.parse(urlStr),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData['success'] == true) {
          final data = jsonData['data'] as List;
          _drugResults.assignAll(
            data.map((d) => Map<String, dynamic>.from(d)).toList(),
          );
        }
      }
    } catch (e) {
      print('Error loading drugs: $e');
    } finally {
      _isLoadingDrugs.value = false;
    }
  }

  void _onDrugSearchChanged(String search) {
    _drugDebounce?.cancel();
    _drugDebounce = Timer(const Duration(milliseconds: 300), () {
      _fetchDrugs(search);
    });
  }

  // ─── build ────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          _buildHeader(),
          _buildSearchAndFilterBar(),
          Expanded(
            child: Obx(() {
              controller.vitalSignsData.length; // reactivity
              _searchQuery.value;
              _activeFilter.value;

              final students = _getFilteredStudents();

              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: _tableWidth,
                  child: SingleChildScrollView(
                    child: _buildTable(students),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  double get _tableWidth {
    switch (_type) {
      case _VitalSignsType.diabetes:
        return 1200;
      case _VitalSignsType.bloodPressure:
        return 1300;
      case _VitalSignsType.cardiovascular:
        return 1200;
      case _VitalSignsType.bmi:
        return 1200;
    }
  }

  // ─── HEADER ───────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              if (widget.onBack != null) {
                widget.onBack!();
              } else {
                controller.switchToAppointmentView();
              }
            },
            icon: const Icon(Icons.arrow_back,
                color: Color(0xFF6B7280), size: 20),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
          const SizedBox(width: 16),
          if (_type == _VitalSignsType.bmi) ...[
            CircleAvatar(
              radius: 24,
              backgroundColor: _classColor(appointment.className),
              child: Text(
                appointment.className.isNotEmpty
                    ? appointment.className.substring(0, 2).toUpperCase()
                    : 'CL',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ] else ...[
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFFEE2E2),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(Icons.warning_rounded,
                  color: Color(0xFFDC2626), size: 24),
            ),
          ],
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _type == _VitalSignsType.bmi
                      ? '${appointment.className} | ${appointment.grade}'
                      : appointment.disease,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF374151),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _type == _VitalSignsType.bmi
                      ? '${appointment.type} | ${appointment.disease}'
                      : '${appointment.selectedStudents.length} students',
                  style:
                      const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
                ),
              ],
            ),
          ),
          if (appointment.status != AppointmentStatus.done)
            ElevatedButton(
              onPressed: () => _completeAppointment(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                elevation: 0,
              ),
              child: const Text('Complete Appointment'),
            ),
        ],
      ),
    );
  }

  // ─── SEARCH + FILTER BAR ─────────────────────────────────────────────

  Widget _buildSearchAndFilterBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 280,
            height: 40,
            child: TextField(
              controller: _searchController,
              onChanged: (v) => _searchQuery.value = v,
              decoration: InputDecoration(
                hintText: 'search',
                hintStyle:
                    const TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
                prefixIcon: const Icon(Icons.search,
                    color: Color(0xFF9CA3AF), size: 20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF2563EB)),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              style: const TextStyle(fontSize: 14, color: Color(0xFF111827)),
            ),
          ),
          const Spacer(),
          Obx(() {
            controller.vitalSignsData.length; // reactivity

            if (_type == _VitalSignsType.bmi) {
              return _buildBmiFilterChips();
            }

            return Row(
              children: [
                _buildBadge(
                  icon: Icons.check_circle,
                  color: const Color(0xFF059669),
                  bg: const Color(0xFFDCFCE7),
                  count: _getDoneCount(),
                  label: 'Done',
                ),
                const SizedBox(width: 8),
                _buildBadge(
                  icon: Icons.cancel,
                  color: const Color(0xFFDC2626),
                  bg: const Color(0xFFFEE2E2),
                  count: _getNotDoneCount(),
                  label: 'Not Done',
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildBmiFilterChips() {
    final counts = _getBmiCategoryCounts();
    final filters = [
      'All',
      'Normal',
      'Overweight',
      'Obesity',
      'Underweight',
      'Absent'
    ];

    return Obx(() => Row(
          children: filters.map((filter) {
            final isSelected = _activeFilter.value == filter;
            final count = counts[filter] ?? 0;

            Color chipColor;
            Color textColor;
            Color borderColor;
            switch (filter) {
              case 'Normal':
                chipColor = isSelected ? const Color(0xFFDCFCE7) : Colors.white;
                textColor = const Color(0xFF059669);
                borderColor = const Color(0xFF86EFAC);
                break;
              case 'Overweight':
                chipColor = isSelected ? const Color(0xFFDBEAFE) : Colors.white;
                textColor = const Color(0xFF2563EB);
                borderColor = const Color(0xFF93C5FD);
                break;
              case 'Obesity':
                chipColor = isSelected ? const Color(0xFFFEE2E2) : Colors.white;
                textColor = const Color(0xFFDC2626);
                borderColor = const Color(0xFFFCA5A5);
                break;
              case 'Underweight':
                chipColor = isSelected ? const Color(0xFFFEE2E2) : Colors.white;
                textColor = const Color(0xFFDC2626);
                borderColor = const Color(0xFFFCA5A5);
                break;
              case 'Absent':
                chipColor = isSelected ? const Color(0xFFF3F4F6) : Colors.white;
                textColor = const Color(0xFF6B7280);
                borderColor = const Color(0xFFD1D5DB);
                break;
              default: // All
                chipColor = isSelected ? const Color(0xFFDBEAFE) : Colors.white;
                textColor = const Color(0xFF2563EB);
                borderColor = const Color(0xFF93C5FD);
            }

            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => _activeFilter.value = filter,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: chipColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: borderColor),
                  ),
                  child: Text(
                    '$count $filter',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: textColor,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ));
  }

  Widget _buildBadge({
    required IconData icon,
    required Color color,
    required Color bg,
    required int count,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            '$count $label',
            style: TextStyle(
                fontSize: 12, fontWeight: FontWeight.w500, color: color),
          ),
        ],
      ),
    );
  }

  // ─── TABLE ────────────────────────────────────────────────────────────

  Widget _buildTable(List<Student> students) {
    return Table(
      columnWidths: _columnWidths,
      children: [
        _buildHeaderRow(),
        ...students.map((s) => _buildStudentRow(s)),
      ],
    );
  }

  Map<int, TableColumnWidth> get _columnWidths {
    switch (_type) {
      case _VitalSignsType.diabetes:
        return const {
          0: FlexColumnWidth(2.5), // Student
          1: FlexColumnWidth(1.5), // Blood Glucose
          2: FlexColumnWidth(2), // Medication
          3: FlexColumnWidth(2), // Administration Form
          4: FlexColumnWidth(1.2), // Doze
          5: FlexColumnWidth(1.2), // Unit
        };
      case _VitalSignsType.bloodPressure:
        return const {
          0: FlexColumnWidth(2.5), // Student
          1: FlexColumnWidth(2), // Blood Pressure
          2: FlexColumnWidth(2), // Medication
          3: FlexColumnWidth(2), // Administration Form
          4: FlexColumnWidth(1.2), // Doze
          5: FlexColumnWidth(1.2), // Unit
        };
      case _VitalSignsType.cardiovascular:
        return const {
          0: FlexColumnWidth(2.5), // Student
          1: FlexColumnWidth(1.5), // Heart Rate
          2: FlexColumnWidth(2), // Medication
          3: FlexColumnWidth(2), // Administration Form
          4: FlexColumnWidth(1.2), // Doze
          5: FlexColumnWidth(1.2), // Unit
        };
      case _VitalSignsType.bmi:
        return const {
          0: FlexColumnWidth(2), // Student
          1: FlexColumnWidth(1.5), // Presence
          2: FlexColumnWidth(1.2), // Height
          3: FlexColumnWidth(1.2), // Weight
          4: FlexColumnWidth(2), // Note
          5: FlexColumnWidth(2), // BMI Result
        };
    }
  }

  List<String> get _headerLabels {
    switch (_type) {
      case _VitalSignsType.diabetes:
        return [
          'Student full name',
          'Blood Glucose',
          'Medication',
          'Administration Form',
          'Doze',
          'Unit',
        ];
      case _VitalSignsType.bloodPressure:
        return [
          'Student full name',
          'Blood Pressure',
          'Medication',
          'Administration Form',
          'Doze',
          'Unit',
        ];
      case _VitalSignsType.cardiovascular:
        return [
          'Student full name',
          'Heart Rate',
          'Medication',
          'Administration Form',
          'Doze',
          'Unit',
        ];
      case _VitalSignsType.bmi:
        return [
          'Student full name',
          'Presence',
          'Height (CM)',
          'Weight (Kg)',
          'Note (Optional)',
          'BMI Result',
        ];
    }
  }

  TableRow _buildHeaderRow() {
    return TableRow(
      decoration: const BoxDecoration(
        color: Color(0xFFF9FAFB),
        border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      children: _headerLabels.map((l) => _headerCell(l)).toList(),
    );
  }

  Widget _headerCell(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Color(0xFF6B7280),
        ),
      ),
    );
  }

  TableRow _buildStudentRow(Student student) {
    final isDone = appointment.status == AppointmentStatus.done;
    final key = _key(student);
    final data = controller.getVitalSignsData(key) ?? VitalSignsData();

    List<Widget> cells;
    switch (_type) {
      case _VitalSignsType.diabetes:
        cells = [
          _buildStudentCell(student),
          _buildTextInputCell(student, 'bloodGlucose', data.bloodGlucose,
              enabled: !isDone, numeric: true),
          _buildMedicationCell(student, data.medication, enabled: !isDone),
          _buildDropdownCell(student, 'administrationForm',
              _administrationFormOptions, data.administrationForm,
              enabled: !isDone),
          _buildTextInputCell(student, 'doze', data.doze,
              enabled: !isDone, numeric: true),
          _buildDropdownCell(student, 'unit', _unitOptions, data.unit,
              enabled: !isDone),
        ];
        break;
      case _VitalSignsType.bloodPressure:
        cells = [
          _buildStudentCell(student),
          _buildBloodPressureCell(student, data, enabled: !isDone),
          _buildMedicationCell(student, data.medication, enabled: !isDone),
          _buildDropdownCell(student, 'administrationForm',
              _administrationFormOptions, data.administrationForm,
              enabled: !isDone),
          _buildTextInputCell(student, 'doze', data.doze,
              enabled: !isDone, numeric: true),
          _buildDropdownCell(student, 'unit', _unitOptions, data.unit,
              enabled: !isDone),
        ];
        break;
      case _VitalSignsType.cardiovascular:
        cells = [
          _buildStudentCell(student),
          _buildTextInputCell(student, 'heartRate', data.heartRate,
              enabled: !isDone, numeric: true),
          _buildMedicationCell(student, data.medication, enabled: !isDone),
          _buildDropdownCell(student, 'administrationForm',
              _administrationFormOptions, data.administrationForm,
              enabled: !isDone),
          _buildTextInputCell(student, 'doze', data.doze,
              enabled: !isDone, numeric: true),
          _buildDropdownCell(student, 'unit', _unitOptions, data.unit,
              enabled: !isDone),
        ];
        break;
      case _VitalSignsType.bmi:
        final isAbsent = data.presence.toLowerCase() == 'absent';
        cells = [
          _buildStudentCell(student),
          _buildDropdownCell(
              student, 'presence', _presenceOptions, data.presence,
              enabled: !isDone),
          _buildTextInputCell(student, 'height', data.height,
              enabled: !isDone && !isAbsent, numeric: true,
              minValue: 30, maxValue: 250, validationLabel: 'Height'),
          _buildTextInputCell(student, 'weight', data.weight,
              enabled: !isDone && !isAbsent, numeric: true,
              minValue: 1, maxValue: 300, validationLabel: 'Weight'),
          _buildTextInputCell(student, 'note', data.note,
              enabled: !isDone && !isAbsent),
          _buildBmiResultCell(data),
        ];
        break;
    }

    return TableRow(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      children: cells,
    );
  }

  // ─── STUDENT CELL ─────────────────────────────────────────────────────

  Widget _buildStudentCell(Student student) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          _buildAvatar(student),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  student.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF111827),
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                const SizedBox(height: 2),
                Text(
                  student.aid ?? student.id,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF6B7280),
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(Student student) {
    if (student.imageUrl != null && student.imageUrl!.isNotEmpty) {
      String url = student.imageUrl!;
      if (url.startsWith('/')) {
        url = '${AppConfig.newBackendUrl}$url';
      }
      return CircleAvatar(
        radius: 18,
        backgroundImage: NetworkImage(url),
        backgroundColor: student.avatarColor,
        onBackgroundImageError: (_, __) {},
      );
    }
    return CircleAvatar(
      radius: 18,
      backgroundColor: student.avatarColor,
      child: const Icon(Icons.person, color: Colors.white, size: 20),
    );
  }

  // ─── VALIDATION ────────────────────────────────────────────────────────

  // Tracks which fields have been blurred (lost focus) at least once
  final Set<String> _blurredFields = {};

  String? _validateNumericRange(String value, double? minValue, double? maxValue, String fieldLabel) {
    if (value.isEmpty) return null;
    final parsed = double.tryParse(value);
    if (parsed == null) return 'Invalid number';
    if (parsed <= 0) return '$fieldLabel must be greater than 0';
    if (minValue != null && parsed < minValue) return '$fieldLabel must be at least ${minValue.toInt()}';
    if (maxValue != null && parsed > maxValue) return '$fieldLabel must be at most ${maxValue.toInt()}';
    return null;
  }

  // ─── TEXT INPUT CELL ──────────────────────────────────────────────────

  Widget _buildTextInputCell(
    Student student,
    String fieldName,
    String initialValue, {
    bool enabled = true,
    bool numeric = false,
    double? minValue,
    double? maxValue,
    String? validationLabel,
  }) {
    final ctrl = _getTextController(student.id, fieldName, initialValue);
    final hasValidation = numeric && (minValue != null || maxValue != null);
    final blurKey = '${student.id}_$fieldName';

    // Only show error after the field has been blurred
    String? errorText;
    if (hasValidation && _blurredFields.contains(blurKey)) {
      errorText = _validateNumericRange(ctrl.text, minValue, maxValue, validationLabel ?? fieldName);
    }

    final isError = errorText != null;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Tooltip(
        message: errorText ?? '',
        child: SizedBox(
          height: 40,
          child: Focus(
            onFocusChange: (hasFocus) {
              if (hasFocus && hasValidation) {
                setState(() {
                  _blurredFields.remove(blurKey);
                });
              } else if (!hasFocus && hasValidation) {
                setState(() {
                  _blurredFields.add(blurKey);
                });
              }
            },
            child: TextField(
              controller: ctrl,
              enabled: enabled,
              keyboardType: numeric
                  ? const TextInputType.numberWithOptions(decimal: true)
                  : TextInputType.text,
              inputFormatters: numeric
                  ? [FilteringTextInputFormatter.allow(RegExp(r'[\d.]'))]
                  : null,
              onChanged: (value) {
                controller.setVitalSignsField(_key(student), fieldName, value);
                if (hasValidation) {
                  final error = _validateNumericRange(value, minValue, maxValue, validationLabel ?? fieldName);
                  if (error == null) {
                    _syncIfComplete(student);
                  }
                  // Re-render to clear error if user fixes it while still focused
                  if (_blurredFields.contains(blurKey)) {
                    setState(() {});
                  }
                } else {
                  _syncIfComplete(student);
                }
              },
              decoration: InputDecoration(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: isError ? const Color(0xFFDC2626) : const Color(0xFFE5E7EB),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: isError ? const Color(0xFFDC2626) : const Color(0xFF2563EB),
                  ),
                ),
                disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                ),
                filled: !enabled || isError,
                fillColor: isError ? const Color(0xFFFEF2F2) : const Color(0xFFF9FAFB),
                suffixIcon: isError
                    ? const Icon(Icons.error_outline, color: Color(0xFFDC2626), size: 18)
                    : null,
              ),
              style: TextStyle(
                fontSize: 14,
                color: isError
                    ? const Color(0xFFDC2626)
                    : enabled
                        ? const Color(0xFF111827)
                        : const Color(0xFF9CA3AF),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ─── BLOOD PRESSURE CELL (two inputs) ─────────────────────────────────

  Widget _buildBloodPressureCell(Student student, VitalSignsData data,
      {bool enabled = true}) {
    final sysCtrl = _getTextController(student.id, 'bpSystolic', data.systolic);
    final diaCtrl =
        _getTextController(student.id, 'bpDiastolic', data.diastolic);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 40,
              child: TextField(
                controller: sysCtrl,
                enabled: enabled,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (value) {
                  data.setBloodPressure(value, diaCtrl.text);
                  controller.setVitalSignsField(
                      _key(student), 'bloodPressure', data.bloodPressure);
                  _syncIfComplete(student);
                },
                decoration: _inputDecoration(enabled),
                style: _inputTextStyle(enabled),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: SizedBox(
              height: 40,
              child: TextField(
                controller: diaCtrl,
                enabled: enabled,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (value) {
                  data.setBloodPressure(sysCtrl.text, value);
                  controller.setVitalSignsField(
                      _key(student), 'bloodPressure', data.bloodPressure);
                  _syncIfComplete(student);
                },
                decoration: _inputDecoration(enabled),
                style: _inputTextStyle(enabled),
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(bool enabled) {
    return InputDecoration(
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF2563EB)),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      filled: !enabled,
      fillColor: const Color(0xFFF9FAFB),
    );
  }

  TextStyle _inputTextStyle(bool enabled) {
    return TextStyle(
      fontSize: 14,
      color: enabled ? const Color(0xFF111827) : const Color(0xFF9CA3AF),
    );
  }

  // ─── DROPDOWN CELL ────────────────────────────────────────────────────

  Widget _buildDropdownCell(
    Student student,
    String fieldName,
    List<String> options,
    String currentValue, {
    bool enabled = true,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: SizedBox(
        height: 40,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE5E7EB)),
            color: enabled ? Colors.white : const Color(0xFFF9FAFB),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: currentValue.isNotEmpty && options.contains(currentValue)
                  ? currentValue
                  : null,
              isExpanded: true,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              icon: Icon(
                Icons.arrow_drop_down,
                color:
                    enabled ? const Color(0xFF2563EB) : const Color(0xFF9CA3AF),
              ),
              hint: Text(
                fieldName == 'presence'
                    ? 'Select'
                    : fieldName == 'unit'
                        ? 'Unit'
                        : 'Select',
                style: const TextStyle(fontSize: 13, color: Color(0xFF9CA3AF)),
              ),
              style: const TextStyle(fontSize: 13, color: Color(0xFF111827)),
              onChanged: enabled
                  ? (value) {
                      if (value != null) {
                        controller.setVitalSignsField(
                            _key(student), fieldName, value);
                        _syncIfComplete(student);
                      }
                    }
                  : null,
              items: options
                  .map((o) => DropdownMenuItem(value: o, child: Text(o)))
                  .toList(),
            ),
          ),
        ),
      ),
    );
  }

  // ─── MEDICATION CELL (searchable dropdown) ────────────────────────────

  Widget _buildMedicationCell(Student student, String currentValue,
      {bool enabled = true}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: SizedBox(
        height: 40,
        child: GestureDetector(
          onTap: enabled
              ? () => _showMedicationDialog(student, currentValue)
              : null,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE5E7EB)),
              color: enabled ? Colors.white : const Color(0xFFF9FAFB),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    currentValue.isNotEmpty ? currentValue : 'Medication',
                    style: TextStyle(
                      fontSize: 13,
                      color: currentValue.isNotEmpty
                          ? const Color(0xFF111827)
                          : const Color(0xFF9CA3AF),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(
                  Icons.arrow_drop_down,
                  color: enabled
                      ? const Color(0xFF2563EB)
                      : const Color(0xFF9CA3AF),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showMedicationDialog(Student student, String currentValue) {
    final searchCtrl = TextEditingController();
    _drugResults.clear();
    _fetchDrugs(''); // load initial list

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420, maxHeight: 500),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Select Medication',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: searchCtrl,
                  onChanged: _onDrugSearchChanged,
                  decoration: InputDecoration(
                    hintText: 'Search medication...',
                    hintStyle:
                        const TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
                    prefixIcon: const Icon(Icons.search,
                        color: Color(0xFF9CA3AF), size: 20),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                    ),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: Obx(() {
                    if (_isLoadingDrugs.value) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (_drugResults.isEmpty) {
                      return const Center(
                        child: Text('No medications found',
                            style: TextStyle(color: Color(0xFF9CA3AF))),
                      );
                    }
                    return ListView.builder(
                      itemCount: _drugResults.length,
                      itemBuilder: (context, index) {
                        final drug = _drugResults[index];
                        final name =
                            drug['drug_name'] ?? drug['name'] ?? 'Unknown';
                        return ListTile(
                          title:
                              Text(name, style: const TextStyle(fontSize: 14)),
                          dense: true,
                          onTap: () {
                            controller.setVitalSignsField(
                                _key(student), 'medication', name);
                            _syncIfComplete(student);
                            Get.back();
                          },
                        );
                      },
                    );
                  }),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Get.back(),
                    child: const Text('Cancel'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── BMI RESULT CELL ──────────────────────────────────────────────────

  Widget _buildBmiResultCell(VitalSignsData data) {
    final result = data.formattedBmiResult;

    if (result.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: const SizedBox(height: 40),
      );
    }

    if (result == 'Absent') {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Container(
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text(
            'Absent',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Color(0xFF6B7280),
            ),
          ),
        ),
      );
    }

    final bmi = data.calculateBmi();
    if (bmi == null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: const SizedBox(height: 40),
      );
    }

    Color bgColor;
    Color textColor;
    final category = VitalSignsData.bmiCategory(bmi);

    switch (category) {
      case 'Underweight':
        bgColor = const Color(0xFFFEE2E2);
        textColor = const Color(0xFFDC2626);
        break;
      case 'Normal':
        bgColor = const Color(0xFFDCFCE7);
        textColor = const Color(0xFF059669);
        break;
      case 'Overweight':
        bgColor = const Color(0xFFDBEAFE);
        textColor = const Color(0xFF2563EB);
        break;
      case 'Obesity':
        bgColor = const Color(0xFFFEE2E2);
        textColor = Colors.white;
        break;
      default:
        bgColor = const Color(0xFFF3F4F6);
        textColor = const Color(0xFF6B7280);
    }

    // Obesity uses filled red bg with white text
    if (category == 'Obesity') {
      bgColor = const Color(0xFFDC2626);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Container(
        height: 40,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
          border: category == 'Overweight'
              ? Border.all(color: const Color(0xFF93C5FD))
              : null,
        ),
        child: Text(
          result,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  // ─── COMPLETE APPOINTMENT ─────────────────────────────────────────────

  void _completeAppointment() {
    final markAllDone = true.obs;

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 486),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle_rounded,
                    size: 64, color: Color(0xFF10B981)),
                const SizedBox(height: 16),
                Text(
                  'Complete ${appointment.type}',
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111827)),
                ),
                const SizedBox(height: 8),
                Text(
                  'By clicking proceed, ${appointment.type} will be marked done for all the students and you can not undo this action',
                  textAlign: TextAlign.center,
                  style:
                      const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
                ),
                const SizedBox(height: 24),
                Obx(() => CheckboxListTile(
                      value: markAllDone.value,
                      onChanged: (val) => markAllDone.value = val ?? true,
                      contentPadding: EdgeInsets.zero,
                      title: const Text(
                        'Mark All unchecked checkups status as done',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                      activeColor: const Color(0xFF2563EB),
                      controlAffinity: ListTileControlAffinity.leading,
                    )),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Get.back(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                          side: const BorderSide(color: Color(0xFFD1D5DB)),
                        ),
                        child: const Text('Dismiss',
                            style: TextStyle(color: Color(0xFF374151))),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          Get.back();

                          // If checkbox checked, mark incomplete students as done and sync
                          if (markAllDone.value) {
                            for (final student
                                in appointment.selectedStudents) {
                              final key = _key(student);
                              final data = controller.getVitalSignsData(key) ??
                                  VitalSignsData();
                              if (!data.isDone(appointment.disease)) {
                                data.patientStatus = 'checked';
                                controller.vitalSignsData.refresh();
                                controller.updatePatientVitalSigns(
                                  sessionId: appointment.id!,
                                  patientAid: student.aid ?? student.id,
                                  studentId: student.id,
                                  data: data,
                                );
                              }
                            }
                          }

                          final success = await controller
                              .checkoutAppointmentSession(appointment.id!);
                          if (success) {
                            if (Get.isRegistered<
                                AppointmentHistoryController>()) {
                              Get.find<AppointmentHistoryController>()
                                  .refreshAppointments();
                            }
                            Get.snackbar(
                              'Success',
                              'Appointment completed successfully',
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: const Color(0xFF10B981),
                              colorText: Colors.white,
                            );
                            if (widget.onBack != null) {
                              widget.onBack!();
                            } else {
                              controller.switchToAppointmentView();
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                          elevation: 0,
                        ),
                        child: const Text('Complete Appointment'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  // ─── UTILS ────────────────────────────────────────────────────────────

  Color _classColor(String className) {
    final colors = [
      const Color(0xFF6366F1),
      const Color(0xFF8B5CF6),
      const Color(0xFFEC4899),
      const Color(0xFFF59E0B),
      const Color(0xFF10B981),
      const Color(0xFF1339FF),
    ];
    return colors[className.hashCode.abs() % colors.length];
  }
}
