import 'package:flutter/material.dart';
import 'package:flutter_getx_app/models/student.dart';
import 'package:flutter_getx_app/config/app_config.dart';
import 'package:flutter_getx_app/controllers/student_controller.dart';
import 'package:flutter_getx_app/controllers/home_controller.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class StudentTableRow extends StatelessWidget {
  final Student student;
  final int index;
  final VoidCallback? onTap;
  final bool fromClinic;

  const StudentTableRow({
    Key? key,
    required this.student,
    required this.index,
    this.onTap,
    this.fromClinic = false,
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

            // 4. Actions (flex: 2)
            Expanded(
              flex: 2,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () {
                        if (fromClinic) {
                          homeController
                              .navigateToClinicStudentProfile(student);
                        } else {
                          homeController.navigateToStudentProfile(
                            student,
                            appointmentType: 'View Profile',
                          );
                        }
                      },
                      icon: SvgPicture.asset(
                        'assets/svg/view.svg',
                        width: 18,
                        height: 18,
                        colorFilter: ColorFilter.mode(
                            Colors.grey.shade600, BlendMode.srcIn),
                      ),
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
                    if (!homeController.isRestrictedRole) ...[
                      const SizedBox(width: 4),
                      IconButton(
                        onPressed: () =>
                            homeController.navigateToEditStudent(student),
                        icon: SvgPicture.asset(
                          'assets/svg/edit-2.svg',
                          width: 18,
                          height: 18,
                          colorFilter: ColorFilter.mode(
                              Colors.blue.shade600, BlendMode.srcIn),
                        ),
                        iconSize: 18,
                        tooltip: 'Edit',
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        style: IconButton.styleFrom(
                          foregroundColor: Colors.blue.shade600,
                          minimumSize: const Size(32, 32),
                          padding: const EdgeInsets.all(6),
                        ),
                      ),
                      const SizedBox(width: 4),
                      IconButton(
                        onPressed: () =>
                            controller.showDeleteConfirmation(student),
                        icon: SvgPicture.asset(
                          'assets/svg/note-remove.svg',
                          width: 18,
                          height: 18,
                          colorFilter: ColorFilter.mode(
                              Colors.red.shade600, BlendMode.srcIn),
                        ),
                        iconSize: 18,
                        tooltip: 'Delete',
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        style: IconButton.styleFrom(
                          foregroundColor: Colors.red.shade600,
                          minimumSize: const Size(32, 32),
                          padding: const EdgeInsets.all(6),
                        ),
                      ),
                    ],
                  ],
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

}
