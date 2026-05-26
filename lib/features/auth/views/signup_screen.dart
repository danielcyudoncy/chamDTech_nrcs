// features/auth/views/signup_screen.dart
import 'package:chamdtech_nrcs/app/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart' as gestures;
import 'package:get/get.dart';
import 'package:chamdtech_nrcs/features/auth/controllers/auth_controller.dart';
import 'package:chamdtech_nrcs/core/constants/app_constants.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  late AuthController authController;
  late GlobalKey<FormState> formKey;
  late TextEditingController fullNameController;
  late TextEditingController emailController;
  late TextEditingController organizationController;
  late TextEditingController passwordController;
  late TextEditingController confirmPasswordController;

  final isPasswordHidden = true.obs;
  final isConfirmPasswordHidden = true.obs;
  final passwordStrength = 0.0.obs;
  bool agreeToTerms = false;

  @override
  void initState() {
    super.initState();
    authController = Get.isRegistered<AuthController>()
        ? Get.find<AuthController>()
        : Get.put(AuthController());
    formKey = GlobalKey<FormState>();
    fullNameController = TextEditingController();
    emailController = TextEditingController();
    organizationController = TextEditingController();
    passwordController = TextEditingController();
    confirmPasswordController = TextEditingController();

    passwordController.addListener(_updatePasswordStrength);
  }

  @override
  void dispose() {
    fullNameController.dispose();
    emailController.dispose();
    organizationController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  void _updatePasswordStrength() {
    final password = passwordController.text;
    double strength = 0.0;

    // Length check
    if (password.length >= 8) strength += 0.25;
    if (password.length >= 12) strength += 0.25;

    // Contains uppercase
    if (password.contains(RegExp(r'[A-Z]'))) strength += 0.25;

    // Contains number
    if (password.contains(RegExp(r'[0-9]'))) strength += 0.25;

    // Contains special character
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength += 0.25;

    passwordStrength.value = (strength / 1.25).clamp(0.0, 1.0);
  }

  String _getPasswordStrengthText() {
    if (passwordStrength.value < 0.25) return 'Weak';
    if (passwordStrength.value < 0.5) return 'Fair';
    if (passwordStrength.value < 0.75) return 'Good';
    return 'Strong';
  }

  Color _getPasswordStrengthColor() {
    if (passwordStrength.value < 0.25) return Colors.red;
    if (passwordStrength.value < 0.5) return Colors.orange;
    if (passwordStrength.value < 0.75) return Colors.amber;
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xFF0F0F0F),
        body: SingleChildScrollView(
          padding:
              EdgeInsets.all(MediaQuery.of(context).size.width > 600 ? 48 : 24),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                const SizedBox(height: 32),
                Text(
                  'Create your account',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Enter your details to join the enterprise news network.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFFB0B0B0),
                      ),
                ),
                const SizedBox(height: 32),
                // Form
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 480),
                    child: Form(
                      key: formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Full Name
                          _buildFormField(
                            controller: fullNameController,
                            label: 'Full Name',
                            hint: 'John Doe',
                            icon: Icons.person_outlined,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your full name';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          // Work Email
                          _buildFormField(
                            controller: emailController,
                            label: 'Work Email',
                            hint: 'name@chamdtech.com',
                            icon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your work email';
                              }
                              if (!GetUtils.isEmail(value)) {
                                return 'Please enter a valid email';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          // Organization Name
                          _buildFormField(
                            controller: organizationController,
                            label: 'Organization Name',
                            hint: 'e.g. chamdtech network',
                            icon: Icons.business_outlined,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your organization name';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          // Role Selection
                          Obx(() => _buildRoleDropdown()),
                          const SizedBox(height: 16),
                          // Password
                          Obx(() => _buildPasswordField(
                                controller: passwordController,
                                label: 'Create Password',
                                isHidden: isPasswordHidden.value,
                                onVisibilityToggle: () {
                                  isPasswordHidden.value =
                                      !isPasswordHidden.value;
                                },
                              )),
                          const SizedBox(height: 8),
                          // Password Strength Indicator
                          Obx(() => _buildPasswordStrengthIndicator()),
                          const SizedBox(height: 16),
                          // Confirm Password
                          Obx(() => _buildPasswordField(
                                controller: confirmPasswordController,
                                label: 'Confirm Password',
                                isHidden: isConfirmPasswordHidden.value,
                                onVisibilityToggle: () {
                                  isConfirmPasswordHidden.value =
                                      !isConfirmPasswordHidden.value;
                                },
                              )),
                          const SizedBox(height: 24),
                          // Terms Checkbox
                          _buildTermsCheckbox(),
                          const SizedBox(height: 24),
                          // Create Account Button
                          Obx(() => ElevatedButton(
                                onPressed: authController.isLoading.value
                                    ? null
                                    : () => _handleSignUp(),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF1976D2),
                                  foregroundColor: Colors.white,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  disabledBackgroundColor: Colors.grey[600],
                                ),
                                child: authController.isLoading.value
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  Colors.white),
                                        ),
                                      )
                                    : const Text(
                                        'Create Account',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                              )),
                          const SizedBox(height: 16),
                          // OR Divider
                          Row(
                            children: [
                              Expanded(
                                child: Divider(color: Colors.grey[700]),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                child: Text(
                                  'OR',
                                  style: TextStyle(color: Colors.grey[500]),
                                ),
                              ),
                              Expanded(
                                child: Divider(color: Colors.grey[700]),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Sign in with Google
                          OutlinedButton(
                            onPressed: () {
                              authController.signInWithGoogle();
                            },
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: Colors.grey[700]!),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.account_circle_rounded,
                                    color: Colors.white, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  'Sign up with Google',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          // Login Link
                          Center(
                            child: RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'Already have an account? ',
                                    style: TextStyle(color: Colors.grey[400]),
                                  ),
                                  TextSpan(
                                    text: 'Log in here',
                                    style: const TextStyle(
                                      color: Color(0xFF1976D2),
                                      fontWeight: FontWeight.w600,
                                      decoration: TextDecoration.underline,
                                    ),
                                    recognizer: gestures.TapGestureRecognizer()
                                      ..onTap = () => Get.offNamed('/login'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                ),
              ]),
        ));
  }

  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: TextInputAction.next,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF757575)),
        prefixIcon: Icon(icon, color: const Color(0xFF1976D2)),
        labelStyle: const TextStyle(color: Color(0xFFB0B0B0)),
        filled: true,
        fillColor: const Color(0xFF1E1E1E),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[700]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[700]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF1976D2), width: 2),
        ),
      ),
      validator: validator,
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool isHidden,
    required VoidCallback onVisibilityToggle,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isHidden,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFFB0B0B0)),
        prefixIcon: const Icon(Icons.lock_outlined, color: Color(0xFF1976D2)),
        suffixIcon: IconButton(
          icon: Icon(
            isHidden
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            color: const Color(0xFF1976D2),
          ),
          onPressed: onVisibilityToggle,
        ),
        filled: true,
        fillColor: const Color(0xFF1E1E1E),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[700]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[700]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF1976D2), width: 2),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a password';
        }
        if (value.length < 8) {
          return 'Password must be at least 8 characters';
        }
        if (label == 'Confirm Password' && value != passwordController.text) {
          return 'Passwords do not match';
        }
        return null;
      },
    );
  }

  Widget _buildPasswordStrengthIndicator() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Password strength:',
              style: TextStyle(color: Colors.grey[400], fontSize: 12),
            ),
            Text(
              _getPasswordStrengthText(),
              style: TextStyle(
                color: _getPasswordStrengthColor(),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: passwordStrength.value,
            minHeight: 4,
            backgroundColor: Colors.grey[700],
            valueColor:
                AlwaysStoppedAnimation<Color>(_getPasswordStrengthColor()),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Minimum 8 characters with at least one number',
          style: TextStyle(color: Colors.grey[500], fontSize: 11),
        ),
      ],
    );
  }

  Widget _buildRoleDropdown() {
    return DropdownButtonFormField<String>(
      initialValue: authController.selectedRole.value,
      style: const TextStyle(color: Colors.white),
      dropdownColor: const Color(0xFF1E1E1E),
      decoration: InputDecoration(
        labelText: 'Select Your Role',
        labelStyle: const TextStyle(color: Color(0xFFB0B0B0)),
        prefixIcon: const Icon(Icons.work_outlined, color: Color(0xFF1976D2)),
        filled: true,
        fillColor: const Color(0xFF1E1E1E),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[700]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[700]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF1976D2), width: 2),
        ),
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
          authController.selectedRole.value = value;
        }
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select a role';
        }
        return null;
      },
    );
  }

  Widget _buildTermsCheckbox() {
    return Row(
      children: [
        Checkbox(
          value: agreeToTerms,
          onChanged: (value) {
            setState(() {
              agreeToTerms = value ?? false;
            });
          },
          fillColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const Color(0xFF1976D2);
            }
            return Colors.transparent;
          }),
          side: BorderSide(color: Colors.grey[700]!),
        ),
        Expanded(
          child: RichText(
            text: TextSpan(
              children: [
                const TextSpan(
                  text: 'I agree to the ',
                  style: TextStyle(color: Color(0xFFB0B0B0), fontSize: 13),
                ),
                TextSpan(
                  text: 'Terms of Service',
                  style: const TextStyle(
                    color: Color(0xFF1976D2),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
                  ),
                  recognizer: gestures.TapGestureRecognizer()
                    ..onTap = () {
                      Get.toNamed(AppRoutes.termsOfService);
                    },
                ),
                const TextSpan(
                  text: ' and ',
                  style: TextStyle(color: Color(0xFFB0B0B0), fontSize: 13),
                ),
                TextSpan(
                  text: 'Privacy Policy',
                  style: const TextStyle(
                    color: Color(0xFF1976D2),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
                  ),
                  recognizer: gestures.TapGestureRecognizer()
                    ..onTap = () {
                      Get.toNamed(AppRoutes.privacyPolicy);
                    },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _handleSignUp() async {
    if (!formKey.currentState!.validate()) {
      Get.snackbar(
        'Validation Error',
        'Please fill in all required fields correctly',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.1),
        colorText: Colors.red,
      );
      return;
    }

    if (!agreeToTerms) {
      Get.snackbar(
        'Terms & Conditions',
        'Please agree to the Terms of Service and Privacy Policy',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.withValues(alpha: 0.1),
        colorText: Colors.orange,
      );
      return;
    }

    await authController.signUp(
      email: emailController.text.trim(),
      password: passwordController.text,
      displayName: fullNameController.text.trim(),
      role: authController.selectedRole.value,
    );
  }
}
