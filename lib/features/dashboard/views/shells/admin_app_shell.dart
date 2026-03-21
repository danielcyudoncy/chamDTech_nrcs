// features/dashboard/views/shells/admin_app_shell.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:chamdtech_nrcs/features/stories/views/widgets/nrcs_layout.dart';
import 'package:chamdtech_nrcs/app/routes/app_routes.dart';

class AdminAppShell extends StatefulWidget {
  const AdminAppShell({super.key});

  @override
  State<AdminAppShell> createState() => _AdminAppShellState();
}

class _AdminAppShellState extends State<AdminAppShell> {
  int _selectedIndex = 0;

  final List<String> _tabs = [
    'Dashboard',
    'Users',
    'Privileges',
    'Desks',
    'Story States',
    'Configurations',
    'Audit Logs',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const NRCSTopNav(),
          const NRCSSubNav(),
          // Sub-header
          Container(
            height: 40,
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: NRCSColors.borderGray, width: 0.5)),
            ),
            child: const Row(
              children: [
                SizedBox(width: 24),
                Text(
                  'ADMIN CONTROL CENTER',
                  style: TextStyle(
                    color: NRCSColors.breakingRed,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    letterSpacing: 1.1,
                  ),
                ),
              ],
            ),
          ),
          const NRCSToolbar(),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Hardcoded Admin Sidebar
                Container(
                  width: 361,
                  decoration: const BoxDecoration(
                    border: Border(
                      right: BorderSide(color: NRCSColors.borderGray, width: 8),
                    ),
                  ),
                  child: ListView.builder(
                    itemCount: _tabs.length,
                    itemBuilder: (context, index) {
                      final tab = _tabs[index];
                      return ListTile(
                        title: Text(tab, style: const TextStyle(fontWeight: FontWeight.bold)),
                        selected: _selectedIndex == index,
                        selectedTileColor: NRCSColors.subNavGray,
                        onTap: () {
                          if (tab == 'Users') {
                            Get.toNamed(AppRoutes.userManagement);
                          } else if (tab == 'Privileges') {
                            Get.toNamed(AppRoutes.adminPrivileges);
                          } else if (tab == 'Desks') {
                            Get.toNamed(AppRoutes.adminDesks);
                          } else if (tab == 'Story States') {
                            Get.toNamed(AppRoutes.adminStoryState);
                          } else if (tab == 'Configurations') {
                            Get.toNamed(AppRoutes.adminConfigurations);
                          } else if (tab == 'Audit Logs') {
                            Get.toNamed(AppRoutes.adminAuditTrail);
                          } else {
                            setState(() {
                              _selectedIndex = index;
                            });
                          }
                        },
                      );
                    },
                  ),
                ),
                // Main Content Area
                Expanded(
                  child: _buildContentArea(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentArea() {
    switch (_selectedIndex) {
      case 0:
        return _buildAdminHome();
      default:
        return _buildAdminHome();
    }
  }

  Widget _buildAdminHome() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'System Overview',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: NRCSColors.textDark,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildStatCard('Total Users', '24'),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard('Active Today', '18', color: Colors.green),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard('Stories Today', '45'),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard('Active Rundowns', '3', color: NRCSColors.activeOrange),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Text(
            'Recent Audit Activity',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: NRCSColors.borderGray),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Text('No recent activity', style: TextStyle(color: Colors.grey)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, {Color? color}) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: NRCSColors.borderGray),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            offset: const Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: color ?? NRCSColors.topNavBlue,
            ),
          ),
        ],
      ),
    );
  }
}
