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
  final String name;
  final String email;
  final String type;
  final String city;
  final String governorate;
  final String role;
  final String status;
  final String avatarUrl;
  final List<CampusAssignment> campusAssignments;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.type,
    required this.city,
    required this.governorate,
    required this.role,
    required this.status,
    required this.avatarUrl,
    this.campusAssignments = const [],
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      type: json['type'] ?? '',
      city: json['city'] ?? '',
      governorate: json['governorate'] ?? '',
      role: json['role'] ?? '',
      status: json['status'] ?? '',
      avatarUrl: json['avatarUrl'] ?? '',
      campusAssignments: (json['campusAssignments'] as List<dynamic>?)
              ?.map((e) => CampusAssignment.fromJson(e))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'type': type,
      'city': city,
      'governorate': governorate,
      'role': role,
      'status': status,
      'avatarUrl': avatarUrl,
      'campusAssignments': campusAssignments.map((e) => e.toJson()).toList(),
    };
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? type,
    String? city,
    String? governorate,
    String? role,
    String? status,
    String? avatarUrl,
    List<CampusAssignment>? campusAssignments,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      type: type ?? this.type,
      city: city ?? this.city,
      governorate: governorate ?? this.governorate,
      role: role ?? this.role,
      status: status ?? this.status,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      campusAssignments: campusAssignments ?? this.campusAssignments,
    );
  }
}
