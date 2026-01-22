import 'package:flutter/material.dart';
import 'package:flutter_getx_app/models/student.dart';
import 'package:flutter_getx_app/controllers/student_controller.dart';
import 'package:flutter_getx_app/controllers/home_controller.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class StudentTableRow extends StatelessWidget {
  final Student student;
  final int index;
  final VoidCallback? onTap;

  const StudentTableRow({
    Key? key,
    required this.student,
    required this.index,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<StudentController>();
    final homeController = Get.find<HomeController>();

    return InkWell(
      onTap: onTap ?? () => controller.viewStudent(student),
      hoverColor: Colors.grey.shade50,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.grey.shade200),
          ),
        ),
        child: Row(
          children: [
            // 1. Student full name (flex: 3)
            Expanded(
              flex: 3,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: student.avatarColor,
                    child: Text(
                      student.initials,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
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
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (student.gender != null) ...[
                          const SizedBox(height: 2),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: student.gender == 'Male'
                                  ? Colors.blue.shade50
                                  : Colors.pink.shade50,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              student.gender!,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: student.gender == 'Male'
                                    ? Colors.blue.shade700
                                    : Colors.pink.shade700,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // 2. AID (flex: 2)
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    student.studentId ?? 'N/A',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  // if (student.studentId != null) ...[
                  //   const SizedBox(height: 2),
                  //   Text(
                  //     'ID: ${student.studentId}',
                  //     style: TextStyle(
                  //       fontSize: 11,
                  //       color: Colors.grey.shade600,
                  //     ),
                  //   ),
                  // ],
                ],
              ),
            ),

            // 3. Grade & Class (flex: 2)
            Expanded(
              flex: 2,
              child: Text(
                student.gradeAndClass,
                style: const TextStyle(fontSize: 13),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // 4. Last appointment date (flex: 3)
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    student.lastAppointmentDate != null
                        ? DateFormat('dd/MM/yyyy')
                            .format(student.lastAppointmentDate!)
                        : 'No appointment',
                    style: TextStyle(
                      fontSize: 13,
                      color: student.lastAppointmentDate != null
                          ? Colors.grey.shade800
                          : Colors.grey.shade500,
                    ),
                  ),
                  // Show contact info below appointment date
                  if (student.phoneNumber != null || student.email != null) ...[
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        if (student.phoneNumber != null)
                          Flexible(
                            child: Text(
                              student.phoneNumber!,
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.blue.shade600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                    ),
                    if (student.email != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        student.email!,
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey.shade600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ],
              ),
            ),

            // 5. Last appointment type (flex: 2)
            Expanded(
              flex: 2,
              child: Text(
                student.lastAppointmentType ?? 'No appointment',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // 6. EMR (flex: 1)
            Expanded(
              flex: 1,
              child: Text(
                student.emrNumber?.toString() ?? '0',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            // 7. Actions (flex: 2)
            Expanded(
              flex: 2,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // View Button
                  IconButton(
                    onPressed: () {
                      controller.viewStudent(student);
                    },
                    icon: const Icon(Icons.visibility_outlined),
                    iconSize: 18,
                    tooltip: 'View Details',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.blue.shade50,
                      foregroundColor: Colors.blue,
                      minimumSize: const Size(32, 32),
                      padding: const EdgeInsets.all(6),
                    ),
                  ),
                  const SizedBox(width: 4),
                  // Edit Button - FIXED
                  IconButton(
                    onPressed: () {
                      print('✏️ Editing student: ${student.name}');
                      homeController.navigateToEditStudent(student);
                    },
                    icon: const Icon(Icons.edit_outlined),
                    iconSize: 18,
                    tooltip: 'Edit Student',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.grey.shade100,
                      foregroundColor: Colors.grey.shade700,
                      minimumSize: const Size(32, 32),
                      padding: const EdgeInsets.all(6),
                    ),
                  ),
                  const SizedBox(width: 4),
                  // Delete Button
                  IconButton(
                    onPressed: () {
                      controller.showDeleteConfirmation(student);
                    },
                    icon: const Icon(Icons.delete_outline),
                    iconSize: 18,
                    tooltip: 'Delete Student',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.red.shade50,
                      foregroundColor: Colors.red,
                      minimumSize: const Size(32, 32),
                      padding: const EdgeInsets.all(6),
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
}
