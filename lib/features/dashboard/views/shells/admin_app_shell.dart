// features/dashboard/views/shells/admin_app_shell.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:chamdtech_nrcs/features/stories/views/widgets/nrcs_layout.dart';
import 'package:chamdtech_nrcs/app/routes/app_routes.dart';
import 'package:chamdtech_nrcs/features/admin/controllers/admin_controller.dart';
import 'package:chamdtech_nrcs/features/auth/models/user_model.dart';
import 'package:chamdtech_nrcs/features/stories/models/story_model.dart';
import 'package:chamdtech_nrcs/features/rundowns/models/rundown_model.dart';
import 'package:intl/intl.dart';



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
    final AdminController controller = Get.put(AdminController());

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
          Obx(() => Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Total Users',
                      '${controller.totalUsersCount.value}',
                      isSelected: controller.selectedStat.value == 'users',
                      onTap: () => controller.selectStat('users'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      'Active Today',
                      '${controller.activeTodayCount.value}',
                      color: Colors.green,
                      isSelected: controller.selectedStat.value == 'active',
                      onTap: () => controller.selectStat('active'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      'Stories Today',
                      '${controller.storiesTodayCount.value}',
                      isSelected: controller.selectedStat.value == 'stories',
                      onTap: () => controller.selectStat('stories'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      'Active Rundowns',
                      '${controller.activeRundownsCount.value}',
                      color: NRCSColors.activeOrange,
                      isSelected: controller.selectedStat.value == 'rundowns',
                      onTap: () => controller.selectStat('rundowns'),
                    ),
                  ),
                ],
              )),
          const SizedBox(height: 32),
          Obx(() {
            final selection = controller.selectedStat.value;
            String title = 'Recent Audit Activity';
            if (selection == 'users') title = 'All Users';
            if (selection == 'active') title = 'Active Today';
            if (selection == 'stories') title = 'Stories Today';
            if (selection == 'rundowns') title = 'Active Rundowns';

            return Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            );
          }),
          const SizedBox(height: 16),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: NRCSColors.borderGray),
                borderRadius: BorderRadius.circular(8),
              ),

              child: Obx(() {
                final selection = controller.selectedStat.value;
                if (selection == 'none') {
                  return const Center(
                    child: Text('Click a card above to see details', style: TextStyle(color: Colors.grey)),
                  );
                }

                if (selection == 'users') {
                  return _buildUserList(controller.allUsersList);
                } else if (selection == 'active') {
                  return _buildUserList(controller.activeUsersList);
                } else if (selection == 'stories') {
                  return _buildStoryList(controller.storiesTodayList);
                } else if (selection == 'rundowns') {
                  return _buildRundownList(controller.activeRundownsList);
                }


                return const Center(child: Text('No data available'));
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserList(List<UserModel> users) {
    if (users.isEmpty) return const Center(child: Text('No users found'));
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: users.length,
      separatorBuilder: (context, index) => const Divider(height: 1, indent: 16, endIndent: 16),
      itemBuilder: (context, index) {
        final user = users[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: NRCSColors.topNavBlue.withValues(alpha: 0.1),
            child: Text(user.displayName.isNotEmpty ? user.displayName[0].toUpperCase() : 'U'),
          ),
          title: Text(
            user.displayName,
            style: const TextStyle(fontWeight: FontWeight.bold, color: NRCSColors.textDark),
          ),
          subtitle: Text(user.email, style: TextStyle(color: NRCSColors.textDark.withValues(alpha: 0.7))),

          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: NRCSColors.subNavGray,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              user.role.toUpperCase(),
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStoryList(List<StoryModel> stories) {
    if (stories.isEmpty) return const Center(child: Text('No stories found today'));
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: stories.length,
      separatorBuilder: (context, index) => const Divider(height: 1, indent: 16, endIndent: 16),
      itemBuilder: (context, index) {
        final story = stories[index];
        return ListTile(
          title: Text(
            story.title,
            style: const TextStyle(fontWeight: FontWeight.bold, color: NRCSColors.textDark),
          ),
          subtitle: Text(
            'by ${story.authorName} • ${story.format}',
            style: TextStyle(color: NRCSColors.textDark.withValues(alpha: 0.7)),
          ),

          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _getStatusColor(story.status).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: _getStatusColor(story.status).withValues(alpha: 0.5)),
            ),
            child: Text(
              story.status.toUpperCase(),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: _getStatusColor(story.status),
              ),
            ),
          ),
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved': return Colors.green;
      case 'draft': return Colors.grey;
      case 'rejected': return Colors.red;
      default: return Colors.blue;
    }
  }

  Widget _buildRundownList(List<RundownModel> rundowns) {
    if (rundowns.isEmpty) return const Center(child: Text('No active rundowns found'));
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: rundowns.length,
      separatorBuilder: (context, index) => const Divider(height: 1, indent: 16, endIndent: 16),
      itemBuilder: (context, index) {
        final rundown = rundowns[index];
        final timeStr = DateFormat('HH:mm').format(rundown.scheduledTime);
        return ListTile(
          title: Text(
            rundown.name,
            style: const TextStyle(fontWeight: FontWeight.bold, color: NRCSColors.textDark),
          ),
          subtitle: Text(
            'Scheduled for $timeStr',
            style: TextStyle(color: NRCSColors.textDark.withValues(alpha: 0.7)),
          ),
          trailing: Text(
            '${(rundown.targetDuration / 60).round()} min',
            style: TextStyle(color: NRCSColors.textDark.withValues(alpha: 0.5)),
          ),
        );

      },
    );
  }

  Widget _buildStatCard(String title, String value, {Color? color, bool isSelected = false, VoidCallback? onTap}) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isSelected ? (color ?? NRCSColors.primaryBlue).withValues(alpha: 0.05) : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? (color ?? NRCSColors.primaryBlue) : NRCSColors.borderGray,
              width: isSelected ? 2 : 1,
            ),
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
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w600,
                ),

              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: color ?? NRCSColors.primaryBlue,
                ),
              ),
            ],
          ),

        ),
      ),
    );
  }
}

