import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/home_controller.dart';
import '../../controllers/appointment_scheduling_controller.dart';
import '../../models/student.dart';
import '../../models/appointment.dart';

class MedicalCheckupTableScreen extends StatelessWidget {
  final Appointment appointment;
  final Map<String, dynamic> medicalCheckupData;

  const MedicalCheckupTableScreen({
    Key? key,
    required this.appointment,
    required this.medicalCheckupData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appointmentController = Get.find<AppointmentSchedulingController>();
    
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with back button
            Row(
              children: [
                InkWell(
                  onTap: () {
                    final controller = Get.find<HomeController>();
                    controller.changeContent(ContentType.appointmentScheduling);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.arrow_back,
                          size: 16,
                          color: Color(0xFF6B7280),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Back',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          'Medical Checkup Results',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF9CA3AF),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Title
            const Text(
              'Medical Checkup Details',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF111827),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Appointment Info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Appointment: ${appointment.type}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF374151),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Class: ${appointment.className} | Grade: ${appointment.grade}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Status: Completed',
                    style: TextStyle(
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Summary Statistics
            Obx(() {
              final dynamicData = appointmentController.getMedicalCheckupData(appointment.id!);
              final doneCount = _getDoneCount(dynamicData);
              final notDoneCount = _getNotDoneCount(dynamicData);
              final absentCount = _getAbsentCount(dynamicData);
              
              return Row(
                children: [
                  _buildSummaryPill('$doneCount Done', Colors.green, Icons.check),
                  const SizedBox(width: 12),
                  _buildSummaryPill('$notDoneCount Not Done', Colors.red, Icons.close),
                  const SizedBox(width: 12),
                  _buildSummaryPill('$absentCount Absent', Colors.grey, null),
                ],
              );
            }),
            
            const SizedBox(height: 24),
            
            // Health Checkup Table
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: SingleChildScrollView(
                  child: Table(
                    columnWidths: const {
                      0: FlexColumnWidth(3), // Student name
                      1: FlexColumnWidth(1), // Hair
                      2: FlexColumnWidth(1), // Ears
                      3: FlexColumnWidth(1), // Nails
                      4: FlexColumnWidth(1), // Teeth
                      5: FlexColumnWidth(1), // Uniform
                    },
                    children: [
                      // Table Header
                      TableRow(
                        decoration: const BoxDecoration(
                          color: Color(0xFFF9FAFB),
                          border: Border(
                            bottom: BorderSide(color: Color(0xFFE5E7EB)),
                          ),
                        ),
                        children: [
                          _buildTableHeaderCell('Student full name'),
                          _buildTableHeaderCell('Hair'),
                          _buildTableHeaderCell('Ears'),
                          _buildTableHeaderCell('Nails'),
                          _buildTableHeaderCell('Teeth'),
                          _buildTableHeaderCell('Uniform'),
                        ],
                      ),
                      
                      // Table Data Rows
                      ...appointment.selectedStudents.map((student) {
                        final studentData = appointmentController.getStudentMedicalCheckupData(appointment.id!, student.id);
                        
                        return TableRow(
                          decoration: BoxDecoration(
                            color: appointment.selectedStudents.indexOf(student) % 2 == 0 
                                ? Colors.white 
                                : const Color(0xFFFAFAFA),
                            border: const Border(
                              bottom: BorderSide(color: Color(0xFFE5E7EB)),
                            ),
                          ),
                          children: [
                            _buildStudentNameCell(student),
                            _buildStatusCell(studentData?['Hair']),
                            _buildStatusCell(studentData?['Ears']),
                            _buildStatusCell(studentData?['Nails']),
                            _buildStatusCell(studentData?['Teeth']),
                            _buildStatusCell(studentData?['Uniform']),
                          ],
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryPill(String text, Color color, IconData? icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
          ],
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeaderCell(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Color(0xFF374151),
        ),
      ),
    );
  }

  Widget _buildStudentNameCell(Student student) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: student.avatarColor,
                child: Text(
                  student.name.isNotEmpty 
                      ? student.name.substring(0, 2).toUpperCase() 
                      : 'ST',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
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
                    Text(
                      'AID number',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6B7280),
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

  Widget _buildStatusCell(dynamic statusData) {
    if (statusData == null) {
      return _buildStatusPill('Absent', const Color(0xFF6B7280), const Color(0xFFF3F4F6), null);
    }
    
    // Handle HealthStatusData object
    final status = statusData.status;
    
    // Determine status type and styling based on HealthStatus enum
    if (status.toString().toLowerCase().contains('good')) {
      return _buildStatusPill('Good', const Color(0xFF059669), const Color(0xFFD1FAE5), Icons.check);
    } else if (status.toString().toLowerCase().contains('issue')) {
      // For issues, show the issue description directly
      final issueDescription = statusData.issueDescription ?? '';
      final displayText = issueDescription.isNotEmpty ? issueDescription : 'Issue';
      
      // Add tooltip for longer descriptions
      if (issueDescription.length > 15) {
        return Tooltip(
          message: issueDescription,
          child: _buildStatusPill(displayText, const Color(0xFFEF4444), const Color(0xFFFEE2E2), null),
        );
      } else {
        return _buildStatusPill(displayText, const Color(0xFFEF4444), const Color(0xFFFEE2E2), null);
      }
    } else {
      return _buildStatusPill('Absent', const Color(0xFF6B7280), const Color(0xFFF3F4F6), null);
    }
  }

  int _getDoneCount(Map<String, Map<String, dynamic>>? data) {
    if (data == null) return 0;
    int count = 0;
    data.forEach((studentId, categories) {
      categories.forEach((category, status) {
        if (status.status.toString().toLowerCase().contains('good')) {
          count++;
        }
      });
    });
    return count;
  }

  int _getNotDoneCount(Map<String, Map<String, dynamic>>? data) {
    if (data == null) return 0;
    int count = 0;
    data.forEach((studentId, categories) {
      categories.forEach((category, status) {
        if (status.status.toString().toLowerCase().contains('issue')) {
          count++;
        }
      });
    });
    return count;
  }

  int _getAbsentCount(Map<String, Map<String, dynamic>>? data) {
    if (data == null) return appointment.selectedStudents.length * 5; // 5 categories per student
    int totalPossible = appointment.selectedStudents.length * 5;
    int present = 0;
    data.forEach((studentId, categories) {
      present += categories.length;
    });
    return totalPossible - present;
  }

  Widget _buildStatusPill(String text, Color textColor, Color bgColor, IconData? icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 120), // Limit width for longer text
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 12, color: textColor),
              const SizedBox(width: 4),
            ],
            Flexible(
              child: Text(
                text,
                style: TextStyle(
                  color: textColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
