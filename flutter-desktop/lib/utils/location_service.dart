import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

class GovernorateModel {
  final String id;
  final String key;
  final String countryKey;
  final String nameAr;
  final String nameEn;

  GovernorateModel({
    required this.id,
    required this.key,
    required this.countryKey,
    required this.nameAr,
    required this.nameEn,
  });

  factory GovernorateModel.fromJson(Map<String, dynamic> json) {
    return GovernorateModel(
      id: json['id'] ?? '',
      key: json['key'] ?? '',
      countryKey: json['countryKey'] ?? '',
      nameAr: json['nameAr'] ?? '',
      nameEn: json['nameEn'] ?? '',
    );
  }
}

class CityModel {
  final String id;
  final String key;
  final String governorateKey;
  final String nameAr;
  final String nameEn;

  CityModel({
    required this.id,
    required this.key,
    required this.governorateKey,
    required this.nameAr,
    required this.nameEn,
  });

  factory CityModel.fromJson(Map<String, dynamic> json) {
    return CityModel(
      id: json['id'] ?? '',
      key: json['key'] ?? '',
      governorateKey: json['governorateKey'] ?? '',
      nameAr: json['nameAr'] ?? '',
      nameEn: json['nameEn'] ?? '',
    );
  }
}

class LocationService extends GetxService {
  static const String _baseUrl = AppConfig.newBackendUrl;

  final RxList<GovernorateModel> governorates = <GovernorateModel>[].obs;
  final RxList<CityModel> cities = <CityModel>[].obs;
  final RxBool isLoadingGovernorates = false.obs;
  final RxBool isLoadingCities = false.obs;

  // Cache cities by governorate key to avoid re-fetching
  final Map<String, List<CityModel>> _citiesCache = {};

  Future<LocationService> init() async {
    await fetchGovernorates();
    return this;
  }

  /// Fetch governorates for a given country (defaults to EG)
  Future<void> fetchGovernorates({String country = 'EG'}) async {
    isLoadingGovernorates.value = true;
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/organizations/governorates?country=$country'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          governorates.value = (data['data'] as List)
              .map((item) => GovernorateModel.fromJson(item))
              .toList();
          // Sort alphabetically by English name
          governorates.sort((a, b) => a.nameEn.compareTo(b.nameEn));
        }
      }
    } catch (e) {
      print('Failed to fetch governorates: $e');
    } finally {
      isLoadingGovernorates.value = false;
    }
  }

  /// Fetch cities for a given governorate key and country
  Future<void> fetchCities(String governorateKey,
      {String country = 'EG'}) async {
    // Check cache first
    if (_citiesCache.containsKey(governorateKey)) {
      cities.value = _citiesCache[governorateKey]!;
      return;
    }

    isLoadingCities.value = true;
    try {
      final response = await http.get(
        Uri.parse(
            '$_baseUrl/api/organizations/cities?governorate=$governorateKey&country=$country'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          final cityList = (data['data'] as List)
              .map((item) => CityModel.fromJson(item))
              .toList();
          // Sort alphabetically by English name
          cityList.sort((a, b) => a.nameEn.compareTo(b.nameEn));
          _citiesCache[governorateKey] = cityList;
          cities.value = cityList;
        }
      }
    } catch (e) {
      print('Failed to fetch cities: $e');
    } finally {
      isLoadingCities.value = false;
    }
  }

  /// Get governorate display names for dropdowns
  List<String> get governorateNames =>
      governorates.map((g) => g.nameEn).toList();

  /// Get city display names for dropdowns
  List<String> get cityNames => cities.map((c) => c.nameEn).toList();

  /// Get governorate key from display name
  String? getGovernorateKey(String nameEn) {
    final gov = governorates.firstWhereOrNull((g) => g.nameEn == nameEn);
    return gov?.key;
  }

  /// Get governorate display name from key
  String? getGovernorateNameFromKey(String key) {
    final gov =
        governorates.firstWhereOrNull((g) => g.key == key.toUpperCase());
    return gov?.nameEn;
  }

  /// Get city display name from key within current cities list
  String? getCityNameFromKey(String key) {
    final city = cities.firstWhereOrNull((c) => c.key == key);
    return city?.nameEn;
  }

  /// Get city key from display name
  String? getCityKey(String nameEn) {
    final city = cities.firstWhereOrNull((c) => c.nameEn == nameEn);
    return city?.key;
  }
}
