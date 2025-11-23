import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_getx_app/controllers/organization_controller.dart';

class OrganizationLogoSection extends StatelessWidget {
  final OrganizationController controller = Get.find();

  OrganizationLogoSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        const SizedBox(height: 12),
        Center(
          child: Stack(
            children: [
              Obx(() {
                final imageFile = controller.organization.value.logoPath;
                return Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.grey[300]!,
                      width: 2,
                    ),
                    image: imageFile != null && imageFile.isNotEmpty
                        ? DecorationImage(
                            image: FileImage(File(imageFile)),
                            fit: BoxFit.cover,
                            onError: (error, stackTrace) {
                              debugPrint('Error loading image: $error');
                            },
                          )
                        : const DecorationImage(
                            image: AssetImage('assets/images/default_org.png'),
                            fit: BoxFit.contain,
                          ),
                  ),
                );
              }),
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  decoration:const BoxDecoration(
                    color:  Color(0xFFCDF7FF),
                    shape: BoxShape.circle,
                   
                  ),
                  child: IconButton(
                    icon: SvgPicture.asset("assets/svg/edit.svg",height: 26,),
                    onPressed: _pickImage,
                    tooltip: 'Change Logo',
                  ),
                ),
              ),
            ],
          ),
        ),
       
      
      ],
    );
  }

  Future<void> _pickImage() async {
    try {
      // Show loading indicator
      Get.dialog(
        const Center(
          child: CircularProgressIndicator(),
        ),
        barrierDismissible: false,
      );

      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'gif', 'webp'],
        allowMultiple: false,
        dialogTitle: 'Select Organization Logo',
        // Enable compression for better performance on Windows
        compressionQuality: 85,
      );

      // Close loading dialog
      Get.back();

      if (result != null && result.files.isNotEmpty) {
        final pickedFile = result.files.single;
        final filePath = pickedFile.path;
        
        if (filePath != null) {
          final file = File(filePath);
          
          // Validate file exists
          if (await file.exists()) {
            // Validate file size (optional)
            final fileSize = await file.length();
            const maxSize = 10 * 1024 * 1024; // 10MB
            
            if (fileSize > maxSize) {
              Get.snackbar(
                'Error',
                'File size too large. Please select an image smaller than 10MB.',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.red[100],
                colorText: Colors.red[800],
              );
              return;
            }
            
            // Validate file extension (double check)
            final extension = filePath.split('.').last.toLowerCase();
            final allowedExtensions = ['jpg', 'jpeg', 'png', 'gif', 'webp'];
            
            if (!allowedExtensions.contains(extension)) {
              Get.snackbar(
                'Error',
                'Invalid file format. Please select JPG, PNG, GIF, or WebP files.',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.red[100],
                colorText: Colors.red[800],
              );
              return;
            }
            
            await _handlePickedFile(file);
          } else {
            throw Exception('Selected file does not exist');
          }
        } else {
          throw Exception('No file path available');
        }
      }
    } catch (e) {
      // Close loading dialog if still open
      if (Get.isDialogOpen == true) {
        Get.back();
      }
      
      debugPrint('Error picking file: $e');
      Get.snackbar(
        'Error',
        'Failed to pick image. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[800],
        duration: const Duration(seconds: 3),
      );
    }
  }

  Future<void> _handlePickedFile(File file) async {
    try {
      // Update the organization logo path
      controller.organization.update((org) {
        if (org != null) {
          org.logoPath = file.path;
        }
      });

      // Show success message
      Get.snackbar(
        'Success',
        'Logo updated successfully!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green[100],
        colorText: Colors.green[800],
        duration: const Duration(seconds: 2),
      );
      
      // Optional: Save to persistent storage or upload to server
      // await controller.saveOrganization();
      
    } catch (e) {
      debugPrint('Error handling picked file: $e');
      Get.snackbar(
        'Error',
        'Failed to update logo. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[800],
      );
    }
  }
}