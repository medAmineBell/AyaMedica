import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/upload_controller.dart';

class UploadStudentsDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final uploadController = UploadController();
    Get.put(uploadController, tag: 'upload');

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        width: 600,
        padding: EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: GetBuilder<UploadController>(
          tag: 'upload',
          builder: (uploadController) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _UploadDialogHeader(),
                SizedBox(height: 24),
                _UploadInstructions(),
                SizedBox(height: 24),
                _UploadArea(controller: uploadController),
                SizedBox(height: 24),
                _UploadedFilesList(controller: uploadController),
                SizedBox(height: 32),
                _UploadDialogActions(controller: uploadController),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _UploadDialogHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Upload student details',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        IconButton(
          onPressed: () {
            Get.delete<UploadController>(tag: 'upload');
            Get.back();
          },
          icon: Icon(Icons.close, color: Colors.grey.shade600),
          style: IconButton.styleFrom(
            backgroundColor: Colors.grey.shade100,
            shape: CircleBorder(),
          ),
        ),
      ],
    );
  }
}

class _UploadInstructions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Text(
      'You may download ayamedica_students_template.xlsx fill it, and upload it here',
      style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
    );
  }
}

class _UploadArea extends StatelessWidget {
  final UploadController controller;

  const _UploadArea({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 120,
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey.shade300,
          style: BorderStyle.solid,
        ),
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey.shade50,
      ),
      child: InkWell(
        onTap: () => controller.pickFiles(),
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
            SizedBox(height: 12),
            Text(
              'Upload file',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UploadedFilesList extends StatelessWidget {
  final UploadController controller;

  const _UploadedFilesList({required this.controller});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<UploadController>(
      tag: 'upload',
      builder: (controller) {
        if (controller.uploadedFiles.isEmpty) {
          return SizedBox.shrink();
        }

        return Container(
          constraints: BoxConstraints(maxHeight: 300),
          child: Column(
            children: controller.uploadedFiles
                .map((file) => UploadFileItem(
                      file: file,
                      controller: controller,
                    ))
                .toList(),
          ),
        );
      },
    );
  }
}

class UploadFileItem extends StatelessWidget {
  final dynamic file; // Replace with your actual file type
  final UploadController controller;

  const UploadFileItem({
    Key? key,
    required this.file,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      margin: EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          _FileIcon(),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  file.name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 6),
                _FileStatus(file: file, controller: controller),
              ],
            ),
          ),
          _RemoveFileButton(
            onPressed: () => controller.removeFile(file),
          ),
        ],
      ),
    );
  }
}

class _FileIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
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
    );
  }
}

class _FileStatus extends StatelessWidget {
  final dynamic file;
  final UploadController controller;

  const _FileStatus({required this.file, required this.controller});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<UploadController>(
      tag: 'upload',
      builder: (controller) {
        final currentFile = controller.uploadedFiles.firstWhere(
          (f) => f.name == file.name,
          orElse: () => file,
        );

        if (currentFile.hasError.value) {
          return Text(
            'Error processing file',
            style: TextStyle(
              fontSize: 12,
              color: Colors.red.shade600,
              fontWeight: FontWeight.w500,
            ),
          );
        } else if (currentFile.isCompleted.value) {
          return Text(
            'Upload completed successfully',
            style: TextStyle(
              fontSize: 12,
              color: Colors.green.shade600,
              fontWeight: FontWeight.w500,
            ),
          );
        } else {
          return _FileProgress(file: currentFile);
        }
      },
    );
  }
}

class _FileProgress extends StatelessWidget {
  final dynamic file;

  const _FileProgress({required this.file});

  @override
  Widget build(BuildContext context) {
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
                  widthFactor: file.progress.value.clamp(0.0, 1.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: 12),
            Text(
              '${(file.progress.value * 100).toInt()}%',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        SizedBox(height: 4),
        Text(
          'Processing...',
          style: TextStyle(
            fontSize: 10,
            color: Colors.blue.shade600,
          ),
        ),
      ],
    );
  }
}

class _RemoveFileButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _RemoveFileButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(Icons.close, color: Colors.white, size: 16),
      style: IconButton.styleFrom(
        backgroundColor: Colors.red,
        shape: CircleBorder(),
        minimumSize: Size(28, 28),
        padding: EdgeInsets.zero,
      ),
    );
  }
}

class _UploadDialogActions extends StatelessWidget {
  final UploadController controller;

  const _UploadDialogActions({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () {
              Get.delete<UploadController>(tag: 'upload');
              Get.back();
            },
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 16),
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
        SizedBox(width: 16),
        Expanded(
          child: GetBuilder<UploadController>(
            tag: 'upload',
            builder: (controller) {
              final hasCompleted = controller.uploadedFiles
                  .any((f) => f.isCompleted.value);
              return ElevatedButton(
                onPressed: hasCompleted
                    ? () {
                        Get.delete<UploadController>(tag: 'upload');
                        Get.back();
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Complete',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}