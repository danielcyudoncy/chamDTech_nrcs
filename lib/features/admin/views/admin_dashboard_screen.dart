import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:chamDTech_nrcs/features/admin/controllers/admin_controller.dart';
import 'package:chamDTech_nrcs/app/routes/app_routes.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(AdminController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Operations'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildCategory(
            context,
            'Identity & Access',
            [
              _AdminTile(label: 'Users', icon: Icons.people, route: AppRoutes.userManagement),
              _AdminTile(label: 'Privileges Master', icon: Icons.security, route: AppRoutes.adminPrivileges),
              _AdminTile(label: 'Designations', icon: Icons.badge, route: AppRoutes.adminDesignations),
            ],
          ),
          _buildCategory(
            context,
            'Production Masters',
            [
              _AdminTile(label: 'Story State', icon: Icons.rule, route: AppRoutes.adminStoryState),
              _AdminTile(label: 'Format', icon: Icons.view_headline, route: AppRoutes.adminFormat),
              _AdminTile(label: 'Sub Format', icon: Icons.view_list, route: AppRoutes.adminSubFormat),
              _AdminTile(label: 'Show Template', icon: Icons.dashboard_customize, route: AppRoutes.adminShowTemplate),
              _AdminTile(label: 'Show Master', icon: Icons.tv, route: AppRoutes.adminShowMaster),
            ],
          ),
          _buildCategory(
            context,
            'Operations',
            [
              _AdminTile(label: 'Desks', icon: Icons.work, route: AppRoutes.adminDesks),
              _AdminTile(label: 'Wire', icon: Icons.rss_feed, route: AppRoutes.adminWire),
              _AdminTile(label: 'Locations', icon: Icons.location_on, route: AppRoutes.adminLocations),
              _AdminTile(label: 'Strings', icon: Icons.text_fields, route: AppRoutes.adminStrings),
            ],
          ),
          _buildCategory(
            context,
            'Technical',
            [
              _AdminTile(label: 'MOS Devices', icon: Icons.settings_input_component, route: AppRoutes.adminMosDevices),
              _AdminTile(label: 'Configurations', icon: Icons.settings, route: AppRoutes.adminConfigurations),
            ],
          ),
          _buildCategory(
            context,
            'Analytics',
            [
              _AdminTile(label: 'Audit Trail', icon: Icons.history, route: AppRoutes.adminAuditTrail),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategory(BuildContext context, String title, List<_AdminTile> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
          child: Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
              letterSpacing: 1.2,
            ),
          ),
        ),
        Card(
          child: Column(
            children: items.map((item) {
              return ListTile(
                leading: Icon(item.icon, color: Theme.of(context).colorScheme.primary),
                title: Text(item.label),
                trailing: const Icon(Icons.chevron_right, size: 20),
                onTap: () => Get.toNamed(item.route),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _AdminTile {
  final String label;
  final IconData icon;
  final String route;

  const _AdminTile({
    required this.label,
    required this.icon,
    required this.route,
  });
}
