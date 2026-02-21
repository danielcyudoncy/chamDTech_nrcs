import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:chamDTech_nrcs/features/settings/controllers/settings_controller.dart';
import 'package:chamDTech_nrcs/features/auth/services/auth_service.dart';
import 'package:chamDTech_nrcs/app/routes/app_routes.dart';
import 'package:chamDTech_nrcs/features/stories/views/widgets/nrcs_layout.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final SettingsController controller = Get.put(SettingsController());
    final AuthService authService = Get.find<AuthService>();
    final user = authService.currentUser.value;
    final isAdmin = user?.role == 'admin';

    return NRCSAppShell(
      title: 'Settings',
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const _SectionHeader(title: 'Appearance'),
          Card(
            child: Column(
              children: [
                Obx(() => ListTile(
                  title: const Text('Theme'),
                  subtitle: Text(
                    controller.themeMode == ThemeMode.system ? 'System Default' :
                    controller.themeMode == ThemeMode.light ? 'Light Mode' : 'Dark Mode'
                  ),
                  trailing: DropdownButton<ThemeMode>(
                    value: controller.themeMode,
                    underline: Container(),
                    onChanged: (ThemeMode? newValue) {
                      if (newValue != null) controller.setThemeMode(newValue);
                    },
                    items: const [
                      DropdownMenuItem(value: ThemeMode.system, child: Text('System Default')),
                      DropdownMenuItem(value: ThemeMode.light, child: Text('Light Mode')),
                      DropdownMenuItem(value: ThemeMode.dark, child: Text('Dark Mode')),
                    ],
                  ),
                )),
              ],
            ),
          ),
          if (isAdmin) ...[
            const SizedBox(height: 24),
            const _SectionHeader(title: 'Management'),
            Card(
              child: ListTile(
                leading: const Icon(Icons.admin_panel_settings),
                title: const Text('Admin Operations'),
                subtitle: const Text('System settings and master data'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Get.toNamed(AppRoutes.adminDashboard),
              ),
            ),
          ],
          const SizedBox(height: 24),
          const _SectionHeader(title: 'About'),
          Card(
            child: ListTile(
              title: const Text('Version'),
              subtitle: const Text('1.0.0+1'),
              trailing: const Icon(Icons.info_outline),
              onTap: () {
                // Show license or detailed info
                showAboutDialog(
                  context: context,
                  applicationName: 'chamDTech NRCS',
                  applicationVersion: '1.0.0+1',
                  applicationIcon: const Icon(Icons.newspaper, size: 48, color: Colors.blue),
                  children: [
                    const Text('Newsroom Computer System for modern workflows.'),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
