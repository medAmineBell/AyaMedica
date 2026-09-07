import 'dart:typed_data';

class CreateBranchRequest {
  final String name;
  final String accountType;
  final bool isHeadquarters;
  final String? educationType;
  final List<String> grades;
  final BranchAddress address;
  final String? phone;
  final String? website;

  // Multipart-only fields (not serialized in toJson)
  final Uint8List? logoBytes;
  final String? logoFileName;

  CreateBranchRequest({
    required this.name,
    required this.accountType,
    required this.isHeadquarters,
    this.educationType,
    required this.grades,
    required this.address,
    this.phone,
    this.website,
    this.logoBytes,
    this.logoFileName,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {
      'name': name,
      'accountType': accountType,
      'isHeadquarters': isHeadquarters,
      'grades': grades,
      'address': address.toJson(),
    };

    if (educationType != null && educationType!.isNotEmpty) {
      json['educationType'] = educationType;
    }

    if (phone != null && phone!.isNotEmpty) {
      json['phone'] = phone;
    }

    if (website != null && website!.isNotEmpty) {
      json['website'] = website;
    }

    return json;
  }
}

class BranchAddress {
  final String governorate;
  final String city;
  final String? street;

  BranchAddress({
    required this.governorate,
    required this.city,
    this.street,
  });

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'governorate': governorate,
      'city': city,
    };
    if (street != null && street!.isNotEmpty) {
      json['street'] = street;
    }
    return json;
  }

  factory BranchAddress.fromJson(Map<String, dynamic> json) {
    return BranchAddress(
      governorate: json['governorate'] ?? '',
      city: json['city'] ?? '',
      street: json['street'],
    );
  }
}

class BranchResponse {
  final String id;
  final String name;
  final String accountType;
  final bool isHeadquarters;
  final String? educationType;
  final List<String> grades;
  final String country;
  final BranchAddress address;
  final String? phone;
  final String? website;
  final String status;
  final String medplumProject;

  BranchResponse({
    required this.id,
    required this.name,
    required this.accountType,
    required this.isHeadquarters,
    this.educationType,
    required this.grades,
    required this.country,
    required this.address,
    this.phone,
    this.website,
    required this.status,
    required this.medplumProject,
  });

  factory BranchResponse.fromJson(Map<String, dynamic> json) {
    return BranchResponse(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      accountType: json['accountType'] ?? 'School',
      isHeadquarters: json['isHeadquarters'] ?? false,
      educationType: json['educationType'],
      grades: json['grades'] != null ? List<String>.from(json['grades']) : [],
      country: json['country'] ?? 'EG',
      address: BranchAddress.fromJson(json['address'] ?? {}),
      phone: json['phone'],
      website: json['website'],
      status: json['status'] ?? 'active',
      medplumProject: json['medplumProject'] ?? 'EG',
    );
  }
}
