import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_getx_app/controllers/feedback_controller.dart';
import 'package:flutter_getx_app/models/feedback.dart';
import 'package:flutter_getx_app/shared/widgets/dynamic_table_widget.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../shared/widgets/custom_text_field.dart';
import '../../shared/widgets/form_field_widget.dart';
import '../appointmentScheduling/widgets/custom_dropdown.dart';
import '../../controllers/home_controller.dart';

class FeedbackDashboardScreen extends StatelessWidget {
  const FeedbackDashboardScreen({super.key});
void showFeedbackDialog(BuildContext context) {
  final TextEditingController subjectController = TextEditingController();
  final TextEditingController explanationController = TextEditingController();
  final controller = Get.find<FeedbackController>();

  String? selectedBranch;
  String? selectedGrade;
  String? selectedClass;

  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (_) => Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 862),
          child: Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            clipBehavior: Clip.antiAlias,
            child: StatefulBuilder(
              builder: (context, setState) => SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Request a new feedback',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: 'IBM Plex Sans Arabic',
                                  color: Color(0xFF2D2E2E),
                                  height: 1.4,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Send a feedback form to parents to rate a specific subject',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  fontFamily: 'Inter',
                                  color: Color(0xFF707579),
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close, color: Colors.black45),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Select grades and name the class',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF747677),
                        fontFamily: 'IBM Plex Sans Arabic',
                        letterSpacing: 0.16,
                      ),
                    ),
                    const SizedBox(height: 16),
                    FormFieldWidget(
                      label: 'Branches',
                      isRequired: true,
                      child: CustomDropdown<String>(
                        hint: 'Choose a branch',
                        value: selectedBranch,
                        items: DropdownHelper.createStringItems(['Branch A', 'Branch B']),
                        onChanged: (value) => setState(() => selectedBranch = value),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: FormFieldWidget(
                            label: 'Grade(s)',
                            child: CustomDropdown<String>(
                              hint: 'Choose grade',
                              value: selectedGrade,
                              items: DropdownHelper.createStringItems(['G1', 'G2']),
                              onChanged: (value) => setState(() => selectedGrade = value),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: FormFieldWidget(
                            label: 'Classes',
                            child: CustomDropdown<String>(
                              hint: 'Choose class',
                              value: selectedClass,
                              items: DropdownHelper.createStringItems(['Class A', 'Class B', 'Class C']),
                              onChanged: (value) => setState(() => selectedClass = value),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (selectedGrade != null) ...[
                      _GradePill(label: selectedGrade!),
                    ],
                    const SizedBox(height: 24),
                    const Text(
                      'Enter the survey subject',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF747677),
                        fontFamily: 'IBM Plex Sans Arabic',
                        letterSpacing: 0.16,
                      ),
                    ),
                    const SizedBox(height: 16),
                    FormFieldWidget(
                      label: 'Subject name',
                      isRequired: true,
                      child: CustomTextField(
                        controller: subjectController,
                        hint: 'Enter the subject title here',
                      ),
                    ),
                    const SizedBox(height: 16),
                    FormFieldWidget(
                      label: 'Explain what it’s about',
                      child: CustomTextField(
                        controller: explanationController,
                        hint: 'Brief explanation about the subject',
                        maxLines: 5,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: const Text(
                              'Back',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF2D2E2E),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (_) => _SendingFeedbackDialog(
                                  onComplete: () {
                                    controller.feedbacks.add(
                                      FeedbackItem(
                                        title: subjectController.text,
                                        branch: selectedBranch ?? 'Unknown',
                                        launchDate: DateTime.now(),
                                        status: 'Draft',
                                        rating: 0,
                                        currentResponses: 0,
                                        totalResponses: 0,
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1339FF),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: const Text(
                              'Send survey request',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFFCDF7FF),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

@override
  Widget build(BuildContext context) {
    final controller = Get.put(FeedbackController());

    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Rating and Star Breakdown Row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Rating Summary
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Overall parents satisfaction',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: List.generate(
                          5,
                          (index) => const Icon(Icons.star,
                              color: Colors.amber, size: 20),
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text('4.9 out of 5'),
                      const SizedBox(height: 4),
                      const Text('Based on 8,475 reviews',
                          style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),

                const SizedBox(width: 32),

                // Star breakdown bars
                Flexible(
                  child: Column(
                    children: List.generate(4, (index) {
                      int star = 5 - index;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            SizedBox(
                                width: 60,
                                child: Text('$star Stars',
                                    style:
                                        const TextStyle(color: Colors.blue))),
                            const SizedBox(width: 8),
                            Expanded(
                              child: LinearProgressIndicator(
                                value: 0.85,
                                backgroundColor: Colors.grey.shade200,
                                color: Colors.blue,
                                minHeight: 6,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text('2478',
                                style: TextStyle(color: Colors.blue)),
                          ],
                        ),
                      );
                    }),
                  ),
                ),

                Spacer()
              ],
            ),

            const SizedBox(height: 24),

            // Search + Buttons Row
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'search',
                      prefixIcon: const Icon(Icons.search),
                      fillColor: Colors.white,
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF1339FF)),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  height: 40,
                  width: 44,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Color(0xffA6A9AC)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    icon: SvgPicture.asset('assets/svg/download.svg',
                        color: Colors.grey),
                    onPressed: () {},
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  height: 44,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  clipBehavior: Clip.antiAlias,
                  decoration: ShapeDecoration(
                    shape: RoundedRectangleBorder(
                      side: const BorderSide(
                        width: 1,
                        color: Color(0xFFA6A9AC),
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.tune,
                          size: 20, color: Color(0xFF747677)),
                      const SizedBox(width: 8),
                      const Text(
                        'Filters',
                        style: TextStyle(
                          color: Color(0xFF747677),
                          fontSize: 14,
                          fontFamily: 'IBM Plex Sans Arabic',
                          fontWeight: FontWeight.w500,
                          height: 1.43,
                          letterSpacing: 0.28,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  height: 44,
                  child: ElevatedButton.icon(
                    onPressed: () {
                        showFeedbackDialog(context);

                    },
                    icon: const Icon(Icons.add,
                        size: 24, color: Color(0xFFCDF7FF)),
                    label: const Text(
                      'New feedback request',
                      style: TextStyle(
                        color: Color(0xFFCDF7FF),
                        fontSize: 14,
                        fontFamily: 'IBM Plex Sans Arabic',
                        fontWeight: FontWeight.w500,
                        height: 1.43,
                        letterSpacing: 0.28,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1339FF),
                      foregroundColor: const Color(0xFFCDF7FF),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      textStyle: const TextStyle(
                        fontSize: 14,
                        fontFamily: 'IBM Plex Sans Arabic',
                        fontWeight: FontWeight.w500,
                        height: 1.43,
                        letterSpacing: 0.28,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 1,
                      shadowColor: const Color(0x0C101828),
                    ),
                  ),
                )
              ],
            ),
            const SizedBox(height: 24),

            // Dynamic table
            Expanded(
              child: Obx(() => DynamicTableWidget<FeedbackItem>(
                    items: controller.feedbacks.toList(),
                    columns: [
                      TableColumnConfig<FeedbackItem>(
                        header: 'Feedback title',
                        columnWidth: const FlexColumnWidth(3),
                        cellBuilder: (item, index) => Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.title,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600)),
                            Text(item.branch,
                                style: const TextStyle(color: Colors.grey)),
                          ],
                        ),
                      ),
                      TableColumnConfig<FeedbackItem>(
                        header: 'Launch date & time',
                        columnWidth: const FlexColumnWidth(2),
                        cellBuilder: (item, index) => TableCellHelpers.textCell(
                          '${item.launchDate.day.toString().padLeft(2, '0')}/${item.launchDate.month.toString().padLeft(2, '0')}/${item.launchDate.year}',
                        ),
                      ),
                      TableColumnConfig<FeedbackItem>(
                        header: 'Status',
                        cellBuilder: (item, index) =>
                            TableCellHelpers.badgeCell(
                          item.status,
                          backgroundColor: const Color(0xFFE6FAEB),
                          textColor: const Color(0xFF1BA94C),
                        ),
                      ),
                      TableColumnConfig<FeedbackItem>(
                        header: 'Overall rating',
                        tooltip: 'Average rating',
                        cellBuilder: (item, index) =>
                            TableCellHelpers.badgeCell(
                          '${item.rating.toStringAsFixed(1)} ★',
                          backgroundColor: const Color(0xFFFFF7E6),
                          textColor: const Color(0xFFCC9A06),
                        ),
                      ),
                      TableColumnConfig<FeedbackItem>(
                        header: 'Number of responses',
                        tooltip: 'Answered / Total',
                        cellBuilder: (item, index) =>
                            TableCellHelpers.badgeCell(
                          '${item.currentResponses}/${item.totalResponses}',
                          backgroundColor: const Color(0xFFE8F3FF),
                          textColor: const Color(0xFF1463FF),
                        ),
                      ),
                    ],
                    actions: [
                      TableActionConfig<FeedbackItem>(
                        icon: Icons.visibility_outlined,
                        tooltip: 'View',
                        onPressed: (item, index) {
                          controller.selectedFeedback.value = item;
                          final homeController = Get.find<HomeController>();
                          homeController.changeContent(ContentType.feedbackDetails);
                        },
                      ),
                      TableActionConfig<FeedbackItem>(
                        icon: Icons.notifications_none,
                        tooltip: 'Notify',
                        onPressed: (item, index) => controller.notify(item),
                      ),
                      TableActionConfig<FeedbackItem>(
                        icon: Icons.airplanemode_on_sharp,
                        color: Color(0xffD6A100) ,
                        tooltip: 'Highlight',
                        onPressed: (item, index) => controller.highlight(item),
                      ),
                    ],
                  )),
            ),
          ],
        ),
      ),
    );
  }
}
class _SendingFeedbackDialog extends StatefulWidget {
  final VoidCallback onComplete;

  const _SendingFeedbackDialog({super.key, required this.onComplete});

  @override
  State<_SendingFeedbackDialog> createState() => _SendingFeedbackDialogState();
}

class _SendingFeedbackDialogState extends State<_SendingFeedbackDialog> {
  double progress = 0;
  int total = 872;
  late Timer timer;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(milliseconds: 20), (t) {
      setState(() {
        progress += 1;
        if (progress >= total) {
          t.cancel();
          Navigator.pop(context);
          widget.onComplete();
        }
      });
    });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Container(
        width: 520,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 16),
            const Icon(Icons.check_circle_outline, size: 56, color: Color(0xFF00C447)),
            const SizedBox(height: 24),
            const Text(
              'Sending feedback request',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: Color(0xFF2D2E2E),
                fontFamily: 'IBM Plex Sans Arabic',
                height: 1.29,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Please wait, we are notifying users',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Color(0xFF858789),
                fontFamily: 'IBM Plex Sans Arabic',
                height: 1.43,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6.33),
                    child: LinearProgressIndicator(
                      value: progress / total,
                      minHeight: 6.32,
                      backgroundColor: const Color(0xFFD8FAE4),
                      valueColor: const AlwaysStoppedAnimation(Color(0xFF00C447)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '(${progress.toInt()} of $total)',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF2D2E2E),
                    fontFamily: 'IBM Plex Sans Arabic',
                    height: 1.4,
                    letterSpacing: 0.4,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
class _GradePill extends StatelessWidget {
  final String label;

  const _GradePill({required this.label, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 70,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFEDF1F5),
        borderRadius: BorderRadius.circular(1000),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF2D2E2E),
              fontFamily: 'IBM Plex Sans Arabic',
            ),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.close, size: 16, color: Color(0xFFCC3E4E)),
        ],
      ),
    );
  }
}
