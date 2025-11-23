import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/organization_model.dart';

class OrganizationController extends GetxController {
  // Form key for validation
  final formKey = GlobalKey<FormState>();
  
  // Organization model to hold form data
  final organization = OrganizationModel().obs;
  
  // Loading state
  final isLoading = false.obs;
  
  // Error message
  final errorMessage = ''.obs;
  
  // List of available options for dropdowns
  final List<String> accountTypes = ['School', 'University', 'Hospital', 'Clinic'];
  final List<String> roles = ['Doctor', 'Nurse', 'Administrator', 'Teacher'];
  final List<String> educationTypes = ['British', 'American', 'French', 'German', 'IB'];
  final List<String> countries = ['Egypt', 'Saudi Arabia', 'UAE', 'Kuwait', 'Qatar'];
// In your OrganizationController
final List<String> governorates = ['Cairo', 'Alexandria', 'Giza', 'Port Said', 'Suez'];
final List<String> cities = ['Cairo City', 'Alexandria City', 'Giza City', 'Sharm El Sheikh', 'Luxor'];
final List<String> areas = ['Nasr City', 'Maadi', 'Zamalek', 'Heliopolis', 'New Cairo'];

  // Update organization field
  void updateField(String field, dynamic value) {
    organization.update((org) {
      if (org == null) return;
      
      switch (field) {
        case 'accountType':
          org.accountType = value as String?;
          break;
        case 'organizationName':
          org.organizationName = value as String?;
          break;
        case 'role':
          org.role = value as String?;
          break;
        case 'educationType':
          org.educationType = value as String?;
          break;
        case 'headquarters':
          org.headquarters = value as String?;
          break;
        case 'streetAddress':
          org.streetAddress = value as String?;
          break;
        case 'country':
          org.country = value as String?;
          break;
        case 'governorate':
          org.governorate = value as String?;
          break;
        case 'city':
          org.city = value as String?;
          break;
        case 'area':
          org.area = value as String?;
          break;
      }
    });
  }

  // Toggle terms acceptance
  void toggleTerms(bool? value) {
    organization.update((org) {
      org!.acceptTerms = value ?? false;
    });
  }

  // Validate form
  bool validateForm() {
    if (formKey.currentState?.validate() ?? false) {
      if (!(organization.value.acceptTerms)) {
        Get.snackbar('Error', 'Please accept the terms and conditions');
        return false;
      }
      return true;
    }
    return false;
  }

  // Submit form
  Future<void> submitForm() async {
    if (!validateForm()) return;

    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      // TODO: Implement API call to submit organization data
      await Future.delayed(const Duration(seconds: 2)); // Simulate API call
      
      // On success, navigate to success screen or dashboard
      Get.snackbar('Success', 'Organization created successfully');
    } catch (e) {
      errorMessage.value = 'Failed to create organization. Please try again.';
      Get.snackbar('Error', errorMessage.value);
    } finally {
      isLoading.value = false;
    }
  }

  // Reset form
  void resetForm() {
    formKey.currentState?.reset();
    organization.value = OrganizationModel();
  }
}