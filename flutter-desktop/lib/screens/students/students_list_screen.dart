import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_getx_app/screens/dashboard/dashboard_screen.dart';
import 'package:flutter_getx_app/screens/dashboard/widgets/charts/bar_chart_widget.dart';
import 'package:flutter_getx_app/screens/dashboard/widgets/charts/line_chart_widget.dart';
import 'package:flutter_getx_app/screens/dashboard/widgets/charts/pie_chart_sample.dart';
import 'package:flutter_getx_app/screens/dashboard/widgets/charts/pie_chart_widget.dart';
import 'package:flutter_getx_app/screens/students/widgets/student_data_table.dart';
import 'package:flutter_getx_app/shared/widgets/breadcrumb_widget.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'widgets/student_count_widget.dart';

class StudentsListScreen extends StatelessWidget {
  const StudentsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFFBFCFD),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height - 80, // Subtract navbar height
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Students List',
                    style: TextStyle(
                      color: Color(0xFF2D2E2E) /* Text-Text-100 */,
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
                  
                ],
              ),
                            StudentDataTable(),

          ],
          ),
        ),
      ),
    );
 
 
  }
}

