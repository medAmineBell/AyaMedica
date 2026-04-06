/// Raw API response item: one guardian-student pair from GET /api/mobile-app/users
class MobileAppUser {
  final String relatedPersonId;
  final MobileAppStudent student;
  final MobileAppGuardian guardian;
  final MobileAppUserAccount? userAccount;
  final String status; // active, inactive, offline, unverified
  final String? emailStatus; // sent, delivered, failed
  final String organizationId;
  final String? branchId;
  final String organizationName;
  final String? branchName;

  MobileAppUser({
    required this.relatedPersonId,
    required this.student,
    required this.guardian,
    this.userAccount,
    required this.status,
    this.emailStatus,
    required this.organizationId,
    this.branchId,
    required this.organizationName,
    this.branchName,
  });

  factory MobileAppUser.fromJson(Map<String, dynamic> json) {
    return MobileAppUser(
      relatedPersonId: json['relatedPersonId'] ?? '',
      student: MobileAppStudent.fromJson(json['student'] ?? {}),
      guardian: MobileAppGuardian.fromJson(json['guardian'] ?? {}),
      userAccount: json['userAccount'] != null
          ? MobileAppUserAccount.fromJson(json['userAccount'])
          : null,
      status: json['status'] ?? 'unverified',
      emailStatus: json['emailStatus'],
      organizationId: json['organizationId'] ?? '',
      branchId: json['branchId'],
      organizationName: json['organizationName'] ?? '',
      branchName: json['branchName'],
    );
  }
}

class MobileAppStudent {
  final String id;
  final String givenName;
  final String familyName;
  final String grade;
  final String className;

  MobileAppStudent({
    required this.id,
    required this.givenName,
    required this.familyName,
    required this.grade,
    required this.className,
  });

  String get fullName => '$givenName $familyName'.trim();

  String get initials {
    final parts = fullName.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return fullName.isNotEmpty ? fullName[0].toUpperCase() : '?';
  }

  String get classGroup => grade.isNotEmpty ? grade : className;

  factory MobileAppStudent.fromJson(Map<String, dynamic> json) {
    final name = json['name'] as Map<String, dynamic>? ?? {};
    return MobileAppStudent(
      id: json['id'] ?? '',
      givenName: name['given'] ?? '',
      familyName: name['family'] ?? '',
      grade: json['grade'] ?? '',
      className: json['class'] ?? '',
    );
  }
}

class MobileAppGuardian {
  final String givenName;
  final String familyName;
  final String relationship;
  final String email;
  final String phone;

  MobileAppGuardian({
    required this.givenName,
    required this.familyName,
    required this.relationship,
    required this.email,
    required this.phone,
  });

  String get fullName => '$givenName $familyName'.trim();

  factory MobileAppGuardian.fromJson(Map<String, dynamic> json) {
    final name = json['name'] as Map<String, dynamic>? ?? {};
    return MobileAppGuardian(
      givenName: name['given'] ?? '',
      familyName: name['family'] ?? '',
      relationship: json['relationship'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
    );
  }
}

class MobileAppUserAccount {
  final String id;
  final String email;
  final String phone;
  final bool emailVerified;
  final bool phoneVerified;
  final DateTime? lastLoginAt;
  final DateTime? createdAt;

  MobileAppUserAccount({
    required this.id,
    required this.email,
    required this.phone,
    required this.emailVerified,
    required this.phoneVerified,
    this.lastLoginAt,
    this.createdAt,
  });

  factory MobileAppUserAccount.fromJson(Map<String, dynamic> json) {
    return MobileAppUserAccount(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      emailVerified: json['emailVerified'] ?? false,
      phoneVerified: json['phoneVerified'] ?? false,
      lastLoginAt: json['lastLoginAt'] != null
          ? DateTime.tryParse(json['lastLoginAt'])
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
    );
  }
}

/// Grouped view model: one row per student with first/second guardian
class UserAppItem {
  final String initials;
  final String fullName;
  final String classGroup;
  final String studentId;
  final Guardian firstGuardian;
  final Guardian secondGuardian;

  UserAppItem({
    required this.initials,
    required this.fullName,
    required this.classGroup,
    required this.studentId,
    required this.firstGuardian,
    required this.secondGuardian,
  });

  /// Group flat API items by student ID into UserAppItem rows
  static List<UserAppItem> groupByStudent(List<MobileAppUser> apiUsers) {
    final Map<String, List<MobileAppUser>> grouped = {};
    for (final user in apiUsers) {
      final key = user.student.id;
      grouped.putIfAbsent(key, () => []).add(user);
    }

    return grouped.entries.map((entry) {
      final items = entry.value;
      final student = items.first.student;

      final first = items.isNotEmpty ? items[0] : null;
      final second = items.length > 1 ? items[1] : null;

      return UserAppItem(
        initials: student.initials,
        fullName: student.fullName,
        classGroup: student.classGroup,
        studentId: student.id,
        firstGuardian: first != null
            ? Guardian.fromApiUser(first)
            : Guardian.empty(),
        secondGuardian: second != null
            ? Guardian.fromApiUser(second)
            : Guardian.empty(),
      );
    }).toList();
  }
}

class Guardian {
  final String name;
  final String phone;
  final String email;
  final String status;
  final String deliveryStatus;
  final String relationship;

  Guardian({
    required this.name,
    required this.phone,
    required this.email,
    required this.status,
    required this.deliveryStatus,
    this.relationship = '',
  });

  factory Guardian.empty() {
    return Guardian(
      name: '--',
      phone: '',
      email: '',
      status: 'Unverified',
      deliveryStatus: '',
    );
  }

  /// Convert API status to display-friendly format
  static String _mapStatus(String apiStatus) {
    switch (apiStatus.toLowerCase()) {
      case 'active':
        return 'Active';
      case 'inactive':
        return 'Inactive';
      case 'offline':
        return 'Offline';
      case 'unverified':
        return 'Unverified';
      default:
        return apiStatus;
    }
  }

  /// Convert API emailStatus to display-friendly format
  static String _mapDeliveryStatus(String? emailStatus) {
    if (emailStatus == null || emailStatus.isEmpty) return '';
    switch (emailStatus.toLowerCase()) {
      case 'sent':
        return 'Sent';
      case 'delivered':
        return 'Delivered';
      case 'failed':
        return 'Failed';
      default:
        return emailStatus;
    }
  }

  factory Guardian.fromApiUser(MobileAppUser apiUser) {
    return Guardian(
      name: apiUser.guardian.fullName,
      phone: apiUser.guardian.phone,
      email: apiUser.guardian.email,
      status: _mapStatus(apiUser.status),
      deliveryStatus: _mapDeliveryStatus(apiUser.emailStatus),
      relationship: apiUser.guardian.relationship,
    );
  }
}
