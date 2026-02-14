import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:chamDTech_nrcs/shared/widgets/app_button.dart';
import 'package:chamDTech_nrcs/shared/widgets/app_text_field.dart';
import 'package:chamDTech_nrcs/shared/widgets/app_card.dart';
import 'package:chamDTech_nrcs/shared/widgets/loading_overlay.dart';
import 'package:chamDTech_nrcs/shared/widgets/empty_state_view.dart';
import 'package:chamDTech_nrcs/shared/layouts/main_layout.dart';

class UIKitScreen extends StatefulWidget {
  const UIKitScreen({super.key});

  @override
  State<UIKitScreen> createState() => _UIKitScreenState();
}

class _UIKitScreenState extends State<UIKitScreen> {
  bool _isLoading = false;

  void _simulateLoading() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 2));
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: 'UI Kit Demo',
      child: LoadingOverlay(
        isLoading: _isLoading,
        message: 'Processing...',
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Shared Widgets',
                style: Theme.of(context).textTheme.displayMedium,
              ),
              const SizedBox(height: 24),
              
              _buildSection(
                'AppButton',
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    AppButton(
                      text: 'Primary Button',
                      onPressed: () {},
                    ),
                    AppButton(
                      text: 'Secondary Button',
                      style: AppButtonStyle.secondary,
                      onPressed: () {},
                    ),
                    AppButton(
                      text: 'Outline Button',
                      style: AppButtonStyle.outline,
                      onPressed: () {},
                    ),
                    AppButton(
                      text: 'Text Button',
                      style: AppButtonStyle.text,
                      onPressed: () {},
                    ),
                    AppButton(
                      text: 'With Icon',
                      icon: Icons.add,
                      onPressed: () {},
                    ),
                    AppButton(
                      text: 'Loading Demo',
                      onPressed: _simulateLoading,
                    ),
                  ],
                ),
              ),
              
              _buildSection(
                'AppTextField',
                Column(
                  children: [
                    const AppTextField(
                      label: 'Simple Text Field',
                      hintText: 'Enter something...',
                    ),
                    const SizedBox(height: 16),
                    const AppTextField(
                      label: 'Password Field',
                      isPassword: true,
                      hintText: 'Enter password',
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      label: 'With Prefix Icon',
                      prefixIcon: Icons.email_outlined,
                      hintText: 'email@example.com',
                      validator: (v) => v?.contains('@') == false ? 'Invalid email' : null,
                    ),
                  ],
                ),
              ),
              
              _buildSection(
                'AppCard',
                Row(
                  children: [
                    Expanded(
                      child: AppCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Card Title',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            const Text('This is a custom card widget with consistent styling.'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: AppCard(
                        onTap: () {},
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                        child: const Column(
                          children: [
                            Icon(Icons.touch_app, size: 32),
                            SizedBox(height: 8),
                            Text('Clickable Card'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              _buildSection(
                'EmptyStateView',
                SizedBox(
                  height: 300,
                  width: double.infinity,
                  child: AppCard(
                    padding: EdgeInsets.zero,
                    child: EmptyStateView(
                      icon: Icons.search_off_rounded,
                      title: 'No Items Found',
                      message: 'Try adjusting your filters or search terms.',
                      actionLabel: 'Reset Filters',
                      onActionPressed: () {},
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Theme.of(context).primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Divider(),
        const SizedBox(height: 16),
        content,
        const SizedBox(height: 48),
      ],
    );
  }
}
