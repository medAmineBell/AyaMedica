class AddressModel {
  final String street;
  final String city;
  final String governorate;
  final String area;

  AddressModel({
    required this.street,
    required this.city,
    required this.governorate,
    required this.area,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      street: json['street'] ?? '',
      city: json['city'] ?? '',
      governorate: json['governorate'] ?? '',
      area: json['area'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'street': street,
      'city': city,
      'governorate': governorate,
      'area': area,
    };
  }

  @override
  String toString() {
    return '$street, $area, $city, $governorate';
  }

  AddressModel copyWith({
    String? street,
    String? city,
    String? governorate,
    String? area,
  }) {
    return AddressModel(
      street: street ?? this.street,
      city: city ?? this.city,
      governorate: governorate ?? this.governorate,
      area: area ?? this.area,
    );
  }
}
