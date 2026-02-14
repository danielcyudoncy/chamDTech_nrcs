import 'package:flutter/material.dart';
import 'package:chamDTech_nrcs/app/config/theme_config.dart';
import 'package:chamDTech_nrcs/shared/widgets/app_card.dart';

class AuthLayout extends StatelessWidget {
  final Widget child;
  final String? title;
  final String? subtitle;

  const AuthLayout({
    super.key,
    required this.child,
    this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 600;

    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  ThemeConfig.primaryColor,
                  ThemeConfig.secondaryColor,
                ],
              ),
            ),
          ),
          
          // Pattern Overlay (Optional - could use an image)
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: SizedBox(
                  width: isDesktop ? 450 : double.infinity,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo or App Icon
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.bolt,
                          color: ThemeConfig.primaryColor,
                          size: 48,
                        ),
                      ),
                      const SizedBox(height: 32),
                      
                      // App Name
                      const Text(
                        'chamDTech NRCS',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 48),
                      
                      // Auth Card
                      AppCard(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (title != null) ...[
                              Text(
                                title!,
                                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                  fontSize: 24,
                                ),
                              ),
                              const SizedBox(height: 8),
                            ],
                            if (subtitle != null) ...[
                              Text(
                                subtitle!,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              const SizedBox(height: 32),
                            ],
                            child,
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 32),
                      // Footer info
                        Text(
                        '© ${DateTime.now().year} chamDTech. All rights reserved.',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
