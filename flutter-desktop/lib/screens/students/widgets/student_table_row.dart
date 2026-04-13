import 'package:flutter/material.dart';
import 'package:flutter_getx_app/models/student.dart';
import 'package:flutter_getx_app/config/app_config.dart';
import 'package:flutter_getx_app/controllers/student_controller.dart';
import 'package:flutter_getx_app/controllers/home_controller.dart';
import 'package:get/get.dart';

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
                  _buildAvatar(),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      student.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

            // 2. AID (flex: 2)
            Expanded(
              flex: 2,
              child: Text(
                student.aid ?? 'N/A',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
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

            // 4. First Guardian (flex: 3)
            Expanded(
              flex: 3,
              child: _buildGuardianCell(
                name: student.firstGuardianName,
                phone: student.firstGuardianPhone,
                status: student.firstGuardianStatus,
                isFirst: true,
              ),
            ),

            // 5. 2nd Guardian (flex: 3)
            Expanded(
              flex: 3,
              child: _buildGuardianCell(
                name: student.secondGuardianName,
                phone: student.secondGuardianPhone,
                status: student.secondGuardianStatus,
                isFirst: false,
              ),
            ),

            // 6. EMR (flex: 1)
            // Expanded(
            //   flex: 1,
            //   child: Center(
            //     child: Text(
            //       student.emrNumber?.toString() ?? '0',
            //       style: const TextStyle(
            //         fontSize: 14,
            //         fontWeight: FontWeight.w600,
            //       ),
            //     ),
            //   ),
            // ),

            // 8. Actions (flex: 1)
            Expanded(
              flex: 1,
              child: Center(
                child: IconButton(
                  onPressed: () {
                    homeController.navigateToStudentProfile(
                      student,
                      appointmentType: 'View Profile',
                    );
                  },
                  icon: const Icon(Icons.visibility_outlined),
                  iconSize: 18,
                  tooltip: 'View Details',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  style: IconButton.styleFrom(
                    foregroundColor: Colors.grey.shade600,
                    minimumSize: const Size(32, 32),
                    padding: const EdgeInsets.all(6),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    final imageUrl = student.imageUrl;
    if (imageUrl != null && imageUrl.isNotEmpty) {
      final fullUrl = imageUrl.startsWith('http')
          ? imageUrl
          : '${AppConfig.newBackendUrl}$imageUrl';
      return CircleAvatar(
        radius: 20,
        backgroundColor: student.avatarColor,
        backgroundImage: NetworkImage(fullUrl),
        onBackgroundImageError: (_, __) {},
      );
    }
    return CircleAvatar(
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
    );
  }

  Widget _buildGuardianCell({
    String? name,
    String? phone,
    String? status,
    required bool isFirst,
  }) {
    if (name == null || name.isEmpty) {
      return Text(
        '-',
        style: TextStyle(fontSize: 13, color: Colors.grey.shade400),
      );
    }

    // Determine status color
    Color statusColor;
    if (status == 'active' || status == 'verified') {
      statusColor = Colors.green;
    } else if (status == 'inactive' || status == 'unverified') {
      statusColor = Colors.red;
    } else {
      statusColor = Colors.grey;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          children: [
            Flexible(
              child: Text(
                name,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 4),
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: statusColor,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
        if (phone != null && phone.isNotEmpty) ...[
          const SizedBox(height: 2),
          Text(
            phone,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }
}
