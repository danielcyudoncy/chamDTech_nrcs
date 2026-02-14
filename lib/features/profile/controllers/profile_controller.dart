import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:chamDTech_nrcs/core/constants/app_constants.dart';
import 'package:chamDTech_nrcs/features/auth/services/auth_service.dart';


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
    print('DEBUG: Profile saving started...');
    try {
      String? photoUrl;
      
      // Upload image if selected
      if (selectedXFile.value != null) {
        final user = _authService.currentUser.value;
        if (user != null) {
          print('DEBUG: Image selection found, uploading for user ${user.id}...');
          final ref = _storage.ref().child('${AppConstants.profilePicturesPath}/${user.id}/profile.jpg');
          
          final bytes = await selectedXFile.value!.readAsBytes();
          print('DEBUG: Read ${bytes.length} bytes for upload.');
          
          // Use metadata to ensure content type
          final uploadTask = ref.putData(
            bytes,
            SettableMetadata(contentType: 'image/jpeg'),
          );
          
          print('DEBUG: Waiting for upload task completion...');
          final snapshot = await uploadTask;
          print('DEBUG: Upload task finished. State: ${snapshot.state}');
          
          photoUrl = await snapshot.ref.getDownloadURL();
          print('DEBUG: Download URL obtained: $photoUrl');
        }
      }
      
      print('DEBUG: Calling AuthService.updateUserProfile...');
      await _authService.updateUserProfile(
        displayName: displayNameController.text.trim(),
        photoUrl: photoUrl,
      );
      print('DEBUG: AuthService.updateUserProfile succeeded.');
      
      Get.back();
      Get.snackbar('Success', 'Profile updated successfully');
    } catch (e, stack) {
      print('DEBUG: Error in saveProfile: $e');
      print('DEBUG: Stack trace: $stack');
      Get.snackbar('Error', 'Failed to update profile: $e');
    } finally {
      print('DEBUG: saveProfile finally block. Setting isLoading to false.');
      isLoading.value = false;
    }
  }
}
