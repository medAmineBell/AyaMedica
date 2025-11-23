import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/student_controller.dart';
import '../../../models/student.dart';
import 'student_table_row.dart';

class StudentTable extends StatelessWidget {
  final StudentController controller;
  final Function(Student) onStudentTap;

  const StudentTable({
    Key? key,
    required this.controller,
    required this.onStudentTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Container(
          width: Get.width > 1200 ? Get.width : 1200,
          child: Column(
            children: [
              _StudentTableHeaderRow(),
              Expanded(
                child: Obx(() {
                  if (controller.paginatedStudents.isEmpty) {
                    return _EmptyState();
                  }

                  return ListView.builder(
                    itemCount: controller.paginatedStudents.length,
                    itemBuilder: (context, index) {
                      final student = controller.paginatedStudents[index];
                      return StudentTableRow(
                        student: student,
                        index: index,
                        controller: controller,
                        onTap: () => onStudentTap(student),
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StudentTableHeaderRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          _HeaderCell('Student full name', flex: 3),
          _HeaderCell('AID', flex: 2, hasTooltip: true),
          _HeaderCell('Grade & Class', flex: 2),
          _HeaderCell('Last appointment date', flex: 3, hasTooltip: true),
          _HeaderCell('Last appointment type', flex: 2),
          _HeaderCell('EMR', flex: 1),
          _HeaderCell('Actions', flex: 2),
        ],
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  final String title;
  final int flex;
  final bool hasTooltip;

  const _HeaderCell(
    this.title, {
    this.flex = 1,
    this.hasTooltip = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Colors.grey.shade700,
              ),
            ),
            if (hasTooltip)
              Padding(
                padding: EdgeInsets.only(left: 4),
                child: Icon(Icons.help_outline,
                    size: 16, color: Colors.grey.shade400),
              ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: Colors.grey.shade400),
          SizedBox(height: 16),
          Text(
            'No students found',
            style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}