class BranchModel {
  final String id;
  final String name;
  final String role;
  final String icon;
  final String? address;
  final String? phone;
  final String? email;
  final String? principalName;
  final int? studentCount; // Maps to totalStudents
  final int? teacherCount; // Maps to totalUsers
  final String? status; // active, inactive, pending
  final String? parentId; // ID of parent organization
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // NEW FIELDS for editing support
  final String? educationType;
  final List<String>? grades;
  final String? governorate;
  final String? city;
  final String? street;
  final bool? isHeadquarters;
  final String? website;
  final String? accountType;

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
    this.educationType,
    this.grades,
    this.governorate,
    this.city,
    this.street,
    this.isHeadquarters,
    this.website,
    this.accountType,
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
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      educationType: json['educationType'],
      grades: json['grades'] != null ? List<String>.from(json['grades']) : null,
      governorate: json['governorate'],
      city: json['city'],
      street: json['street'],
      isHeadquarters: json['isHeadquarters'],
      website: json['website'],
      accountType: json['accountType'],
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
    } else if (role.toLowerCase().contains('school') ||
        role.toLowerCase().contains('educational')) {
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
      'educationType': educationType,
      'grades': grades,
      'governorate': governorate,
      'city': city,
      'street': street,
      'isHeadquarters': isHeadquarters,
      'website': website,
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
    String? educationType,
    List<String>? grades,
    String? governorate,
    String? city,
    String? street,
    bool? isHeadquarters,
    String? website,
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
      educationType: educationType ?? this.educationType,
      grades: grades ?? this.grades,
      governorate: governorate ?? this.governorate,
      city: city ?? this.city,
      street: street ?? this.street,
      isHeadquarters: isHeadquarters ?? this.isHeadquarters,
      website: website ?? this.website,
    );
  }
}

// API Response Model
class BranchApiResponse {
  final String id;
  final String name;
  final String accountType;
  final bool isHeadquarters;
  final bool isAdministrative;
  final String? educationType;
  final List<String> grades;
  final String country;
  final BranchAddress address;
  final String? phone;
  final String? website;
  final String status;
  final String medplumProject;
  final int totalStudents;
  final int totalUsers;

  BranchApiResponse({
    required this.id,
    required this.name,
    required this.accountType,
    required this.isHeadquarters,
    required this.isAdministrative,
    this.educationType,
    required this.grades,
    required this.country,
    required this.address,
    this.phone,
    this.website,
    required this.status,
    required this.medplumProject,
    required this.totalStudents,
    required this.totalUsers,
  });

  factory BranchApiResponse.fromJson(Map<String, dynamic> json) {
    return BranchApiResponse(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      accountType: json['accountType'] ?? 'School',
      isHeadquarters: json['isHeadquarters'] ?? false,
      isAdministrative: json['isAdministrative'] ?? false,
      educationType: json['educationType'],
      grades: json['grades'] != null ? List<String>.from(json['grades']) : [],
      country: json['country'] ?? '',
      address: BranchAddress.fromJson(json['address'] ?? {}),
      phone: json['phone'],
      website: json['website'],
      status: json['status'] ?? 'active',
      medplumProject: json['medplumProject'] ?? '',
      totalStudents: json['totalStudents'] ?? 0,
      totalUsers: json['totalUsers'] ?? 0,
    );
  }
}

class BranchAddress {
  final String governorate;
  final String city;
  final String street;

  BranchAddress({
    required this.governorate,
    required this.city,
    required this.street,
  });

  factory BranchAddress.fromJson(Map<String, dynamic> json) {
    return BranchAddress(
      governorate: json['governorate'] ?? '',
      city: json['city'] ?? '',
      street: json['street'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'governorate': governorate,
      'city': city,
      'street': street,
    };
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
