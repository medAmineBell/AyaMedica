class UserRole {
  final String role;
  final String organizationId;
  final String organizationName;

  UserRole({
    required this.role,
    required this.organizationId,
    required this.organizationName,
  });

  factory UserRole.fromJson(Map<String, dynamic> json) {
    return UserRole(
      role: json['role'] ?? '',
      organizationId: json['organizationId'] ?? '',
      organizationName: json['organizationName'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'role': role,
        'organizationId': organizationId,
        'organizationName': organizationName,
      };
}

class CampusAssignment {
  final String campusId;
  final String campusName;
  final String role;
  final String position;
  final Map<String, Map<String, bool>> permissions;

  CampusAssignment({
    required this.campusId,
    required this.campusName,
    required this.role,
    required this.position,
    required this.permissions,
  });

  factory CampusAssignment.fromJson(Map<String, dynamic> json) {
    return CampusAssignment(
      campusId: json['campusId'] ?? '',
      campusName: json['campusName'] ?? '',
      role: json['role'] ?? '',
      position: json['position'] ?? '',
      permissions: Map<String, Map<String, bool>>.from(json['permissions']?.map(
              (key, value) => MapEntry(key, Map<String, bool>.from(value))) ??
          {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'campusId': campusId,
      'campusName': campusName,
      'role': role,
      'position': position,
      'permissions': permissions,
    };
  }

  CampusAssignment copyWith({
    String? campusId,
    String? campusName,
    String? role,
    String? position,
    Map<String, Map<String, bool>>? permissions,
  }) {
    return CampusAssignment(
      campusId: campusId ?? this.campusId,
      campusName: campusName ?? this.campusName,
      role: role ?? this.role,
      position: position ?? this.position,
      permissions: permissions ?? this.permissions,
    );
  }
}

class UserModel {
  final String id;
  final String userId;
  final String name;
  final String givenName;
  final String familyName;
  final String email;
  final String? phone;
  final String? gender;
  final String? photo;
  final bool active;
  final String? dateOfBirth;
  final String? documentType;
  final String? documentNumber;
  final String? aid;
  final String? nationality;
  final String? countryOfResidence;
  final String city;
  final String governorate;
  final List<UserRole> roles;
  final List<CampusAssignment> campusAssignments;

  UserModel({
    required this.id,
    this.userId = '',
    required this.name,
    this.givenName = '',
    this.familyName = '',
    required this.email,
    this.phone,
    this.gender,
    this.photo,
    this.active = true,
    this.dateOfBirth,
    this.documentType,
    this.documentNumber,
    this.aid,
    this.nationality,
    this.countryOfResidence,
    this.city = '',
    this.governorate = '',
    this.roles = const [],
    this.campusAssignments = const [],
  });

  /// Primary role from roles list
  String get role {
    if (roles.isNotEmpty) return roles.first.role;
    return '';
  }

  /// Status derived from active field
  String get status => active ? 'Active' : 'Inactive';

  /// Type — hardcoded for now (API doesn't provide this field yet)
  String get type => 'School clinic';

  /// Comma-separated branch/organization names from roles
  String get branchNames {
    final names = roles.map((r) => r.organizationName).where((n) => n.isNotEmpty).toSet();
    return names.join(', ');
  }

  String get avatarUrl => photo ?? '';

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Parse name — API returns nested object {given, family, full}
    String parsedName = '';
    String parsedGiven = '';
    String parsedFamily = '';
    final nameField = json['name'];
    if (nameField is Map<String, dynamic>) {
      parsedGiven = nameField['given'] ?? '';
      parsedFamily = nameField['family'] ?? '';
      parsedName = nameField['full'] ?? '$parsedGiven $parsedFamily'.trim();
    } else if (nameField is String) {
      parsedName = nameField;
      final parts = nameField.split(' ');
      parsedGiven = parts.isNotEmpty ? parts.first : '';
      parsedFamily = parts.length > 1 ? parts.sublist(1).join(' ') : '';
    }

    // Parse roles list
    final rolesList = (json['roles'] as List<dynamic>?)
            ?.map((r) => UserRole.fromJson(r as Map<String, dynamic>))
            .toList() ??
        [];

    return UserModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      name: parsedName,
      givenName: parsedGiven,
      familyName: parsedFamily,
      email: json['email'] ?? '',
      phone: json['phone'] as String?,
      gender: json['gender'] as String?,
      photo: json['photo'] as String?,
      active: json['active'] as bool? ?? true,
      dateOfBirth: json['date_of_birth'] as String? ?? json['dateOfBirth'] as String?,
      documentType: json['document_type'] as String? ?? json['documentType'] as String?,
      documentNumber: json['document_number'] as String? ?? json['documentNumber'] as String?,
      aid: json['aid'] as String?,
      nationality: json['nationality'] as String?,
      countryOfResidence: json['country_of_residence'] as String? ?? json['countryOfResidence'] as String?,
      city: json['city'] ?? '',
      governorate: json['governorate'] ?? '',
      roles: rolesList,
      campusAssignments: (json['campusAssignments'] as List<dynamic>?)
              ?.map((e) => CampusAssignment.fromJson(e))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'email': email,
      'phone': phone,
      'gender': gender,
      'photo': photo,
      'active': active,
      'dateOfBirth': dateOfBirth,
      'documentType': documentType,
      'documentNumber': documentNumber,
      'aid': aid,
      'nationality': nationality,
      'countryOfResidence': countryOfResidence,
      'city': city,
      'governorate': governorate,
      'roles': roles.map((r) => r.toJson()).toList(),
      'campusAssignments': campusAssignments.map((e) => e.toJson()).toList(),
    };
  }

  UserModel copyWith({
    String? id,
    String? userId,
    String? name,
    String? givenName,
    String? familyName,
    String? email,
    String? phone,
    String? gender,
    String? photo,
    bool? active,
    String? dateOfBirth,
    String? documentType,
    String? documentNumber,
    String? aid,
    String? nationality,
    String? countryOfResidence,
    String? city,
    String? governorate,
    List<UserRole>? roles,
    List<CampusAssignment>? campusAssignments,
  }) {
    return UserModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      givenName: givenName ?? this.givenName,
      familyName: familyName ?? this.familyName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      gender: gender ?? this.gender,
      photo: photo ?? this.photo,
      active: active ?? this.active,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      documentType: documentType ?? this.documentType,
      documentNumber: documentNumber ?? this.documentNumber,
      aid: aid ?? this.aid,
      nationality: nationality ?? this.nationality,
      countryOfResidence: countryOfResidence ?? this.countryOfResidence,
      city: city ?? this.city,
      governorate: governorate ?? this.governorate,
      roles: roles ?? this.roles,
      campusAssignments: campusAssignments ?? this.campusAssignments,
    );
  }
}
