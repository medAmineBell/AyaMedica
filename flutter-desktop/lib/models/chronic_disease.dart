import 'package:flutter/material.dart';

class ChronicDisease {
  final String id;
  final String name;
  final String? description;
  final String? category;
  final DateTime? diagnosedDate;
  final String? severity; // mild, moderate, severe
  final bool isActive;
  final String? treatmentPlan;
  final String? medications;
  final String? notes;

  const ChronicDisease({
    required this.id,
    required this.name,
    this.description,
    this.category,
    this.diagnosedDate,
    this.severity,
    this.isActive = true,
    this.treatmentPlan,
    this.medications,
    this.notes,
  });

  factory ChronicDisease.fromJson(Map<String, dynamic> json) {
    return ChronicDisease(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      category: json['category'] as String?,
      diagnosedDate: json['diagnosedDate'] != null
          ? DateTime.parse(json['diagnosedDate'])
          : null,
      severity: json['severity'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      treatmentPlan: json['treatmentPlan'] as String?,
      medications: json['medications'] as String?,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'diagnosedDate': diagnosedDate?.toIso8601String(),
      'severity': severity,
      'isActive': isActive,
      'treatmentPlan': treatmentPlan,
      'medications': medications,
      'notes': notes,
    };
  }

  ChronicDisease copyWith({
    String? id,
    String? name,
    String? description,
    String? category,
    DateTime? diagnosedDate,
    String? severity,
    bool? isActive,
    String? treatmentPlan,
    String? medications,
    String? notes,
  }) {
    return ChronicDisease(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      diagnosedDate: diagnosedDate ?? this.diagnosedDate,
      severity: severity ?? this.severity,
      isActive: isActive ?? this.isActive,
      treatmentPlan: treatmentPlan ?? this.treatmentPlan,
      medications: medications ?? this.medications,
      notes: notes ?? this.notes,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChronicDisease && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'ChronicDisease(id: $id, name: $name, category: $category, severity: $severity)';
  }

  // Helper method to get severity color
  Color get severityColor {
    switch (severity?.toLowerCase()) {
      case 'mild':
        return Colors.green;
      case 'moderate':
        return Colors.orange;
      case 'severe':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // Helper method to get formatted diagnosed date
  String get formattedDiagnosedDate {
    if (diagnosedDate == null) return 'Not specified';
    return '${diagnosedDate!.day.toString().padLeft(2, '0')}/${diagnosedDate!.month.toString().padLeft(2, '0')}/${diagnosedDate!.year}';
  }
}
