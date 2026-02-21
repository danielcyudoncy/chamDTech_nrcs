import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:chamDTech_nrcs/features/auth/services/auth_service.dart';
import 'package:chamDTech_nrcs/features/profile/controllers/profile_controller.dart';
import 'package:chamDTech_nrcs/features/stories/views/widgets/nrcs_layout.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ProfileController controller = Get.put(ProfileController());
    final AuthService authService = Get.find<AuthService>();
    final user = authService.currentUser.value;

    return NRCSAppShell(
      title: 'Profile',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Stack(
              children: [
                Obx(() {
                  final pickedFile = controller.selectedXFile.value;
                  final currentPhotoUrl = authService.currentUser.value?.photoUrl;
                  
                  ImageProvider? backgroundImage;
                  if (pickedFile != null) {
                    if (kIsWeb) {
                      backgroundImage = NetworkImage(pickedFile.path);
                    } else {
                      backgroundImage = FileImage(File(pickedFile.path));
                    }
                  } else if (currentPhotoUrl != null) {
                    backgroundImage = NetworkImage(currentPhotoUrl);
                  }

                  return CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.grey[300],
                    backgroundImage: backgroundImage,
                    child: (pickedFile == null && currentPhotoUrl == null)
                        ? Text(
                            user?.displayName.isNotEmpty == true
                                ? user!.displayName.substring(0, 1).toUpperCase()
                                : 'U',
                            style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
                          )
                        : null,
                  );
                }),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: controller.pickImage,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            TextField(
              controller: controller.displayNameController,
              decoration: const InputDecoration(
                labelText: 'Display Name',
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              readOnly: true,
              controller: TextEditingController(text: user?.email),
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email),
                filled: true,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              readOnly: true,
              controller: TextEditingController(text: user?.role.toUpperCase()),
              decoration: const InputDecoration(
                labelText: 'Role',
                prefixIcon: Icon(Icons.badge),
                filled: true,
              ),
            ),
            const SizedBox(height: 32),
            Obx(() => controller.isLoading.value
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: controller.saveProfile,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text('Save Changes'),
                  )
            ),
          ],
        ),
      ),
    );
  }
}
