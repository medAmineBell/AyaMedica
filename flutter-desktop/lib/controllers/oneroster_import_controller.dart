import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_getx_app/routes/app_pages.dart';
import 'package:flutter_getx_app/utils/api_service.dart';
import 'package:flutter_getx_app/utils/app_snackbar.dart';
import 'package:get/get.dart';

class OneRosterImportController extends GetxController {
  final ApiService _api = Get.find<ApiService>();

  final RxBool isLoadingOrg = true.obs;
  final RxnString orgLoadError = RxnString();
  final RxnString parentOrgId = RxnString();
  final RxnString parentOrgName = RxnString();

  final Rxn<PlatformFile> pickedFile = Rxn<PlatformFile>();
  final RxBool dryRun = true.obs;

  final RxBool isSubmitting = false.obs;
  final Rxn<Map<String, dynamic>> lastResult = Rxn<Map<String, dynamic>>();
  final RxnString lastErrorMessage = RxnString();

  @override
  void onInit() {
    super.onInit();
    fetchParentOrganization();
  }

  Future<void> fetchParentOrganization() async {
    isLoadingOrg.value = true;
    orgLoadError.value = null;
    final result = await _api.fetchOrganizationsList();
    if (result['success'] == true) {
      final data = result['data'];
      if (data is List && data.isNotEmpty) {
        final parent = data.firstWhere(
          (o) => o is Map && o['branches'] is List,
          orElse: () => data.first,
        );
        if (parent is Map) {
          parentOrgId.value = parent['id']?.toString();
          parentOrgName.value = parent['name']?.toString();
        } else {
          orgLoadError.value = 'Unexpected organization payload shape.';
        }
      } else {
        orgLoadError.value = 'No organizations returned.';
      }
    } else {
      orgLoadError.value = result['error']?.toString() ?? 'Failed to load organizations.';
    }
    isLoadingOrg.value = false;
  }

  Future<void> pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
      allowMultiple: false,
      withData: true,
    );
    if (result != null && result.files.isNotEmpty) {
      pickedFile.value = result.files.first;
    }
  }

  void clearFile() {
    pickedFile.value = null;
  }

  Future<void> submit() async {
    final orgId = parentOrgId.value;
    final file = pickedFile.value;
    if (orgId == null || orgId.isEmpty) {
      appSnackbar(
        'Missing organization',
        'Owner organization is not loaded yet.',
        backgroundColor: Colors.red[100],
        colorText: Colors.red[800],
      );
      return;
    }
    if (file == null) {
      appSnackbar(
        'No file selected',
        'Please pick a OneRoster .json bundle first.',
        backgroundColor: Colors.red[100],
        colorText: Colors.red[800],
      );
      return;
    }

    isSubmitting.value = true;
    lastErrorMessage.value = null;
    lastResult.value = null;

    final response = await _api.importOneRoster(
      organizationId: orgId,
      fileName: file.name,
      filePath: file.path,
      fileBytes: file.bytes,
      dryRun: dryRun.value,
    );

    isSubmitting.value = false;

    if (response['success'] == true) {
      lastResult.value = response['data'] as Map<String, dynamic>?;
      final summary = lastResult.value?['summary'] as Map<String, dynamic>?;
      final total = summary?['total'] ?? 0;
      final successful = summary?['successful'] ?? 0;
      appSnackbar(
        dryRun.value ? 'Dry-run complete' : 'Import complete',
        '$successful of $total rows succeeded.',
        backgroundColor: Colors.green[50],
        colorText: Colors.green[900],
      );
    } else {
      final error = response['error']?.toString() ?? 'Import failed.';
      lastErrorMessage.value = error;
      appSnackbar(
        'Import failed',
        error,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[800],
      );
    }
  }

  void skip() {
    Get.offAllNamed(Routes.ORGANISATION);
  }

  void continueToBranchSelection() {
    Get.offAllNamed(Routes.ORGANISATION);
  }
}
