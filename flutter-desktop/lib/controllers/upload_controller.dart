import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_getx_app/config/app_config.dart';
import 'package:flutter_getx_app/controllers/student_controller.dart';
import 'package:flutter_getx_app/models/bulk_upload_models.dart';
import 'package:flutter_getx_app/utils/app_snackbar.dart';
import 'package:flutter_getx_app/utils/location_service.dart';
import 'package:flutter_getx_app/utils/storage_service.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class UploadController extends GetxController {
  final StorageService _storageService = Get.find();

  final RxList<UploadFile> uploadedFiles = <UploadFile>[].obs;
  final RxBool isUploading = false.obs;
  final RxnString errorMessage = RxnString();

  // Async job progress. The backend now returns 202 + jobId immediately and we
  // poll for live counters every 3s until status is completed/failed.
  final RxInt processed = 0.obs;
  final RxInt totalCount = 0.obs;
  final RxnString jobStatus = RxnString(); // queued/processing/completed/failed
  String? _jobId;
  Timer? _pollTimer;
  bool _fetchingProgress = false;

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
      // Resolve full country names ("Egypt", "Saudi Arabia") to ISO codes so
      // documentType is derived correctly regardless of how the nationality was
      // spelled in the spreadsheet. Backed by the app's country list, with the
      // parser's built-in EG/SA aliases as a fallback.
      final location =
          Get.isRegistered<LocationService>() ? Get.find<LocationService>() : null;
      String? resolveCountryKey(String raw) {
        final s = raw.trim();
        if (s.isEmpty) return null;
        final match = location?.countries.firstWhereOrNull((c) =>
            c.key.toUpperCase() == s.toUpperCase() ||
            c.code.toUpperCase() == s.toUpperCase() ||
            c.nameEn.toLowerCase() == s.toLowerCase());
        return match?.key;
      }

      final payloads = BulkUploadParser.parseExcel(
        file.bytes,
        branchCountry: branchCountry,
        countryKeyResolver: resolveCountryKey,
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
      file.progress.value = 0.5;

      // The endpoint is now async: it validates, creates a job, and returns 202
      // with { data: { jobId, total } }. Results arrive via the progress poll.
      if (response.statusCode != 200 &&
          response.statusCode != 201 &&
          response.statusCode != 202) {
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
      final data = decoded['data'];
      final jobId = data is Map ? data['jobId']?.toString() : null;
      if (jobId == null || jobId.isEmpty) {
        throw Exception('Server did not return a job id.');
      }

      _jobId = jobId;
      totalCount.value = (data['total'] as num?)?.toInt() ?? 0;
      processed.value = 0;
      jobStatus.value = 'queued';
      // Keep isUploading = true and the dialog open while we poll for progress.
      _startPolling();
      return;
    } on BulkUploadParseException catch (e) {
      file.hasError.value = true;
      errorMessage.value = e.message;
      isUploading.value = false;
    } catch (e) {
      file.hasError.value = true;
      errorMessage.value = 'Upload failed: $e';
      appSnackbar(
        'Upload Failed',
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      isUploading.value = false;
    }
  }

  void _startPolling() {
    _pollTimer?.cancel();
    // Poll immediately so the UI updates without waiting a full interval, then
    // every 3 seconds until the job completes or fails.
    _pollProgress();
    _pollTimer =
        Timer.periodic(const Duration(seconds: 3), (_) => _pollProgress());
  }

  Future<void> _pollProgress() async {
    if (_fetchingProgress || _jobId == null) return;
    _fetchingProgress = true;
    final file = uploadedFiles.isNotEmpty ? uploadedFiles.first : null;
    try {
      final accessToken = await _storageService.getAccessToken();
      if (accessToken == null || accessToken.isEmpty) {
        _failPolling('Session expired, please log in again.', file);
        return;
      }

      final url = Uri.parse(
          '${AppConfig.newBackendUrl}/api/school-admin/students/bulk-upload/$_jobId/progress');
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      if (response.statusCode != 200) {
        // 403 = not the owning user, 404 = unknown/expired job, etc.
        String message = 'HTTP ${response.statusCode}';
        try {
          final decoded = jsonDecode(response.body);
          if (decoded is Map && decoded['message'] is String) {
            message = decoded['message'];
          }
        } catch (_) {}
        _failPolling(message, file);
        return;
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) return;
      final data = decoded['data'];
      if (data is! Map) return;

      processed.value = (data['processed'] as num?)?.toInt() ?? processed.value;
      final total = (data['total'] as num?)?.toInt();
      if (total != null) totalCount.value = total;
      jobStatus.value = data['status']?.toString();

      if (file != null && totalCount.value > 0) {
        file.progress.value =
            (processed.value / totalCount.value).clamp(0.0, 1.0);
      }

      final status = jobStatus.value;
      if (status == 'completed') {
        _pollTimer?.cancel();
        final created = (data['created'] as num?)?.toInt() ?? 0;
        final updated = (data['updated'] as num?)?.toInt() ?? 0;
        final transferred = (data['transferred'] as num?)?.toInt() ?? 0;
        final failed = (data['failed'] as num?)?.toInt() ?? 0;
        // The async payload drops the human-readable message the old
        // synchronous response carried — synthesize one from the counters.
        final message =
            'Bulk upload completed: $created created, $updated updated, '
            '$transferred transferred, $failed failed.';
        final parsed = BulkUploadResponse.fromJson({
          'success': true,
          'message': message,
          'data': Map<String, dynamic>.from(data),
        });

        if (file != null) {
          file.progress.value = 1.0;
          file.isCompleted.value = true;
        }
        isUploading.value = false;

        final studentController = Get.find<StudentController>();
        // Close the dialog first so the results screen / refreshed list shows
        // underneath, then hand off to the student controller, then clean up.
        Get.back();
        studentController.handleBulkUploadResponse(parsed);
        Get.delete<UploadController>(tag: 'upload');
      } else if (status == 'failed') {
        final error = data['error']?.toString() ?? 'Bulk upload failed.';
        _failPolling(error, file);
      }
    } catch (_) {
      // Transient network errors: swallow and let the next tick retry.
    } finally {
      _fetchingProgress = false;
    }
  }

  void _failPolling(String message, UploadFile? file) {
    _pollTimer?.cancel();
    file?.hasError.value = true;
    errorMessage.value = message;
    isUploading.value = false;
    appSnackbar(
      'Upload Failed',
      message,
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }

  @override
  void onClose() {
    _pollTimer?.cancel();
    super.onClose();
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
