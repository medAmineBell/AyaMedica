import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/upload_controller.dart';

class UploadStudentsDialog extends StatelessWidget {
  static const String _tag = 'upload';

  const UploadStudentsDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(UploadController(), tag: _tag);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        width: 600,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _UploadDialogHeader(tag: _tag),
            const SizedBox(height: 24),
            _UploadInstructions(controller: controller),
            const SizedBox(height: 24),
            _UploadArea(controller: controller),
            const SizedBox(height: 16),
            _UploadErrorBanner(controller: controller),
            _UploadedFilesList(controller: controller),
            const SizedBox(height: 32),
            _UploadDialogActions(controller: controller, tag: _tag),
          ],
        ),
      ),
    );
  }
}

class _UploadDialogHeader extends StatelessWidget {
  final String tag;
  const _UploadDialogHeader({required this.tag});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Upload student details',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        IconButton(
          onPressed: () {
            Get.delete<UploadController>(tag: tag);
            Get.back();
          },
          icon: Icon(Icons.close, color: Colors.grey.shade600),
          style: IconButton.styleFrom(
            backgroundColor: Colors.grey.shade100,
            shape: const CircleBorder(),
          ),
        ),
      ],
    );
  }
}

class _UploadInstructions extends StatelessWidget {
  final UploadController controller;
  const _UploadInstructions({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Don't have the template? Download it, fill in your students, and upload it here. "
          "documentType is filled in automatically based on the branch and each student's nationality.",
          style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 12),
        Obx(() => OutlinedButton.icon(
              onPressed: controller.isUploading.value
                  ? null
                  : () => controller.downloadTemplate(),
              icon: const Icon(Icons.download_outlined, size: 18),
              label: const Text('Download template'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF1339FF),
                side: const BorderSide(color: Color(0xFF1339FF)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            )),
      ],
    );
  }
}

class _UploadArea extends StatelessWidget {
  final UploadController controller;

  const _UploadArea({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final hasFile = controller.uploadedFiles.isNotEmpty;
      final disabled = controller.isUploading.value || hasFile;
      return Opacity(
        opacity: disabled ? 0.5 : 1.0,
        child: Container(
          width: double.infinity,
          height: 120,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
            color: Colors.grey.shade50,
          ),
          child: InkWell(
            onTap: disabled ? null : () => controller.pickFiles(),
            borderRadius: BorderRadius.circular(8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.add,
                    color: Colors.grey.shade600,
                    size: 24,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  hasFile
                      ? 'Remove the current file to pick another'
                      : 'Upload file',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}

class _UploadErrorBanner extends StatelessWidget {
  final UploadController controller;

  const _UploadErrorBanner({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final msg = controller.errorMessage.value;
      if (msg == null || msg.isEmpty) return const SizedBox.shrink();
      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFFEE2E2),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFFECACA)),
        ),
        child: Row(
          children: [
            const Icon(Icons.error_outline,
                color: Color(0xFFB91C1C), size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                msg,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF7F1D1D),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _UploadedFilesList extends StatelessWidget {
  final UploadController controller;

  const _UploadedFilesList({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.uploadedFiles.isEmpty) {
        return const SizedBox.shrink();
      }
      return Container(
        constraints: const BoxConstraints(maxHeight: 220),
        child: Column(
          children: controller.uploadedFiles
              .map((file) =>
                  _UploadFileItem(file: file, controller: controller))
              .toList(),
        ),
      );
    });
  }
}

class _UploadFileItem extends StatelessWidget {
  final UploadFile file;
  final UploadController controller;

  const _UploadFileItem({required this.file, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.description_outlined,
              color: Colors.grey.shade600,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  file.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 6),
                _FileStatus(file: file),
              ],
            ),
          ),
          Obx(() {
            if (controller.isUploading.value) {
              return const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              );
            }
            return IconButton(
              onPressed: () => controller.removeFile(file),
              icon: const Icon(Icons.close, color: Colors.white, size: 16),
              style: IconButton.styleFrom(
                backgroundColor: Colors.red,
                shape: const CircleBorder(),
                minimumSize: const Size(28, 28),
                padding: EdgeInsets.zero,
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _FileStatus extends StatelessWidget {
  final UploadFile file;

  const _FileStatus({required this.file});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (file.hasError.value) {
        return Text(
          'Error processing file',
          style: TextStyle(
            fontSize: 12,
            color: Colors.red.shade600,
            fontWeight: FontWeight.w500,
          ),
        );
      }
      if (file.isCompleted.value) {
        return Text(
          'Upload completed successfully',
          style: TextStyle(
            fontSize: 12,
            color: Colors.green.shade600,
            fontWeight: FontWeight.w500,
          ),
        );
      }
      return _FileProgress(file: file);
    });
  }
}

class _FileProgress extends StatelessWidget {
  final UploadFile file;

  const _FileProgress({required this.file});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final progress = file.progress.value;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: progress.clamp(0.0, 1.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${(progress * 100).toInt()}%',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            progress >= 1.0 ? 'Done' : 'Ready to upload',
            style: TextStyle(
              fontSize: 10,
              color: Colors.blue.shade600,
            ),
          ),
        ],
      );
    });
  }
}

class _UploadDialogActions extends StatelessWidget {
  final UploadController controller;
  final String tag;

  const _UploadDialogActions({required this.controller, required this.tag});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () {
              Get.delete<UploadController>(tag: tag);
              Get.back();
            },
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: BorderSide(color: Colors.grey.shade300),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Cancel',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Obx(() {
            final enabled = controller.canSubmit;
            return ElevatedButton(
              onPressed: enabled ? () => controller.submit() : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1339FF),
                disabledBackgroundColor: Colors.grey.shade300,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: controller.isUploading.value
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'Complete',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
            );
          }),
        ),
      ],
    );
  }
}
