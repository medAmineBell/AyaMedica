import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_getx_app/config/app_config.dart';
import 'package:flutter_getx_app/controllers/student_controller.dart';
import 'package:flutter_getx_app/models/bulk_upload_models.dart';
import 'package:flutter_getx_app/utils/app_snackbar.dart';
import 'package:flutter_getx_app/utils/storage_service.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class UploadController extends GetxController {
  final StorageService _storageService = Get.find();

  final RxList<UploadFile> uploadedFiles = <UploadFile>[].obs;
  final RxBool isUploading = false.obs;
  final RxnString errorMessage = RxnString();

  bool get canSubmit =>
      uploadedFiles.length == 1 &&
      !isUploading.value &&
      !uploadedFiles.first.hasError.value;

  Future<void> pickFiles() async {
    try {
      errorMessage.value = null;
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls'],
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) return;

      final platformFile = result.files.first;
      Uint8List? fileBytes = platformFile.bytes;
      if (fileBytes == null && platformFile.path != null) {
        fileBytes = await File(platformFile.path!).readAsBytes();
      }
      if (fileBytes == null) {
        errorMessage.value = 'Could not read file: ${platformFile.name}';
        return;
      }

      uploadedFiles
        ..clear()
        ..add(UploadFile(
          name: platformFile.name,
          size: platformFile.size,
          bytes: fileBytes,
        ));
    } catch (e) {
      errorMessage.value = 'Failed to pick file: $e';
    }
  }

  void removeFile(UploadFile file) {
    uploadedFiles.removeWhere((f) => f.name == file.name);
    errorMessage.value = null;
  }

  Future<void> downloadTemplate() async {
    try {
      errorMessage.value = null;
      final bytes = BulkUploadParser.buildTemplateXlsx();
      final savePath = await FilePicker.platform.saveFile(
        dialogTitle: 'Save students template',
        fileName: 'ayamedica_students_template.xlsx',
        type: FileType.custom,
        allowedExtensions: ['xlsx'],
      );
      if (savePath == null) return;

      final pathWithExt =
          savePath.toLowerCase().endsWith('.xlsx') ? savePath : '$savePath.xlsx';
      await File(pathWithExt).writeAsBytes(bytes, flush: true);

      appSnackbar(
        'Template saved',
        'ayamedica_students_template.xlsx saved to your selected location.',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      errorMessage.value = 'Could not save template: $e';
    }
  }

  Future<void> submit() async {
    if (uploadedFiles.isEmpty || isUploading.value) return;
    final file = uploadedFiles.first;

    final studentController = Get.find<StudentController>();
    final branchId = studentController.selectedBranchId.value;
    if (branchId.isEmpty) {
      errorMessage.value = 'Please select a branch first.';
      return;
    }

    final branchData = _storageService.getSelectedBranchData();
    final branchCountry =
        (branchData?['country'] as String?)?.trim().toUpperCase() ?? '';
    if (branchCountry != 'EG' && branchCountry != 'SA') {
      errorMessage.value =
          'Bulk upload is only supported for Egypt (EG) and Saudi Arabia (SA) branches.';
      return;
    }

    final accessToken = await _storageService.getAccessToken();
    if (accessToken == null || accessToken.isEmpty) {
      errorMessage.value = 'Session expired, please log in again.';
      return;
    }

    isUploading.value = true;
    errorMessage.value = null;
    file.hasError.value = false;
    file.progress.value = 0.1;

    try {
      final payloads = BulkUploadParser.parseExcel(
        file.bytes,
        branchCountry: branchCountry,
      );
      if (payloads.isEmpty) {
        throw BulkUploadParseException(
            'No student rows found in the spreadsheet.');
      }
      file.progress.value = 0.45;

      final url = Uri.parse(
          '${AppConfig.newBackendUrl}/api/school-admin/students/bulk-upload-json?branchId=$branchId');

      final body = jsonEncode({
        'students': payloads.map((p) => p.toJson()).toList(),
      });

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: body,
      );
      file.progress.value = 0.9;

      if (response.statusCode != 200 && response.statusCode != 201) {
        String message = 'HTTP ${response.statusCode}';
        try {
          final decoded = jsonDecode(response.body);
          if (decoded is Map && decoded['message'] is String) {
            message = decoded['message'];
          }
        } catch (_) {}
        throw Exception(message);
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        throw Exception('Unexpected response from server.');
      }

      final parsed = BulkUploadResponse.fromJson(decoded);
      file.progress.value = 1.0;
      file.isCompleted.value = true;

      // Close the upload dialog FIRST so the results screen (or refreshed
      // list) is visible underneath. The dialog is opened via Flutter's
      // showDialog, so Get.isDialogOpen is false here — call Get.back()
      // unconditionally to pop the dialog route.
      Get.back();

      // Then notify the student controller, which navigates to the results
      // screen (on partial failure) or back to the list (on full success).
      studentController.handleBulkUploadResponse(parsed);

      // Clean up so the next dialog open starts with a fresh controller
      // (otherwise the stale "completed" file would remain in the list).
      Get.delete<UploadController>(tag: 'upload');
      return;
    } on BulkUploadParseException catch (e) {
      file.hasError.value = true;
      errorMessage.value = e.message;
    } catch (e) {
      file.hasError.value = true;
      errorMessage.value = 'Upload failed: $e';
      appSnackbar(
        'Upload Failed',
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isUploading.value = false;
    }
  }
}

class UploadFile {
  final String name;
  final int size;
  final Uint8List bytes;
  final RxDouble progress;
  final RxBool isCompleted;
  final RxBool hasError;

  UploadFile({
    required this.name,
    required this.size,
    required this.bytes,
    double progress = 0.0,
  })  : progress = progress.obs,
        isCompleted = false.obs,
        hasError = false.obs;
}
