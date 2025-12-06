import 'package:flutter/material.dart';
import 'package:flutter_getx_app/controllers/calendar_controller.dart';
import 'package:flutter_getx_app/models/student.dart';
import 'package:flutter_getx_app/screens/appointmentScheduling/widgets/appointment_type_card_widget.dart';
import 'package:flutter_getx_app/screens/appointmentScheduling/widgets/custom_dropdown.dart';
import 'package:flutter_getx_app/screens/appointmentScheduling/widgets/custom_radio_option_widget.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class CreateAppointmentDialog extends StatefulWidget {
  const CreateAppointmentDialog({Key? key}) : super(key: key);

  @override
  State<CreateAppointmentDialog> createState() => _CreateAppointmentDialogState();
}

class _CreateAppointmentDialogState extends State<CreateAppointmentDialog> {
  final CalendarController calendarController = Get.find<CalendarController>();
  
  // Form state
  String _selectedType = 'Checkup';
  String _selectedOption = 'all'; // 'all' or 'selected'
  String _selectedDateTimeOption = 'addDate'; // 'addDate' or 'startNow'
  DateTime? _selectedDate;
  TimeOfDay? _selectedStartTime;
  TimeOfDay? _selectedEndTime;
  String? _selectedDisease;
  String? _selectedDiseaseType;
  String? _selectedGrade;
  String? _selectedClass;
  String? _selectedDoctor;
  List<Student> _selectedStudents = [];

  // Sample data
  final List<Map<String, dynamic>> _appointmentTypes = [
    {'label': 'Checkup', 'icon': const Icon(Icons.medical_services)},
    {'label': 'Follow-Up', 'icon': const Icon(Icons.description)},
    {'label': 'Vaccination', 'icon': const Icon(Icons.vaccines)},
    {'label': 'Walk-In', 'icon': const Icon(Icons.favorite)},
  ];

  final List<String> _diseases = [
    'Body Mass index - BMI',
    'Vision Test',
    'Hearing Test',
    'Blood Pressure',
  ];

  final List<String> _diseaseTypes = [
    'Disease type',
    'Type A',
    'Type B',
    'Type C',
  ];

  final List<String> _grades = ['G4', 'G5', 'G6', 'G7', 'G8'];
  final List<String> _classes = ['Lion Class', 'Tiger Class', 'Eagle Class', 'Bear Class'];
  final List<String> _doctors = [
    'Dr. Salem Said Al Ali',
    'Dr. Ahmad Samir',
    'Doctor name goes here',
  ];

  // Sample students
  final List<Student> _allStudents = List.generate(23, (index) => Student(
    id: 'student_$index',
    name: index == 0 ? 'Student name here' : 
          index == 1 ? 'Emily Johnson' :
          index == 2 ? 'John Doe' :
          index == 3 ? 'Alice Smith' :
          'Student ${index + 1}',
    avatarColor: Colors.blue,
    grade: 'G4',
    className: 'Lion Class',
  ));

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _selectedStartTime = const TimeOfDay(hour: 8, minute: 0);
    _selectedEndTime = const TimeOfDay(hour: 8, minute: 30);
    _selectedDisease = _diseases.first;
    _selectedDiseaseType = null;
    _selectedGrade = null;
    _selectedClass = null;
    _selectedDoctor = null;
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  String _formatTimeRange(TimeOfDay start, TimeOfDay end) {
    final startStr = _formatTimeOfDay(start);
    final endStr = _formatTimeOfDay(end);
    return '$startStr - $endStr';
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hour == 0 ? 12 : (time.hour > 12 ? time.hour - 12 : time.hour);
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickStartTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedStartTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedStartTime = picked;
        // Auto-set end time to 30 minutes later
        final endHour = picked.minute >= 30 
            ? (picked.hour + 1) % 24 
            : picked.hour;
        final endMinute = picked.minute >= 30 
            ? (picked.minute + 30) % 60 
            : picked.minute + 30;
        _selectedEndTime = TimeOfDay(hour: endHour, minute: endMinute);
      });
    }
  }

  void _showStudentSelectionDialog() {
    showDialog(
      context: context,
      builder: (context) => _StudentSelectionDialog(
        students: _allStudents,
        selectedStudents: _selectedStudents,
        onSelectionChanged: (students) {
          setState(() => _selectedStudents = students);
        },
      ),
    );
  }

  void _createAppointment() {
    if (_selectedDate == null || 
        _selectedStartTime == null || 
        _selectedEndTime == null ||
        _selectedDisease == null ||
        _selectedGrade == null ||
        _selectedClass == null ||
        _selectedDoctor == null) {
      Get.snackbar(
        'Error',
        'Please fill all required fields',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    final timeRange = _formatTimeRange(_selectedStartTime!, _selectedEndTime!);
    
    calendarController.createAppointment(
      date: _selectedDate!,
      time: timeRange,
      doctor: _selectedDoctor!,
      type: _selectedType,
      disease: _selectedDisease!,
      diseaseType: _selectedDiseaseType ?? '',
      grade: _selectedGrade!,
      className: _selectedClass!,
      selectedStudents: _selectedStudents,
      allStudents: _selectedOption == 'all',
    );

    Get.back();
    Get.snackbar(
      'Success',
      'Appointment created successfully',
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    final shouldShowDateTime = _selectedDateTimeOption == 'addDate';
    final shouldShowStartNowButton = _selectedDateTimeOption == 'startNow' && 
                                     (_selectedType == 'Checkup' || _selectedType == 'Follow-Up');
    final buttonText = shouldShowStartNowButton ? 'Start appointment' : 'Add appointment';

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 700,
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.9),
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
                      'New appointment',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Add appointments details and students',
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
                    // Select appointment type
                    _buildSectionTitle('Select appointment type'),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _appointmentTypes.map((type) => AppointmentTypeCard(
                        label: type['label'],
                        icon: type['icon'],
                        isActive: _selectedType == type['label'],
                        onTap: () => setState(() => _selectedType = type['label']),
                      )).toList(),
                    ),
                    const SizedBox(height: 24),

                    // Checkup details (All students / Selected Diseases)
                    if (_selectedType != 'Walk-In') ...[
                      _buildSectionTitle('Checkup details'),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          CustomRadioOption<String>(
                            value: 'all',
                            groupValue: _selectedOption,
                            label: 'All students',
                            onChanged: (val) => setState(() => _selectedOption = val),
                          ),
                          const SizedBox(width: 16),
                          CustomRadioOption<String>(
                            value: 'selected',
                            groupValue: _selectedOption,
                            label: 'Selected Diseases',
                            onChanged: (val) => setState(() => _selectedOption = val),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Date & time
                    _buildSectionTitle('Date & time'),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        CustomRadioOption<String>(
                          value: 'addDate',
                          groupValue: _selectedDateTimeOption,
                          label: 'Add date',
                          onChanged: (val) => setState(() => _selectedDateTimeOption = val),
                        ),
                        const SizedBox(width: 16),
                        CustomRadioOption<String>(
                          value: 'startNow',
                          groupValue: _selectedDateTimeOption,
                          label: 'Start now',
                          onChanged: (val) => setState(() => _selectedDateTimeOption = val),
                        ),
                      ],
                    ),
                    if (_selectedDateTimeOption == 'startNow' && 
                        (_selectedType == 'Checkup' || _selectedType == 'Follow-Up')) ...[
                      const SizedBox(height: 8),
                      const Text(
                        '[Dev note] when selecting start now the button bellow becomes "start appointment" and hide date and time (Checkup and follow up)',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.red,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                    if (shouldShowDateTime) ...[
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildDateField(),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildTimeField(),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 24),

                    // Checkup details (Disease / Check and Disease type)
                    if (_selectedType != 'Walk-In') ...[
                      _buildSectionTitle('Checkup details'),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                RichText(
                                  text: const TextSpan(
                                    text: 'Disease / Check',
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
                                CustomDropdown<String>(
                                  hint: 'Disease / Check',
                                  value: _selectedDisease,
                                  items: DropdownHelper.createStringItems(_diseases),
                                  onChanged: (val) => setState(() => _selectedDisease = val),
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
                                    text: 'Disease type',
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
                                CustomDropdown<String>(
                                  hint: 'Disease type',
                                  value: _selectedDiseaseType,
                                  items: DropdownHelper.createStringItems(_diseaseTypes),
                                  onChanged: (val) => setState(() => _selectedDiseaseType = val),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Grades and students
                    _buildSectionTitle('Grades and students'),
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
                                      style: TextStyle(color: Color(0xFFDC2626)),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                              CustomDropdown<String>(
                                hint: 'Grade',
                                value: _selectedGrade,
                                items: DropdownHelper.createStringItems(_grades),
                                onChanged: (val) => setState(() => _selectedGrade = val),
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
                                      style: TextStyle(color: Color(0xFFDC2626)),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                              CustomDropdown<String>(
                                hint: 'Class name',
                                value: _selectedClass,
                                items: DropdownHelper.createStringItems(_classes),
                                onChanged: (val) => setState(() => _selectedClass = val),
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
                                  text: 'Doctor(s)',
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
                              CustomDropdown<String>(
                                hint: 'Doctor name goes here',
                                value: _selectedDoctor,
                                items: DropdownHelper.createStringItems(_doctors),
                                onChanged: (val) => setState(() => _selectedDoctor = val),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Students (Multi selection)
                    if (_selectedType != 'Walk-In' && _selectedOption == 'selected') ...[
                      _buildSectionTitle('Students (Multi selection)'),
                      const SizedBox(height: 8),
                      _buildStudentMultiSelectField(),
                      if (_selectedStudents.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        _buildSelectedStudentsDisplay(),
                      ],
                      const SizedBox(height: 8),
                      const Text(
                        '[Dev note] If All students, Do not display the students tags. If Selected > 5 Display the "+N"',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.red,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ],
                ),
              ),
            ),

            // Action buttons
            const SizedBox(height: 24),
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
                    onPressed: _createAppointment,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0066FF),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      buttonText,
                      style: const TextStyle(
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

  Widget _buildDateField() {
    return InkWell(
      onTap: _pickDate,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFFBFCFD),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE9E9E9)),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, size: 20, color: Color(0xFF9CA3AF)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Date*',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _selectedDate != null ? _formatDate(_selectedDate!) : 'Select date',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF374151),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeField() {
    return InkWell(
      onTap: _pickStartTime,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFFBFCFD),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE9E9E9)),
        ),
        child: Row(
          children: [
            const Icon(Icons.access_time, size: 20, color: Color(0xFF9CA3AF)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Time*',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _selectedStartTime != null && _selectedEndTime != null
                        ? _formatTimeRange(_selectedStartTime!, _selectedEndTime!)
                        : 'Select time',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF374151),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentMultiSelectField() {
    return InkWell(
      onTap: _showStudentSelectionDialog,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFFBFCFD),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE9E9E9)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                _selectedOption == 'all' ? 'All students' : 'Select Students',
                style: TextStyle(
                  color: _selectedOption == 'all' 
                      ? const Color(0xFF374151) 
                      : const Color(0xFF9CA3AF),
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            const Icon(
              Icons.keyboard_arrow_down,
              color: Color(0xFF0066FF),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedStudentsDisplay() {
    const displayLimit = 5;
    final shouldShowMore = _selectedStudents.length > displayLimit;
    final studentsToShow = shouldShowMore 
        ? _selectedStudents.take(displayLimit).toList() 
        : _selectedStudents;
    final remainingCount = _selectedStudents.length - displayLimit;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        ...studentsToShow.map((student) => _buildStudentChip(student)),
        if (shouldShowMore)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF0066FF),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '+$remainingCount',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildStudentChip(Student student) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: student.avatarColor,
            child: Text(
              _getInitials(student.name),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            student.name,
            style: const TextStyle(
              color: Color(0xFF374151),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () {
              setState(() {
                _selectedStudents.removeWhere((s) => s.id == student.id);
              });
            },
            child: Container(
              width: 16,
              height: 16,
              decoration: const BoxDecoration(
                color: Color(0xFFF43F5E),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close,
                color: Colors.white,
                size: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getInitials(String name) {
    final words = name.split(' ');
    if (words.length >= 2) {
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }
}

class _StudentSelectionDialog extends StatefulWidget {
  final List<Student> students;
  final List<Student> selectedStudents;
  final Function(List<Student>) onSelectionChanged;

  const _StudentSelectionDialog({
    required this.students,
    required this.selectedStudents,
    required this.onSelectionChanged,
  });

  @override
  State<_StudentSelectionDialog> createState() => _StudentSelectionDialogState();
}

class _StudentSelectionDialogState extends State<_StudentSelectionDialog> {
  late List<Student> _selectedStudents;
  final TextEditingController _searchController = TextEditingController();
  List<Student> _filteredStudents = [];

  @override
  void initState() {
    super.initState();
    _selectedStudents = List<Student>.from(widget.selectedStudents);
    _filteredStudents = widget.students;
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
        _filteredStudents = widget.students;
      } else {
        _filteredStudents = widget.students
            .where((student) => student.name.toLowerCase().contains(_searchController.text.toLowerCase()))
            .toList();
      }
    });
  }

  void _toggleStudent(Student student) {
    setState(() {
      if (_selectedStudents.any((s) => s.id == student.id)) {
        _selectedStudents.removeWhere((s) => s.id == student.id);
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
                  final isSelected = _selectedStudents.any((s) => s.id == student.id);
                  return ListTile(
                    leading: CircleAvatar(
                      radius: 16,
                      backgroundColor: student.avatarColor,
                      child: Text(
                        _getInitials(student.name),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    title: Text(student.name),
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

  String _getInitials(String name) {
    final words = name.split(' ');
    if (words.length >= 2) {
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }
}
