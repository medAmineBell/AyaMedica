import 'dart:io';
import 'dart:typed_data';

import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/student.dart';
import 'student_controller.dart';

class UploadController extends GetxController {
  final RxList<UploadFile> uploadedFiles = <UploadFile>[].obs;
  final RxBool isUploading = false.obs;

  // Pick and upload Excel files
  Future<void> pickFiles() async {
    try {
      print('🔍 Starting file picker...');
      
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls'],
        allowMultiple: true,
      );

      if (result != null && result.files.isNotEmpty) {
        print('✅ Files selected: ${result.files.length}');
        
        for (var platformFile in result.files) {
          print('🔍 Processing file: ${platformFile.name}');
          print('📏 File size: ${platformFile.size} bytes');
          print('💾 Has bytes: ${platformFile.bytes != null}');
          
          // Check if we have file data
          Uint8List? fileBytes;
          
          if (platformFile.bytes != null) {
            fileBytes = platformFile.bytes!;
            print('✅ Using bytes from picker');
          } else if (platformFile.path != null) {
            // Fallback to reading from path (for desktop)
            try {
              final file = File(platformFile.path!);
              fileBytes = await file.readAsBytes();
              print('✅ Read bytes from file path');
            } catch (e) {
              print('❌ Failed to read file from path: $e');
              continue;
            }
          }
          
          if (fileBytes != null) {
            print('📁 Creating UploadFile object for: ${platformFile.name}');
            
            final uploadFile = UploadFile(
              name: platformFile.name,
              size: platformFile.size,
              bytes: fileBytes,
              progress: 0.0,
            );
            
            print('➕ Adding file to list...');
            
            // Add file to list
            uploadedFiles.add(uploadFile);
            
            print('✅ File added! Current list length: ${uploadedFiles.length}');
            
            // Force multiple UI updates
            update();
            uploadedFiles.refresh();
            ever(uploadedFiles, (_) => update()); // Additional reactive update
            
            print('🔄 UI update triggered');
            
            // Start processing after UI updates
            Future.delayed(Duration(milliseconds: 100), () {
              print('🚀 Starting file processing...');
              _processFile(uploadFile);
            });
            
          } else {
            print('❌ No file data available for: ${platformFile.name}');
            Get.snackbar(
              'Error',
              'Could not read file: ${platformFile.name}',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.red,
              colorText: Colors.white,
            );
          }
        }
      } else {
        print('❌ No files selected or result is null');
      }
    } catch (e) {
      print('💥 Error in pickFiles: $e');
      Get.snackbar(
        'Error',
        'Failed to pick files: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Process Excel file and extract student data
  Future<void> _processFile(UploadFile uploadFile) async {
    try {
      print('🚀 Starting to process file: ${uploadFile.name}');
      isUploading.value = true;
      update();
      
      // Progress simulation
      for (int i = 0; i <= 10; i++) {
        await Future.delayed(Duration(milliseconds: 300));
        double progress = i / 10.0;
        uploadFile.progress.value = progress;
        print('📊 Progress for ${uploadFile.name}: ${(progress * 100).toInt()}%');
        update();
        uploadedFiles.refresh();
      }
      
      await Future.delayed(Duration(milliseconds: 300));
      
      try {
        print('📊 Starting Excel parsing...');
        
        final excel = Excel.decodeBytes(uploadFile.bytes);
        
        if (excel.tables.isEmpty) {
          throw Exception('No sheets found in Excel file');
        }
        
        final sheet = excel.tables[excel.tables.keys.first];
        
        if (sheet == null || sheet.maxRows <= 1) {
          throw Exception('Excel sheet is empty or has no data rows');
        }
        
        final students = <Student>[];
        final defectiveRecords = <Map<String, dynamic>>[];
        
        print('📋 Processing ${sheet.maxRows} rows...');
        
        // Skip header row (index 0)
        for (int row = 1; row < sheet.maxRows; row++) {
          final rowData = sheet.row(row);
          
          // Skip empty rows
          if (rowData.isEmpty || rowData[0]?.value == null) {
            print('⏭️ Skipping empty row $row');
            continue;
          }
          
          try {
            // Validate required fields
            final name = _getCellValue(rowData, 0);
            final studentId = _getCellValue(rowData, 1);
            final aid = _getCellValue(rowData, 2);
            final email = _getCellValue(rowData, 27);
            
            // Check for validation errors
            List<String> errors = [];
            
            if (name == null || name.trim().isEmpty) {
              errors.add('Name is required');
            }
            if (studentId == null || studentId.trim().isEmpty) {
              errors.add('Student ID is required');
            }
            if (email != null && !_isValidEmail(email)) {
              errors.add('Invalid email format');
            }
            
            // If there are validation errors, add to defective records
            if (errors.isNotEmpty) {
              defectiveRecords.add({
                'row': row + 1, // Excel row number (1-based)
                'name': name ?? '',
                'studentId': studentId ?? '',
                'aid': aid ?? '',
                'email': email ?? '',
                'errors': errors,
                'data': rowData.map((cell) => cell?.value?.toString() ?? '').toList(),
              });
              print('❌ Row $row has errors: ${errors.join(', ')}');
              continue;
            }
            
            // Create student if validation passes
            final student = Student(
              id: DateTime.now().millisecondsSinceEpoch.toString() + row.toString(),
              name: name ?? 'Student $row',
              avatarColor: _getRandomColor(),
              studentId: studentId,
              aid: aid,
              grade: _getCellValue(rowData, 3),
              className: _getCellValue(rowData, 4),
              gender: _getCellValue(rowData, 5),
              dateOfBirth: _parseDate(_getCellValue(rowData, 6)),
              bloodType: _getCellValue(rowData, 7),
              weightKg: _parseDouble(_getCellValue(rowData, 8)),
              heightCm: _parseDouble(_getCellValue(rowData, 9)),
              goToHospital: _getCellValue(rowData, 10),
              firstGuardianName: _getCellValue(rowData, 11),
              firstGuardianPhone: _getCellValue(rowData, 12),
              firstGuardianEmail: _getCellValue(rowData, 13),
              secondGuardianName: _getCellValue(rowData, 14),
              secondGuardianPhone: _getCellValue(rowData, 15),
              secondGuardianEmail: _getCellValue(rowData, 16),
              city: _getCellValue(rowData, 17),
              street: _getCellValue(rowData, 18),
              zipCode: _getCellValue(rowData, 19),
              province: _getCellValue(rowData, 20),
              insuranceCompany: _getCellValue(rowData, 21),
              policyNumber: _getCellValue(rowData, 22),
              passportIdNumber: _getCellValue(rowData, 23),
              nationality: _getCellValue(rowData, 24),
              nationalId: _getCellValue(rowData, 25),
              phoneNumber: _getCellValue(rowData, 26),
              email: email,
              lastAppointmentDate: DateTime.now().subtract(Duration(days: row * 2)),
              lastAppointmentType: ['Walk in', 'Scheduled', 'Emergency'][row % 3],
              emrNumber: 20 + row,
            );
            
            students.add(student);
            print('👤 Created student: ${student.name}');
            
          } catch (e) {
            print('❌ Error processing row $row: $e');
            defectiveRecords.add({
              'row': row + 1,
              'name': _getCellValue(rowData, 0) ?? '',
              'studentId': _getCellValue(rowData, 1) ?? '',
              'aid': _getCellValue(rowData, 2) ?? '',
              'email': _getCellValue(rowData, 27) ?? '',
              'errors': ['Processing error: $e'],
              'data': rowData.map((cell) => cell?.value?.toString() ?? '').toList(),
            });
          }
        }
        
        print('📊 Total students created: ${students.length}');
        print('❌ Total defective records: ${defectiveRecords.length}');
        
        // Add students to main controller
        try {
          final studentController = Get.find<StudentController>();
          
          // Add valid students
          for (final student in students) {
            studentController.addStudent(student);
          }
          
          // Add defective records if any
          if (defectiveRecords.isNotEmpty) {
            studentController.addDefectiveRecords(defectiveRecords);
          }
          
          uploadFile.isCompleted.value = true;
          update();
          uploadedFiles.refresh();
          
          print('🎉 Upload completed successfully!');
          
          // Show appropriate message
          if (defectiveRecords.isNotEmpty) {
            Get.snackbar(
              'Upload Completed with Issues',
              '${students.length} students imported, ${defectiveRecords.length} records need correction',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.orange,
              colorText: Colors.white,
            );
          } else {
            Get.snackbar(
              'Upload Complete',
              '${students.length} students imported successfully!',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.green,
              colorText: Colors.white,
            );
          }
          
        } catch (controllerError) {
          print('❌ Error adding students to controller: $controllerError');
          uploadFile.hasError.value = true;
          update();
        }
        
      } catch (parseError) {
        print('❌ Excel parse error: $parseError');
        uploadFile.hasError.value = true;
        update();
        uploadedFiles.refresh();
        
        Get.snackbar(
          'Excel Parse Error',
          'Failed to read Excel file. Please check the format.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
      
    } catch (e) {
      print('💥 General processing error: $e');
      uploadFile.hasError.value = true;
      update();
      uploadedFiles.refresh();
      
      Get.snackbar(
        'Processing Error',
        'Failed to process ${uploadFile.name}: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isUploading.value = false;
      update();
      uploadedFiles.refresh();
    }
  }
  bool _isValidEmail(String email) {
    return RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email);
  }

  // Helper methods
  String? _getCellValue(List<Data?> row, int index) {
    if (index >= row.length || row[index]?.value == null) return null;
    return row[index]!.value.toString();
  }

  DateTime? _parseDate(String? dateStr) {
    if (dateStr == null) return null;
    try {
      return DateTime.parse(dateStr);
    } catch (e) {
      return null;
    }
  }

  double? _parseDouble(String? str) {
    if (str == null) return null;
    try {
      return double.parse(str);
    } catch (e) {
      return null;
    }
  }

  Color _getRandomColor() {
    final colors = [
      Colors.blue,
      Colors.purple,
      Colors.green,
      Colors.orange,
      Colors.red,
      Colors.teal,
    ];
    return colors[DateTime.now().millisecond % colors.length];
  }

  void removeFile(UploadFile file) {
    print('🗑️ Attempting to remove file: ${file.name}');
    print('📊 Files before removal: ${uploadedFiles.length}');
    
    uploadedFiles.removeWhere((f) => f.name == file.name);
    
    // Force UI updates
    update();
    uploadedFiles.refresh();
    
    print('✅ Files after removal: ${uploadedFiles.length}');
    
    Get.snackbar(
      'File Removed',
      '${file.name} removed from upload queue',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.orange,
      colorText: Colors.white,
      duration: Duration(seconds: 2),
    );
  }
}

// UploadFile Model (Add this to your file or create separate model file)
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
  }) : progress = progress.obs,
       isCompleted = false.obs,
       hasError = false.obs;
}