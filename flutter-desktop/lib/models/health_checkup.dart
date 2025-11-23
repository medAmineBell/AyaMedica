import 'package:flutter/material.dart';

// Health status enum
enum HealthStatus { good, issue }

// Health category model
class HealthCategory {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final String description;

  const HealthCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.description,
  });
}

// Health status data model
class HealthStatusData {
  final HealthStatus status;
  final String? issueDescription;
  final DateTime? checkedAt;
  final String? checkedBy;

  const HealthStatusData({
    required this.status,
    this.issueDescription,
    this.checkedAt,
    this.checkedBy,
  });

  // Create a copy with new values
  HealthStatusData copyWith({
    HealthStatus? status,
    String? issueDescription,
    DateTime? checkedAt,
    String? checkedBy,
  }) {
    return HealthStatusData(
      status: status ?? this.status,
      issueDescription: issueDescription ?? this.issueDescription,
      checkedAt: checkedAt ?? this.checkedAt,
      checkedBy: checkedBy ?? this.checkedBy,
    );
  }
}

// Student health checkup record
class StudentHealthCheckup {
  final String studentId;
  final String appointmentId;
  final Map<String, HealthStatusData> categoryStatuses;
  final DateTime createdAt;
  final DateTime? completedAt;
  final String? notes;

  const StudentHealthCheckup({
    required this.studentId,
    required this.appointmentId,
    required this.categoryStatuses,
    required this.createdAt,
    this.completedAt,
    this.notes,
  });

  // Check if all categories are completed
  bool get isCompleted {
    return categoryStatuses.values.every((status) => status.status != HealthStatus.issue);
  }

  // Get completion percentage
  double get completionPercentage {
    if (categoryStatuses.isEmpty) return 0.0;
    final completed = categoryStatuses.values.where((status) => status.status == HealthStatus.good).length;
    return completed / categoryStatuses.length;
  }

  // Get status for a specific category
  HealthStatusData? getStatusForCategory(String categoryId) {
    return categoryStatuses[categoryId];
  }

  // Create a copy with updated category status
  StudentHealthCheckup copyWithCategoryStatus(String categoryId, HealthStatusData status) {
    final updatedStatuses = Map<String, HealthStatusData>.from(categoryStatuses);
    updatedStatuses[categoryId] = status;
    
    return StudentHealthCheckup(
      studentId: studentId,
      appointmentId: appointmentId,
      categoryStatuses: updatedStatuses,
      createdAt: createdAt,
      completedAt: completedAt,
      notes: notes,
    );
  }
}

// Predefined health categories
class HealthCategories {
  static const List<HealthCategory> defaultCategories = [
    HealthCategory(
      id: 'hair',
      name: 'Hair',
      icon: Icons.face,
      color: Colors.brown,
      description: 'Check hair cleanliness and condition',
    ),
    HealthCategory(
      id: 'ears',
      name: 'Ears',
      icon: Icons.hearing,
      color: Colors.orange,
      description: 'Check ear hygiene and any issues',
    ),
    HealthCategory(
      id: 'nails',
      name: 'Nails',
      icon: Icons.content_cut,
      color: Colors.pink,
      description: 'Check nail cleanliness and length',
    ),
    HealthCategory(
      id: 'teeth',
      name: 'Teeth',
      icon: Icons.sentiment_satisfied,
      color: Colors.white,
      description: 'Check dental hygiene and condition',
    ),
    HealthCategory(
      id: 'uniform',
      name: 'Uniform',
      icon: Icons.checkroom,
      color: Colors.blue,
      description: 'Check uniform cleanliness and fit',
    ),
  ];

  // Get category by ID
  static HealthCategory? getById(String id) {
    try {
      return defaultCategories.firstWhere((category) => category.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get all category IDs
  static List<String> get allIds {
    return defaultCategories.map((category) => category.id).toList();
  }
}
