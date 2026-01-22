class CreateStudentRequest {
  final String branchId;
  final String organizationId;
  final StudentName name;
  final String dateOfBirth;
  final String gender;
  final String? email;
  final String? phone;
  final String? nationalId;
  final String? passportNumber;
  final String grade;
  final Address? address;
  final List<ParentInfo>? parents;

  CreateStudentRequest({
    required this.branchId,
    required this.organizationId,
    required this.name,
    required this.dateOfBirth,
    required this.gender,
    this.email,
    this.phone,
    this.nationalId,
    this.passportNumber,
    required this.grade,
    this.address,
    this.parents,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {
      'branchId': branchId,
      'organizationId': organizationId,
      'name': name.toJson(),
      'dateOfBirth': dateOfBirth,
      'gender': gender,
      'grade': grade,
    };

    if (email != null && email!.isNotEmpty) {
      json['email'] = email;
    }

    if (phone != null && phone!.isNotEmpty) {
      json['phone'] = phone;
    }

    if (nationalId != null && nationalId!.isNotEmpty) {
      json['nationalId'] = nationalId;
    }

    if (passportNumber != null && passportNumber!.isNotEmpty) {
      json['passportNumber'] = passportNumber;
    }

    if (address != null) {
      json['address'] = address!.toJson();
    }

    if (parents != null && parents!.isNotEmpty) {
      json['parents'] = parents!.map((p) => p.toJson()).toList();
    }

    return json;
  }

  factory CreateStudentRequest.fromFormData({
    required String branchId,
    required String organizationId,
    required String firstName,
    required String lastName,
    required DateTime dateOfBirth,
    required String gender,
    required String grade,
    String? email,
    String? phone,
    String? nationalId,
    String? passportNumber,
    String? country,
    String? guardian1FirstName,
    String? guardian1LastName,
    String? guardian1Email,
    String? guardian1Phone,
    String? guardian1Relationship,
    String? guardian2FirstName,
    String? guardian2LastName,
    String? guardian2Email,
    String? guardian2Phone,
    String? guardian2Relationship,
  }) {
    // Build parents list
    final List<ParentInfo> parents = [];

    if (guardian1FirstName != null &&
        guardian1FirstName.isNotEmpty &&
        guardian1LastName != null &&
        guardian1LastName.isNotEmpty) {
      parents.add(ParentInfo(
        name: StudentName(
          given: guardian1FirstName,
          family: guardian1LastName,
        ),
        email: guardian1Email ?? '',
        phone: guardian1Phone ?? '',
        relationship: guardian1Relationship ?? 'mother',
      ));
    }

    if (guardian2FirstName != null &&
        guardian2FirstName.isNotEmpty &&
        guardian2LastName != null &&
        guardian2LastName.isNotEmpty) {
      parents.add(ParentInfo(
        name: StudentName(
          given: guardian2FirstName,
          family: guardian2LastName,
        ),
        email: guardian2Email ?? '',
        phone: guardian2Phone ?? '',
        relationship: guardian2Relationship ?? 'father',
      ));
    }

    return CreateStudentRequest(
      branchId: branchId,
      organizationId: organizationId,
      name: StudentName(
        given: firstName,
        family: lastName,
      ),
      dateOfBirth:
          _formatDateForApi(dateOfBirth), // Fixed: Format date as YYYY-MM-DD
      gender: gender,
      email: email,
      phone: phone,
      nationalId: nationalId,
      passportNumber: passportNumber,
      grade: grade,
      address:
          country != null ? Address(country: _mapCountryToCode(country)) : null,
      parents: parents.isNotEmpty ? parents : null,
    );
  }

  // Helper method to format date as YYYY-MM-DD
  static String _formatDateForApi(DateTime date) {
    final year = date.year.toString();
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  static String _mapCountryToCode(String country) {
    final countryMap = {
      'Egypt': 'EG',
      'Tunisia': 'TN',
      'Morocco': 'MA',
      'Algeria': 'DZ',
      'Saudi Arabia': 'SA',
      'UAE': 'AE',
    };
    return countryMap[country] ?? 'EG';
  }
}

class StudentName {
  final String given;
  final String family;

  StudentName({
    required this.given,
    required this.family,
  });

  Map<String, dynamic> toJson() {
    return {
      'given': given,
      'family': family,
    };
  }

  factory StudentName.fromJson(Map<String, dynamic> json) {
    return StudentName(
      given: json['given'] ?? '',
      family: json['family'] ?? '',
    );
  }
}

class Address {
  final List<String>? line;
  final String? city;
  final String country;

  Address({
    this.line,
    this.city,
    required this.country,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {
      'country': country,
    };

    if (line != null && line!.isNotEmpty) {
      json['line'] = line;
    }

    if (city != null && city!.isNotEmpty) {
      json['city'] = city;
    }

    return json;
  }

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      line: json['line'] != null ? List<String>.from(json['line']) : null,
      city: json['city'],
      country: json['country'] ?? 'EG',
    );
  }
}

class ParentInfo {
  final StudentName name;
  final String email;
  final String phone;
  final String relationship;

  ParentInfo({
    required this.name,
    required this.email,
    required this.phone,
    required this.relationship,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name.toJson(),
      'email': email,
      'phone': phone,
      'relationship': relationship,
    };
  }

  factory ParentInfo.fromJson(Map<String, dynamic> json) {
    return ParentInfo(
      name: StudentName.fromJson(json['name']),
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      relationship: json['relationship'] ?? 'mother',
    );
  }
}
