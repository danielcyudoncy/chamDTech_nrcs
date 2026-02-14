import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:chamDTech_nrcs/features/auth/services/auth_service.dart';
import 'package:chamDTech_nrcs/core/constants/app_constants.dart';

class AuthController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final displayNameController = TextEditingController();
  
  final isLoading = false.obs;
  final isPasswordHidden = true.obs;
  final selectedRole = AppConstants.roleReporter.obs;
  
  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }
  
  Future<void> login() async {
    isLoading.value = true;
    try {
      final user = await _authService.signIn(
        emailController.text.trim(),
        passwordController.text,
      );
      if (user != null) {
        Get.offAllNamed('/stories');
      }
    } finally {
      isLoading.value = false;
    }
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
        Get.back(); // Close dialog
        Get.offAllNamed('/stories');
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
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
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
                    value: selectedRole.value,
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
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
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
    );
  }
  
  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    displayNameController.dispose();
    super.onClose();
  }
}
