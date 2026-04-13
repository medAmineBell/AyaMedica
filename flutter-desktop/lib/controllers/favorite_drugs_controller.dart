import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../utils/storage_service.dart';
import '../utils/app_snackbar.dart';

class FavoriteDrugsController extends GetxController {
  final StorageService _storageService = Get.find<StorageService>();

  // Search
  final drugSearchController = TextEditingController();
  final drugSearchResults = <Map<String, dynamic>>[].obs;
  final isLoadingSearch = false.obs;
  final selectedDrug = Rxn<Map<String, dynamic>>();
  Timer? _searchDebounce;

  // Favorites list
  final favoriteDrugs = <Map<String, dynamic>>[].obs;
  final isLoadingFavorites = false.obs;
  final isAddingFavorite = false.obs;

  String get _country {
    final branchData = _storageService.getSelectedBranchData();
    return branchData?['country'] as String? ?? 'EG';
  }

  String? get _branchId {
    return _storageService.getSelectedBranchData()?['id'] as String?;
  }

  Map<String, String> _authHeaders() {
    final accessToken = _storageService.getAccessToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken',
    };
  }

  @override
  void onInit() {
    super.onInit();
    fetchFavorites();
  }

  @override
  void onClose() {
    _searchDebounce?.cancel();
    drugSearchController.dispose();
    super.onClose();
  }

  // --- Drug Search with debounce ---
  void onSearchChanged(String query) {
    selectedDrug.value = null;
    _searchDebounce?.cancel();
    if (query.trim().isEmpty) {
      drugSearchResults.clear();
      return;
    }
    _searchDebounce = Timer(const Duration(milliseconds: 300), () {
      _fetchDrugSearch(query);
    });
  }

  Future<void> _fetchDrugSearch(String search) async {
    try {
      isLoadingSearch.value = true;
      var urlStr =
          '${AppConfig.newBackendUrl}/api/lookups/drugs?country=$_country';
      if (search.isNotEmpty) {
        urlStr += '&search=${Uri.encodeComponent(search)}';
      }
      final response =
          await http.get(Uri.parse(urlStr), headers: _authHeaders());
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData['success'] == true) {
          final data = jsonData['data'] as List;
          drugSearchResults.assignAll(
            data.map((d) => Map<String, dynamic>.from(d)).toList(),
          );
        }
      }
    } catch (e) {
      debugPrint('[FavoriteDrugsController] Error searching drugs: $e');
    } finally {
      isLoadingSearch.value = false;
    }
  }

  void selectDrug(Map<String, dynamic> drug) {
    selectedDrug.value = drug;
    drugSearchController.text = drug['drug_name']?.toString() ?? '';
    drugSearchResults.clear();
  }

  // --- Add to favorites ---
  Future<void> addSelectedToFavorites() async {
    final drug = selectedDrug.value;
    if (drug == null) return;
    final drugId = drug['id']?.toString();
    if (drugId == null) return;

    try {
      isAddingFavorite.value = true;
      final response = await http.post(
        Uri.parse(
            '${AppConfig.newBackendUrl}/api/clinic/medications/$drugId/mark-favorite'),
        headers: _authHeaders(),
        body: jsonEncode({
          'branchId': _branchId,
          'country': _country,
          'isFavorite': true,
        }),
      );
      if (response.statusCode == 200) {
        drugSearchController.clear();
        selectedDrug.value = null;
        drugSearchResults.clear();
        await fetchFavorites();
        appSnackbar('Success', 'Drug added to favorites',
            backgroundColor: const Color(0xFF10B981));
      }
    } catch (e) {
      debugPrint('[FavoriteDrugsController] Error adding favorite: $e');
      appSnackbar('Error', 'Failed to add drug to favorites',
          backgroundColor: const Color(0xFFEF4444));
    } finally {
      isAddingFavorite.value = false;
    }
  }

  // --- Fetch favorites list ---
  Future<void> fetchFavorites() async {
    try {
      isLoadingFavorites.value = true;
      final branchId = _branchId;
      if (branchId == null) return;

      final url =
          '${AppConfig.newBackendUrl}/api/clinic/medications/favorites'
          '?branchId=$branchId&country=$_country';
      final response = await http.get(Uri.parse(url), headers: _authHeaders());
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData['success'] == true) {
          final data = jsonData['data'] as List;
          favoriteDrugs.assignAll(
            data.map((d) => Map<String, dynamic>.from(d)).toList(),
          );
        }
      }
    } catch (e) {
      debugPrint('[FavoriteDrugsController] Error fetching favorites: $e');
    } finally {
      isLoadingFavorites.value = false;
    }
  }

  // --- Remove from favorites ---
  Future<void> removeFavorite(Map<String, dynamic> drug) async {
    final drugId = drug['id']?.toString();
    if (drugId == null) return;

    try {
      final response = await http.post(
        Uri.parse(
            '${AppConfig.newBackendUrl}/api/clinic/medications/$drugId/mark-favorite'),
        headers: _authHeaders(),
        body: jsonEncode({
          'branchId': _branchId,
          'country': _country,
          'isFavorite': false,
        }),
      );
      if (response.statusCode == 200) {
        favoriteDrugs.removeWhere((d) => d['id']?.toString() == drugId);
        appSnackbar('Success', 'Drug removed from favorites',
            backgroundColor: const Color(0xFF10B981));
      }
    } catch (e) {
      debugPrint('[FavoriteDrugsController] Error removing favorite: $e');
      appSnackbar('Error', 'Failed to remove drug from favorites',
          backgroundColor: const Color(0xFFEF4444));
    }
  }
}
