import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_getx_app/screens/dashboard/dashboard_screen.dart';
import 'package:flutter_getx_app/screens/dashboard/widgets/charts/bar_chart_widget.dart';
import 'package:flutter_getx_app/screens/dashboard/widgets/charts/line_chart_widget.dart';
import 'package:flutter_getx_app/screens/dashboard/widgets/charts/pie_chart_sample.dart';
import 'package:flutter_getx_app/screens/dashboard/widgets/charts/pie_chart_widget.dart';
import 'package:flutter_getx_app/shared/widgets/breadcrumb_widget.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'widgets/student_count_widget.dart';

class StudentOverviewScreen extends StatelessWidget {
  const StudentOverviewScreen({super.key});

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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Students Overview',
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

                          BreadcrumbItem(label: 'Overview'),
                        ],
                      ),
                    ],
                  ),
                  OutlineButton(
                    text: 'Export data',
                    icon: SvgPicture.asset(
                      'assets/svg/download.svg',
                      width: 18,
                      height: 18,
                      color: const Color(0xFF7A7A7A),
                    ),
                    onPressed: () {
                      print('Export data pressed');
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(children: [
                 Expanded(
                   child: StudentCountWidget(
                                   studentCount: 1700,
                   
                                 ),
                 ),
                 SizedBox(width: 16), // Add space between widgets
               Expanded(
                 child: StudentCountWidget(
                  studentCount: 1700,
                  
                               ),
               ),
                                SizedBox(width: 16), // Add space between widgets

               Expanded(
                 child: StudentCountWidget(
                  studentCount: 1700,
                  
                               ),
               ),
                                SizedBox(width: 16), // Add space between widgets

               Expanded(
                 child: StudentCountWidget(
                  studentCount: 1700,
                  
                               ),
               ),
              ],),
             
              const SizedBox(height: 16),
              // First row: 1/3 + 2/3

              SizedBox(
                height: 350,
                child: Row(
                  children: const [
                    Expanded(
                      flex: 1,
                      child: PieChartWidget(),
                    ),
                    Expanded(
                      flex: 2,
                      child: LineChartWidget(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Second row: 2/3 + 1/3
              SizedBox(
                height: 350, // Fixed height for second row
                child: Row(
                  children: const [
                    Expanded(
                      flex: 2,
                      child: BarChartWidget(),
                    ),
                    Expanded(
                      flex: 1,
                      child: PieChartSample(
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
 
 
  }
}

