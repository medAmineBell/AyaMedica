import 'package:flutter/material.dart';
import 'package:flutter_getx_app/screens/students/widgets/student_data_table.dart';
import 'package:get/get.dart';

import '../../../controllers/student_controller.dart';

class DefectiveRecordsNotification extends StatelessWidget {
  final StudentController controller;

  const DefectiveRecordsNotification({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (!controller.hasDefectiveRecords.value) {
        return SizedBox.shrink();
      }

      return Container(
        margin: EdgeInsets.only(bottom: 16),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Color(0xFFFEF2F2), // Light red background
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Color(0xFFFECACA)), // Light red border
        ),
        child: Row(
          children: [
            // Warning Icon
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Color(0xFFDC2626), // Red background
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.warning_outlined,
                color: Colors.white,
                size: 20,
              ),
            ),
            
            SizedBox(width: 12),
            
            // Error Message
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '(${controller.defectiveRecords.length}) defected records found',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF7F1D1D), // Dark red text
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Download the defected records file, correct it and re-upload it again.',
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF7F1D1D), // Dark red text
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(width: 16),
            
            // Action Buttons
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Upload Corrected Records Button
                ElevatedButton.icon(
                  onPressed: () {
                    // Trigger upload dialog for corrected records
                  },
                  icon: Icon(Icons.upload_outlined, size: 16),
                  label: Text('Upload corrected records'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFDC2626), // Red background
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    textStyle: TextStyle(fontSize: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
                
                SizedBox(width: 8),
                
                // Download Defective Records Button
                OutlinedButton.icon(
                  onPressed: () {
                    controller.downloadDefectiveRecords();
                  },
                  icon: Icon(Icons.download_outlined, size: 16),
                  label: Text('Download defected records'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Color(0xFFDC2626), // Red text
                    side: BorderSide(color: Color(0xFFDC2626)),
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    textStyle: TextStyle(fontSize: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }
}