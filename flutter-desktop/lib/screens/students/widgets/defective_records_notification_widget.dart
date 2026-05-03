import 'package:flutter/material.dart';
import 'package:flutter_getx_app/controllers/home_controller.dart';
import 'package:flutter_getx_app/controllers/student_controller.dart';
import 'package:flutter_getx_app/screens/students/widgets/upload_students_dialog.dart';
import 'package:get/get.dart';

class DefectiveRecordsNotification extends StatelessWidget {
  final StudentController controller;

  const DefectiveRecordsNotification({Key? key, required this.controller})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (!controller.hasDefectiveRecords.value) {
        return const SizedBox.shrink();
      }

      final hasFile =
          (controller.defectedRecordsFileBase64.value ?? '').isNotEmpty;

      return InkWell(
        onTap: () => Get.find<HomeController>().navigateToBulkUploadResults(),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFFEF2F2),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFFECACA)),
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: Color(0xFFDC2626),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.warning_outlined,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '(${controller.defectiveRecords.length}) defected records found',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF7F1D1D),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Download the defected records file, correct it and re-upload it again.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF7F1D1D),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => showDialog(
                      context: Get.context!,
                      builder: (_) => const UploadStudentsDialog(),
                    ),
                    icon: const Icon(Icons.upload_outlined, size: 16),
                    label: const Text('Upload corrected records'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFDC2626),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      textStyle: const TextStyle(fontSize: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: hasFile
                        ? () => controller.downloadDefectedRecordsFile()
                        : null,
                    icon: const Icon(Icons.download_outlined, size: 16),
                    label: const Text('Download defected records'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFDC2626),
                      side: const BorderSide(color: Color(0xFFDC2626)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      textStyle: const TextStyle(fontSize: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }
}
