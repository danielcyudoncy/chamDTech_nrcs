// features/profile/controllers/profile_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:chamdtech_nrcs/core/constants/app_constants.dart';
import 'package:chamdtech_nrcs/features/auth/services/auth_service.dart';


class ProfileController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  final ImagePicker _picker = ImagePicker();
  final FirebaseStorage _storage = FirebaseStorage.instance;
  
  final displayNameController = TextEditingController();
  final isLoading = false.obs;
  final selectedXFile = Rx<XFile?>(null);
  
  @override
  void onInit() {
    super.onInit();
    final user = _authService.currentUser.value;
    if (user != null) {
      displayNameController.text = user.displayName;
    }
  }
  
  @override
  void onClose() {
    displayNameController.dispose();
    super.onClose();
  }
  
  // Pick image from gallery
  Future<void> pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 75,
      );
      
      if (image != null) {
        selectedXFile.value = image;
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to pick image: $e');
    }
  }
  
  Future<void> saveProfile() async {
    if (displayNameController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Display name cannot be empty');
      return;
    }
    
    isLoading.value = true;
    try {
      String? photoUrl;
      
      // Upload image if selected
      if (selectedXFile.value != null) {
        final user = _authService.currentUser.value;
        if (user != null) {
          final ref = _storage.ref().child('${AppConstants.profilePicturesPath}/${user.id}/profile.jpg');
          
          final bytes = await selectedXFile.value!.readAsBytes();
          
          // Use metadata to ensure content type
          final uploadTask = ref.putData(
            bytes,
            SettableMetadata(contentType: 'image/jpeg'),
          );
          
          final snapshot = await uploadTask;
          
          photoUrl = await snapshot.ref.getDownloadURL();
        }
      }
      
      await _authService.updateUserProfile(
        displayName: displayNameController.text.trim(),
        photoUrl: photoUrl,
      );
      
      Get.back();
      Get.snackbar('Success', 'Profile updated successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to update profile: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
