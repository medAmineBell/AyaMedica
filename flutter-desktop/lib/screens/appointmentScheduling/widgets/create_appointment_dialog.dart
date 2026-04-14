import 'package:flutter/material.dart';
import 'package:flutter_getx_app/controllers/create_appointment_controller.dart';
import 'package:flutter_getx_app/models/student.dart';
import 'package:flutter_getx_app/screens/appointmentScheduling/widgets/custom_radio_option_widget.dart';
import 'package:get/get.dart';
import 'appointment_type_card_widget.dart';
import 'custom_dropdown.dart';
import 'date_time_picker_row_widget.dart';

class CreateAppointmentDialog extends StatefulWidget {
  const CreateAppointmentDialog({super.key});

  @override
  State<CreateAppointmentDialog> createState() =>
      _CreateAppointmentDialogState();
}

class _CreateAppointmentDialogState extends State<CreateAppointmentDialog> {
  final LayerLink _searchLayerLink = LayerLink();
  OverlayEntry? _searchOverlayEntry;

  @override
  void dispose() {
    _searchWorker?.dispose();
    _removeSearchOverlay();
    super.dispose();
  }

  void _removeSearchOverlay() {
    _searchOverlayEntry?.remove();
    _searchOverlayEntry = null;
  }

  void _updateSearchOverlay(CreateAppointmentController controller) {
    _removeSearchOverlay();
    if (controller.searchResults.isEmpty) return;

    _searchOverlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          // Full-screen tap catcher to dismiss
          Positioned.fill(
            child: GestureDetector(
              onTap: _removeSearchOverlay,
              behavior: HitTestBehavior.opaque,
              child: const SizedBox.expand(),
            ),
          ),
          Positioned(
        width: _searchLayerLink.leaderSize?.width ?? 0,
        child: CompositedTransformFollower(
          link: _searchLayerLink,
          offset: const Offset(0, 56),
          showWhenUnlinked: false,
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(8),
            color: Colors.white,
            child: Container(
              constraints: const BoxConstraints(maxHeight: 200),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: ListView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: controller.searchResults.length,
                itemBuilder: (context, index) {
                  final student = controller.searchResults[index];
                  return InkWell(
                    onTap: () {
                      controller.selectStudentFromSearch(student);
                      _removeSearchOverlay();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        border: index < controller.searchResults.length - 1
                            ? const Border(
                                bottom:
                                    BorderSide(color: Color(0xFFF3F4F6)))
                            : null,
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 14,
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
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  student.name,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF374151),
                                  ),
                                ),
                                if (student.aid != null &&
                                    student.aid!.isNotEmpty)
                                  Text(
                                    student.aid!,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF9CA3AF),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
        ],
      ),
    );
    Overlay.of(context).insert(_searchOverlayEntry!);
  }

  Worker? _searchWorker;

  void _setupSearchListener(CreateAppointmentController controller) {
    _searchWorker?.dispose();
    _searchWorker = ever(controller.searchResults, (_) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _updateSearchOverlay(controller);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    Get.delete<CreateAppointmentController>(force: true);
    final controller = Get.put(CreateAppointmentController());
    _setupSearchListener(controller);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(24),
        width: MediaQuery.of(context).size.width * 0.4,
        height: MediaQuery.of(context).size.height * 0.9,
        child: Form(
          key: controller.formKey,
          child: Column(
            children: [
              // Fixed Header
              _buildHeader(controller),
              const SizedBox(height: 4),
              // Subtitle for all types
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Add appointments details and students',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Scrollable Content
              Expanded(
                child: SingleChildScrollView(
                  child: Obx(() {
                    switch (controller.selectedType.value) {
                      case 'Walk-In':
                        return _buildWalkInContent(controller);
                      case 'Follow-Up':
                        return _buildFollowUpContent(controller);
                      case 'Vaccination':
                        return _buildVaccinationContent(controller);
                      case 'Checkup':
                      default:
                        return _buildCheckupContent(controller);
                    }
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

  // ─── HEADER ────────────────────────────────────────────────────────────

  Widget _buildHeader(CreateAppointmentController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'New appointment',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        ),
        IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.close),
        ),
      ],
    );
  }

  // ─── CHECKUP CONTENT ──────────────────────────────────────────────────

  Widget _buildCheckupContent(CreateAppointmentController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTypeSelector(controller),
        const SizedBox(height: 16),
        _buildDateTimeSelection(controller),
        const SizedBox(height: 16),
        // Date/Time picker (conditional)
        Obx(() => controller.selectedDateTimeOption.value == 'addDate'
            ? Column(
                children: [
                  _buildLabeledDateTimePicker(
                    date: controller.selectedDate.value,
                    time: controller.selectedTime.value,
                    onDateChanged: controller.updateSelectedDate,
                    onTimeChanged: controller.updateSelectedTime,
                  ),
                  const SizedBox(height: 16),
                ],
              )
            : const SizedBox.shrink()),
        // Checkup details: Disease (searchable)
        _buildSectionTitle('Checkup details'),
        const SizedBox(height: 8),
        _buildSearchableDisease(controller),
        const SizedBox(height: 16),
        // Doctor(s) - full width
        Obx(() => _buildLabeledDropdown<String>(
          label: 'Doctor(s)',
          hint: 'Doctor name goes here',
          value: controller.selectedDoctor.value,
          items: DropdownHelper.createStringItems(controller.doctors),
          onChanged: controller.updateSelectedDoctor,
        )),
        const SizedBox(height: 16),
        // Grades and students
        _buildGradeClassRow(controller),
        const SizedBox(height: 16),
        // Students multi-select (only show when class is selected)
        Obx(() => controller.selectedClass.value != null
            ? _buildStudentMultiSelect(controller)
            : const SizedBox.shrink()),
      ],
    );
  }

  // ─── FOLLOW-UP CONTENT ────────────────────────────────────────────────

  Widget _buildFollowUpContent(CreateAppointmentController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTypeSelector(controller),
        const SizedBox(height: 16),
        _buildDateTimeSelection(controller),
        const SizedBox(height: 16),
        // Date/Time picker (conditional)
        Obx(() => controller.selectedDateTimeOption.value == 'addDate'
            ? Column(
                children: [
                  _buildLabeledDateTimePicker(
                    date: controller.selectedDate.value,
                    time: controller.selectedTime.value,
                    onDateChanged: controller.updateSelectedDate,
                    onTimeChanged: controller.updateSelectedTime,
                  ),
                  const SizedBox(height: 16),
                ],
              )
            : const SizedBox.shrink()),
        // Follow up details: Disease (searchable)
        _buildSectionTitle('Follow up details'),
        const SizedBox(height: 8),
        _buildSearchableDisease(controller),
        const SizedBox(height: 16),
        // Doctor(s) - full width
        Obx(() => _buildLabeledDropdown<String>(
          label: 'Doctor(s)',
          hint: 'Doctor name goes here',
          value: controller.selectedDoctor.value,
          items: DropdownHelper.createStringItems(controller.doctors),
          onChanged: controller.updateSelectedDoctor,
        )),
        const SizedBox(height: 16),
        // Grades and students
        _buildGradeClassRow(controller),
        const SizedBox(height: 16),
        // Students multi-select (only show when class is selected)
        Obx(() => controller.selectedClass.value != null
            ? _buildStudentMultiSelect(controller)
            : const SizedBox.shrink()),
      ],
    );
  }

  // ─── VACCINATION CONTENT ──────────────────────────────────────────────

  Widget _buildVaccinationContent(CreateAppointmentController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTypeSelector(controller),
        const SizedBox(height: 16),
        _buildCheckupDetailsRadio(controller),
        const SizedBox(height: 16),
        _buildDateTimeSelection(controller),
        const SizedBox(height: 16),
        // Date/Time picker (conditional)
        Obx(() => controller.selectedDateTimeOption.value == 'addDate'
            ? Column(
                children: [
                  _buildLabeledDateTimePicker(
                    date: controller.selectedDate.value,
                    time: controller.selectedTime.value,
                    onDateChanged: controller.updateSelectedDate,
                    onTimeChanged: controller.updateSelectedTime,
                  ),
                  const SizedBox(height: 16),
                ],
              )
            : const SizedBox.shrink()),
        // Last confirmation date
        _buildSectionTitle('Last confirmation date'),
        const SizedBox(height: 8),
        _buildLabeledDateTimePicker(
          date: controller.lastConfirmationDate.value,
          time: controller.lastConfirmationTime.value,
          onDateChanged: controller.updateLastConfirmationDate,
          onTimeChanged: controller.updateLastConfirmationTime,
        ),
        const SizedBox(height: 16),
        // Checkup details: Doctor + Vaccination type
        _buildSectionTitle('Checkup details'),
        const SizedBox(height: 8),
        Obx(() => _buildLabeledDropdown<String>(
          label: 'Doctor',
          hint: 'Doctor name goes here',
          value: controller.selectedDoctor.value,
          items: DropdownHelper.createStringItems(controller.doctors),
          onChanged: controller.updateSelectedDoctor,
        )),
        const SizedBox(height: 16),
        _buildSearchableVaccination(controller),
        const SizedBox(height: 16),
        // Grades and students
        _buildGradeClassRow(controller),
        const SizedBox(height: 16),
        // Students multi-select (only show when class is selected)
        Obx(() => controller.selectedClass.value != null
            ? _buildStudentMultiSelect(controller)
            : const SizedBox.shrink()),
      ],
    );
  }

  // ─── WALK-IN CONTENT ──────────────────────────────────────────────────

  Widget _buildWalkInContent(CreateAppointmentController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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

  // ─── SHARED BUILDERS ──────────────────────────────────────────────────

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
                  .map((type) {
                    final isDisabled = type['label'] == 'Vaccination';
                    return Opacity(
                      opacity: isDisabled ? 0.4 : 1.0,
                      child: AppointmentTypeCard(
                        label: type['label'],
                        icon: type['icon'],
                        isActive:
                            controller.selectedType.value == type['label'],
                        onTap: isDisabled
                            ? () {}
                            : () => controller.updateSelectedType(type['label']),
                      ),
                    );
                  })
                  .toList(),
            )),
      ],
    );
  }

  Widget _buildCheckupDetailsRadio(CreateAppointmentController controller) {
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
                  label: 'All students',
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

  Widget _buildGradeClassRow(CreateAppointmentController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Grades and students'),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Obx(() => _buildLabeledDropdown<String>(
                    label: 'Grade',
                    hint: 'Grade',
                    value: controller.selectedGrade.value,
                    items: DropdownHelper.createStringItems(controller.grades),
                    onChanged: controller.updateSelectedGrade,
                  )),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Obx(() => _buildLabeledDropdown<String>(
                    label: 'Class',
                    hint: 'Class name',
                    value: controller.selectedClass.value,
                    items: DropdownHelper.createStringItems(controller.classes),
                    onChanged: controller.updateSelectedClass,
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
        _buildFieldLabel('Students (Multi selection)'),
        const SizedBox(height: 8),
        Obx(() {
          final isAllStudents = controller.selectedOption.value == 'all';
          final selectedStudents = controller.selectedStudents;

          return Column(
            children: [
              // Multi-select input field
              _buildStudentMultiSelectField(controller, isAllStudents),

              // Selected students display
              if (selectedStudents.isNotEmpty) ...[
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
          child: Obx(() => Row(
            children: [
              Expanded(
                child: controller.isLoadingStudents.value
                    ? Row(
                        children: const [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          SizedBox(width: 8),
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
                    : Text(
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
          )),
        ),
      ),
    );
  }

  Widget _buildSelectedStudentsDisplay(
      List<Student> selectedStudents, CreateAppointmentController controller) {
    const displayLimit = 3;
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
        ...studentsToShow
            .map((student) => _buildStudentChip(student, controller)),
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

  // ─── WALK-IN SPECIFIC ─────────────────────────────────────────────────

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

        // Student name search
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFieldLabel('Student name'),
            const SizedBox(height: 8),
            CompositedTransformTarget(
              link: _searchLayerLink,
              child: TextFormField(
                controller: controller.aidController,
                decoration: InputDecoration(
                  hintText: 'Search by name',
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
                onChanged: controller.searchByName,
              ),
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

        // Grade, Class, Student dropdowns - step by step
        Row(
          children: [
            Expanded(
              child: Obx(() => _buildLabeledDropdown<String>(
                    label: 'Grade',
                    hint: 'Grade',
                    value: controller.selectedGrade.value,
                    items: DropdownHelper.createStringItems(controller.grades),
                    onChanged: controller.updateSelectedGrade,
                  )),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Obx(() => _buildLabeledDropdown<String>(
                    label: 'Class',
                    hint: 'Class name',
                    value: controller.selectedClass.value,
                    items: controller.selectedGrade.value != null
                        ? DropdownHelper.createStringItems(controller.classes)
                        : [],
                    onChanged: controller.selectedGrade.value != null
                        ? controller.updateSelectedClass
                        : (_) {},
                  )),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Obx(() => _buildLabeledDropdown<Student>(
                    label: 'Student name',
                    hint: 'Student name',
                    value: controller.walkInSelectedStudent.value,
                    items: controller.selectedClass.value != null
                        ? controller.filteredStudentsForWalkIn
                            .map(
                              (student) => DropdownMenuItem<Student>(
                                value: student,
                                child: Text(student.name),
                              ),
                            )
                            .toList()
                        : [],
                    onChanged: controller.selectedClass.value != null
                        ? controller.updateWalkInSelectedStudent
                        : (_) {},
                  )),
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

  // ─── HELPER WIDGETS ───────────────────────────────────────────────────

  Widget _buildFieldLabel(String label, {bool required = true}) {
    return RichText(
      text: TextSpan(
        text: label,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Color(0xFF374151),
        ),
        children: required
            ? [
                const TextSpan(
                  text: '*',
                  style: TextStyle(color: Color(0xFFDC2626)),
                ),
              ]
            : [],
      ),
    );
  }

  Widget _buildSearchableDisease(CreateAppointmentController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text.rich(
          TextSpan(children: [
            TextSpan(
              text: 'Disease',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF374151)),
            ),
            TextSpan(text: '*', style: TextStyle(color: Colors.red)),
          ]),
        ),
        const SizedBox(height: 6),
        Obx(() => CustomDropdown<String>(
              hint: 'Select disease',
              value: CreateAppointmentController.predefinedDiseases
                      .contains(controller.selectedDisease.value)
                  ? controller.selectedDisease.value
                  : null,
              items: DropdownHelper.createStringItems(
                  CreateAppointmentController.predefinedDiseases),
              onChanged: (value) => controller.updateSelectedDisease(value),
            )),
        Obx(() {
          if (controller.selectedDisease.value != 'General') {
            return const SizedBox.shrink();
          }
          return Padding(
            padding: const EdgeInsets.only(top: 8),
            child: TextFormField(
              controller: controller.otherDiseaseController,
              onChanged: (value) => controller.otherDiseaseText.value = value,
              decoration: InputDecoration(
                hintText: 'Other...',
                hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
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
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildSearchableVaccination(CreateAppointmentController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text.rich(
          TextSpan(children: [
            TextSpan(
              text: 'Vaccination type',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF374151)),
            ),
            TextSpan(text: '*', style: TextStyle(color: Colors.red)),
          ]),
        ),
        const SizedBox(height: 6),
        Autocomplete<String>(
          optionsBuilder: (TextEditingValue textEditingValue) {
            controller.fetchVaccinations(textEditingValue.text);
            if (textEditingValue.text.isEmpty) {
              return controller.vaccinationTypes;
            }
            return controller.vaccinationTypes.where((v) =>
                v.toLowerCase().contains(textEditingValue.text.toLowerCase()));
          },
          onSelected: (String selection) {
            controller.updateSelectedVaccinationType(selection);
          },
          fieldViewBuilder: (context, textController, focusNode, onFieldSubmitted) {
            return TextFormField(
              controller: textController,
              focusNode: focusNode,
              decoration: InputDecoration(
                hintText: 'Search vaccination type...',
                hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
                prefixIcon: const Icon(Icons.search, color: Color(0xFF9CA3AF), size: 20),
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
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              ),
            );
          },
          optionsViewBuilder: (context, onSelected, options) {
            return Align(
              alignment: Alignment.topLeft,
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(8),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 200, maxWidth: 400),
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemCount: options.length,
                    itemBuilder: (context, index) {
                      final option = options.elementAt(index);
                      return InkWell(
                        onTap: () => onSelected(option),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          child: Text(option, style: const TextStyle(fontSize: 14)),
                        ),
                      );
                    },
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildLabeledDropdown<T>({
    required String label,
    required String hint,
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel(label),
        const SizedBox(height: 8),
        CustomDropdown<T>(
          hint: hint,
          value: value,
          items: items,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildLabeledDateTimePicker({
    required DateTime? date,
    required TimeOfDay? time,
    required ValueChanged<DateTime?> onDateChanged,
    required ValueChanged<TimeOfDay?> onTimeChanged,
  }) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFieldLabel('Date'),
              const SizedBox(height: 8),
              CustomDateTimePickerRow(
                initialDate: date,
                initialTime: time,
                onDateChanged: onDateChanged,
                onTimeChanged: onTimeChanged,
              ),
            ],
          ),
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

  // ─── ACTION BUTTONS ───────────────────────────────────────────────────

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
          child: Obx(() {
            final isValid = controller.selectedType.value == 'Walk-In'
                ? true
                : controller.isFormValid;

            return ElevatedButton(
              onPressed: isValid
                  ? (controller.selectedType.value == 'Walk-In'
                      ? controller.handleStartWalkInAppointment
                      : controller.handleCreateAppointment)
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                disabledBackgroundColor: const Color(0xFF2563EB).withAlpha(100),
                disabledForegroundColor: Colors.white70,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: Text(
                controller.actionButtonText,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  // ─── DIALOGS ──────────────────────────────────────────────────────────

  void _showStudentSelectionDialog(CreateAppointmentController controller) {
    showDialog(
      context: Get.context!,
      builder: (context) => Obx(() => _StudentSelectionDialog(
        students: controller.students,
        selectedStudents: controller.selectedStudents,
        isLoading: controller.isLoadingStudents.value,
        onSelectionChanged: (selectedStudents) {
          controller.updateSelectedStudents(selectedStudents);
        },
      )),
    );
  }

  void _removeStudent(CreateAppointmentController controller, Student student) {
    final currentStudents = List<Student>.from(controller.selectedStudents);
    currentStudents.removeWhere((s) => s.id == student.id);
    controller.updateSelectedStudents(currentStudents);
  }

  // ─── UTILS ────────────────────────────────────────────────────────────

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

// ─── STUDENT SELECTION DIALOG ─────────────────────────────────────────────

class _StudentSelectionDialog extends StatefulWidget {
  final List<Student> students;
  final List<Student> selectedStudents;
  final Function(List<Student>) onSelectionChanged;
  final bool isLoading;

  const _StudentSelectionDialog({
    required this.students,
    required this.selectedStudents,
    required this.onSelectionChanged,
    this.isLoading = false,
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
    _filteredStudents = List<Student>.from(widget.students);
    _searchController.addListener(_filterStudents);
  }

  @override
  void didUpdateWidget(covariant _StudentSelectionDialog oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.students != widget.students) {
      _filterStudents();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterStudents() {
    setState(() {
      final allStudents = List<Student>.from(widget.students);
      if (_searchController.text.isEmpty) {
        _filteredStudents = allStudents;
      } else {
        _filteredStudents = allStudents
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
              child: widget.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredStudents.isEmpty
                      ? const Center(
                          child: Text(
                            'No students found',
                            style: TextStyle(color: Color(0xFF9CA3AF)),
                          ),
                        )
                      : ListView.builder(
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
