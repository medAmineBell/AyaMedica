import 'package:flutter/material.dart';
import 'package:flutter_getx_app/models/chronic_disease.dart';
import 'package:flutter_getx_app/models/student.dart';
import 'package:flutter_getx_app/theme/app_theme.dart';
import 'package:get/get.dart';

class ChronicDiseaseTable extends StatelessWidget {
  final List<Student> students;
  final String? selectedDisease;

  const ChronicDiseaseTable({
    Key? key,
    required this.students,
    this.selectedDisease,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Filter students who have chronic diseases
    final studentsWithDiseases = students
        .where((student) => student.chronicDiseases?.isNotEmpty == true)
        .toList();

    if (studentsWithDiseases.isEmpty) {
      return _buildEmptyState();
    }

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
          // Header
          _buildHeader(),
          // Table content
          _buildTableContent(studentsWithDiseases),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: 400,
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
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.medical_services_outlined,
              size: 64,
              color: AppTheme.colorPalette['neutral']!['60']!,
            ),
            const SizedBox(height: 24),
            Text(
              'No chronic diseases found',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppTheme.colorPalette['neutral']!['80']!,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Students with chronic diseases will appear here',
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.colorPalette['neutral']!['60']!,
              ),
            ),
          ],
        ),
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
          // Title and search row
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Chronic Diseases Management',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.colorPalette['neutral']!['90']!,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Monitor and manage student chronic conditions',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppTheme.colorPalette['neutral']!['60']!,
                      ),
                    ),
                  ],
                ),
              ),
              // Complete Appointment button
              ElevatedButton.icon(
                onPressed: () => _showCompleteAppointmentDialog(),
                icon: Icon(
                  Icons.check_circle,
                  size: 20,
                  color: Colors.white,
                ),
                label: Text(
                  'Complete Appointment',
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
          // Status count badges row
          Row(
            children: [
              Container(
                width: 300,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: AppTheme.colorPalette['neutral']!['30']!),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 16),
                    Icon(
                      Icons.search,
                      size: 20,
                      color: AppTheme.colorPalette['neutral']!['60']!,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search by student name or disease...',
                          hintStyle: TextStyle(
                            color: AppTheme.colorPalette['neutral']!['60']!,
                            fontSize: 14,
                          ),
                          border: InputBorder.none,
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Spacer(),
              // Done badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.check_outlined,
                          size: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${_getDoneCount()}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Done',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // Not Done badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.close_outlined,
                          size: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${_getNotDoneCount()}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Not Done',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.red,
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

  Widget _buildTableContent(List<Student> studentsWithDiseases) {
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
                  label: Text('Student Full Name'),
                ),
                DataColumn(
                  label: Text('Disease'),
                ),
                DataColumn(
                  label: Text('Blood Glucose'),
                ),
                DataColumn(
                  label: Text('Medication'),
                ),
                DataColumn(
                  label: Text('Dose'),
                ),
              ],
              rows: _buildTableRows(studentsWithDiseases),
            ),
          ),
        );
      },
    );
  }

  List<DataRow> _buildTableRows(List<Student> studentsWithDiseases) {
    List<DataRow> rows = [];

    for (final student in studentsWithDiseases) {
      if (student.chronicDiseases != null) {
        for (final disease in student.chronicDiseases!) {
          rows.add(DataRow(
            cells: [
              // Student full name
              DataCell(
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: student.avatarColor,
                      child: Text(
                        student.initials,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            student.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            '${student.grade ?? 'N/A'} - ${student.className ?? 'N/A'}',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppTheme.colorPalette['neutral']!['60']!,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Disease name
              DataCell(
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: disease.severityColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: disease.severityColor),
                  ),
                  child: Text(
                    disease.name,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: disease.severityColor,
                    ),
                  ),
                ),
              ),
              // Blood glucose
              DataCell(
                Container(
                  width: 120,
                  height: 40,
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: AppTheme.colorPalette['neutral']!['30']!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: '120',
                      hintStyle: TextStyle(
                        color: AppTheme.colorPalette['neutral']!['60']!,
                        fontSize: 14,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      suffixText: 'mg/dL',
                      suffixStyle: TextStyle(
                        color: AppTheme.colorPalette['neutral']!['60']!,
                        fontSize: 12,
                      ),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ),
              // Medication
              DataCell(
                ElevatedButton(
                  onPressed: () => _showMedicationDialog(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.colorPalette['info']!['main']!,
                    foregroundColor: Colors.white,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Medication',
                    style: TextStyle(fontSize: 14),
                  ),
                ),
              ),
              // Dose
              DataCell(
                Row(
                  children: [
                    Container(
                      width: 80,
                      height: 40,
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: AppTheme.colorPalette['neutral']!['30']!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: '12',
                          hintStyle: TextStyle(
                            color: AppTheme.colorPalette['neutral']!['60']!,
                            fontSize: 14,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 8),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      height: 40,
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: AppTheme.colorPalette['neutral']!['30']!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButton<String>(
                        value: 'mg',
                        underline: Container(),
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        items: const [
                          DropdownMenuItem(value: 'mg', child: Text('mg')),
                          DropdownMenuItem(value: 'g', child: Text('g')),
                          DropdownMenuItem(value: 'ml', child: Text('ml')),
                          DropdownMenuItem(
                              value: 'units', child: Text('units')),
                        ],
                        onChanged: (value) {},
                      ),
                    ),
                  ],
                ),
              ),
              // Status
              // DataCell(
              //   Container(
              //     padding:
              //         const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              //     decoration: BoxDecoration(
              //       color: disease.isActive
              //           ? Colors.green.withOpacity(0.1)
              //           : Colors.grey.withOpacity(0.1),
              //       borderRadius: BorderRadius.circular(8),
              //       border: Border.all(
              //         color: disease.isActive ? Colors.green : Colors.grey,
              //       ),
              //     ),
              //     child: Text(
              //       disease.isActive ? 'ACTIVE' : 'INACTIVE',
              //       style: TextStyle(
              //         fontSize: 12,
              //         fontWeight: FontWeight.w600,
              //         color: disease.isActive ? Colors.green : Colors.grey,
              //       ),
              //     ),
              //   ),
              // ),
              // // Actions
              // DataCell(
              //   Row(
              //     mainAxisSize: MainAxisSize.min,
              //     children: [
              //       IconButton(
              //         onPressed: () => _showDiseaseDetails(disease, student),
              //         icon: Icon(
              //           Icons.visibility,
              //           size: 20,
              //           color: AppTheme.colorPalette['neutral']!['60']!,
              //         ),
              //         tooltip: 'View Details',
              //       ),
              //       IconButton(
              //         onPressed: () => _editDisease(disease, student),
              //         icon: Icon(
              //           Icons.edit,
              //           size: 20,
              //           color: AppTheme.colorPalette['neutral']!['60']!,
              //         ),
              //         tooltip: 'Edit',
              //       ),
              //       IconButton(
              //         onPressed: () => _showHistory(disease, student),
              //         icon: Icon(
              //           Icons.history,
              //           size: 20,
              //           color: AppTheme.colorPalette['neutral']!['60']!,
              //         ),
              //         tooltip: 'History',
              //       ),
              //     ],
              //   ),
              // ),
            ],
          ));
        }
      }
    }

    return rows;
  }

  void _showMedicationDialog() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: 500,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.medication,
                    size: 24,
                    color: AppTheme.colorPalette['info']!['main']!,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Select Medication',
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
              _buildMedicationOption('Insulin Regular', 'Short-acting insulin'),
              _buildMedicationOption(
                  'Insulin NPH', 'Intermediate-acting insulin'),
              _buildMedicationOption('Metformin', 'Oral diabetes medication'),
              _buildMedicationOption('Glipizide', 'Sulfonylurea medication'),
              _buildMedicationOption('Albuterol', 'Bronchodilator for asthma'),
              _buildMedicationOption(
                  'Lisinopril', 'ACE inhibitor for hypertension'),
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
                    child: const Text('Select'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMedicationOption(String name, String description) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.colorPalette['neutral']!['30']!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Radio<String>(
            value: name,
            groupValue: null,
            onChanged: (value) {},
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.colorPalette['neutral']!['90']!,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.colorPalette['neutral']!['60']!,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showDiseaseDetails(ChronicDisease disease, Student student) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: 600,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: student.avatarColor,
                    child: Text(
                      student.initials,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          student.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          '${student.grade ?? 'N/A'} - ${student.className ?? 'N/A'}',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppTheme.colorPalette['neutral']!['60']!,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                disease.name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 20),
              _buildDetailRow('Category', disease.category ?? 'N/A'),
              _buildDetailRow(
                  'Severity', disease.severity?.toUpperCase() ?? 'N/A'),
              _buildDetailRow('Diagnosed Date', disease.formattedDiagnosedDate),
              _buildDetailRow(
                  'Status', disease.isActive ? 'Active' : 'Inactive'),
              if (disease.description != null)
                _buildDetailRow('Description', disease.description!),
              if (disease.treatmentPlan != null)
                _buildDetailRow('Treatment Plan', disease.treatmentPlan!),
              if (disease.medications != null)
                _buildDetailRow('Medications', disease.medications!),
              if (disease.notes != null)
                _buildDetailRow('Notes', disease.notes!),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.colorPalette['neutral']!['80']!,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.colorPalette['neutral']!['70']!,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _editDisease(ChronicDisease disease, Student student) {
    Get.snackbar(
      'Edit Disease',
      'Edit functionality will be implemented here',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void _showHistory(ChronicDisease disease, Student student) {
    Get.snackbar(
      'Disease History',
      'History functionality will be implemented here',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  int _getDoneCount() {
    int count = 0;
    for (final student in students) {
      if (student.chronicDiseases != null) {
        for (final disease in student.chronicDiseases!) {
          // Consider a disease as "Done" if it's active and has treatment plan
          if (disease.isActive &&
              disease.treatmentPlan != null &&
              disease.treatmentPlan!.isNotEmpty) {
            count++;
          }
        }
      }
    }
    return count;
  }

  int _getNotDoneCount() {
    int count = 0;
    for (final student in students) {
      if (student.chronicDiseases != null) {
        for (final disease in student.chronicDiseases!) {
          // Consider a disease as "Not Done" if it's active but has no treatment plan
          if (disease.isActive &&
              (disease.treatmentPlan == null ||
                  disease.treatmentPlan!.isEmpty)) {
            count++;
          }
        }
      }
    }
    return count;
  }

  void _showCompleteAppointmentDialog() {
    final markAllDone = true.obs;

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 486,
              minHeight: 300,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Green check icon
                const Icon(Icons.check_circle_rounded,
                    size: 64, color: Color(0xFF10B981)),

                const SizedBox(height: 16),

                // Title
                const Text(
                  'Complete Checkup',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                  ),
                ),

                const SizedBox(height: 8),

                // Subtitle
                const Text(
                  'By clicking proceed, Chronic Diseases Checkup will be marked done for all the students and you can not undo this action',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6B7280),
                  ),
                ),

                const SizedBox(height: 24),

                // Checkbox
                Obx(() => CheckboxListTile(
                      value: markAllDone.value,
                      onChanged: (val) => markAllDone.value = val ?? true,
                      contentPadding: EdgeInsets.zero,
                      title: const Text(
                        'Mark All unchecked checkups status as done',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                      activeColor: Color(0xFF1339FF),
                      controlAffinity: ListTileControlAffinity.leading,
                    )),

                const SizedBox(height: 24),

                // Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Dismiss
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Get.back(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          side: const BorderSide(color: Color(0xFFD1D5DB)),
                        ),
                        child: const Text('Dismiss'),
                      ),
                    ),
                    SizedBox(width: 16), // Spacing between buttons
                    // Complete
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Get.back();
                          Get.snackbar(
                            'Success',
                            'Chronic Diseases checkup completed successfully!',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor:
                                AppTheme.colorPalette['success']!['main']!,
                            colorText: Colors.white,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              AppTheme.colorPalette['info']!['main']!,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
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
    );
  }
}
