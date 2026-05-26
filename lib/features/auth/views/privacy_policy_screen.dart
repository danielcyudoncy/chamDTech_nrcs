// features/auth/views/privacy_policy_screen.dart
import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Center(
              child: Text(
                "Privacy Policy",
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDark ? colorScheme.onSurface : colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Dates
            Center(
              child: Column(
                children: [
                  Text(
                    "Effective Date: 12/08/2025",
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: (isDark
                          ? colorScheme.onSurface
                          : colorScheme.primary),
                    ),
                  ),
                  Text(
                    "Last Updated: 29/05/2026",
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: (isDark
                          ? colorScheme.onSurface
                          : colorScheme.primary),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Introduction
            _buildSection(
              theme,
              "",
              "Thank you for using our Task Management App (\"we\", \"our\", or \"us\"). Your privacy is important to us. This Privacy Policy explains how we collect, use, disclose, and safeguard your information when you use our mobile application (the \"App\"). Please read this policy carefully. If you do not agree with the terms of this Privacy Policy, please do not use the App.",
            ),

            // Section 1
            _buildSection(
              theme,
              "1. Information We Collect",
              "We may collect the following types of information:",
            ),

            _buildSubSection(
              theme,
              "a. Personal Information",
              [
                "Name",
                "Email address",
                "User role (e.g., admin, user, librarian)",
                "Profile photo (if uploaded)"
              ],
            ),

            _buildSubSection(
              theme,
              "b. Task-related Data",
              [
                "Tasks you create or are assigned",
                "Task metadata such as due dates, tags, and completion status",
                "Comments or notes on tasks"
              ],
            ),

            _buildSubSection(
              theme,
              "c. Usage Information",
              [
                "App usage statistics",
                "Device information (e.g., model, operating system)",
                "Log files (e.g., errors, crashes)"
              ],
            ),

            _buildSubSection(
              theme,
              "d. Optional Permissions",
              [
                "Access to device storage (for file attachments)",
                "Notifications (to alert users about task updates)"
              ],
            ),

            // Section 2
            _buildSection(
              theme,
              "2. How We Use Your Information",
              "We use the collected information for the following purposes:",
            ),

            _buildBulletList(
              theme,
              [
                "To create and manage your account",
                "To assign and track tasks",
                "To send notifications related to tasks",
                "To improve the functionality and performance of the app",
                "To provide customer support",
                "To ensure compliance with app policies and terms"
              ],
            ),

            // Section 3
            _buildSection(
              theme,
              "3. Sharing Your Information",
              "We do not sell or rent your personal data. We may share your information in the following cases:",
            ),

            _buildBulletList(
              theme,
              [
                "With other users in your team or organization (e.g., task assignments)",
                "With service providers who help us operate the app (e.g., Firebase, analytics)",
                "If required by law or in response to valid legal requests"
              ],
            ),

            // Section 4
            _buildSection(
              theme,
              "4. Data Retention",
              "We retain your personal and task data for as long as necessary to provide our services, fulfill legal obligations, resolve disputes, and enforce our agreements.",
            ),

            // Section 5
            _buildSection(
              theme,
              "5. Security",
              "We implement reasonable administrative, technical, and physical safeguards to protect your information. However, no method of transmission over the internet or electronic storage is 100% secure.",
            ),

            // Section 6
            _buildSection(
              theme,
              "6. Your Choices and Rights",
              "Depending on your location, you may have the right to:",
            ),

            _buildBulletList(
              theme,
              [
                "Access the personal information we hold about you",
                "Request correction or deletion of your data",
                "Object to processing or request data portability"
              ],
            ),

            _buildParagraph(
              theme,
              "You can manage your account settings or contact us directly at danielcyudoncy@gmail.com for assistance.",
            ),

            // Section 7
            _buildSection(
              theme,
              "7. Children's Privacy",
              "Our App is not intended for children under the age of 13 (or under the age of 16 in some jurisdictions), and we do not knowingly collect data from them.",
            ),

            // Section 8
            _buildSection(
              theme,
              "8. Third-Party Services",
              "Our App may link to or use third-party services (e.g., Firebase). Their privacy practices are governed by their own policies. We encourage you to review them.",
            ),

            // Section 9
            _buildSection(
              theme,
              "9. Changes to This Privacy Policy",
              "We may update this policy from time to time. We will notify you of any significant changes by updating the \"Effective Date\" and, where appropriate, via in-app notification.",
            ),

            // Section 10
            _buildSection(
              theme,
              "10. Contact Us",
              "If you have any questions or concerns about this Privacy Policy, please contact us at:",
            ),

            const SizedBox(height: 10),

            // Contact Info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.email_outlined,
                        color: colorScheme.onSecondaryContainer,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Email: danielcyudoncy@gmail.com",
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSecondaryContainer,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.person_outline,
                        color: colorScheme.onSecondaryContainer,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Developer: Daniel Udoncy",
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSecondaryContainer,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(ThemeData theme, String title, String content) {
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title.isNotEmpty)
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: isDark ? colorScheme.onSurface : colorScheme.primary,
              ),
            ),
          if (title.isNotEmpty) const SizedBox(height: 8),
          Text(
            content,
            textAlign: TextAlign.justify,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isDark
                  ? colorScheme.onSurface.withValues(alpha: 0.8)
                  : colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubSection(ThemeData theme, String title, List<String> points) {
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title.isNotEmpty)
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: isDark ? colorScheme.onSurface : colorScheme.primary,
              ),
            ),
          if (title.isNotEmpty) const SizedBox(height: 8),
          ...points.map(
            (point) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("• "),
                  Expanded(
                    child: Text(
                      point,
                      textAlign: TextAlign.justify,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isDark
                            ? colorScheme.onSurface.withValues(alpha: 0.8)
                            : colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBulletList(ThemeData theme, List<String> items) {
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: items
            .map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("• "),
                    Expanded(
                      child: Text(
                        item,
                        textAlign: TextAlign.justify,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: isDark
                              ? colorScheme.onSurface.withValues(alpha: 0.8)
                              : colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildParagraph(ThemeData theme, String content) {
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Text(
        content,
        textAlign: TextAlign.justify,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: isDark
              ? colorScheme.onSurface.withValues(alpha: 0.8)
              : colorScheme.onSurface,
        ),
      ),
    );
  }
}
