import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class GeneratingReportController extends GetxController {
  final RxDouble _progress = 0.0.obs;
  final RxInt _records = 0.obs;
  final Rx<DateTime> _date = DateTime.now().obs;

  double get progress => _progress.value;
  int get records => _records.value;
  DateTime get date => _date.value;

  void updateProgress(double value) {
    _progress.value = value.clamp(0.0, 1.0);
  }

  void updateRecords(int value) {
    _records.value = value;
  }

  void setDate(DateTime date) {
    _date.value = date;
  }
}

class GeneratingReportDialog extends StatefulWidget {
  final DateTime reportDate;
  final int totalRecords;

  const GeneratingReportDialog({
    Key? key,
    required this.reportDate,
    required this.totalRecords,
  }) : super(key: key);

  @override
  State<GeneratingReportDialog> createState() => _GeneratingReportDialogState();
}

class _GeneratingReportDialogState extends State<GeneratingReportDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get or create controller
    GeneratingReportController controller;
    if (Get.isRegistered<GeneratingReportController>()) {
      controller = Get.find<GeneratingReportController>();
    } else {
      controller = Get.put(GeneratingReportController());
      controller.setDate(widget.reportDate);
      controller.updateRecords(widget.totalRecords);
    }

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(48),
        child: Obx(() => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Cloud icon with rotating arrows
            Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  Icons.cloud_outlined,
                  size: 80,
                  color: Colors.green[300],
                ),
                RotationTransition(
                  turns: _rotationController,
                  child: Icon(
                    Icons.sync,
                    size: 40,
                    color: Colors.green[400],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Title
            const Text(
              'Generating report',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 12),

            // Subtitle
            Text(
              'Please wait, We are generating your reports',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 32),

            // Progress bar
            Row(
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      // Background
                      Container(
                        height: 8,
                        decoration: BoxDecoration(
                          color: Colors.green[100],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      // Progress
                      FractionallySizedBox(
                        widthFactor: controller.progress,
                        alignment: Alignment.centerLeft,
                        child: Container(
                          height: 8,
                          decoration: BoxDecoration(
                            color: Colors.green[600],
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '${(controller.progress * 100).toInt()}%',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF111827),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),

            // Date and Records
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Date',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('dd/MM/yyyy').format(controller.date),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF111827),
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Records',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      controller.records.toString(),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF111827),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        )),
      ),
    );
  }
}

