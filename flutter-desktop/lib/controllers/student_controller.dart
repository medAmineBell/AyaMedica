import 'dart:async';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_getx_app/config/app_config.dart';
import 'package:flutter_getx_app/controllers/branch_management_controller.dart';
import 'package:flutter_getx_app/controllers/home_controller.dart';
import 'package:flutter_getx_app/models/branch_model.dart';
import 'package:flutter_getx_app/models/bulk_upload_models.dart';
import 'package:flutter_getx_app/models/student.dart';
import 'package:flutter_getx_app/models/chronic_disease.dart';
import 'package:flutter_getx_app/models/create_student_request.dart';
import 'package:flutter_getx_app/utils/storage_service.dart';
import 'package:flutter_getx_app/controllers/resources_controller.dart';
import 'package:flutter_getx_app/screens/students/widgets/student_details_sheet_widget.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:flutter_getx_app/utils/app_snackbar.dart';

class StudentController extends GetxController {
  // Services
  final StorageService _storageService = Get.find();
  final ResourcesController _resourcesController = Get.find<ResourcesController>();

  // Reactive variables
  final RxList<Student> _allStudents = <Student>[].obs;
  final RxList<Student> filteredStudents = <Student>[].obs;
  final RxString searchQuery = ''.obs;
  final TextEditingController searchTextController = TextEditingController();
  final RxString selectedFilter = 'All'.obs;
  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs;
  final RxInt currentPage = 1.obs;
  final RxInt itemsPerPage = 10.obs;
  final RxInt totalStudents = 0.obs;
  final RxInt totalPages = 0.obs;
  final RxList<BulkUploadRowResult> defectiveRecords =
      <BulkUploadRowResult>[].obs;
  final RxBool hasDefectiveRecords = false.obs;
  final RxnString defectedRecordsFileBase64 = RxnString();
  final RxnString lastBulkUploadMessage = RxnString();
  final Rxn<BulkUploadResponse> lastBulkUploadResponse =
      Rxn<BulkUploadResponse>();

  // Filter state (single selection)
  final Rx<String?> selectedGrade = Rx<String?>(null);
  final Rx<String?> selectedClass = Rx<String?>(null);
  final RxList<String> availableGrades = <String>[].obs;
  final RxList<String> availableClasses = <String>[].obs;

  int get activeFilterCount => (selectedGrade.value != null ? 1 : 0) + (selectedClass.value != null ? 1 : 0);

  // Branch ID from storage
  final RxString selectedBranchId = ''.obs;

  // Branches available to this user (for the branch switcher on
  // ClinicStudentListScreen). Mirrors ClinicVisitsController.
  final RxList<BranchModel> accessibleBranches = <BranchModel>[].obs;
  Worker? _branchesWorker;

  // Debounce timer for search
  Timer? _searchDebounce;

  @override
  void onInit() {
    super.onInit();
    _loadBranchId();
    _loadAccessibleBranches();
    _updateAvailableLists();
    // Update available grades/classes when ResourcesController loads data
    ever(_resourcesController.classes, (_) => _updateAvailableLists());
    // Update available classes when grade selection changes
    ever(selectedGrade, (_) => _updateAvailableLists());
    loadStudents();
  }

  @override
  void onClose() {
    _searchDebounce?.cancel();
    _branchesWorker?.dispose();
    searchTextController.dispose();
    super.onClose();
  }

  void _loadAccessibleBranches() {
    final branchData = _storageService.getSelectedBranchData();
    if (branchData != null && (branchData['id'] ?? '').toString().isNotEmpty) {
      accessibleBranches.assignAll([
        BranchModel(
          id: branchData['id'].toString(),
          name: (branchData['name'] ?? 'Selected branch').toString(),
          role: '',
          icon: '',
        ),
      ]);
    }

    if (Get.isRegistered<BranchManagementController>()) {
      final branchCtl = Get.find<BranchManagementController>();
      if (branchCtl.branches.isNotEmpty) {
        accessibleBranches.assignAll(branchCtl.branches);
      }
      _branchesWorker = ever<List<BranchModel>>(branchCtl.branches, (list) {
        if (list.isNotEmpty) {
          accessibleBranches.assignAll(list);
        }
      });
    }
  }

  String get selectedBranchName {
    final match = accessibleBranches
        .firstWhereOrNull((b) => b.id == selectedBranchId.value);
    return match?.name ?? 'Select branch';
  }

  Future<void> changeBranch(String branchId) async {
    if (branchId.isEmpty || branchId == selectedBranchId.value) return;
    selectedBranchId.value = branchId;
    currentPage.value = 1;
    await loadStudents();
  }

  // Load branch ID from storage
  void _loadBranchId() {
    final branchData = _storageService.getSelectedBranchData();
    if (branchData != null) {
      selectedBranchId.value = branchData['id'] ?? '';
    }
  }

  // Update available grades and classes from ResourcesController
  void _updateAvailableLists() {
    availableGrades.assignAll(_resourcesController.availableGrades);
    availableClasses.assignAll(
      _resourcesController.getClassNamesForGrade(selectedGrade.value),
    );
  }

  void clearDefectiveRecords() {
    defectiveRecords.clear();
    defectedRecordsFileBase64.value = null;
    lastBulkUploadMessage.value = null;
    lastBulkUploadResponse.value = null;
    hasDefectiveRecords.value = false;
  }

  void handleBulkUploadResponse(BulkUploadResponse response) {
    final failed = response.results.where((r) => !r.success).toList();
    print('📋 handleBulkUploadResponse: total=${response.total} successful=${response.successful} failed=${failed.length} (created=${response.created} updated=${response.updated} transferred=${response.transferred})');

    defectiveRecords.assignAll(failed);
    defectedRecordsFileBase64.value = response.errorFileBase64;
    lastBulkUploadMessage.value = response.message;
    lastBulkUploadResponse.value = response;
    hasDefectiveRecords.value = failed.isNotEmpty;

    // Refresh the underlying list either way so created/updated rows show up
    // when the user later returns to the students list.
    loadStudents();

    final homeController = Get.find<HomeController>();
    if (failed.isEmpty) {
      print('✅ All rows processed successfully. Navigating to students list.');
      appSnackbar(
        'Upload Complete',
        response.message,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
      );
      homeController.navigateToStudentsList();
    } else {
      print('⚠️ ${failed.length} rows still defected. Staying on results screen.');
      appSnackbar(
        'Upload Completed With Issues',
        response.message,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
      );
      homeController.navigateToBulkUploadResults();
    }
  }

  Future<void> downloadDefectedRecordsFile() async {
    final b64 = defectedRecordsFileBase64.value;
    print('📥 downloadDefectedRecordsFile invoked. base64 length=${b64?.length ?? 0}');
    if (b64 == null || b64.isEmpty) {
      appSnackbar(
        'No File Available',
        'There is no defected records file to download.',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    try {
      // Strip whitespace just in case the server pretty-printed the base64.
      final clean = b64.replaceAll(RegExp(r'\s'), '');
      final bytes = base64Decode(clean);
      print('📥 decoded ${bytes.length} bytes');

      final savePath = await FilePicker.platform.saveFile(
        dialogTitle: 'Save defected records',
        fileName: 'defected-records.xlsx',
        type: FileType.custom,
        allowedExtensions: ['xlsx'],
      );
      print('📥 saveFile returned: $savePath');

      if (savePath == null) {
        // User cancelled.
        return;
      }

      final outPath =
          savePath.toLowerCase().endsWith('.xlsx') ? savePath : '$savePath.xlsx';
      await File(outPath).writeAsBytes(bytes, flush: true);
      print('📥 wrote file to $outPath');

      appSnackbar(
        'Download Complete',
        'Defected records saved to $outPath',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e, st) {
      print('❌ downloadDefectedRecordsFile failed: $e\n$st');
      appSnackbar(
        'Download Failed',
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Getters
  List<Student> get students => filteredStudents;
  List<Student> get paginatedStudents {
    return filteredStudents;
  }

  // CREATE STUDENT - API Integration
  Future<bool> createStudent(CreateStudentRequest request) async {
    isSaving.value = true;
    try {
      print('📤 Creating student...');
      print('📤 Request body: ${jsonEncode(request.toJson())}');

      // Get access token
      final accessToken = await _storageService.getAccessToken();
      if (accessToken == null) {
        throw Exception('No access token found');
      }

      // Make API request
      final response = await http.post(
        Uri.parse(
            '${AppConfig.newBackendUrl}/api/school-admin/students'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(request.toJson()),
      );

      print('📡 Response Status: ${response.statusCode}');
      print('📡 Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);

        if (responseData['success'] == true) {
          print('✅ Student created successfully');

          appSnackbar(
            'Success',
            'Student added successfully',
            backgroundColor: Colors.green,
            colorText: Colors.white,
            duration: const Duration(seconds: 2),
          );

          // Refresh student list
          await loadStudents();

          return true;
        } else {
          throw Exception(
              responseData['message'] ?? 'Failed to create student');
        }
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'HTTP ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error creating student: $e');
      appSnackbar(
        'Error',
        'Failed to create student: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  // UPDATE STUDENT - API Integration
  Future<bool> updateStudent(
      String studentId, Map<String, dynamic> updateData) async {
    isSaving.value = true;
    try {
      print('✏️ Updating student...');
      print('📤 Student ID: $studentId');
      print('📤 Update data: ${jsonEncode(updateData)}');

      // Get access token
      final accessToken = await _storageService.getAccessToken();
      if (accessToken == null) {
        throw Exception('No access token found');
      }

      // Make API request
      final response = await http.put(
        Uri.parse(
            '${AppConfig.newBackendUrl}/api/school-admin/students/$studentId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(updateData),
      );

      print('📡 Response Status: ${response.statusCode}');
      print('📡 Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);

        if (responseData['success'] == true) {
          print('✅ Student updated successfully');

          appSnackbar(
            'Success',
            'Student updated successfully',
            backgroundColor: Colors.green,
            colorText: Colors.white,
            duration: const Duration(seconds: 2),
          );

          // Refresh student list
          await loadStudents();

          return true;
        } else {
          throw Exception(
              responseData['message'] ?? 'Failed to update student');
        }
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'HTTP ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error updating student: $e');
      appSnackbar(
        'Error',
        'Failed to update student: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  // DELETE STUDENT - API Integration
  Future<bool> deleteStudentApi(String studentId) async {
    isLoading.value = true;
    try {
      print('🗑️ Deleting student...');
      print('📤 Student ID: $studentId');

      // Get access token
      final accessToken = await _storageService.getAccessToken();
      if (accessToken == null) {
        throw Exception('No access token found');
      }

      // Make API request
      final response = await http.delete(
        Uri.parse(
            '${AppConfig.newBackendUrl}/api/school-admin/students/$studentId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      print('📡 Response Status: ${response.statusCode}');
      print('📡 Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        print('✅ Student deleted successfully');

        appSnackbar(
          'Success',
          'Student deleted successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );

        // Refresh student list
        await loadStudents();

        return true;
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'HTTP ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error deleting student: $e');
      appSnackbar(
        'Error',
        'Failed to delete student: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Load students from API
  Future<void> loadStudents({int page = 1, String? search, String? grade, String? studentClass}) async {
    if (selectedBranchId.value.isEmpty) {
      print('❌ Cannot load students: No branch ID available');
      appSnackbar(
        'Error',
        'Please select a branch first',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    isLoading.value = true;
    try {
      print('📡 Fetching students for branch: ${selectedBranchId.value}');

      // Get access token from storage
      final accessToken = await _storageService.getAccessToken();
      if (accessToken == null) {
        throw Exception('No access token found');
      }

      // Build API URL
      var urlStr = '${AppConfig.newBackendUrl}/api/school-admin/students?branchId=${selectedBranchId.value}&page=$page&limit=${itemsPerPage.value}';
      if (search != null && search.isNotEmpty) urlStr += '&search=${Uri.encodeComponent(search)}';
      if (grade != null && grade.isNotEmpty) urlStr += '&grade=${Uri.encodeComponent(grade)}';
      if (studentClass != null && studentClass.isNotEmpty) urlStr += '&studentClass=${Uri.encodeComponent(studentClass)}';
      final url = Uri.parse(urlStr);

      // Make API request
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      print('📡 Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);

        if (jsonData['success'] == true) {
          final data = jsonData['data'];
          final studentsJson = data['students'] as List;
          final pagination = data['pagination'] as Map<String, dynamic>;

          // Parse students
          final students =
              studentsJson.map((json) => _parseStudent(json)).toList();

          // Update observables
          _allStudents.value = students;
          filteredStudents.value = students;
          currentPage.value = pagination['page'];
          totalStudents.value = pagination['total'];
          totalPages.value = pagination['totalPages'];

          // Extract unique class names for filter
          final classNames = <String>{};
          for (final s in students) {
            if (s.className != null && s.className!.isNotEmpty) {
              classNames.add(s.className!);
            }
          }
          availableClasses.value = classNames.toList()..sort();

          print('✅ Students loaded successfully:');
          print('   - Students: ${students.length}');
          print('   - Total: ${totalStudents.value}');
          print('   - Page: ${currentPage.value}/${totalPages.value}');
        } else {
          throw Exception('API returned success: false');
        }
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('❌ Error loading students: $e');
      appSnackbar(
        'Error',
        'Failed to load students: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );

      // Clear data on error
      _allStudents.value = [];
      filteredStudents.value = [];
    } finally {
      isLoading.value = false;
    }
  }

  // Parse student from API response
  Student _parseStudent(Map<String, dynamic> json) {
    try {
      // Parse name
      final nameMap = json['name'] as Map<String, dynamic>?;
      final givenName = nameMap?['given'] ?? '';
      final familyName = nameMap?['family'] ?? '';
      final fullName = '$givenName $familyName'.trim();

      // Parse branch
      final branchMap = json['branch'] as Map<String, dynamic>?;
      final branchName = branchMap?['name'] ?? '';

      // Parse classes (take first class if available)
      final classList = json['classes'] as List? ?? [];
      String? grade;
      String? className;
      if (classList.isNotEmpty) {
        final firstClass = classList.first as Map<String, dynamic>;
        grade = firstClass['grade'];
        className = firstClass['name'];
      }

      // Parse last appointment
      DateTime? lastAppointmentDate;
      String? lastAppointmentType;
      if (json['lastAppointment'] != null) {
        final lastAppointment = json['lastAppointment'] as Map<String, dynamic>;
        final dateStr = lastAppointment['date'] as String?;
        if (dateStr != null) {
          lastAppointmentDate = DateTime.parse(dateStr);
        }
        lastAppointmentType = lastAppointment['type'];
      }

      // Parse guardians
      final firstGuardian = json['firstGuardian'] as Map<String, dynamic>?;
      final secondGuardian = json['secondGuardian'] as Map<String, dynamic>?;

      // Generate avatar color from ID
      final id = json['id'] as String;
      final colorValue = id.hashCode & 0xFFFFFFFF;
      final avatarColor = Color(colorValue | 0xFF000000);

      return Student(
        id: id,
        name: fullName,
        avatarColor: avatarColor,
        dateOfBirth: json['dateOfBirth'] != null
            ? DateTime.parse(json['dateOfBirth'])
            : null,
        gender: json['gender'] == 'male' ? 'Male' : 'Female',
        email: json['email'],
        phoneNumber: json['phone'],
        nationalId: json['nationalId'],
        passportIdNumber: json['passportNumber'],
        documentType: json['documentType'] as String?,
        documentNumber: json['documentNumber'] as String?,
        imageUrl: json['photo'] as String?,
        studentId: json['studentId'],
        aid: json['aid'],
        grade: grade ?? json['grade'],
        className: className,
        lastAppointmentDate: lastAppointmentDate,
        lastAppointmentType: lastAppointmentType,
        emrNumber: 0,
        bloodType: null,
        weightKg: null,
        heightCm: null,
        city: json['city'],
        street: null,
        zipCode: null,
        province: null,
        nationality: json['nationality'],
        firstGuardianName: firstGuardian?['fullName'],
        firstGuardianPhone: firstGuardian?['phone'],
        firstGuardianEmail: firstGuardian?['email'],
        firstGuardianStatus: firstGuardian?['status'],
        firstGuardianRelation: firstGuardian?['relation'],
        secondGuardianName: secondGuardian?['fullName'],
        secondGuardianPhone: secondGuardian?['phone'],
        secondGuardianEmail: secondGuardian?['email'],
        secondGuardianStatus: secondGuardian?['status'],
        secondGuardianRelation: secondGuardian?['relation'],
        goToHospital: null,
        insuranceCompany: null,
        policyNumber: null,
        chronicDiseases: [],
      );
    } catch (e) {
      print('❌ Error parsing student: $e');
      rethrow;
    }
  }

  // SEARCH with debounced API call
  void searchStudents(String query) {
    searchQuery.value = query;
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 300), () {
      _reloadWithFilters();
    });
  }

  // Filter methods (single selection)
  void selectGrade(String? grade) {
    selectedGrade.value = grade;
    selectedClass.value = null; // reset class when grade changes
    _reloadWithFilters();
  }

  void selectClass(String? className) {
    selectedClass.value = className;
    _reloadWithFilters();
  }

  void clearFilters() {
    selectedGrade.value = null;
    selectedClass.value = null;
    _reloadWithFilters();
  }

  // Reload students from API with current search + filter params
  void _reloadWithFilters() {
    final search = searchQuery.value.isNotEmpty ? searchQuery.value : null;
    loadStudents(
      page: 1,
      search: search,
      grade: selectedGrade.value,
      studentClass: selectedClass.value,
    );
  }

  // Refresh table data (keeps current search & filters)
  void refreshStudents() {
    final search = searchQuery.value.isNotEmpty ? searchQuery.value : null;
    loadStudents(
      page: currentPage.value,
      search: search,
      grade: selectedGrade.value,
      studentClass: selectedClass.value,
    );
  }

  // Pagination with current filters
  void goToPage(int page) {
    if (page >= 1 && page <= totalPages.value) {
      _loadPageWithFilters(page);
    }
  }

  void previousPage() {
    if (currentPage.value > 1) {
      _loadPageWithFilters(currentPage.value - 1);
    }
  }

  void nextPage() {
    if (currentPage.value < totalPages.value) {
      _loadPageWithFilters(currentPage.value + 1);
    }
  }

  void _loadPageWithFilters(int page) {
    final search = searchQuery.value.isNotEmpty ? searchQuery.value : null;
    loadStudents(
      page: page,
      search: search,
      grade: selectedGrade.value,
      studentClass: selectedClass.value,
    );
  }

  // View student details
  void viewStudent(Student student) {
    Get.bottomSheet(
      StudentDetailsSheet(student: student),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  // Show delete confirmation dialog
  void showDeleteConfirmation(Student student) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Colors.white,
        child: SizedBox(
          width: Get.width * 0.38,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset(
                  'assets/svg/trash.svg',
                  width: 48,
                  height: 48,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Delete student details from school ?',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Do you want to remove the student from the school? '
                  'This data cannot be recovered.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        side: const BorderSide(color: Colors.grey),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Get.back();
                        deleteStudentApi(student.id);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFED1F4F),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Delete student'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Get student by ID
  Student? getStudentById(String id) {
    try {
      return _allStudents.firstWhere((student) => student.id == id);
    } catch (e) {
      return null;
    }
  }

  // Statistics
  Map<String, int> getStudentCountByGrade() {
    final gradeCount = <String, int>{};
    for (final student in _allStudents) {
      final grade = student.grade ?? 'Unknown';
      gradeCount[grade] = (gradeCount[grade] ?? 0) + 1;
    }
    return gradeCount;
  }

  Map<String, int> getStudentCountByClass() {
    final classCount = <String, int>{};
    for (final student in _allStudents) {
      final className = student.className ?? 'Unknown';
      classCount[className] = (classCount[className] ?? 0) + 1;
    }
    return classCount;
  }
}
