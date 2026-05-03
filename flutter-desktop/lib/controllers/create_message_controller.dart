import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_getx_app/config/app_config.dart';
import 'package:flutter_getx_app/controllers/communication_controller.dart';
import 'package:flutter_getx_app/controllers/resources_controller.dart';
import 'package:flutter_getx_app/models/student.dart';
import 'package:flutter_getx_app/utils/api_service.dart';
import 'package:flutter_getx_app/utils/app_snackbar.dart';
import 'package:flutter_getx_app/utils/storage_service.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

enum MessageAudience { all, gradeClass, selected }

class CreateMessageController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  final StorageService _storageService = Get.find<StorageService>();
  final ResourcesController _resourcesController =
      Get.find<ResourcesController>();

  final Rx<MessageAudience> selectedMode = MessageAudience.all.obs;

  final Rx<String?> selectedGrade = Rx<String?>(null);
  final Rx<String?> selectedClass = Rx<String?>(null);

  final RxList<Student> students = <Student>[].obs;
  final RxList<Student> selectedStudents = <Student>[].obs;
  final RxBool isLoadingStudents = false.obs;

  final TextEditingController subjectController = TextEditingController();
  final TextEditingController bodyController = TextEditingController();

  final RxList<PlatformFile> attachments = <PlatformFile>[].obs;

  final RxBool isSending = false.obs;

  final RxList<String> grades = <String>[].obs;
  final RxList<String> classes = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    _refreshGradesAndClasses();
    ever(_resourcesController.classes, (_) => _refreshGradesAndClasses());
    ever(selectedGrade, (_) => _refreshGradesAndClasses());
    _resourcesController.loadClasses();
  }

  @override
  void onClose() {
    subjectController.dispose();
    bodyController.dispose();
    super.onClose();
  }

  void _refreshGradesAndClasses() {
    grades.assignAll(_resourcesController.availableGrades);
    classes.assignAll(
      _resourcesController.getClassNamesForGrade(selectedGrade.value),
    );
  }

  void setMode(MessageAudience mode) {
    if (selectedMode.value == mode) return;
    selectedMode.value = mode;
    selectedGrade.value = null;
    selectedClass.value = null;
    students.clear();
    selectedStudents.clear();
  }

  void setGrade(String? grade) {
    selectedGrade.value = grade;
    selectedClass.value = null;
    students.clear();
    selectedStudents.clear();
    if (selectedMode.value == MessageAudience.selected && grade != null) {
      _loadStudents(grade: grade);
    }
  }

  void setClass(String? className) {
    selectedClass.value = className;
    if (selectedMode.value == MessageAudience.selected) {
      students.clear();
      selectedStudents.clear();
      if (className != null) {
        _loadStudents(
          grade: selectedGrade.value,
          studentClass: className,
        );
      } else if (selectedGrade.value != null) {
        _loadStudents(grade: selectedGrade.value);
      }
    }
  }

  void toggleStudent(Student student) {
    final idx = selectedStudents.indexWhere((s) => s.id == student.id);
    if (idx >= 0) {
      selectedStudents.removeAt(idx);
    } else {
      selectedStudents.add(student);
    }
  }

  void replaceSelectedStudents(List<Student> list) {
    selectedStudents.assignAll(list);
  }

  void removeStudent(Student student) {
    selectedStudents.removeWhere((s) => s.id == student.id);
  }

  Future<void> pickAttachments() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      withData: true,
    );
    if (result == null) return;
    for (final file in result.files) {
      if (file.bytes == null) continue;
      attachments.add(file);
    }
  }

  void removeAttachment(int index) {
    if (index < 0 || index >= attachments.length) return;
    attachments.removeAt(index);
  }

  Future<void> _loadStudents({String? grade, String? studentClass}) async {
    isLoadingStudents.value = true;
    try {
      final branchData = _storageService.getSelectedBranchData();
      final branchId = branchData?['id'];
      final accessToken = _storageService.getAccessToken();
      if (branchId == null || accessToken == null) return;

      var urlStr =
          '${AppConfig.newBackendUrl}/api/school-admin/students?branchId=$branchId&page=1&limit=100';
      if (grade != null && grade.isNotEmpty) {
        urlStr += '&grade=${Uri.encodeComponent(grade)}';
      }
      if (studentClass != null && studentClass.isNotEmpty) {
        urlStr += '&studentClass=${Uri.encodeComponent(studentClass)}';
      }

      final response = await http.get(
        Uri.parse(urlStr),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData['success'] == true) {
          final studentsJson = jsonData['data']['students'] as List;
          students.assignAll(
              studentsJson.map((s) => _parseStudent(s)).toList());
        }
      }
    } catch (e) {
      // swallow — UI shows an empty list
    } finally {
      isLoadingStudents.value = false;
    }
  }

  Student _parseStudent(Map<String, dynamic> json) {
    final nameObj = json['name'];
    final fullName = nameObj is Map
        ? '${nameObj['given'] ?? ''} ${nameObj['family'] ?? ''}'.trim()
        : (nameObj?.toString() ?? 'Unknown');

    final classList = json['classes'] as List? ?? [];
    String? gradeVal;
    String? classNameVal;
    String? classIdVal;
    if (classList.isNotEmpty) {
      final firstClass = classList.first as Map<String, dynamic>;
      gradeVal = firstClass['grade'] as String?;
      classNameVal = firstClass['name'] as String?;
      classIdVal = firstClass['id'] as String?;
    }

    final id = json['id'] as String? ?? '';
    final colorValue = id.hashCode & 0xFFFFFFFF;
    final avatarColor = Color(colorValue | 0xFF000000);

    return Student(
      id: id,
      name: fullName,
      avatarColor: avatarColor,
      aid: json['aid'] as String?,
      grade: gradeVal ?? json['grade'] as String?,
      className: classNameVal ?? json['studentClass'] as String?,
      classId: classIdVal,
      imageUrl: json['photo'] as String?,
    );
  }

  String _mimeFor(PlatformFile file) {
    final ext = (file.extension ?? '').toLowerCase();
    switch (ext) {
      case 'pdf':
        return 'application/pdf';
      case 'png':
        return 'image/png';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      case 'doc':
        return 'application/msword';
      case 'docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      case 'xls':
        return 'application/vnd.ms-excel';
      case 'xlsx':
        return 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
      case 'txt':
        return 'text/plain';
      default:
        return 'application/octet-stream';
    }
  }

  List<Map<String, dynamic>> _buildAttachments() {
    return attachments
        .where((f) => f.bytes != null)
        .map((f) => {
              'base64': base64Encode(f.bytes!),
              'contentType': _mimeFor(f),
              'filename': f.name,
            })
        .toList();
  }

  String? _validate() {
    if (subjectController.text.trim().isEmpty) return 'Subject is required';
    switch (selectedMode.value) {
      case MessageAudience.all:
        return null;
      case MessageAudience.gradeClass:
        if ((selectedGrade.value ?? '').isEmpty &&
            (selectedClass.value ?? '').isEmpty) {
          return 'Select a grade or class';
        }
        return null;
      case MessageAudience.selected:
        if (selectedStudents.isEmpty) return 'Select at least one student';
        return null;
    }
  }

  Future<bool> send() async {
    final error = _validate();
    if (error != null) {
      appSnackbar('Validation', error,
          backgroundColor: Colors.red, colorText: Colors.white);
      return false;
    }

    final branchData = _storageService.getSelectedBranchData();
    final branchId = branchData?['id'];
    if (branchId == null) {
      appSnackbar('Error', 'No branch selected',
          backgroundColor: Colors.red, colorText: Colors.white);
      return false;
    }
    final country = (branchData?['country'] as String?)?.trim();
    final effectiveCountry = (country == null || country.isEmpty) ? 'EG' : country;
    final branchName = ((branchData?['name'] as String?) ?? '').trim();

    final subject = subjectController.text.trim();
    final body = bodyController.text.trim();
    final attachmentPayload = _buildAttachments();

    Map<String, dynamic> buildRequestData({
      required String destinationType,
      required String destinationLabel,
      Student? student,
      String? grade,
      String? className,
    }) {
      final data = <String, dynamic>{
        'destinationType': destinationType,
        'destinationLabel': destinationLabel,
      };
      if (branchName.isNotEmpty) data['branchName'] = branchName;
      if (grade != null && grade.isNotEmpty) data['grade'] = grade;
      if (className != null && className.isNotEmpty) data['class'] = className;
      if (student != null) {
        data['firstName'] = student.firstName ?? '';
        data['lastName'] = student.lastName ?? '';
        data['photo'] = student.imageUrl ?? '';
        data['studentAid'] = student.aid ?? '';
        if (student.grade != null && student.grade!.isNotEmpty) {
          data['grade'] = student.grade;
        }
        if (student.className != null && student.className!.isNotEmpty) {
          data['class'] = student.className;
        }
      }
      return data;
    }

    Map<String, dynamic> commonPayload(
      Map<String, dynamic> recipients, {
      String? relatedPatientId,
      Map<String, dynamic>? requestData,
    }) =>
        {
          'recipients': recipients,
          'subject': subject,
          'body': body,
          'attachments': attachmentPayload,
          'country': effectiveCountry,
          if (relatedPatientId != null) 'relatedPatientId': relatedPatientId,
          if (requestData != null) 'requestData': requestData,
        };

    isSending.value = true;
    try {
      switch (selectedMode.value) {
        case MessageAudience.all:
          {
            final allLabel = branchName.isNotEmpty
                ? 'All branch students · $branchName'
                : 'All branch students';
            final res = await _apiService.createMessage(commonPayload(
              {
                'type': 'branch_to_parents',
                'mode': 'all_branch_students',
                'branchId': branchId,
              },
              requestData: buildRequestData(
                destinationType: 'all_branch',
                destinationLabel: allLabel,
              ),
            ));
            return _handleResult(res);
          }
        case MessageAudience.gradeClass:
          {
            final grade = selectedGrade.value;
            final className = selectedClass.value;
            Map<String, dynamic> recipients;
            String destinationType;
            String destinationLabel;
            if (className != null && className.isNotEmpty) {
              final classMeta = grade != null && grade.isNotEmpty
                  ? _resourcesController.getClassByNameAndGrade(
                      className, grade)
                  : null;
              final classId = classMeta?['id'];
              if (classId == null) {
                appSnackbar('Error', 'Could not resolve class ID',
                    backgroundColor: Colors.red, colorText: Colors.white);
                return false;
              }
              recipients = {
                'type': 'branch_to_parents',
                'mode': 'class_students',
                'branchId': branchId,
                'classIds': [classId],
                if (grade != null && grade.isNotEmpty) 'grades': [grade],
              };
              destinationType = 'class';
              destinationLabel = grade != null && grade.isNotEmpty
                  ? 'Grade $grade · Class $className'
                  : 'Class $className';
            } else {
              recipients = {
                'type': 'branch_to_parents',
                'mode': 'grade_students',
                'branchId': branchId,
                'grades': [grade!],
              };
              destinationType = 'grade';
              destinationLabel = 'Grade $grade';
            }
            final res = await _apiService.createMessage(commonPayload(
              recipients,
              requestData: buildRequestData(
                destinationType: destinationType,
                destinationLabel: destinationLabel,
                grade: grade,
                className: className,
              ),
            ));
            return _handleResult(res);
          }
        case MessageAudience.selected:
          {
            int okCount = 0;
            final failures = <String>[];
            for (final student in selectedStudents) {
              final res = await _apiService.createMessage(commonPayload(
                {
                  'type': 'branch_to_parents',
                  'mode': 'single_student',
                  'branchId': branchId,
                  'studentId': student.id,
                },
                relatedPatientId: student.id,
                requestData: buildRequestData(
                  destinationType: 'single_student',
                  destinationLabel: student.name,
                  student: student,
                ),
              ));
              if (res['success'] == true) {
                okCount++;
              } else {
                failures.add(student.name);
              }
            }
            final total = selectedStudents.length;
            if (okCount == total) {
              appSnackbar('Success', 'Sent to $okCount students',
                  backgroundColor: Colors.green, colorText: Colors.white);
              _refreshSentTab();
              return true;
            } else if (okCount > 0) {
              appSnackbar(
                'Partial',
                'Sent to $okCount/$total. Failed: ${failures.join(', ')}',
                backgroundColor: Colors.orange,
                colorText: Colors.white,
              );
              _refreshSentTab();
              return true;
            } else {
              appSnackbar('Error', 'Failed to send message',
                  backgroundColor: Colors.red, colorText: Colors.white);
              return false;
            }
          }
      }
    } finally {
      isSending.value = false;
    }
  }

  bool _handleResult(Map<String, dynamic> res) {
    if (res['success'] == true) {
      appSnackbar('Success', 'Message sent',
          backgroundColor: Colors.green, colorText: Colors.white);
      _refreshSentTab();
      return true;
    }
    appSnackbar(
      'Error',
      (res['error'] ?? 'Failed to send message').toString(),
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
    return false;
  }

  void _refreshSentTab() {
    try {
      final comm = Get.find<CommunicationController>();
      comm.selectedStatusFilter.value = 'Sent';
      comm.selectedType.value = 'sent';
      comm.selectedMessage.value = null;
      comm.fetchInboxMessages(page: 1, type: 'sent');
    } catch (_) {}
  }
}
