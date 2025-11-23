import 'package:flutter/material.dart';
import 'package:flutter_getx_app/models/appointment.dart';
import 'package:flutter_getx_app/models/student.dart';
import 'package:flutter_getx_app/models/health_status.dart';
import 'package:get/get.dart';
import '../../../controllers/appointment_scheduling_controller.dart';
import '../../../shared/widgets/dynamic_table_widget.dart';

class MedicalCheckupTableWidget extends StatelessWidget {
  final Appointment appointment;
  
  const MedicalCheckupTableWidget({
    Key? key,
    required this.appointment,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    
    final controller = Get.find<AppointmentSchedulingController>();
    
    return SizedBox(
      width: double.infinity, // Take full available width
      child: Column(
        children: [
          _buildHeader(controller),
          
          // Table with improved scrolling
          SizedBox(
            height: 500, // Fixed height to avoid layout constraints issue
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: _buildDynamicTable(controller),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildDynamicTable(AppointmentSchedulingController controller) {
    // Define table columns configuration with flexible widths
    final columns = [
      TableColumnConfig<Student>(
        header: 'Student Details',
        columnWidth: const FlexColumnWidth(3.0), // Flexible width for student details
        cellBuilder: (student, index) => _buildStudentCell(student),
      ),
      TableColumnConfig<Student>(
        header: 'Hair',
        columnWidth: const FlexColumnWidth(1.5), // Flexible width for health columns
        cellBuilder: (student, index) => _buildHealthStatusCell('Hair', student, controller),
      ),
      TableColumnConfig<Student>(
        header: 'Ears',
        columnWidth: const FlexColumnWidth(1.5),
        cellBuilder: (student, index) => _buildHealthStatusCell('Ears', student, controller),
      ),
      TableColumnConfig<Student>(
        header: 'Nails',
        columnWidth: const FlexColumnWidth(1.5),
        cellBuilder: (student, index) => _buildHealthStatusCell('Nails', student, controller),
      ),
      TableColumnConfig<Student>(
        header: 'Teeth',
        columnWidth: const FlexColumnWidth(1.5),
        cellBuilder: (student, index) => _buildHealthStatusCell('Teeth', student, controller),
      ),
      TableColumnConfig<Student>(
        header: 'Uniform',
        columnWidth: const FlexColumnWidth(1.5),
        cellBuilder: (student, index) => _buildHealthStatusCell('Uniform', student, controller),
      ),
    ];

    return SizedBox(
      width: double.infinity, // Take full available width
      child: DynamicTableWidget<Student>(
        items: appointment.selectedStudents,
        columns: columns,
        showActions: false, // No action column needed for this table
        headerColor: Colors.grey.shade50,
        borderColor: Colors.grey.shade200,
      ),
    );
  }

  Widget _buildHeader(AppointmentSchedulingController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Column(
        children: [
          // Back button row
          Row(
            children: [
              InkWell(
                onTap: () {
                  try {
                    final appointmentController = Get.find<AppointmentSchedulingController>();
                    appointmentController.currentViewMode.value = TableViewMode.appointments;
                    print('Back button pressed - navigating to appointments table');
                  } catch (e) {
                    print('Error navigating back: $e');
                    // Fallback navigation
                    Get.back();
                  }
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
                        'Medical Checkup',
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
          
          const SizedBox(height: 16),
          
          // Top row with search and status
          Row(
            children: [
              // Search bar - flexible width
              Expanded(
                flex: 3,
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 12),
                      Icon(Icons.search, color: Colors.grey.shade600, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Search students...',
                            border: InputBorder.none,
                            hintStyle: TextStyle(color: Colors.grey.shade500),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Complete Appointment Button
              _buildCompleteAppointmentButton(controller),
              
              const SizedBox(width: 16),
              
              // Status indicators - flexible
              Expanded(
                flex: 2,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _buildStatusBadge(
                      icon: Icons.check_circle,
                      color: Colors.green,
                      count: _getDoneCount(controller),
                      label: 'Done',
                    ),
                    
                    const SizedBox(width: 12),
                    
                    _buildStatusBadge(
                      icon: Icons.cancel,
                      color: Colors.red,
                      count: _getNotDoneCount(controller),
                      label: 'Not Done',
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          // Progress indicator
          const SizedBox(height: 12),
          _buildProgressIndicator(controller),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator(AppointmentSchedulingController controller) {
    final total = appointment.selectedStudents.length;
    final completed = _getDoneCount(controller);
    final progress = total > 0 ? completed / total : 0.0;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Progress: $completed of $total students completed',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '${(progress * 100).toInt()}%',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.grey.shade200,
          valueColor: AlwaysStoppedAnimation<Color>(
            progress == 1.0 ? Colors.green : Colors.blue,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge({
    required IconData icon,
    required Color color,
    required int count,
    required String label,
  }) {
    return Flexible(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                '$count $label',
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentCell(Student student) {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: student.avatarColor,
            child: Text(
              _getInitials(student.name),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
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
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF111827),
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                const SizedBox(height: 2),
                Text(
                  student.id,
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

  Widget _buildHealthStatusCell(String category, Student student, AppointmentSchedulingController controller) {
    return Obx(() {
      final status = _getHealthStatus(category, student, controller);
      
      return Container(
        padding: const EdgeInsets.all(8),
        child: status == null 
          ? _buildStatusSelector(category, student, controller)
          : _buildStatusDisplay(status, category, student, controller),
      );
    });
  }

  Widget _buildStatusSelector(String category, Student student, AppointmentSchedulingController controller) {
    return Row(
      children: [
        // Good button
        Expanded(
          child: GestureDetector(
            onTap: () => _setHealthStatus(category, student, controller, HealthStatus.good),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.green.shade300),
              ),
              child: Text(
                'Good',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.green.shade700,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
        
        const SizedBox(width: 6),
        
        // Issue button - Modified to capture tap position
        Expanded(
          child: GestureDetector(
            onTapDown: (TapDownDetails details) => _showIssuePopupMenu(
              category, 
              student, 
              controller, 
              details.globalPosition
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.red.shade100,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.red.shade300),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Issue',
                    style: TextStyle(
                      color: Colors.red.shade700,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 2),
                  Icon(Icons.keyboard_arrow_down, size: 14, color: Colors.red.shade700),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusDisplay(HealthStatusData status, String category, Student student, AppointmentSchedulingController controller) {
    final isGood = status.status == HealthStatus.good;
    
    if (isGood) {
      // Show only "Good" status with undo button for good status
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Good status indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.green.shade100,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.green.shade300),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_circle,
                  color: Colors.green.shade700,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  'Good',
                  style: TextStyle(
                    color: Colors.green.shade700,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(width: 8),
          
          // Undo button
          GestureDetector(
            onTap: () => _undoHealthStatus(category, student, controller),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade300),
              ),
              child: Icon(
                Icons.undo,
                color: Colors.blue.shade700,
                size: 14,
              ),
            ),
          ),
        ],
      );
    } else {
      // Show full status display for issues
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Issue status indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.red.shade100,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.red.shade300),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.cancel,
                  color: Colors.red.shade700,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  'Issue',
                  style: TextStyle(
                    color: Colors.red.shade700,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          
          // Issue description
          if (status.issueDescription != null) ...[
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Text(
                status.issueDescription!,
                style: TextStyle(
                  color: Colors.orange.shade800,
                  fontSize: 11,
                ),
              ),
            ),
          ],
          
          // Undo button
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => _undoHealthStatus(category, student, controller),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade300),
              ),
              child: Icon(
                Icons.undo,
                color: Colors.blue.shade700,
                size: 14,
              ),
            ),
          ),
        ],
      );
    }
  }

  void _setHealthStatus(String category, Student student, AppointmentSchedulingController controller, HealthStatus status) {
    final key = '${appointment.id}_${student.id}_$category';
    controller.setHealthStatus(key, status);
  }

  // Modified to accept tap position
  void _showIssuePopupMenu(String category, Student student, AppointmentSchedulingController controller, Offset tapPosition) {
    final List<String> issueOptions = [
      'Missing',
      'Damaged', 
      'Broken',
      'Other',
    ];

    // Calculate position based on tap coordinates
    final RenderBox overlay = Get.overlayContext!.findRenderObject() as RenderBox;
    
    // Create a small rect at the tap position for the popup
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        tapPosition,
        tapPosition.translate(1, 1), // Small rect at tap position
      ),
      Offset.zero & overlay.size,
    );
    
    // Show popup menu at the tap position
    showMenu<String>(
      context: Get.context!,
      position: position,
      items: issueOptions.map((option) => PopupMenuItem<String>(
        value: option,
        child: Row(
          children: [
            _getIssueIcon(option),
            const SizedBox(width: 12),
            Text(option),
          ],
        ),
      )).toList(),
    ).then((value) {
      if (value != null) {
        if (value == 'Other') {
          // Show custom issue dialog for "Other"
          _showCustomIssueDialog(category, student, controller);
        } else {
          // Set predefined issue
          final key = '${appointment.id}_${student.id}_$category';
          controller.setHealthStatusWithIssue(key, HealthStatus.issue, value);
        }
      }
    });
  }

  Widget _getIssueIcon(String issueType) {
    switch (issueType) {
      case 'Missing':
        return Icon(Icons.remove_circle_outline, color: Colors.orange.shade600, size: 24);
      case 'Damaged':
        return Icon(Icons.broken_image, color: Colors.red.shade600, size: 24);
      case 'Broken':
        return Icon(Icons.build, color: Colors.grey.shade600, size: 24);
      case 'Other':
        return Icon(Icons.more_horiz, color: Colors.blue.shade600, size: 24);
      default:
        return Icon(Icons.help_outline, color: Colors.grey.shade600, size: 24);
    }
  }

  void _showCustomIssueDialog(String category, Student student, AppointmentSchedulingController controller) {
    final issueController = TextEditingController();
    
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          width: MediaQuery.of(Get.context!).size.width * 0.9,
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(Icons.warning, color: Colors.orange.shade600, size: 24),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Issue with ${student.name}\'s $category',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              TextField(
                controller: issueController,
                decoration: InputDecoration(
                  hintText: 'Describe the issue in detail...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.all(12),
                ),
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
              ),
              
              const SizedBox(height: 20),
              
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        final issue = issueController.text.trim();
                        if (issue.isNotEmpty) {
                          final key = '${appointment.id}_${student.id}_$category';
                          controller.setHealthStatusWithIssue(key, HealthStatus.issue, issue);
                          Get.back();
                        } else {
                          Get.snackbar(
                            'Error',
                            'Please describe the issue',
                            backgroundColor: Colors.red.shade100,
                            colorText: Colors.red.shade700,
                            duration: const Duration(seconds: 2),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        backgroundColor: Colors.red.shade600,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Save Issue'),
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

  void _undoHealthStatus(String category, Student student, AppointmentSchedulingController controller) {
    final key = '${appointment.id}_${student.id}_$category';
    controller.clearHealthStatus(key);
    
    Get.snackbar(
      'Status Cleared',
      'Health status for ${student.name}\'s $category has been reset',
      backgroundColor: Colors.blue.shade100,
      colorText: Colors.blue.shade700,
      duration: const Duration(seconds: 2),
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  HealthStatusData? _getHealthStatus(String category, Student student, AppointmentSchedulingController controller) {
    final key = '${appointment.id}_${student.id}_$category';
    return controller.getHealthStatus(key);
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0].toUpperCase()}${parts[1][0].toUpperCase()}';
    }
    return name.length >= 2 ? name.substring(0, 2).toUpperCase() : name.toUpperCase();
  }

  int _getDoneCount(AppointmentSchedulingController controller) {
    int count = 0;
    for (var student in appointment.selectedStudents) {
      final categories = ['Hair', 'Ears', 'Nails', 'Teeth', 'Uniform'];
      bool allDone = true;
      for (var category in categories) {
        final status = _getHealthStatus(category, student, controller);
        if (status == null || status.status != HealthStatus.good) {
          allDone = false;
          break;
        }
      }
      if (allDone) count++;
    }
    return count;
  }

  int _getNotDoneCount(AppointmentSchedulingController controller) {
    return appointment.selectedStudents.length - _getDoneCount(controller);
  }

  Widget _buildCompleteAppointmentButton(AppointmentSchedulingController controller) {
    final isAllMarked = _isAllStudentsMarked(controller);
    return GestureDetector(
      onTap: isAllMarked ? () => _completeAppointment(controller) : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isAllMarked ? Colors.green.shade100 : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isAllMarked ? Colors.green.shade300 : Colors.grey.shade300),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isAllMarked ? Icons.check_circle : Icons.pending,
              color: isAllMarked ? Colors.green.shade700 : Colors.grey.shade700,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              isAllMarked ? 'Complete Appointment' : 'Mark All Categories',
              style: TextStyle(
                color: isAllMarked ? Colors.green.shade700 : Colors.grey.shade700,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _completeAppointment(AppointmentSchedulingController controller) {
    Get.dialog(
      AlertDialog(
        title: const Text('Complete Appointment'),
        content: Text('Are you sure you want to complete this medical checkup appointment?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              // Save the medical checkup data before completing
              controller.saveMedicalCheckupData(appointment.id!, appointment.selectedStudents);
              
              // Mark appointment as completed
              controller.markAppointmentAsCompleted(appointment.id!);
              
              Get.back();
              Get.snackbar(
                'Success', 
                'Medical checkup appointment completed and data saved!', 
                backgroundColor: Colors.green.shade100,
                duration: const Duration(seconds: 3),
              );
              
              // Navigate back to appointments table
              controller.currentViewMode.value = TableViewMode.appointments;
            },
            child: const Text('Complete'),
          ),
        ],
      ),
    );
  }

  bool _isAllStudentsMarked(AppointmentSchedulingController controller) {
    for (var student in appointment.selectedStudents) {
      final categories = ['Hair', 'Ears', 'Nails', 'Teeth', 'Uniform'];
      for (var category in categories) {
        final status = _getHealthStatus(category, student, controller);
        if (status == null) return false;
      }
    }
    return true;
  }
}