import 'package:flutter/material.dart';

import '../../../controllers/student_controller.dart';
import '../../../models/student.dart';

class StudentTableRow extends StatelessWidget {
  final Student student;
  final int index;
  final StudentController controller;
  final VoidCallback onTap;

  const StudentTableRow({
    Key? key,
    required this.student,
    required this.index,
    required this.controller,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: index % 2 == 0 ? Colors.white : Colors.grey.shade50,
        border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
      ),
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            _StudentNameCell(student: student),
            _TextCell(student.aid ?? 'N/A', flex: 2),
            _TextCell(student.gradeAndClass, flex: 2),
            _TextCell(student.formattedAppointmentDate, flex: 3),
            _TextCell(student.lastAppointmentType ?? 'N/A', flex: 2),
            _EmrCell(student: student),
            _ActionsCell(student: student, controller: controller),
          ],
        ),
      ),
    );
  }
}

class _StudentNameCell extends StatelessWidget {
  final Student student;

  const _StudentNameCell({required this.student});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 3,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    student.studentId ?? 'No ID',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
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

class _TextCell extends StatelessWidget {
  final String text;
  final int flex;

  const _TextCell(this.text, {this.flex = 1});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Text(text, style: const TextStyle(fontSize: 14)),
      ),
    );
  }
}

class _EmrCell extends StatelessWidget {
  final Student student;

  const _EmrCell({required this.student});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 1,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.cyan.shade50,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Center(
            child: Text(
              '${student.emrNumber ?? 0}',
              style: TextStyle(
                color: Colors.cyan.shade700,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionsCell extends StatelessWidget {
  final Student student;
  final StudentController controller;

  const _ActionsCell({
    required this.student,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            _ActionIconButton(
              icon: Icons.delete_outline,
              color: Colors.red.shade400,
              onPressed: () => controller.deleteStudent(student),
            ),
            _ActionIconButton(
              icon: Icons.edit_outlined,
              color: Colors.grey.shade600,
              onPressed: () => controller.editStudent(student),
            ),
            _ActionIconButton(
              icon: Icons.visibility_outlined,
              color: Colors.grey.shade600,
              onPressed: () => controller.viewStudent(student),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionIconButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  const _ActionIconButton({
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon, color: color, size: 20),
      padding: const EdgeInsets.all(4),
      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
    );
  }
}
