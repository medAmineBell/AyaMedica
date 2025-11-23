class OrganizationModel {
  String? id;
  String? accountType;
  String? organizationName;
  String? role;
  String? educationType;
  String? headquarters;
  String? streetAddress;
  String? country;
  String? governorate;
  String? city;
  String? area;
  bool acceptTerms;
  String? userId;
  DateTime? createdAt;
  DateTime? updatedAt;
  String? logoPath;

  OrganizationModel({
    this.id,
    this.accountType = 'School',
    this.organizationName,
    this.role = 'Doctor',
    this.educationType = 'British',
    this.headquarters,
    this.streetAddress,
    this.country = 'Egypt',
    this.governorate = 'Alexandria',
    this.city = 'Alexandria',
    this.area = 'Alexandria',
    this.acceptTerms = false,
    this.userId,
    this.createdAt,
    this.updatedAt,
    this.logoPath,
  });

  // Convert OrganizationModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'accountType': accountType,
      'organizationName': organizationName,
      'role': role,
      'educationType': educationType,
      'headquarters': headquarters,
      'streetAddress': streetAddress,
      'country': country,
      'governorate': governorate,
      'city': city,
      'area': area,
      'acceptTerms': acceptTerms,
      'userId': userId,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'logoPath': logoPath,
    };
  }

  // Create OrganizationModel from JSON
  factory OrganizationModel.fromJson(Map<String, dynamic> json) {
    return OrganizationModel(
      id: json['id'],
      accountType: json['accountType'] ?? 'School',
      organizationName: json['organizationName'],
      role: json['role'] ?? 'Doctor',
      educationType: json['educationType'] ?? 'British',
      headquarters: json['headquarters'],
      streetAddress: json['streetAddress'],
      country: json['country'] ?? 'Egypt',
      governorate: json['governorate'] ?? 'Alexandria',
      city: json['city'] ?? 'Alexandria',
      area: json['area'] ?? 'Alexandria',
      acceptTerms: json['acceptTerms'] ?? false,
      userId: json['userId'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      logoPath: json['logoPath'],
    );
  }

  // Create a copy of the model with updated fields
  OrganizationModel copyWith({
    String? id,
    String? accountType,
    String? organizationName,
    String? role,
    String? educationType,
    String? headquarters,
    String? streetAddress,
    String? country,
    String? governorate,
    String? city,
    String? area,
    bool? acceptTerms,
    String? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? logoPath,
  }) {
    return OrganizationModel(
      id: id ?? this.id,
      accountType: accountType ?? this.accountType,
      organizationName: organizationName ?? this.organizationName,
      role: role ?? this.role,
      educationType: educationType ?? this.educationType,
      headquarters: headquarters ?? this.headquarters,
      streetAddress: streetAddress ?? this.streetAddress,
      country: country ?? this.country,
      governorate: governorate ?? this.governorate,
      city: city ?? this.city,
      area: area ?? this.area,
      acceptTerms: acceptTerms ?? this.acceptTerms,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      logoPath: logoPath ?? this.logoPath,
    );
  }
}