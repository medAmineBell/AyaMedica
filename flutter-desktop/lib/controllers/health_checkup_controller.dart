import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/health_checkup.dart';

class HealthCheckupController extends GetxController {
  // Observable map to store health checkup data for each student and appointment
  final RxMap<String, StudentHealthCheckup> _healthCheckups = <String, StudentHealthCheckup>{}.obs;
  
  // Observable list of health categories
  final RxList<HealthCategory> _categories = <HealthCategory>[].obs;
  
  // Observable for current appointment being checked
  final Rx<String?> _currentAppointmentId = Rx<String?>(null);
  
  // Observable for current student being checked
  final Rx<String?> _currentStudentId = Rx<String?>(null);

  @override
  void onInit() {
    super.onInit();
    // Initialize with default categories
    _categories.value = HealthCategories.defaultCategories;
  }

  // Getters
  Map<String, StudentHealthCheckup> get healthCheckups => _healthCheckups;
  List<HealthCategory> get categories => _categories;
  String? get currentAppointmentId => _currentAppointmentId.value;
  String? get currentStudentId => _currentStudentId.value;

  // Set current appointment and student for checkup
  void setCurrentCheckup(String appointmentId, String studentId) {
    _currentAppointmentId.value = appointmentId;
    _currentStudentId.value = studentId;
    
    // Initialize health checkup if it doesn't exist
    _initializeHealthCheckup(appointmentId, studentId);
  }

  // Initialize health checkup for a student
  void _initializeHealthCheckup(String appointmentId, String studentId) {
    final key = _generateKey(appointmentId, studentId);
    
    if (!_healthCheckups.containsKey(key)) {
      final checkup = StudentHealthCheckup(
        studentId: studentId,
        appointmentId: appointmentId,
        categoryStatuses: {},
        createdAt: DateTime.now(),
      );
      _healthCheckups[key] = checkup;
    }
  }

  // Set health status for a category
  void setHealthStatus(String categoryId, HealthStatus status, {String? issueDescription}) {
    if (_currentAppointmentId.value == null || _currentStudentId.value == null) return;
    
    final key = _generateKey(_currentAppointmentId.value!, _currentStudentId.value!);
    final checkup = _healthCheckups[key];
    
    if (checkup != null) {
      final statusData = HealthStatusData(
        status: status,
        issueDescription: issueDescription,
        checkedAt: DateTime.now(),
        checkedBy: 'Current User', // TODO: Get from auth service
      );
      
      final updatedCheckup = checkup.copyWithCategoryStatus(categoryId, statusData);
      _healthCheckups[key] = updatedCheckup;
    }
  }

  // Get health status for a category
  HealthStatusData? getHealthStatus(String categoryId) {
    if (_currentAppointmentId.value == null || _currentStudentId.value == null) return null;
    
    final key = _generateKey(_currentAppointmentId.value!, _currentStudentId.value!);
    final checkup = _healthCheckups[key];
    
    return checkup?.getStatusForCategory(categoryId);
  }

  // Clear health status for a category
  void clearHealthStatus(String categoryId) {
    if (_currentAppointmentId.value == null || _currentStudentId.value == null) return;
    
    final key = _generateKey(_currentAppointmentId.value!, _currentStudentId.value!);
    final checkup = _healthCheckups[key];
    
    if (checkup != null) {
      final updatedStatuses = Map<String, HealthStatusData>.from(checkup.categoryStatuses);
      updatedStatuses.remove(categoryId);
      
      final updatedCheckup = StudentHealthCheckup(
        studentId: checkup.studentId,
        appointmentId: checkup.appointmentId,
        categoryStatuses: updatedStatuses,
        createdAt: checkup.createdAt,
        completedAt: checkup.completedAt,
        notes: checkup.notes,
      );
      
      _healthCheckups[key] = updatedCheckup;
    }
  }

  // Get completion statistics for current appointment
  Map<String, dynamic> getCompletionStats(String appointmentId) {
    final appointmentCheckups = _healthCheckups.values
        .where((checkup) => checkup.appointmentId == appointmentId)
        .toList();
    
    if (appointmentCheckups.isEmpty) {
      return {
        'totalStudents': 0,
        'completedStudents': 0,
        'completionPercentage': 0.0,
        'totalCategories': categories.length,
      };
    }
    
    final totalStudents = appointmentCheckups.length;
    final completedStudents = appointmentCheckups
        .where((checkup) => checkup.isCompleted)
        .length;
    
    final completionPercentage = totalStudents > 0 
        ? (completedStudents / totalStudents) * 100 
        : 0.0;
    
    return {
      'totalStudents': totalStudents,
      'completedStudents': completedStudents,
      'completionPercentage': completionPercentage,
      'totalCategories': categories.length,
    };
  }

  // Get health checkup for a specific student and appointment
  StudentHealthCheckup? getHealthCheckup(String appointmentId, String studentId) {
    final key = _generateKey(appointmentId, studentId);
    return _healthCheckups[key];
  }

  // Add custom health category
  void addCustomCategory(HealthCategory category) {
    if (!_categories.any((cat) => cat.id == category.id)) {
      _categories.add(category);
    }
  }

  // Remove custom health category
  void removeCustomCategory(String categoryId) {
    // Don't allow removing default categories
    if (HealthCategories.getById(categoryId) != null) return;
    
    _categories.removeWhere((category) => category.id == categoryId);
    
    // Remove all statuses for this category from existing checkups
    for (final key in _healthCheckups.keys) {
      final checkup = _healthCheckups[key];
      if (checkup != null) {
        final updatedStatuses = Map<String, HealthStatusData>.from(checkup.categoryStatuses);
        updatedStatuses.remove(categoryId);
        
        final updatedCheckup = StudentHealthCheckup(
          studentId: checkup.studentId,
          appointmentId: checkup.appointmentId,
          categoryStatuses: updatedStatuses,
          createdAt: checkup.createdAt,
          completedAt: checkup.completedAt,
          notes: checkup.notes,
        );
        
        _healthCheckups[key] = updatedCheckup;
      }
    }
  }

  // Update category details
  void updateCategory(String categoryId, {String? name, IconData? icon, Color? color, String? description}) {
    final index = _categories.indexWhere((category) => category.id == categoryId);
    if (index != -1) {
      final category = _categories[index];
      final updatedCategory = HealthCategory(
        id: category.id,
        name: name ?? category.name,
        icon: icon ?? category.icon,
        color: color ?? category.color,
        description: description ?? category.description,
      );
      _categories[index] = updatedCategory;
    }
  }

  // Generate unique key for health checkup storage
  String _generateKey(String appointmentId, String studentId) {
    return '${appointmentId}_$studentId';
  }

  // Clear current checkup session
  void clearCurrentCheckup() {
    _currentAppointmentId.value = null;
    _currentStudentId.value = null;
  }

  // Export health checkup data (for reporting)
  Map<String, dynamic> exportHealthCheckupData(String appointmentId) {
    final appointmentCheckups = _healthCheckups.values
        .where((checkup) => checkup.appointmentId == appointmentId)
        .toList();
    
    return {
      'appointmentId': appointmentId,
      'exportedAt': DateTime.now().toIso8601String(),
      'totalStudents': appointmentCheckups.length,
      'checkups': appointmentCheckups.map((checkup) => {
        'studentId': checkup.studentId,
        'createdAt': checkup.createdAt.toIso8601String(),
        'completedAt': checkup.completedAt?.toIso8601String(),
        'isCompleted': checkup.isCompleted,
        'completionPercentage': checkup.completionPercentage,
        'categoryStatuses': checkup.categoryStatuses.map((key, value) => MapEntry(key, {
          'status': value.status.toString(),
          'issueDescription': value.issueDescription,
          'checkedAt': value.checkedAt?.toIso8601String(),
          'checkedBy': value.checkedBy,
        })),
        'notes': checkup.notes,
      }).toList(),
    };
  }
}
