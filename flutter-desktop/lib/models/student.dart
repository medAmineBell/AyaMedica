// Updated Student Model with additional helper methods
import 'package:flutter/material.dart';
import 'package:flutter_getx_app/models/medicalRecord.dart';
import 'package:flutter_getx_app/models/chronic_disease.dart';
import 'package:get/get.dart';

// Student Model with JSON serialization and additional table fields
class Student {
  final String id;
  final String name;
  final String? imageUrl;
  final Color avatarColor;

  final DateTime? dateOfBirth;
  final String? bloodType;
  final double? weightKg;
  final double? heightCm;
  final String? goToHospital;

  final String? firstGuardianName;
  final String? firstGuardianPhone;
  final String? firstGuardianEmail;
  final String? firstGuardianStatus;

  final String? secondGuardianName;
  final String? secondGuardianPhone;
  final String? secondGuardianEmail;
  final String? secondGuardianStatus;

  final String? city;
  final String? street;
  final String? zipCode;
  final String? province;

  final String? insuranceCompany;
  final String? policyNumber;

  final String? passportIdNumber;
  final String? nationality;
  final String? nationalId;
  final String? gender;
  final String? phoneNumber;
  final String? email;

  // Additional fields for the data table
  final String? studentId;
  final String? aid;
  final String? grade;
  final String? className;
  final DateTime? lastAppointmentDate;
  final String? lastAppointmentType;
  final int? emrNumber;
  final List<MedicalRecord>? medicalRecords;
  final List<ChronicDisease>? chronicDiseases;


  const Student({
    required this.id,
    required this.name,
    this.imageUrl,
    required this.avatarColor,
    this.dateOfBirth,
    this.bloodType,
    this.weightKg,
    this.heightCm,
    this.goToHospital,
    this.firstGuardianName,
    this.firstGuardianPhone,
    this.firstGuardianEmail,
    this.firstGuardianStatus,
    this.secondGuardianName,
    this.secondGuardianPhone,
    this.secondGuardianEmail,
    this.secondGuardianStatus,
    this.city,
    this.street,
    this.zipCode,
    this.province,
    this.insuranceCompany,
    this.policyNumber,
    this.passportIdNumber,
    this.nationality,
    this.nationalId,
    this.gender,
    this.phoneNumber,
    this.email,
    this.studentId,
    this.aid,
    this.grade,
    this.className,
    this.lastAppointmentDate,
    this.lastAppointmentType,
    this.emrNumber,
    this.medicalRecords,
    this.chronicDiseases,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['id'] as String,
      name: json['name'] as String,
      imageUrl: json['imageUrl'] as String?,
      avatarColor: Color(json['avatarColor'] as int),
      dateOfBirth: json['dateOfBirth'] != null ? DateTime.parse(json['dateOfBirth']) : null,
      bloodType: json['bloodType'] as String?,
      weightKg: (json['weightKg'] as num?)?.toDouble(),
      heightCm: (json['heightCm'] as num?)?.toDouble(),
      goToHospital: json['goToHospital'] as String?,
      firstGuardianName: json['firstGuardianName'] as String?,
      firstGuardianPhone: json['firstGuardianPhone'] as String?,
      firstGuardianEmail: json['firstGuardianEmail'] as String?,
      firstGuardianStatus: json['firstGuardianStatus'] as String?,
      secondGuardianName: json['secondGuardianName'] as String?,
      secondGuardianPhone: json['secondGuardianPhone'] as String?,
      secondGuardianEmail: json['secondGuardianEmail'] as String?,
      secondGuardianStatus: json['secondGuardianStatus'] as String?,
      city: json['city'] as String?,
      street: json['street'] as String?,
      zipCode: json['zipCode'] as String?,
      province: json['province'] as String?,
      insuranceCompany: json['insuranceCompany'] as String?,
      policyNumber: json['policyNumber'] as String?,
      passportIdNumber: json['passportIdNumber'] as String?,
      nationality: json['nationality'] as String?,
      nationalId: json['nationalId'] as String?,
      gender: json['gender'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      email: json['email'] as String?,
      studentId: json['studentId'] as String?,
      aid: json['aid'] as String?,
      grade: json['grade'] as String?,
      className: json['className'] as String?,
      lastAppointmentDate: json['lastAppointmentDate'] != null ? DateTime.parse(json['lastAppointmentDate']) : null,
      lastAppointmentType: json['lastAppointmentType'] as String?,
      emrNumber: json['emrNumber'] as int?,
      medicalRecords: (json['medicalRecords'] as List<dynamic>?)
          ?.map((record) => MedicalRecord.fromJson(record as Map<String, dynamic>))
          .toList(),
      chronicDiseases: (json['chronicDiseases'] as List<dynamic>?)
          ?.map((disease) => ChronicDisease.fromJson(disease as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
      'avatarColor': avatarColor.value,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'bloodType': bloodType,
      'weightKg': weightKg,
      'heightCm': heightCm,
      'goToHospital': goToHospital,
      'firstGuardianName': firstGuardianName,
      'firstGuardianPhone': firstGuardianPhone,
      'firstGuardianEmail': firstGuardianEmail,
      'firstGuardianStatus': firstGuardianStatus,
      'secondGuardianName': secondGuardianName,
      'secondGuardianPhone': secondGuardianPhone,
      'secondGuardianEmail': secondGuardianEmail,
      'secondGuardianStatus': secondGuardianStatus,
      'city': city,
      'street': street,
      'zipCode': zipCode,
      'province': province,
      'insuranceCompany': insuranceCompany,
      'policyNumber': policyNumber,
      'passportIdNumber': passportIdNumber,
      'nationality': nationality,
      'nationalId': nationalId,
      'gender': gender,
      'phoneNumber': phoneNumber,
      'email': email,
      'studentId': studentId,
      'aid': aid,
      'grade': grade,
      'className': className,
      'lastAppointmentDate': lastAppointmentDate?.toIso8601String(),
      'lastAppointmentType': lastAppointmentType,
      'emrNumber': emrNumber,
      'medicalRecords': medicalRecords?.map((record) => record.toJson()).toList(),
      'chronicDiseases': chronicDiseases?.map((disease) => disease.toJson()).toList(),
    };
  }

  // Helper method to calculate age
  int get age {
    if (dateOfBirth == null) return 0;
    final now = DateTime.now();
    int age = now.year - dateOfBirth!.year;
    if (now.month < dateOfBirth!.month ||
        (now.month == dateOfBirth!.month && now.day < dateOfBirth!.day)) {
      age--;
    }
    return age;
  }

  // Helper method to get initials
  String get initials {
    final names = name.split(' ');
    if (names.length >= 2) {
      return '${names[0][0]}${names[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  // Helper method to get first name
  String? get firstName {
    final names = name.trim().split(' ');
    return names.isNotEmpty ? names.first : null;
  }

  // Helper method to get last name
  String? get lastName {
    final names = name.trim().split(' ');
    return names.length > 1 ? names.sublist(1).join(' ') : null;
  }

  // Helper method to get full name from first and last
  static String buildFullName(String? firstName, String? lastName) {
    final first = firstName?.trim() ?? '';
    final last = lastName?.trim() ?? '';
    return '$first $last'.trim();
  }

  String get gradeAndClass => '${grade ?? 'N/A'} - ${className ?? 'N/A'}';
  
  String get formattedAppointmentDate {
    if (lastAppointmentDate == null) return 'No appointment';
    final date = lastAppointmentDate!;
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} - ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')} ${date.hour >= 12 ? 'PM' : 'AM'}';
  }

  // Helper method to get guardian info
  String get primaryGuardianInfo {
    if (firstGuardianName?.isNotEmpty == true) {
      return '$firstGuardianName${firstGuardianPhone?.isNotEmpty == true ? ' - ${firstGuardianPhone}' : ''}';
    }
    return 'No guardian info';
  }

  String get secondaryGuardianInfo {
    if (secondGuardianName?.isNotEmpty == true) {
      return '$secondGuardianName${secondGuardianPhone?.isNotEmpty == true ? ' - ${secondGuardianPhone}' : ''}';
    }
    return 'No secondary guardian info';
  }

  // Helper method to get formatted address
  String get formattedAddress {
    final addressParts = <String>[];
    
    if (street?.isNotEmpty == true) addressParts.add(street!);
    if (city?.isNotEmpty == true) addressParts.add(city!);
    if (province?.isNotEmpty == true) addressParts.add(province!);
    if (zipCode?.isNotEmpty == true) addressParts.add(zipCode!);
    
    return addressParts.isNotEmpty ? addressParts.join(', ') : 'No address';
  }

  // Helper method to check if student has complete basic info
  bool get hasCompleteBasicInfo {
    return name.isNotEmpty &&
           dateOfBirth != null &&
           nationalId?.isNotEmpty == true &&
           grade?.isNotEmpty == true &&
           className?.isNotEmpty == true;
  }

  // Helper method to check if student has guardian info
  bool get hasGuardianInfo {
    return firstGuardianName?.isNotEmpty == true ||
           secondGuardianName?.isNotEmpty == true;
  }

  // Helper method to get completion percentage
  double get profileCompletionPercentage {
    int completedFields = 0;
    int totalFields = 0;

    // Basic info fields
    totalFields += 5;
    if (name.isNotEmpty) completedFields++;
    if (dateOfBirth != null) completedFields++;
    if (nationalId?.isNotEmpty == true) completedFields++;
    if (grade?.isNotEmpty == true) completedFields++;
    if (className?.isNotEmpty == true) completedFields++;

    // Guardian info fields
    totalFields += 4;
    if (firstGuardianName?.isNotEmpty == true) completedFields++;
    if (firstGuardianPhone?.isNotEmpty == true) completedFields++;
    if (firstGuardianEmail?.isNotEmpty == true) completedFields++;
    if (secondGuardianName?.isNotEmpty == true) completedFields++;

    // Medical info fields
    totalFields += 3;
    if (bloodType?.isNotEmpty == true) completedFields++;
    if (weightKg != null) completedFields++;
    if (heightCm != null) completedFields++;

    return totalFields > 0 ? (completedFields / totalFields) : 0.0;
  }

  // Helper method to create a copy with updated fields
  Student copyWith({
    String? id,
    String? name,
    String? imageUrl,
    Color? avatarColor,
    DateTime? dateOfBirth,
    String? bloodType,
    double? weightKg,
    double? heightCm,
    String? goToHospital,
    String? firstGuardianName,
    String? firstGuardianPhone,
    String? firstGuardianEmail,
    String? firstGuardianStatus,
    String? secondGuardianName,
    String? secondGuardianPhone,
    String? secondGuardianEmail,
    String? secondGuardianStatus,
    String? city,
    String? street,
    String? zipCode,
    String? province,
    String? insuranceCompany,
    String? policyNumber,
    String? passportIdNumber,
    String? nationality,
    String? nationalId,
    String? gender,
    String? phoneNumber,
    String? email,
    String? studentId,
    String? aid,
    String? grade,
    String? className,
    DateTime? lastAppointmentDate,
    String? lastAppointmentType,
    int? emrNumber,
    List<MedicalRecord>? medicalRecords,
    List<ChronicDisease>? chronicDiseases
  }) {
    return Student(
      id: id ?? this.id,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      avatarColor: avatarColor ?? this.avatarColor,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      bloodType: bloodType ?? this.bloodType,
      weightKg: weightKg ?? this.weightKg,
      heightCm: heightCm ?? this.heightCm,
      goToHospital: goToHospital ?? this.goToHospital,
      firstGuardianName: firstGuardianName ?? this.firstGuardianName,
      firstGuardianPhone: firstGuardianPhone ?? this.firstGuardianPhone,
      firstGuardianEmail: firstGuardianEmail ?? this.firstGuardianEmail,
      firstGuardianStatus: firstGuardianStatus ?? this.firstGuardianStatus,
      secondGuardianName: secondGuardianName ?? this.secondGuardianName,
      secondGuardianPhone: secondGuardianPhone ?? this.secondGuardianPhone,
      secondGuardianEmail: secondGuardianEmail ?? this.secondGuardianEmail,
      secondGuardianStatus: secondGuardianStatus ?? this.secondGuardianStatus,
      city: city ?? this.city,
      street: street ?? this.street,
      zipCode: zipCode ?? this.zipCode,
      province: province ?? this.province,
      insuranceCompany: insuranceCompany ?? this.insuranceCompany,
      policyNumber: policyNumber ?? this.policyNumber,
      passportIdNumber: passportIdNumber ?? this.passportIdNumber,
      nationality: nationality ?? this.nationality,
      nationalId: nationalId ?? this.nationalId,
      gender: gender ?? this.gender,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      studentId: studentId ?? this.studentId,
      aid: aid ?? this.aid,
      grade: grade ?? this.grade,
      className: className ?? this.className,
      lastAppointmentDate: lastAppointmentDate ?? this.lastAppointmentDate,
      lastAppointmentType: lastAppointmentType ?? this.lastAppointmentType,
      emrNumber: emrNumber ?? this.emrNumber,
      medicalRecords: medicalRecords ?? this.medicalRecords,
      chronicDiseases: chronicDiseases ?? this.chronicDiseases,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is Student &&
           other.id == id &&
           other.name == name &&
           other.nationalId == nationalId &&
           other.studentId == studentId;
  }

  @override
  int get hashCode {
    return id.hashCode ^ 
           name.hashCode ^ 
           nationalId.hashCode ^ 
           studentId.hashCode;
  }

  @override
  String toString() {
    return 'Student(id: $id, name: $name, studentId: $studentId, grade: $grade, class: $className)';
  }
}