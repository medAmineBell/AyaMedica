class BranchModel {
  final String id;
  final String name;
  final String role;
  final String icon;
  final String? address;
  final String? phone;
  final String? email;
  final String? principalName;
  final int? studentCount;
  final int? teacherCount;
  final String? status; // active, inactive, pending
  final String? parentId; // ID of parent organization
  final DateTime? createdAt;
  final DateTime? updatedAt;

  BranchModel({
    required this.name,
    required this.role,
    required this.icon,
    this.id = '',
    this.address,
    this.phone,
    this.email,
    this.principalName,
    this.studentCount,
    this.teacherCount,
    this.status,
    this.parentId,
    this.createdAt,
    this.updatedAt,
  });

  factory BranchModel.fromJson(Map<String, dynamic> json) {
    return BranchModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      role: json['role'] ?? '',
      icon: json['icon'] ?? '',
      address: json['address'],
      phone: json['phone'],
      email: json['email'],
      principalName: json['principalName'],
      studentCount: json['studentCount'],
      teacherCount: json['teacherCount'],
      status: json['status'] ?? 'active',
      parentId: json['parentId'],
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : null,
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt']) 
          : null,
    );
  }

  // Factory method to create BranchModel from FhirOrganization
  factory BranchModel.fromFhirOrganization(dynamic fhirOrg) {
    // Extract organization type/role
    String role = 'Organization';
    if (fhirOrg.type != null && fhirOrg.type.isNotEmpty) {
      for (var orgType in fhirOrg.type) {
        if (orgType.coding.isNotEmpty) {
          for (var coding in orgType.coding) {
            if (coding.code == 'Branch') {
              role = 'Branch';
              break;
            } else if (coding.display.isNotEmpty) {
              role = coding.display;
            }
          }
        }
      }
    }

    // Extract contact information
    String? phone;
    String? email;
    if (fhirOrg.telecom != null) {
      for (var telecom in fhirOrg.telecom) {
        if (telecom.system == 'phone') {
          phone = telecom.value;
        } else if (telecom.system == 'email') {
          email = telecom.value;
        }
      }
    }

    // Extract address
    String? address;
    if (fhirOrg.address != null && fhirOrg.address.isNotEmpty) {
      final addr = fhirOrg.address.first;
      if (addr.line.isNotEmpty) {
        address = addr.line.join(', ');
      }
    }

    // Extract parent ID from partOf reference
    String? parentId;
    if (fhirOrg.partOf != null && fhirOrg.partOf.reference.isNotEmpty) {
      // Extract ID from reference like "Organization/12345"
      final reference = fhirOrg.partOf.reference;
      if (reference.contains('/')) {
        parentId = reference.split('/').last;
      }
    }

    // Determine icon based on organization type
    String icon = 'organization';
    if (role.toLowerCase().contains('branch')) {
      icon = 'clinic';
    } else if (role.toLowerCase().contains('school') || role.toLowerCase().contains('educational')) {
      icon = 'school';
    }

    return BranchModel(
      id: fhirOrg.id,
      name: fhirOrg.name,
      role: role,
      icon: icon,
      address: address,
      phone: phone,
      email: email,
      status: fhirOrg.active ? 'active' : 'inactive',
      parentId: parentId,
      createdAt: fhirOrg.meta.lastUpdated != null 
          ? DateTime.tryParse(fhirOrg.meta.lastUpdated) 
          : null,
      updatedAt: fhirOrg.meta.lastUpdated != null 
          ? DateTime.tryParse(fhirOrg.meta.lastUpdated) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'role': role,
      'icon': icon,
      'address': address,
      'phone': phone,
      'email': email,
      'principalName': principalName,
      'studentCount': studentCount,
      'teacherCount': teacherCount,
      'status': status,
      'parentId': parentId,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  BranchModel copyWith({
    String? id,
    String? name,
    String? role,
    String? icon,
    String? address,
    String? phone,
    String? email,
    String? principalName,
    int? studentCount,
    int? teacherCount,
    String? status,
    String? parentId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BranchModel(
      id: id ?? this.id,
      name: name ?? this.name,
      role: role ?? this.role,
      icon: icon ?? this.icon,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      principalName: principalName ?? this.principalName,
      studentCount: studentCount ?? this.studentCount,
      teacherCount: teacherCount ?? this.teacherCount,
      status: status ?? this.status,
      parentId: parentId ?? this.parentId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

// models/user_model.dart
class UserModel {
  final String name;
  final String aid;
  final String initials;

  UserModel({
    required this.name,
    required this.aid,
    required this.initials,
  });
}