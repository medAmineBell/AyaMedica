import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../utils/storage_service.dart';

class AssessmentController extends GetxController {
  final StorageService _storageService = Get.find<StorageService>();

  // Appointment identifiers
  String? appointmentId;
  String? medicalRecordId;

  // Search text controllers
  final complaintSearchController = TextEditingController();
  final diseaseSearchController = TextEditingController();
  final recommendationSearchController = TextEditingController();
  final examinationController = TextEditingController();

  // Vitals text controllers
  final heartRateController = TextEditingController();
  final bloodPressureController = TextEditingController();
  final temperatureController = TextEditingController();
  final respiratoryRateController = TextEditingController();
  final bloodGlucoseController = TextEditingController();
  final oxygenSaturationController = TextEditingController();
  final heightController = TextEditingController();
  final weightController = TextEditingController();
  final assessmentNoteController = TextEditingController();

  // API search results
  final complaints = <Map<String, dynamic>>[].obs;
  final suspectedDiseases = <Map<String, dynamic>>[].obs;
  final recommendations = <Map<String, dynamic>>[].obs;

  // Selected items
  final selectedComplaints = <Map<String, dynamic>>[].obs;
  final selectedDiseases = <Map<String, dynamic>>[].obs;
  final selectedRecommendations = <Map<String, dynamic>>[].obs;

  // Drug search
  final drugResults = <Map<String, dynamic>>[].obs;
  final isLoadingDrugs = false.obs;
  final addedDrugs = <Map<String, dynamic>>[].obs;

  // Sick leave
  final sickLeaveDaysController = TextEditingController();
  final sickLeaveNotesController = TextEditingController();
  DateTime? sickLeaveStartDate;

  // Loading states
  final isLoadingComplaints = false.obs;
  final isLoadingDiseases = false.obs;
  final isLoadingRecommendations = false.obs;
  final isLoadingRecord = false.obs;
  final isSaving = false.obs;

  // Debounce timers
  Timer? _complaintDebounce;
  Timer? _diseaseDebounce;
  Timer? _recommendationDebounce;
  Timer? _drugDebounce;

  @override
  void onClose() {
    complaintSearchController.dispose();
    diseaseSearchController.dispose();
    recommendationSearchController.dispose();
    examinationController.dispose();
    heartRateController.dispose();
    bloodPressureController.dispose();
    temperatureController.dispose();
    respiratoryRateController.dispose();
    bloodGlucoseController.dispose();
    oxygenSaturationController.dispose();
    heightController.dispose();
    weightController.dispose();
    assessmentNoteController.dispose();
    sickLeaveDaysController.dispose();
    sickLeaveNotesController.dispose();
    _complaintDebounce?.cancel();
    _diseaseDebounce?.cancel();
    _recommendationDebounce?.cancel();
    _drugDebounce?.cancel();
    super.onClose();
  }

  String get _country {
    final branchData = _storageService.getSelectedBranchData();
    return branchData?['country'] as String? ?? 'EG';
  }

  Map<String, String> _authHeaders() {
    final accessToken = _storageService.getAccessToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken',
    };
  }

  // --- Initialize with appointment data ---

  void init(String aptId, String? recordId) {
    appointmentId = aptId;
    medicalRecordId = recordId;
    print('[AssessmentController] init: appointmentId=$aptId, medicalRecordId=$recordId');
    if (recordId != null) {
      fetchMedicalRecord();
    } else {
      print('[AssessmentController] No medicalRecordId, skipping fetchMedicalRecord');
    }
  }

  // --- GET Medical Record ---

  Future<void> fetchMedicalRecord() async {
    if (appointmentId == null || medicalRecordId == null) return;
    try {
      isLoadingRecord.value = true;
      final accessToken = _storageService.getAccessToken();
      if (accessToken == null) return;

      final url =
          '${AppConfig.newBackendUrl}/api/appointment-sessions/$appointmentId/medical-records/$medicalRecordId';
      print('[AssessmentController] GET $url');

      final response = await http.get(
        Uri.parse(url),
        headers: _authHeaders(),
      );

      print('[AssessmentController] fetchMedicalRecord status: ${response.statusCode}');
      print('[AssessmentController] fetchMedicalRecord body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData['success'] == true) {
          final data = jsonData['data'] as Map<String, dynamic>;
          final record = data['medicalRecord'] as Map<String, dynamic>? ?? data;
          _populateFromRecord(record);
          print('[AssessmentController] Medical record populated successfully');
        }
      }
    } catch (e) {
      print('[AssessmentController] Error loading medical record: $e');
    } finally {
      isLoadingRecord.value = false;
    }
  }

  void _populateFromRecord(Map<String, dynamic> data) {
    // Vitals
    if (data['heart_rate'] != null) {
      heartRateController.text = data['heart_rate'].toString();
    }
    if (data['blood_pressure'] != null) {
      bloodPressureController.text = data['blood_pressure'].toString();
    }
    if (data['temperature'] != null) {
      temperatureController.text = data['temperature'].toString();
    }
    if (data['respiratory_rate'] != null) {
      respiratoryRateController.text = data['respiratory_rate'].toString();
    }
    if (data['blood_glucose'] != null) {
      bloodGlucoseController.text = data['blood_glucose'].toString();
    }
    if (data['oxygen_saturation'] != null) {
      oxygenSaturationController.text = data['oxygen_saturation'].toString();
    }
    if (data['height'] != null) {
      heightController.text = data['height'].toString();
    }
    if (data['weight'] != null) {
      weightController.text = data['weight'].toString();
    }

    // Examination
    if (data['examination_details'] != null) {
      examinationController.text = data['examination_details'].toString();
    }

    // Assessment note
    if (data['assessment_note'] != null) {
      assessmentNoteController.text = data['assessment_note'].toString();
    }

    // Chief complaints (list of strings)
    if (data['chief_complaints'] is List) {
      final list = data['chief_complaints'] as List;
      selectedComplaints.assignAll(
        list.map((c) => <String, dynamic>{'complaint': c, 'name_en': c, 'name_ar': c}).toList(),
      );
    }

    // Suspected diseases (list of strings)
    if (data['suspected_diseases'] is List) {
      final list = data['suspected_diseases'] as List;
      selectedDiseases.assignAll(
        list.map((d) => <String, dynamic>{'key': d, 'name_en': d, 'name_ar': d}).toList(),
      );
    }

    // Recommendations (list of strings)
    if (data['recommendation'] is List) {
      final list = data['recommendation'] as List;
      selectedRecommendations.assignAll(
        list.map((r) => <String, dynamic>{'name': r}).toList(),
      );
    }
  }

  // --- PATCH Medical Record ---

  Future<bool> saveMedicalRecord() async {
    if (appointmentId == null || medicalRecordId == null) return false;
    try {
      isSaving.value = true;
      final accessToken = _storageService.getAccessToken();
      if (accessToken == null) return false;

      final url =
          '${AppConfig.newBackendUrl}/api/appointment-sessions/$appointmentId/medical-records/$medicalRecordId';

      print('[AssessmentController] PATCH $url');

      final request = http.MultipartRequest('PATCH', Uri.parse(url));
      request.headers['Authorization'] = 'Bearer $accessToken';

      // Vitals
      if (heartRateController.text.isNotEmpty) {
        request.fields['heart_rate'] = heartRateController.text;
      }
      if (bloodPressureController.text.isNotEmpty) {
        request.fields['blood_pressure'] = bloodPressureController.text;
      }
      if (temperatureController.text.isNotEmpty) {
        request.fields['temperature'] = temperatureController.text;
      }
      if (respiratoryRateController.text.isNotEmpty) {
        request.fields['respiratory_rate'] = respiratoryRateController.text;
      }
      if (bloodGlucoseController.text.isNotEmpty) {
        request.fields['blood_glucose'] = bloodGlucoseController.text;
      }
      if (oxygenSaturationController.text.isNotEmpty) {
        request.fields['oxygen_saturation'] = oxygenSaturationController.text;
      }
      if (heightController.text.isNotEmpty) {
        request.fields['height'] = heightController.text;
      }
      if (weightController.text.isNotEmpty) {
        request.fields['weight'] = weightController.text;
      }

      // Assessment fields
      request.fields['chief_complaints'] = jsonEncode(complaintValues);
      request.fields['examination_details'] = examinationController.text;
      request.fields['suspected_diseases'] = jsonEncode(diseaseKeys);
      request.fields['recommendation'] = jsonEncode(recommendationNames);

      if (assessmentNoteController.text.isNotEmpty) {
        request.fields['assessment_note'] = assessmentNoteController.text;
      }

      // Drugs — always send (empty array if none)
      request.fields['drugs'] = jsonEncode(addedDrugs.toList());
      print('[AssessmentController] drugs to save: ${addedDrugs.length} items');

      // Sick leave
      final sickLeaveDays = int.tryParse(sickLeaveDaysController.text) ?? 0;
      if (sickLeaveDays > 0) {
        final sickLeave = <String, dynamic>{
          'days': sickLeaveDays,
          'sickleave_confirmed': true,
        };
        if (sickLeaveStartDate != null) {
          sickLeave['start_date'] =
              '${sickLeaveStartDate!.year}-${sickLeaveStartDate!.month.toString().padLeft(2, '0')}-${sickLeaveStartDate!.day.toString().padLeft(2, '0')}';
        }
        request.fields['sick_leave'] = jsonEncode(sickLeave);
        print('[AssessmentController] sick_leave: $sickLeave');
      }

      // Note
      if (sickLeaveNotesController.text.isNotEmpty) {
        request.fields['note'] = sickLeaveNotesController.text;
      }

      print('[AssessmentController] PATCH fields: ${request.fields}');

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('[AssessmentController] saveMedicalRecord status: ${response.statusCode}');
      print('[AssessmentController] saveMedicalRecord body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData['success'] == true) {
          return true;
        }
      }
      Get.snackbar('Error', 'Failed to save assessment',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade100);
      return false;
    } catch (e) {
      print('[AssessmentController] Error saving medical record: $e');
      Get.snackbar('Error', 'Failed to save assessment',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade100);
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  /// Save assessment + plans data, then checkout the appointment
  Future<bool> completeWalkIn() async {
    // Step 1: PATCH medical record with all data
    final saved = await saveMedicalRecord();
    if (!saved) return false;

    // Step 2: POST checkout
    try {
      isSaving.value = true;
      final accessToken = _storageService.getAccessToken();
      if (accessToken == null) return false;

      final url =
          '${AppConfig.newBackendUrl}/api/appointment-sessions/$appointmentId/checkout';
      print('[AssessmentController] POST checkout: $url');

      final response = await http.post(
        Uri.parse(url),
        headers: _authHeaders(),
      );

      print('[AssessmentController] checkout status: ${response.statusCode}');

      if (response.statusCode == 200) {
        Get.snackbar('Success', 'Walk-in completed successfully',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green.shade100);
        return true;
      } else {
        Get.snackbar('Error', 'Failed to checkout appointment',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red.shade100);
        return false;
      }
    } catch (e) {
      print('[AssessmentController] Error checking out: $e');
      Get.snackbar('Error', 'Failed to checkout appointment',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade100);
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  // --- Complaints ---

  void onComplaintSearchChanged(String search) {
    _complaintDebounce?.cancel();
    _complaintDebounce = Timer(const Duration(milliseconds: 300), () {
      fetchComplaints(search);
    });
  }

  Future<void> fetchComplaints(String search) async {
    try {
      isLoadingComplaints.value = true;
      final accessToken = _storageService.getAccessToken();
      if (accessToken == null) return;

      var urlStr =
          '${AppConfig.newBackendUrl}/api/lookups/complaints?search=${Uri.encodeComponent(search)}';
      print('[AssessmentController] GET complaints: $urlStr');

      final response = await http.get(
        Uri.parse(urlStr),
        headers: _authHeaders(),
      );

      print('[AssessmentController] fetchComplaints status: ${response.statusCode}');
      print('[AssessmentController] fetchComplaints body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData['success'] == true) {
          final data = jsonData['data'] as List;
          complaints.assignAll(
            data.map((d) => Map<String, dynamic>.from(d)).toList(),
          );
          print('[AssessmentController] Complaints loaded: ${complaints.length} items');
        }
      }
    } catch (e) {
      print('[AssessmentController] Error loading complaints: $e');
    } finally {
      isLoadingComplaints.value = false;
    }
  }

  void addComplaint(Map<String, dynamic> item) {
    final alreadySelected =
        selectedComplaints.any((c) => c['complaint'] == item['complaint']);
    if (!alreadySelected) {
      selectedComplaints.add(item);
    }
    complaintSearchController.clear();
    complaints.clear();
  }

  void removeComplaint(Map<String, dynamic> item) {
    selectedComplaints.removeWhere((c) => c['complaint'] == item['complaint']);
  }

  // --- Suspected Diseases ---

  void onDiseaseSearchChanged(String search) {
    _diseaseDebounce?.cancel();
    _diseaseDebounce = Timer(const Duration(milliseconds: 300), () {
      fetchSuspectedDiseases(search);
    });
  }

  Future<void> fetchSuspectedDiseases(String search) async {
    try {
      isLoadingDiseases.value = true;
      final accessToken = _storageService.getAccessToken();
      if (accessToken == null) return;

      var urlStr =
          '${AppConfig.newBackendUrl}/api/lookups/suspected-diseases?search=${Uri.encodeComponent(search)}';
      print('[AssessmentController] GET suspected-diseases: $urlStr');

      final response = await http.get(
        Uri.parse(urlStr),
        headers: _authHeaders(),
      );

      print('[AssessmentController] fetchSuspectedDiseases status: ${response.statusCode}');
      print('[AssessmentController] fetchSuspectedDiseases body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData['success'] == true) {
          final data = jsonData['data'] as List;
          suspectedDiseases.assignAll(
            data.map((d) => Map<String, dynamic>.from(d)).toList(),
          );
          print('[AssessmentController] Suspected diseases loaded: ${suspectedDiseases.length} items');
        }
      }
    } catch (e) {
      print('[AssessmentController] Error loading suspected diseases: $e');
    } finally {
      isLoadingDiseases.value = false;
    }
  }

  void addDisease(Map<String, dynamic> item) {
    final alreadySelected =
        selectedDiseases.any((d) => d['key'] == item['key']);
    if (!alreadySelected) {
      selectedDiseases.add(item);
    }
    diseaseSearchController.clear();
    suspectedDiseases.clear();
  }

  void removeDisease(Map<String, dynamic> item) {
    selectedDiseases.removeWhere((d) => d['key'] == item['key']);
  }

  // --- Recommendations (Doctor Specialities) ---

  void onRecommendationSearchChanged(String search) {
    _recommendationDebounce?.cancel();
    _recommendationDebounce = Timer(const Duration(milliseconds: 300), () {
      fetchRecommendations(search);
    });
  }

  Future<void> fetchRecommendations(String search) async {
    try {
      isLoadingRecommendations.value = true;
      final accessToken = _storageService.getAccessToken();
      if (accessToken == null) return;

      var urlStr =
          '${AppConfig.newBackendUrl}/api/lookups/doctor-specialities?search=${Uri.encodeComponent(search)}&country=$_country';
      print('[AssessmentController] GET recommendations: $urlStr');

      final response = await http.get(
        Uri.parse(urlStr),
        headers: _authHeaders(),
      );

      print('[AssessmentController] fetchRecommendations status: ${response.statusCode}');
      print('[AssessmentController] fetchRecommendations body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData['success'] == true) {
          final data = jsonData['data'] as List;
          recommendations.assignAll(
            data.map((d) => Map<String, dynamic>.from(d)).toList(),
          );
          print('[AssessmentController] Recommendations loaded: ${recommendations.length} items');
        }
      }
    } catch (e) {
      print('[AssessmentController] Error loading recommendations: $e');
    } finally {
      isLoadingRecommendations.value = false;
    }
  }

  void addRecommendation(Map<String, dynamic> item) {
    final alreadySelected =
        selectedRecommendations.any((r) => r['name'] == item['name']);
    if (!alreadySelected) {
      selectedRecommendations.add(item);
    }
    recommendationSearchController.clear();
    recommendations.clear();
  }

  void removeRecommendation(Map<String, dynamic> item) {
    selectedRecommendations.removeWhere((r) => r['name'] == item['name']);
  }

  // --- Drugs Lookup ---

  void onDrugSearchChanged(String search) {
    _drugDebounce?.cancel();
    _drugDebounce = Timer(const Duration(milliseconds: 300), () {
      fetchDrugs(search);
    });
  }

  Future<void> fetchDrugs(String search) async {
    try {
      isLoadingDrugs.value = true;
      final accessToken = _storageService.getAccessToken();
      if (accessToken == null) return;

      var urlStr =
          '${AppConfig.newBackendUrl}/api/lookups/drugs?country=$_country';
      if (search.isNotEmpty) {
        urlStr += '&search=${Uri.encodeComponent(search)}';
      }

      final response = await http.get(
        Uri.parse(urlStr),
        headers: _authHeaders(),
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData['success'] == true) {
          final data = jsonData['data'] as List;
          drugResults.assignAll(
            data.map((d) => Map<String, dynamic>.from(d)).toList(),
          );
        }
      }
    } catch (e) {
      print('[AssessmentController] Error loading drugs: $e');
    } finally {
      isLoadingDrugs.value = false;
    }
  }

  void addDrug(Map<String, dynamic> drug) {
    addedDrugs.add(drug);
  }

  void removeDrug(int index) {
    addedDrugs.removeAt(index);
  }

  // --- Data getters for submission ---

  List<String> get complaintValues =>
      selectedComplaints.map((c) => c['complaint'] as String).toList();

  List<String> get diseaseKeys =>
      selectedDiseases.map((d) => d['name_en'] as String).toList();

  List<String> get recommendationNames =>
      selectedRecommendations.map((r) => r['name'] as String).toList();

  bool get isAssessmentFilled =>
      selectedComplaints.isNotEmpty &&
      selectedDiseases.isNotEmpty &&
      selectedRecommendations.isNotEmpty;
}
