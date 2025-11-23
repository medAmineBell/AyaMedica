import 'package:flutter/material.dart';
import 'package:flutter_getx_app/models/student.dart';
import 'package:flutter_getx_app/screens/studentProfile/widgets/medical_card.dart';
import 'medical_records_header.dart';
import 'medical_records_timeline.dart';
import 'medical_record_card.dart';

class MedicalRecordsView extends StatelessWidget {
  final Student student;

  const MedicalRecordsView({
    Key? key,
    required this.student,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const MedicalRecordsHeader(),
        const SizedBox(height: 24),
        const MedicalRecordsTimeline(),
Text(
  'Vaccination | 01/01/2025',
  style: TextStyle(
    color: const Color(0xFF595A5B) /* Text-Text-90 */,
    fontSize: 16,
    fontFamily: 'IBM Plex Sans Arabic',
    fontWeight: FontWeight.w700,
    height: 1.50,
    letterSpacing: 0.16,
  ),
),
SizedBox(height: 16,),
GridView.builder(
  shrinkWrap: true,
  physics: const NeverScrollableScrollPhysics(),
  itemCount: 9,
  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 2,
    crossAxisSpacing: 16,
    mainAxisSpacing: 16,

    mainAxisExtent:  316
  ),
  itemBuilder: (context, index) => const MedicalCard(),
)

        // Medical Record Cards
        // const MedicalRecordCard(
        //   title: 'Vaccination',
        //   date: '01/01/2025',
        //   doctorName: 'Dr. Habib Al Ali',
        //   clinicInfo: 'Al Amen Clinic pediatric Clinic, Cairo, 223121',
        //   category: 'Category',
        //   note: 'Note goes here',
        //   fileName: 'Uploaded file.pdf',
        //   fileDate: '25 July 2025 At 7:48 PM',
        //   isExpanded: true,
        //   isSynchronized: true,
        // ),
        // const SizedBox(height: 16),
        // const MedicalRecordCard(
        //   title: 'Regular checkup',
        //   date: '01/01/2025',
        //   doctorName: 'Dr. Ahmed Hassan',
        //   clinicInfo: 'Cairo Medical Center, Cairo, 11511',
        //   category: 'Routine',
        //   note: 'Regular checkup completed',
        //   fileName: 'Checkup report.pdf',
        //   fileDate: '15 June 2025 At 3:30 PM',
        //   isExpanded: false,
        //   isSynchronized: false,
        // ),
      ],
    );
  }
}