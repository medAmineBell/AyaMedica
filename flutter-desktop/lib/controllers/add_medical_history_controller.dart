import 'dart:async';
import 'package:get/get.dart';
import '../utils/api_service.dart';
import '../utils/storage_service.dart';

class AddMedicalHistoryController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  final StorageService _storageService = Get.find<StorageService>();

  // Lookup search state
  final lookupResults = <Map<String, dynamic>>[].obs;
  final isSearchingLookup = false.obs;
  Timer? _lookupDebounce;

  // Drug search state
  final drugResults = <Map<String, dynamic>>[].obs;
  final isSearchingDrugs = false.obs;
  Timer? _drugDebounce;

  // Submission state
  final isSubmitting = false.obs;

  String get country {
    final branchData = _storageService.getSelectedBranchData();
    return branchData?['country'] as String? ?? 'EG';
  }

  String? get organizationId {
    final branchData = _storageService.getSelectedBranchData();
    return branchData?['id'] as String?;
  }

  @override
  void onClose() {
    _lookupDebounce?.cancel();
    _drugDebounce?.cancel();
    super.onClose();
  }

  // --- Lookup search (diseases, surgeries, vaccinations) ---

  void onLookupSearchChanged(String query, String category) {
    _lookupDebounce?.cancel();
    if (query.trim().isEmpty) {
      lookupResults.clear();
      return;
    }
    _lookupDebounce = Timer(const Duration(milliseconds: 300), () {
      _fetchLookupSearch(query, category);
    });
  }

  Future<void> _fetchLookupSearch(String query, String category) async {
    try {
      isSearchingLookup.value = true;
      final result = await _apiService.searchMedicalRecordLookups(
        type: category,
        country: country,
        search: query,
      );
      if (result['success'] == true && result['data'] is List) {
        lookupResults.assignAll(
          (result['data'] as List)
              .map((e) => Map<String, dynamic>.from(e))
              .toList(),
        );
      } else {
        lookupResults.clear();
      }
    } catch (_) {
      lookupResults.clear();
    } finally {
      isSearchingLookup.value = false;
    }
  }

  void clearLookupResults() {
    lookupResults.clear();
  }

  // --- Drug search ---

  void onDrugSearchChanged(String query) {
    _drugDebounce?.cancel();
    if (query.trim().isEmpty) {
      drugResults.clear();
      return;
    }
    _drugDebounce = Timer(const Duration(milliseconds: 300), () {
      _fetchDrugSearch(query);
    });
  }

  Future<void> _fetchDrugSearch(String query) async {
    try {
      isSearchingDrugs.value = true;
      final result = await _apiService.searchDrugs(
        country: country,
        search: query,
      );
      if (result['success'] == true && result['data'] is List) {
        drugResults.assignAll(
          (result['data'] as List)
              .map((e) => Map<String, dynamic>.from(e))
              .toList(),
        );
      } else {
        drugResults.clear();
      }
    } catch (_) {
      drugResults.clear();
    } finally {
      isSearchingDrugs.value = false;
    }
  }

  void clearDrugResults() {
    drugResults.clear();
  }

  // --- Submit medical history ---

  Future<bool> submitMedicalHistory({
    required String patientId,
    required String category,
    DateTime? date,
    Map<String, String>? disease,
    List<Map<String, dynamic>>? medications,
    List<Map<String, dynamic>>? items,
    String? note,
  }) async {
    isSubmitting.value = true;
    try {
      final body = <String, dynamic>{
        'patientId': patientId,
        'category': category,
        'organizationId': organizationId,
        'country': country,
      };

      if (date != null) body['date'] = date.toIso8601String();
      if (note != null && note.isNotEmpty) body['note'] = note;
      if (disease != null) body['disease'] = disease;
      if (medications != null && medications.isNotEmpty) {
        body['medications'] = medications;
      }
      if (items != null && items.isNotEmpty) {
        body['items'] = items;
      }

      final result = await _apiService.submitMedicalHistory(body: body);
      return result['success'] == true;
    } catch (_) {
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }
}
