import 'package:flutter/widgets.dart';
import 'package:flutter_getx_app/screens/students/widgets/student_data_table.dart';
import 'package:flutter_getx_app/shared/widgets/breadcrumb_widget.dart';

class StudentsListScreen extends StatelessWidget {
  const StudentsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFFBFCFD),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Students List',
            style: TextStyle(
              color: Color(0xFF2D2E2E),
              fontSize: 20,
              fontFamily: 'IBM Plex Sans Arabic',
              fontWeight: FontWeight.w700,
              height: 1.40,
            ),
          ),
          const BreadcrumbWidget(
            items: [
              BreadcrumbItem(label: 'Ayamedica portal'),
              BreadcrumbItem(label: 'Students'),
              BreadcrumbItem(label: 'Students List'),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(child: StudentDataTable()),
        ],
      ),
    );
  }
}
