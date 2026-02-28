import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:chamDTech_nrcs/features/stories/views/widgets/nrcs_layout.dart';
import 'package:chamDTech_nrcs/core/constants/app_constants.dart';
import 'package:chamDTech_nrcs/app/routes/app_routes.dart';

class ReporterAppShell extends StatefulWidget {
  const ReporterAppShell({super.key});

  @override
  State<ReporterAppShell> createState() => _ReporterAppShellState();
}

class _ReporterAppShellState extends State<ReporterAppShell> {
  int _selectedIndex = 0;

  final List<String> _tabs = [
    'Dashboard',
    'My Stories',
    'Create Story',
    'Notifications',
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
                  'REPORTER WORKSPACE',
                  style: TextStyle(
                    color: NRCSColors.textDark,
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
              children: [
                // Hardcoded Reporter Sidebar
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
                          if (tab == 'Create Story') {
                            Get.toNamed(AppRoutes.storyEditor);
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
      case 0: // Dashboard
        return _buildReporterHome();
      case 1: // My Stories
        return const Center(child: Text('My Stories List View'));
      case 3: // Notifications
        return const Center(child: Text('Notifications'));
      default:
        return _buildReporterHome();
    }
  }

  Widget _buildReporterHome() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'My Workspace',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: NRCSColors.topNavBlue,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              ElevatedButton.icon(
                onPressed: () => Get.toNamed(AppRoutes.storyEditor),
                icon: const Icon(Icons.add),
                label: const Text('Create New Story'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: NRCSColors.topNavBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: _buildSection(
                  title: 'My Stories (Draft / Pending)',
                  icon: Icons.article,
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                flex: 1,
                child: _buildSection(
                  title: 'Recent Activity',
                  icon: Icons.history,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection({required String title, required IconData icon}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: NRCSColors.borderGray),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: NRCSColors.topNavBlue),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: NRCSColors.topNavBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 48),
              child: Text(
                'No items',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
