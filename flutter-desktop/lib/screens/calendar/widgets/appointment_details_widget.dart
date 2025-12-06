import 'package:flutter/material.dart';
import 'package:flutter_getx_app/controllers/appointment_details_controller.dart';
import 'package:flutter_getx_app/controllers/calendar_controller.dart';
import 'package:flutter_getx_app/models/appointment.dart';
import 'package:flutter_getx_app/models/student.dart';
import 'package:flutter_getx_app/screens/appointmentScheduling/widgets/custom_dropdown.dart';
import 'package:get/get.dart';

class AppointmentDetailsWidget extends StatelessWidget {
  final Appointment appointment;

  const AppointmentDetailsWidget({
    Key? key,
    required this.appointment,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final detailsController = Get.put(AppointmentDetailsController(appointment: appointment));
    final calendarController = Get.find<CalendarController>();

    return Column(
      children: [
        // Header
        _buildHeader(detailsController, calendarController),
        
        // Search and Filters
        _buildSearchAndFilters(detailsController),
        
        // Table
        Expanded(
          child: _buildTable(detailsController),
        ),
      ],
    );
  }

  Widget _buildHeader(AppointmentDetailsController controller, CalendarController calendarController) {
    final displayName = appointment.allStudents
        ? '${appointment.className} | ${appointment.grade}'
        : appointment.selectedStudents.isNotEmpty
            ? appointment.selectedStudents.first.name
            : '${appointment.className} | ${appointment.grade}';

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => calendarController.hideAppointmentDetails(),
          ),
          const SizedBox(width: 12),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF0066FF),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                _getInitials(displayName),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${appointment.diseaseType} | ${appointment.type}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: controller.completeAppointment,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0066FF),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Complete Appointment',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters(AppointmentDetailsController controller) {
    return Container(
      padding: const EdgeInsets.all(24),
      color: Colors.white,
      child: Column(
        children: [
          Row(
            children: [
              // Search bar
              Expanded(
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
                        child: Icon(Icons.search, color: Colors.grey[600], size: 20),
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Filter tabs
              Obx(() => Wrap(
                spacing: 8,
                children: [
                  _buildFilterTab(controller, 'All', controller.allCount, controller.selectedFilter.value == 'All'),
                  _buildFilterTab(controller, 'Normal', controller.normalCount, controller.selectedFilter.value == 'Normal', color: const Color(0xFF10B981)),
                  _buildFilterTab(controller, 'Overweight', controller.overweightCount, controller.selectedFilter.value == 'Overweight', color: const Color(0xFFF59E0B)),
                  _buildFilterTab(controller, 'Obesity', controller.obesityCount, controller.selectedFilter.value == 'Obesity', color: const Color(0xFFEC4899)),
                  _buildFilterTab(controller, 'Underweight', controller.underweightCount, controller.selectedFilter.value == 'Underweight', color: const Color(0xFFEF4444)),
                  _buildFilterTab(controller, 'Absent', controller.absentCount, controller.selectedFilter.value == 'Absent', color: Colors.grey),
                ],
              )),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTab(AppointmentDetailsController controller, String label, int count, bool isSelected, {Color? color}) {
    final bgColor = isSelected 
        ? (color ?? const Color(0xFF0066FF))
        : Colors.transparent;
    final textColor = isSelected ? Colors.white : (color ?? const Color(0xFF6B7280));
    final borderColor = isSelected ? Colors.transparent : (color ?? const Color(0xFFE5E7EB));

    return InkWell(
      onTap: () => controller.setFilter(label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$count',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTable(AppointmentDetailsController controller) {
    return Obx(() {
      final filteredStudents = controller.filteredStudents;

      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
        ),
        child: Column(
          children: [
            // Table Header
            _buildTableHeader(),
            // Table Rows
            Expanded(
              child: filteredStudents.isEmpty
                  ? Center(
                      child: Text(
                        'No students found',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: filteredStudents.length,
                      itemBuilder: (context, index) {
                        return _buildStudentRow(controller, filteredStudents[index], index);
                      },
                    ),
            ),
          ],
        ),
      );
    });
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
          Expanded(flex: 2, child: _buildHeaderCell('Student full name')),
          Expanded(flex: 1, child: _buildHeaderCell('Presence')),
          Expanded(flex: 1, child: _buildHeaderCell('Height (CM)')),
          Expanded(flex: 1, child: _buildHeaderCell('Weight (Kg)')),
          Expanded(flex: 2, child: _buildHeaderCell('Note (Optional)')),
          Expanded(flex: 1, child: _buildHeaderCell('BMI Result')),
        ],
      ),
    );
  }

  Widget _buildHeaderCell(String text) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
          ),
        ),
      ),
    );
  }

  Widget _buildStudentRow(AppointmentDetailsController controller, StudentAppointmentData data, int index) {
    final isAbsent = data.presence == PresenceStatus.absent;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
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
              child: _buildStudentNameCell(data.student),
            ),
          ),
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: _buildPresenceDropdown(controller, data, index),
            ),
          ),
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: _buildHeightField(controller, data, index, isAbsent),
            ),
          ),
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: _buildWeightField(controller, data, index, isAbsent),
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: _buildNoteField(controller, data, index, isAbsent),
            ),
          ),
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Center(
                child: _buildBMICell(data),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentNameCell(Student student) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFF0066FF),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              _getInitials(student.name),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                student.name,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                student.studentId ?? 'AID number',
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

  Widget _buildPresenceDropdown(AppointmentDetailsController controller, StudentAppointmentData data, int index) {
    return CustomDropdown<String>(
      hint: 'Presence',
      value: data.presence == PresenceStatus.present ? 'Present' : 'Absent',
      items: const [
        DropdownMenuItem(value: 'Present', child: Text('Present')),
        DropdownMenuItem(value: 'Absent', child: Text('Absent')),
      ],
      onChanged: (value) {
        if (value == 'Present') {
          controller.updatePresence(index, PresenceStatus.present);
        } else if (value == 'Absent') {
          controller.updatePresence(index, PresenceStatus.absent);
        }
      },
    );
  }

  Widget _buildHeightField(AppointmentDetailsController controller, StudentAppointmentData data, int index, bool isAbsent) {
    return TextField(
      enabled: !isAbsent,
      textAlign: TextAlign.center,
      controller: TextEditingController(
        text: data.height?.toStringAsFixed(0) ?? '',
      )..selection = TextSelection.collapsed(offset: data.height?.toStringAsFixed(0).length ?? 0),
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        hintText: 'Height',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF0066FF)),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        filled: true,
        fillColor: isAbsent ? Colors.grey[100] : Colors.white,
      ),
      onChanged: (value) => controller.updateHeight(index, value),
    );
  }

  Widget _buildWeightField(AppointmentDetailsController controller, StudentAppointmentData data, int index, bool isAbsent) {
    return TextField(
      enabled: !isAbsent,
      textAlign: TextAlign.center,
      controller: TextEditingController(
        text: data.weight?.toStringAsFixed(1) ?? '',
      )..selection = TextSelection.collapsed(offset: data.weight?.toStringAsFixed(1).length ?? 0),
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        hintText: 'Weight',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF0066FF)),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        filled: true,
        fillColor: isAbsent ? Colors.grey[100] : Colors.white,
      ),
      onChanged: (value) => controller.updateWeight(index, value),
    );
  }

  Widget _buildNoteField(AppointmentDetailsController controller, StudentAppointmentData data, int index, bool isAbsent) {
    return TextField(
      enabled: !isAbsent,
      textAlign: TextAlign.center,
      controller: TextEditingController(text: data.note)
        ..selection = TextSelection.collapsed(offset: data.note.length),
      decoration: InputDecoration(
        hintText: 'Doctor note goes here',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF0066FF)),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        filled: true,
        fillColor: isAbsent ? Colors.grey[100] : Colors.white,
      ),
      onChanged: (value) => controller.updateNote(index, value),
    );
  }

  Widget _buildBMICell(StudentAppointmentData data) {
    if (data.presence == PresenceStatus.absent) {
      return const Text(
        'Absent',
        style: TextStyle(
          fontSize: 14,
          color: Color(0xFF6B7280),
        ),
      );
    }

    if (data.bmiValue == null || data.bmiCategory == null) {
      return const Text(
        '--',
        style: TextStyle(
          fontSize: 14,
          color: Color(0xFF9CA3AF),
        ),
      );
    }

    String categoryText;
    Color backgroundColor;
    Color textColor;

    switch (data.bmiCategory!) {
      case BMICategory.normal:
        categoryText = 'Normal';
        backgroundColor = const Color(0xFF10B981);
        textColor = Colors.white;
        break;
      case BMICategory.overweight:
        categoryText = 'Overweight';
        backgroundColor = const Color(0xFFF59E0B);
        textColor = Colors.white;
        break;
      case BMICategory.obesity:
        categoryText = 'Obesity';
        backgroundColor = const Color(0xFFEC4899);
        textColor = Colors.white;
        break;
      case BMICategory.underweight:
        categoryText = 'Underweight';
        backgroundColor = const Color(0xFFEF4444);
        textColor = Colors.white;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        'BMI = ${data.bmiValue!.toStringAsFixed(0)} ($categoryText)',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }
}

