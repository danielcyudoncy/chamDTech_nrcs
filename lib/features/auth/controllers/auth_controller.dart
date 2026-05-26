// features/auth/controllers/auth_controller.dart
import 'package:chamdtech_nrcs/features/auth/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:chamdtech_nrcs/features/auth/services/auth_service.dart';
import 'package:chamdtech_nrcs/core/constants/app_constants.dart';
import 'package:chamdtech_nrcs/app/routes/app_routes.dart';

class AuthController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final displayNameController = TextEditingController();
  final organizationController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final isLoading = false.obs;
  final isPasswordHidden = true.obs;
  final isConfirmPasswordHidden = true.obs;
  final selectedRole = AppConstants.roleReporter.obs;

  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordHidden.value = !isConfirmPasswordHidden.value;
  }

  Future<void> login() async {
    isLoading.value = true;
    try {
      final user = await _authService.signIn(
        emailController.text.trim(),
        passwordController.text,
      );
      if (user != null) {
        Get.offAllNamed(AppRoutes.getRouteForRole(user.role));
      }
    } catch (e) {
      Get.snackbar(
        'Login Error',
        'An unexpected error occurred.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.1),
        colorText: Colors.red,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signInWithGoogle() async {
    isLoading.value = true;
    try {
      final result = await _authService.signInWithGoogle();

      if (result is UserModel) {
        // Existing user, navigate to their dashboard
        Get.offAllNamed(AppRoutes.getRouteForRole(result.role));
      } else if (result is User) {
        // New user, show role selection dialog
        _showRoleSelectionDialog(result);
      } else {
        // This handles the case where the user cancels the sign-in
        Get.snackbar(
          'Sign-In Canceled',
          'The Google Sign-In process was canceled.',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Google Sign-In Error',
        'An unexpected error occurred: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.1),
        colorText: Colors.red,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void _showRoleSelectionDialog(User user) {
    Get.dialog(
      AlertDialog(
        title: const Text('Select Your Role'),
        content: DropdownButtonFormField<String>(
          initialValue: selectedRole.value,
          items: const [
            DropdownMenuItem(
                value: AppConstants.roleAdmin, child: Text('Admin')),
            DropdownMenuItem(
                value: AppConstants.roleReporter, child: Text('Reporter')),
            DropdownMenuItem(
                value: AppConstants.roleProducer, child: Text('Producer')),
            DropdownMenuItem(
                value: AppConstants.roleEditor, child: Text('Editor')),
            DropdownMenuItem(
                value: AppConstants.roleAnchor, child: Text('Anchor')),
            DropdownMenuItem(
                value: AppConstants.roleDirector, child: Text('Director')),
          ],
          onChanged: (value) {
            if (value != null) {
              selectedRole.value = value;
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back(); // Close the dialog
              final newUser = await _authService.completeGoogleSignUp(
                user: user,
                role: selectedRole.value,
              );
              if (newUser != null) {
                Get.offAllNamed(AppRoutes.getRouteForRole(newUser.role));
              }
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String displayName,
    required String role,
  }) async {
    isLoading.value = true;
    try {
      final user = await _authService.signUp(
        email: email,
        password: password,
        displayName: displayName,
        role: role,
      );

      if (user != null) {
        Get.offAllNamed(AppRoutes.getRouteForRole(user.role));
      }
    } catch (e) {
      Get.snackbar(
        'Sign Up Error',
        'An unexpected error occurred.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.1),
        colorText: Colors.red,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void showForgotPasswordDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final emailCtrl = TextEditingController(text: emailController.text.trim());

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          padding: const EdgeInsets.all(24),
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Reset Password',
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Get.back(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Enter your email address and we\'ll send you a link to reset your password.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.done,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      prefixIcon: const Icon(Icons.email_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!GetUtils.isEmail(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                    onFieldSubmitted: (_) {
                      if (formKey.currentState!.validate()) {
                        _sendPasswordReset(emailCtrl.text.trim());
                      }
                    },
                  ),
                  const SizedBox(height: 24),
                  Obx(() => ElevatedButton(
                        onPressed: isLoading.value
                            ? null
                            : () {
                                if (formKey.currentState!.validate()) {
                                  _sendPasswordReset(emailCtrl.text.trim());
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: const Color(0xFF1976D2),
                          foregroundColor: Colors.white,
                        ),
                        child: isLoading.value
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              )
                            : const Text(
                                'Send Reset Link',
                                style: TextStyle(fontSize: 16),
                              ),
                      )),
                ],
              ),
            ),
          ),
        ),
      ),
    ).then((_) {
      // Dispose controller when dialog is closed
      emailCtrl.dispose();
    });
  }

  Future<void> _sendPasswordReset(String email) async {
    isLoading.value = true;
    try {
      final success = await _authService.sendPasswordResetEmail(email);
      if (success) {
        Get.back(); // Close the dialog
        Get.snackbar(
          'Email Sent',
          'Password reset link has been sent to $email',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withValues(alpha: 0.1),
          colorText: Colors.green,
        );
      }
    } finally {
      isLoading.value = false;
    }
  }

  void showSignUpDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final emailCtrl = TextEditingController();
    final passwordCtrl = TextEditingController();
    final nameCtrl = TextEditingController();

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          padding: const EdgeInsets.all(24),
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Create Account',
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Get.back(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: nameCtrl,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Full Name',
                      prefixIcon: Icon(Icons.person_outlined),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!GetUtils.isEmail(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: passwordCtrl,
                    obscureText: true,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) {
                      if (formKey.currentState!.validate()) {
                        signUp(
                          email: emailCtrl.text.trim(),
                          password: passwordCtrl.text,
                          displayName: nameCtrl.text.trim(),
                          role: selectedRole.value,
                        );
                      }
                    },
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      prefixIcon: Icon(Icons.lock_outlined),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  Obx(() => DropdownButtonFormField<String>(
                        initialValue: selectedRole.value,
                        decoration: const InputDecoration(
                          labelText: 'Role',
                          prefixIcon: Icon(Icons.work_outlined),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: AppConstants.roleAdmin,
                            child: Text('Admin'),
                          ),
                          DropdownMenuItem(
                            value: AppConstants.roleReporter,
                            child: Text('Reporter'),
                          ),
                          DropdownMenuItem(
                            value: AppConstants.roleProducer,
                            child: Text('Producer'),
                          ),
                          DropdownMenuItem(
                            value: AppConstants.roleEditor,
                            child: Text('Editor'),
                          ),
                          DropdownMenuItem(
                            value: AppConstants.roleAnchor,
                            child: Text('Anchor'),
                          ),
                          DropdownMenuItem(
                            value: AppConstants.roleDirector,
                            child: Text('Director'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            selectedRole.value = value;
                          }
                        },
                      )),
                  const SizedBox(height: 24),
                  Obx(() => ElevatedButton(
                        onPressed: isLoading.value
                            ? null
                            : () {
                                if (formKey.currentState!.validate()) {
                                  signUp(
                                    email: emailCtrl.text.trim(),
                                    password: passwordCtrl.text,
                                    displayName: nameCtrl.text.trim(),
                                    role: selectedRole.value,
                                  );
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: isLoading.value
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              )
                            : const Text(
                                'Create Account',
                                style: TextStyle(fontSize: 16),
                              ),
                      )),
                ],
              ),
            ),
          ),
        ),
      ),
    ).then((_) {
      // Dispose controllers when dialog is closed
      emailCtrl.dispose();
      passwordCtrl.dispose();
      nameCtrl.dispose();
    });
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    displayNameController.dispose();
    super.onClose();
  }
}
