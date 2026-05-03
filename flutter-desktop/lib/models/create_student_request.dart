class CreateStudentRequest {
  final String branchId;
  final String organizationId;
  final StudentName name;
  final String dateOfBirth;
  final String gender;
  final String grade;
  final String classId;
  final String? nationality;
  final String? documentType;
  final String? documentNumber;
  final Address? address;
  final String? fgFullName;
  final String? fgRelation;
  final String? fgEmail;
  final String? fgPhone;
  final String? sgFullName;
  final String? sgRelation;
  final String? sgEmail;
  final String? sgPhone;
  final Photo? photo;

  CreateStudentRequest({
    required this.branchId,
    required this.organizationId,
    required this.name,
    required this.dateOfBirth,
    required this.gender,
    required this.grade,
    required this.classId,
    this.nationality,
    this.documentType,
    this.documentNumber,
    this.address,
    this.fgFullName,
    this.fgRelation,
    this.fgEmail,
    this.fgPhone,
    this.sgFullName,
    this.sgRelation,
    this.sgEmail,
    this.sgPhone,
    this.photo,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {
      'branchId': branchId,
      'organizationId': organizationId,
      'name': name.toJson(),
      'dateOfBirth': dateOfBirth,
      'gender': gender,
      'grade': grade,
      'classId': classId,
    };

    void putIfSet(String key, String? value) {
      if (value != null && value.isNotEmpty) json[key] = value;
    }

    putIfSet('nationality', nationality);
    putIfSet('documentType', documentType);
    putIfSet('documentNumber', documentNumber);
    putIfSet('fgFullName', fgFullName);
    putIfSet('fgRelation', fgRelation);
    putIfSet('fgEmail', fgEmail);
    putIfSet('fgPhone', fgPhone);
    putIfSet('sgFullName', sgFullName);
    putIfSet('sgRelation', sgRelation);
    putIfSet('sgEmail', sgEmail);
    putIfSet('sgPhone', sgPhone);

    if (address != null) {
      final addrJson = address!.toJson();
      if (addrJson.isNotEmpty) json['address'] = addrJson;
    }

    if (photo != null) json['photo'] = photo!.toJson();

    return json;
  }

  /// Same as [toJson] but strips fields that the PUT
  /// `/api/school-admin/students/{id}` endpoint does not accept.
  Map<String, dynamic> toUpdateJson() {
    return toJson()
      ..remove('branchId')
      ..remove('organizationId');
  }

  factory CreateStudentRequest.fromFormData({
    required String branchId,
    required String organizationId,
    required String firstName,
    required String lastName,
    required DateTime dateOfBirth,
    required String gender,
    required String grade,
    required String classId,
    String? nationality,
    String? documentType,
    String? documentNumber,
    String? addressLine,
    String? addressCity,
    String? addressState,
    String? addressCountry,
    String? fgFullName,
    String? fgRelation,
    String? fgEmail,
    String? fgPhone,
    String? sgFullName,
    String? sgRelation,
    String? sgEmail,
    String? sgPhone,
    String? photoBase64,
    String? photoContentType,
  }) {
    Address? address;
    final hasAddress = (addressLine?.isNotEmpty ?? false) ||
        (addressCity?.isNotEmpty ?? false) ||
        (addressState?.isNotEmpty ?? false) ||
        (addressCountry?.isNotEmpty ?? false);
    if (hasAddress) {
      address = Address(
        line: (addressLine != null && addressLine.isNotEmpty)
            ? [addressLine]
            : null,
        city: addressCity,
        state: addressState,
        country: addressCountry,
      );
    }

    Photo? photo;
    if (photoBase64 != null &&
        photoBase64.isNotEmpty &&
        photoContentType != null &&
        photoContentType.isNotEmpty) {
      photo = Photo(fileBase64: photoBase64, contentType: photoContentType);
    }

    return CreateStudentRequest(
      branchId: branchId,
      organizationId: organizationId,
      name: StudentName(given: firstName, family: lastName),
      dateOfBirth: _formatDateForApi(dateOfBirth),
      gender: gender,
      grade: grade,
      classId: classId,
      nationality: nationality,
      documentType: documentType,
      documentNumber: documentNumber,
      address: address,
      fgFullName: fgFullName,
      fgRelation: fgRelation,
      fgEmail: fgEmail,
      fgPhone: fgPhone,
      sgFullName: sgFullName,
      sgRelation: sgRelation,
      sgEmail: sgEmail,
      sgPhone: sgPhone,
      photo: photo,
    );
  }

  static String _formatDateForApi(DateTime date) {
    final year = date.year.toString();
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }
}

class StudentName {
  final String given;
  final String family;

  StudentName({required this.given, required this.family});

  Map<String, dynamic> toJson() => {'given': given, 'family': family};

  factory StudentName.fromJson(Map<String, dynamic> json) => StudentName(
        given: json['given'] ?? '',
        family: json['family'] ?? '',
      );
}

class Address {
  final List<String>? line;
  final String? city;
  final String? state;
  final String? country;

  Address({this.line, this.city, this.state, this.country});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {};
    if (line != null && line!.isNotEmpty) json['line'] = line;
    if (city != null && city!.isNotEmpty) json['city'] = city;
    if (state != null && state!.isNotEmpty) json['state'] = state;
    if (country != null && country!.isNotEmpty) json['country'] = country;
    return json;
  }

  factory Address.fromJson(Map<String, dynamic> json) => Address(
        line: json['line'] != null ? List<String>.from(json['line']) : null,
        city: json['city'],
        state: json['state'],
        country: json['country'],
      );
}

class Photo {
  final String fileBase64;
  final String contentType;

  Photo({required this.fileBase64, required this.contentType});

  Map<String, dynamic> toJson() => {
        'fileBase64': fileBase64,
        'contentType': contentType,
      };
}
