// features/profile/views/profile_screen.dart
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chamdtech_nrcs/features/auth/services/auth_service.dart';
import 'package:chamdtech_nrcs/features/profile/controllers/profile_controller.dart';
import 'package:chamdtech_nrcs/features/stories/views/widgets/nrcs_layout.dart';

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
        child: Column(
          children: [
            // Modern Header with Gradient
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Theme.of(context).primaryColor,
                    Theme.of(context)
                        .primaryColor
                        .withAlpha((0.7 * 255).round()),
                  ],
                ),
              ),
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
              child: Column(
                children: [
                  // Avatar with Camera Button
                  Stack(
                    children: [
                      Obx(() {
                        final pickedFile = controller.selectedXFile.value;
                        final currentPhotoUrl =
                            authService.currentUser.value?.photoUrl;

                        ImageProvider? backgroundImage;
                        if (pickedFile != null) {
                          if (kIsWeb) {
                            backgroundImage =
                                CachedNetworkImageProvider(pickedFile.path);
                          } else {
                            backgroundImage = FileImage(File(pickedFile.path));
                          }
                        } else if (currentPhotoUrl != null) {
                          backgroundImage =
                              CachedNetworkImageProvider(currentPhotoUrl);
                        }

                        return Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color:
                                    Colors.black.withAlpha((0.3 * 255).round()),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 70,
                            backgroundColor: Colors.grey[300],
                            backgroundImage: backgroundImage,
                            child:
                                (pickedFile == null && currentPhotoUrl == null)
                                    ? Text(
                                        user?.displayName.isNotEmpty == true
                                            ? user!.displayName
                                                .substring(0, 1)
                                                .toUpperCase()
                                            : 'U',
                                        style: const TextStyle(
                                          fontSize: 56,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      )
                                    : null,
                          ),
                        );
                      }),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: controller.pickImage,
                            borderRadius: BorderRadius.circular(50),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black
                                        .withAlpha((0.2 * 255).round()),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.camera_alt,
                                color: Theme.of(context).primaryColor,
                                size: 24,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    user?.displayName ?? 'User Profile',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha((0.2 * 255).round()),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      user?.role.toUpperCase() ?? 'USER',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                ],
              ),
            ),
            // Content Section
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  // Personal Information Section
                  _buildSectionHeader(context, 'Personal Information'),
                  const SizedBox(height: 16),
                  _buildModernTextField(
                    context,
                    controller: controller.displayNameController,
                    labelText: 'Display Name',
                    prefixIcon: Icons.person_outline,
                    onChanged: (_) {},
                  ),
                  const SizedBox(height: 20),

                  // Account Information Section
                  _buildSectionHeader(context, 'Account Information'),
                  const SizedBox(height: 16),
                  _buildReadOnlyField(
                    context,
                    labelText: 'Email',
                    value: user?.email ?? 'N/A',
                    prefixIcon: Icons.email_outlined,
                  ),
                  const SizedBox(height: 20),
                  _buildReadOnlyField(
                    context,
                    labelText: 'Role',
                    value: user?.role.toUpperCase() ?? 'N/A',
                    prefixIcon: Icons.badge_outlined,
                  ),
                  const SizedBox(height: 32),

                  // Save Button
                  Obx(() => controller.isLoading.value
                      ? Container(
                          height: 56,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            gradient: LinearGradient(
                              colors: [
                                Theme.of(context).primaryColor,
                                Theme.of(context)
                                    .primaryColor
                                    .withAlpha((0.8 * 255).round()),
                              ],
                            ),
                          ),
                          child: const Center(
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                          ),
                        )
                      : Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            gradient: LinearGradient(
                              colors: [
                                Theme.of(context).primaryColor,
                                Theme.of(context)
                                    .primaryColor
                                    .withAlpha((0.8 * 255).round()),
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Theme.of(context)
                                    .primaryColor
                                    .withAlpha((0.4 * 255).round()),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: controller.saveProfile,
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                height: 56,
                                alignment: Alignment.center,
                                child: Text(
                                  'Save Changes',
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelLarge
                                      ?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                      ),
                                ),
                              ),
                            ),
                          ),
                        )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
      ),
    );
  }

  Widget _buildModernTextField(
    BuildContext context, {
    required TextEditingController controller,
    required String labelText,
    required IconData prefixIcon,
    required Function(String) onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.05 * 255).round()),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: labelText,
          prefixIcon: Icon(prefixIcon),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey[800]
              : Colors.grey[50],
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          labelStyle: TextStyle(
            color: Theme.of(context).hintColor,
          ),
          prefixIconColor: Theme.of(context).primaryColor,
        ),
      ),
    );
  }

  Widget _buildReadOnlyField(
    BuildContext context, {
    required String labelText,
    required String value,
    required IconData prefixIcon,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.05 * 255).round()),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        readOnly: true,
        controller: TextEditingController(text: value),
        decoration: InputDecoration(
          labelText: labelText,
          prefixIcon: Icon(prefixIcon),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey[900]
              : Colors.grey[100],
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          labelStyle: TextStyle(
            color: Theme.of(context).hintColor,
          ),
          prefixIconColor: Theme.of(context).primaryColor,
        ),
        style: TextStyle(
          color: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.color
              ?.withAlpha((0.6 * 255).round()),
        ),
      ),
    );
  }
}
