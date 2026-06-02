// features/auth/views/login_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart' as gestures;
import 'package:get/get.dart';
import 'package:chamdtech_nrcs/features/auth/controllers/auth_controller.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Check if controller is already registered to avoid "used after disposed"
    final AuthController authController = Get.isRegistered<AuthController>()
        ? Get.find<AuthController>()
        : Get.put(AuthController());
    final formKey = GlobalKey<FormState>();

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth > 1000;

          if (isDesktop) {
            return Row(
              children: [
                // Left side - Image
                Expanded(
                  child: Container(
                    color: const Color(0xFF0F0F0F),
                    padding: const EdgeInsets.all(48),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Monitor Illustration using CustomPaint
                        SizedBox(
                          height: 300,
                          width: 300,
                          child: CustomPaint(
                            painter: MonitorPainter(),
                          ),
                        ),
                        const SizedBox(height: 48),
                        Text(
                          'CHAMDTECH NRCS',
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .headlineLarge
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 2,
                              ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Centralised News Operations',
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                color: const Color(0xFFB0B0B0),
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Right side - Form
                Expanded(
                  child: Container(
                    color: const Color(0xFF1A1A1A),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 600),
                        child: Padding(
                          padding: const EdgeInsets.all(48),
                          child: SingleChildScrollView(
                            child: _buildLoginForm(
                                context, authController, formKey),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          } else {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const SizedBox(height: 32),
                  SizedBox(
                    height: 200,
                    width: 200,
                    child: CustomPaint(
                      painter: MonitorPainter(),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'chamDTECH NRCS',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.5,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Centralized News Operations',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: const Color(0xFFB0B0B0),
                        ),
                  ),
                  const SizedBox(height: 32),
                  _buildLoginForm(context, authController, formKey),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildLoginForm(BuildContext context, AuthController authController,
      GlobalKey<FormState> formKey) {
    return Form(
      key: formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Title
          Text(
            'System Login',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
          ),
          const SizedBox(height: 8),
          // Subtitle
          Text(
            'Enter your credentials to access the newsroom suite',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFFB0B0B0),
                ),
          ),
          const SizedBox(height: 32),
          // Username Field
          TextFormField(
            controller: authController.emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'USERNAME',
              hintText: 'e.g. j.smith@chamdtech.net',
              hintStyle: const TextStyle(color: Color(0xFF757575)),
              prefixIcon:
                  const Icon(Icons.person_outlined, color: Color(0xFF1976D2)),
              labelStyle: const TextStyle(
                color: Color(0xFFB0B0B0),
                fontSize: 12,
                letterSpacing: 0.5,
              ),
              filled: true,
              fillColor: const Color(0xFF0F0F0F),
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
                borderSide:
                    const BorderSide(color: Color(0xFF1976D2), width: 2),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your username/email';
              }
              if (!GetUtils.isEmail(value)) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          // Password Field
          Obx(() => TextFormField(
                controller: authController.passwordController,
                obscureText: authController.isPasswordHidden.value,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) {
                  if (formKey.currentState!.validate()) {
                    authController.login();
                  }
                },
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'PASSWORD',
                  labelStyle: const TextStyle(
                    color: Color(0xFFB0B0B0),
                    fontSize: 12,
                    letterSpacing: 0.5,
                  ),
                  prefixIcon:
                      const Icon(Icons.lock_outlined, color: Color(0xFF1976D2)),
                  suffixIcon: IconButton(
                    icon: Icon(
                      authController.isPasswordHidden.value
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: const Color(0xFF1976D2),
                    ),
                    onPressed: authController.togglePasswordVisibility,
                  ),
                  filled: true,
                  fillColor: const Color(0xFF0F0F0F),
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
                    borderSide:
                        const BorderSide(color: Color(0xFF1976D2), width: 2),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              )),
          const SizedBox(height: 12),
          // Remember & Forgot Password Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Checkbox(
                    value: false,
                    onChanged: (value) {},
                    fillColor: WidgetStateProperty.resolveWith((states) {
                      if (states.contains(WidgetState.selected)) {
                        return const Color(0xFF1976D2);
                      }
                      return Colors.transparent;
                    }),
                    side: BorderSide(color: Colors.grey[700]!),
                  ),
                  Text(
                    'Remember this station',
                    style: TextStyle(color: Colors.grey[400], fontSize: 13),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () {
                  authController.showForgotPasswordDialog(context);
                },
                child: const Text(
                  'Forgot credentials?',
                  style: TextStyle(
                    color: Color(0xFF1976D2),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Login Button
          Obx(() => ElevatedButton(
                onPressed: authController.isLoading.value
                    ? null
                    : () {
                        if (formKey.currentState!.validate()) {
                          authController.login();
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1976D2),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
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
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Access Workspace',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              )),
          const SizedBox(height: 16),
          // Divider
          Row(
            children: [
              Expanded(
                child: Divider(color: Colors.grey[700]),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
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
          // Google Sign In
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
                  'Sign in with Google',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Create Account Link
          Center(
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'Don\'t have an account? ',
                    style: TextStyle(color: Colors.grey[400], fontSize: 13),
                  ),
                  TextSpan(
                    text: 'Sign up here',
                    style: const TextStyle(
                      color: Color(0xFF1976D2),
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      decoration: TextDecoration.underline,
                    ),
                    recognizer: gestures.TapGestureRecognizer()
                      ..onTap = () => Get.toNamed('/signup'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Custom painter for monitor illustration
class MonitorPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1976D2)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..color = const Color(0xFF1976D2).withValues(alpha: 0.1)
      ..style = PaintingStyle.fill;

    // Monitor screen
    final screenRect = Rect.fromLTWH(
      size.width * 0.15,
      size.height * 0.15,
      size.width * 0.7,
      size.height * 0.55,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(screenRect, const Radius.circular(8)),
      fillPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(screenRect, const Radius.circular(8)),
      paint,
    );

    // Screen content - simplified lines
    final contentPaint = Paint()
      ..color = const Color(0xFF1976D2).withValues(alpha: 0.5)
      ..strokeWidth = 1.5;

    double lineY = screenRect.top + 20;
    for (int i = 0; i < 4; i++) {
      canvas.drawLine(
        Offset(screenRect.left + 15, lineY),
        Offset(screenRect.right - 15, lineY),
        contentPaint,
      );
      lineY += 12;
    }

    // Monitor stand
    final standWidth = size.width * 0.3;
    final standHeight = size.height * 0.15;
    final standRect = Rect.fromLTWH(
      size.width * 0.5 - standWidth / 2,
      screenRect.bottom,
      standWidth,
      standHeight,
    );
    canvas.drawRect(standRect, fillPaint);
    canvas.drawRect(standRect, paint);

    // Monitor base
    final baseWidth = size.width * 0.5;
    final baseHeight = size.height * 0.08;
    final baseRect = Rect.fromLTWH(
      size.width * 0.5 - baseWidth / 2,
      screenRect.bottom + standHeight,
      baseWidth,
      baseHeight,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(baseRect, const Radius.circular(4)),
      fillPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(baseRect, const Radius.circular(4)),
      paint,
    );
  }

  @override
  bool shouldRepaint(MonitorPainter oldDelegate) => false;
}
