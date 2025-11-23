import 'package:flutter_getx_app/models/student.dart';

class Gardes {
  String? id;
  final String name;
  final int NumClasses;
  final int MaxCapacity;
  final String ClassName;
  final int ActualCapacity;

  Gardes({
    this.id,
    required this.name,
    required this.NumClasses,
    required this.MaxCapacity,
    required this.ClassName,
    required this.ActualCapacity,
  });

  // Convert to JSON for API calls
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'NumClasses': NumClasses,
      'name': name,
      'MaxCapacity': MaxCapacity,
      'ClassName': ClassName,
      'ActualCapacity': ActualCapacity,
    };
  }

  // Create from JSON
  factory Gardes.fromJson(Map<String, dynamic> json) {
    return Gardes(
      id: json['id'],
      NumClasses: json['NumClasses'],
      MaxCapacity: json['MaxCapacity'],
      ClassName: json['ClassName'],
      ActualCapacity: json['ActualCapacity'],
      name: json['name'],
    );
  }
}
