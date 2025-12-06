import 'package:flutter/material.dart';
import 'package:flutter_getx_app/controllers/create_appointment_controller.dart';
import 'package:flutter_getx_app/models/student.dart';
import 'package:flutter_getx_app/screens/appointmentScheduling/widgets/custom_radio_option_widget.dart';
import 'package:get/get.dart';
import 'appointment_type_card_widget.dart';
import 'custom_dropdown.dart';
import 'date_time_picker_row_widget.dart';

class CreateAppointmentDialog extends StatelessWidget {
  const CreateAppointmentDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CreateAppointmentController());

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(24),
        height: MediaQuery.of(context).size.height * 0.8,
        child: Form(
          key: controller.formKey,
          child: Column(
            children: [
              // Fixed Header
              _buildHeader(controller),
              const SizedBox(height: 24),

              // Scrollable Content
              Expanded(
                child: SingleChildScrollView(
                  child: Obx(() {
                    // Show Walk-In interface if Walk-In is selected
                    if (controller.selectedType.value == 'Walk-In') {
                      return _buildWalkInContent(controller);
                    }
                    // Otherwise show regular appointment interface
                    return _buildRegularAppointmentContent(controller);
                  }),
                ),
              ),

              // Fixed Footer
              const SizedBox(height: 24),
              _buildActionButtons(controller),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(CreateAppointmentController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Obx(() => Text(
              controller.selectedType.value == 'Walk-In'
                  ? 'New appointment'
                  : 'Create New Appointment',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            )),
        IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.close),
        ),
      ],
    );
  }

  Widget _buildWalkInContent(CreateAppointmentController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header subtitle for Walk-In
        const Text(
          'Add appointments details and students',
          style: TextStyle(
            fontSize: 16,
            color: Color(0xFF6B7280),
          ),
        ),
        const SizedBox(height: 24),

        // Appointment Type Selection
        _buildTypeSelector(controller),
        const SizedBox(height: 24),

        // Find Student Section
        _buildFindStudentSection(controller),
        const SizedBox(height: 24),

        // Selected Student Display
        _buildSelectedStudentDisplay(controller),
      ],
    );
  }

  Widget _buildRegularAppointmentContent(
      CreateAppointmentController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTypeSelector(controller),
        const SizedBox(height: 16),
        _buildCheckupDetails(controller),
        const SizedBox(height: 16),
        _buildDateTimeSelection(controller),
        const SizedBox(height: 16),
        Obx(() => controller.selectedDateTimeOption.value == 'addDate'
            ? _buildDateTimePicker(controller)
            : const SizedBox.shrink()),
        const SizedBox(height: 16),
        Obx(() => controller.selectedType.value == 'Follow-Up'
            ? _buildDoctorSelection(controller)
            : const SizedBox.shrink()),
        const SizedBox(height: 16),
        Obx(() => controller.selectedType.value == 'Vaccination'
            ? _buildVaccinationTypeSelection(controller)
            : const SizedBox.shrink()),
        const SizedBox(height: 16),
        Obx(() => controller.selectedOption.value == 'all'
            ? const SizedBox.shrink()
            : _buildStudentMultiSelect(controller)),
        const SizedBox(height: 16),
        _buildDiseaseDetails(controller),
        const SizedBox(height: 16),
        _buildGradeClassDropdowns(controller),
      ],
    );
  }

  Widget _buildFindStudentSection(CreateAppointmentController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Find student',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 16),

        // Student AID Search
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: const TextSpan(
                text: 'Student AID',
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
            TextFormField(
              controller: controller.aidController,
              decoration: InputDecoration(
                hintText: 'search',
                hintStyle: const TextStyle(
                  color: Color(0xFF9CA3AF),
                  fontSize: 16,
                ),
                prefixIcon: const Icon(
                  Icons.search,
                  color: Color(0xFF9CA3AF),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF2563EB)),
                ),
                filled: true,
                fillColor: const Color(0xFFFBFCFD),
              ),
              onChanged: controller.searchByAID,
            ),
          ],
        ),

        const SizedBox(height: 24),

        // Or search by grade
        const Text(
          'Or search by grade',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 16),

        // Grade, Class, Student dropdowns
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
                  Obx(() => CustomDropdown<String>(
                        hint: 'Grade',
                        value: controller.selectedGrade.value,
                        items:
                            DropdownHelper.createStringItems(controller.grades),
                        onChanged: controller.updateSelectedGrade,
                      )),
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
                  Obx(() => CustomDropdown<String>(
                        hint: 'Class name',
                        value: controller.selectedClass.value,
                        items: DropdownHelper.createStringItems(
                            controller.classes),
                        onChanged: controller.updateSelectedClass,
                      )),
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
                      text: 'Student name',
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
                  Obx(() => CustomDropdown<Student>(
                        hint: 'Student name',
                        value: controller.walkInSelectedStudent.value,
                        items: controller.filteredStudentsForWalkIn
                            .map(
                              (student) => DropdownMenuItem<Student>(
                                value: student,
                                child: Text(student.name),
                              ),
                            )
                            .toList(),
                        onChanged: controller.updateWalkInSelectedStudent,
                      )),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSelectedStudentDisplay(CreateAppointmentController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Selected student',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 12),
        Obx(() {
          if (controller.walkInSelectedStudent.value == null) {
            return const SizedBox.shrink();
          }

          final student = controller.walkInSelectedStudent.value!;
          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                CircleAvatar(
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
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    student.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF374151),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => controller.removeWalkInSelectedStudent(),
                  icon: const Icon(
                    Icons.close,
                    size: 18,
                    color: Color(0xFF6B7280),
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildTypeSelector(CreateAppointmentController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Select appointment type'),
        const SizedBox(height: 8),
        Obx(() => Wrap(
              spacing: 8,
              runSpacing: 12,
              children: controller.appointmentTypes
                  .map((type) => AppointmentTypeCard(
                        label: type['label'],
                        icon: type['icon'],
                        isActive:
                            controller.selectedType.value == type['label'],
                        onTap: () =>
                            controller.updateSelectedType(type['label']),
                      ))
                  .toList(),
            )),
      ],
    );
  }

  Widget _buildCheckupDetails(CreateAppointmentController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Checkup details'),
        const SizedBox(height: 8),
        Obx(() => Row(
              children: [
                CustomRadioOption<String>(
                  value: 'all',
                  groupValue: controller.selectedOption.value,
                  label: 'All Students',
                  onChanged: (val) => controller.updateSelectedOption(val),
                ),
                const SizedBox(width: 16),
                CustomRadioOption<String>(
                  value: 'selected',
                  groupValue: controller.selectedOption.value,
                  label: 'Selected Diseases',
                  onChanged: (val) => controller.updateSelectedOption(val),
                ),
              ],
            )),
      ],
    );
  }

  Widget _buildDoctorSelection(CreateAppointmentController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Select Doctor'),
        const SizedBox(height: 8),
        Obx(() => CustomDropdown<String>(
              hint: 'Choose a doctor',
              value: controller.selectedDoctor.value,
              items: DropdownHelper.createStringItems(controller.doctors),
              onChanged: controller.updateSelectedDoctor,
            )),
      ],
    );
  }

  Widget _buildVaccinationTypeSelection(
      CreateAppointmentController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Vaccination Type'),
        const SizedBox(height: 8),
        Obx(() => CustomDropdown<String>(
              hint: 'Select vaccination type',
              value: controller.selectedVaccinationType.value,
              items:
                  DropdownHelper.createStringItems(controller.vaccinationTypes),
              onChanged: controller.updateSelectedVaccinationType,
            )),
      ],
    );
  }

  Widget _buildDateTimeSelection(CreateAppointmentController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Date & time'),
        const SizedBox(height: 8),
        Obx(() => Row(
              children: [
                CustomRadioOption<String>(
                  value: 'addDate',
                  groupValue: controller.selectedDateTimeOption.value,
                  label: 'Add date',
                  onChanged: (val) =>
                      controller.updateSelectedDateTimeOption(val),
                ),
                const SizedBox(width: 16),
                CustomRadioOption<String>(
                  value: 'startNow',
                  groupValue: controller.selectedDateTimeOption.value,
                  label: 'Start now',
                  onChanged: (val) =>
                      controller.updateSelectedDateTimeOption(val),
                ),
              ],
            )),
      ],
    );
  }

  Widget _buildDateTimePicker(CreateAppointmentController controller) {
    return Obx(() => CustomDateTimePickerRow(
          initialDate: controller.selectedDate.value,
          initialTime: controller.selectedTime.value,
          onDateChanged: controller.updateSelectedDate,
          onTimeChanged: controller.updateSelectedTime,
        ));
  }

  Widget _buildDiseaseDetails(CreateAppointmentController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Checkup details'),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Obx(() => CustomDropdown<String>(
                    hint: 'Disease',
                    value: controller.selectedDisease.value,
                    items:
                        DropdownHelper.createStringItems(controller.diseases),
                    onChanged: controller.updateSelectedDisease,
                  )),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Obx(() => CustomDropdown<String>(
                    hint: 'Disease type',
                    value: controller.selectedDiseaseType.value,
                    items: DropdownHelper.createStringItems(
                        controller.diseaseTypes),
                    onChanged: controller.updateSelectedDiseaseType,
                  )),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGradeClassDropdowns(CreateAppointmentController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Grades and students'),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Obx(() => CustomDropdown<String>(
                    hint: 'Grade',
                    value: controller.selectedGrade.value,
                    items: DropdownHelper.createStringItems(controller.grades),
                    onChanged: controller.updateSelectedGrade,
                  )),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Obx(() => CustomDropdown<String>(
                    hint: 'Class name',
                    value: controller.selectedClass.value,
                    items: DropdownHelper.createStringItems(controller.classes),
                    onChanged: controller.updateSelectedClass,
                  )),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Obx(() => CustomDropdown<String>(
                    hint: 'Doctor name',
                    value: controller.selectedDoctor.value,
                    items: DropdownHelper.createStringItems(controller.doctors),
                    onChanged: controller.updateSelectedDoctor,
                  )),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStudentMultiSelect(CreateAppointmentController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Students (Multi selection)'),
        const SizedBox(height: 8),
        Obx(() {
          final isAllStudents = controller.selectedOption.value == 'all';
          final selectedStudents = controller.selectedStudents;

          return Column(
            children: [
              // Multi-select input field
              _buildStudentMultiSelectField(controller, isAllStudents),

              // Selected students display (only if not "All students")
              if (!isAllStudents && selectedStudents.isNotEmpty) ...[
                const SizedBox(height: 12),
                _buildSelectedStudentsDisplay(selectedStudents, controller),
              ],
            ],
          );
        }),
      ],
    );
  }

  Widget _buildStudentMultiSelectField(
      CreateAppointmentController controller, bool isAllStudents) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE9E9E9),
          width: 1,
        ),
        color: const Color(0xFFFBFCFD),
      ),
      child: InkWell(
        onTap: () => _showStudentSelectionDialog(controller),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  isAllStudents ? 'All students' : 'Select Students',
                  style: TextStyle(
                    color: isAllStudents
                        ? const Color(0xFF374151)
                        : const Color(0xFF9CA3AF),
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              const Icon(
                Icons.keyboard_arrow_down,
                color: Color(0xFF1339FF),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedStudentsDisplay(
      List<Student> selectedStudents, CreateAppointmentController controller) {
    const displayLimit = 5;
    final shouldShowMore = selectedStudents.length > displayLimit;
    final studentsToShow = shouldShowMore
        ? selectedStudents.take(displayLimit).toList()
        : selectedStudents;
    final remainingCount = selectedStudents.length - displayLimit;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      runAlignment: WrapAlignment.start,
      alignment: WrapAlignment.start,
      crossAxisAlignment: WrapCrossAlignment.start,
      children: [
        // Show individual student chips
        ...studentsToShow
            .map((student) => _buildStudentChip(student, controller)),

        // Show "+N" chip if there are more than 5 students
        if (shouldShowMore) _buildMoreStudentsChip(remainingCount),
      ],
    );
  }

  Widget _buildStudentChip(
      Student student, CreateAppointmentController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Student avatar
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
          // Student name
          Text(
            student.name,
            style: const TextStyle(
              color: Color(0xFF374151),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 8),
          // Remove button
          GestureDetector(
            onTap: () => _removeStudent(controller, student),
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

  Widget _buildMoreStudentsChip(int remainingCount) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
          width: 1,
        ),
      ),
      child: Text(
        '+$remainingCount',
        style: const TextStyle(
          color: Color(0xFF374151),
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  void _showStudentSelectionDialog(CreateAppointmentController controller) {
    showDialog(
      context: Get.context!,
      builder: (context) => _StudentSelectionDialog(
        students: controller.students,
        selectedStudents: controller.selectedStudents,
        onSelectionChanged: (selectedStudents) {
          controller.updateSelectedStudents(selectedStudents);
        },
      ),
    );
  }

  void _removeStudent(CreateAppointmentController controller, Student student) {
    final currentStudents = List<Student>.from(controller.selectedStudents);
    currentStudents.removeWhere((s) => s.id == student.id);
    controller.updateSelectedStudents(currentStudents);
  }

  Widget _buildActionButtons(CreateAppointmentController controller) {
    return Row(
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
          child: Obx(() => ElevatedButton(
                onPressed: controller.selectedType.value == 'Walk-In'
                    ? controller.handleStartWalkInAppointment
                    : controller.handleCreateAppointment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  controller.selectedType.value == 'Walk-In'
                      ? 'Start appointment'
                      : 'Create',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              )),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Color(0xFF747677),
        fontSize: 16,
        fontWeight: FontWeight.w500,
        height: 1.50,
        letterSpacing: 0.16,
      ),
    );
  }

  String _getInitials(String name) {
    final words = name.split(' ');
    if (words.length >= 2) {
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    } else if (words.isNotEmpty) {
      return words[0].substring(0, 1).toUpperCase();
    }
    return 'U';
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
  State<_StudentSelectionDialog> createState() =>
      _StudentSelectionDialogState();
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
            .where((student) => student.name
                .toLowerCase()
                .contains(_searchController.text.toLowerCase()))
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

  void _selectAll() {
    setState(() {
      _selectedStudents = List<Student>.from(_filteredStudents);
    });
  }

  void _clearAll() {
    setState(() {
      _selectedStudents.clear();
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
            // Header
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

            // Search field
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

            // Action buttons
            Row(
              children: [
                TextButton(
                  onPressed: _selectAll,
                  child: const Text('Select All'),
                ),
                const SizedBox(width: 16),
                TextButton(
                  onPressed: _clearAll,
                  child: const Text('Clear All'),
                ),
                const Spacer(),
                Text(
                  '${_selectedStudents.length} selected',
                  style: const TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Students list
            Expanded(
              child: ListView.builder(
                itemCount: _filteredStudents.length,
                itemBuilder: (context, index) {
                  final student = _filteredStudents[index];
                  final isSelected =
                      _selectedStudents.any((s) => s.id == student.id);

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
                      activeColor: const Color(0xFF1339FF),
                    ),
                    onTap: () => _toggleStudent(student),
                  );
                },
              ),
            ),

            // Bottom buttons
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
                      backgroundColor: const Color(0xFF1339FF),
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
    } else if (words.isNotEmpty) {
      return words[0].substring(0, 1).toUpperCase();
    }
    return 'U';
  }
}
