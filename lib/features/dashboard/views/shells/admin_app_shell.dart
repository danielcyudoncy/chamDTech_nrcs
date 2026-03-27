// features/dashboard/views/shells/admin_app_shell.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:chamdtech_nrcs/features/stories/views/widgets/nrcs_layout.dart';
import 'package:chamdtech_nrcs/app/routes/app_routes.dart';
import 'package:chamdtech_nrcs/features/admin/controllers/admin_controller.dart';
import 'package:chamdtech_nrcs/features/auth/models/user_model.dart';
import 'package:chamdtech_nrcs/features/stories/models/story_model.dart';
import 'package:chamdtech_nrcs/features/stories/controllers/story_controller.dart';
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
    'Archive',
    'Configurations',
    'Audit Logs',
  ];

  @override
  Widget build(BuildContext context) {
    final AdminController controller = Get.put(AdminController());

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 1100;

        return Scaffold(
          key: GlobalKey<ScaffoldState>(),
          backgroundColor: Colors.white,
          appBar: isMobile ? AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            scrolledUnderElevation: 0,
            title: const Text(
              'ADMIN CONTROL CENTER',
              style: TextStyle(
                color: Color(0xFF1A237E),
                fontWeight: FontWeight.bold,
                fontSize: 16,
                letterSpacing: 1.1,
              ),
            ),
            iconTheme: const IconThemeData(color: Color(0xFF1A237E)),
            shape: const Border(bottom: BorderSide(color: NRCSColors.borderGray, width: 0.5)),
          ) : null,
          drawer: isMobile ? _buildDrawer(controller) : null,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (!isMobile) ...[
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
              ],
              const NRCSToolbar(),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Sidebar (Desktop only)
                    if (!isMobile)
                      Container(
                        width: 300,
                        decoration: const BoxDecoration(
                          border: Border(
                            right: BorderSide(color: NRCSColors.borderGray, width: 8),
                          ),
                        ),
                        child: ListView.builder(
                          itemCount: _tabs.length,
                          itemBuilder: (context, index) {
                            final tab = _tabs[index];
                            IconData icon;
                            switch (tab) {
                              case 'Dashboard': icon = Icons.dashboard_outlined; break;
                              case 'Users': icon = Icons.people_outline; break;
                              case 'Privileges': icon = Icons.security_outlined; break;
                              case 'Desks': icon = Icons.desk_outlined; break;
                              case 'Story States': icon = Icons.low_priority; break;
                              case 'Archive': icon = Icons.archive_outlined; break;
                              case 'Configurations': icon = Icons.settings_outlined; break;
                              case 'Audit Logs': icon = Icons.history; break;
                              default: icon = Icons.folder_outlined;
                            }
                            return ListTile(
                              leading: Icon(icon, color: _selectedIndex == index ? const Color(0xFF1A237E) : Colors.grey.shade600),
                              title: Text(
                                tab, 
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: _selectedIndex == index ? const Color(0xFF1A237E) : Colors.black87
                                )
                              ),
                              selected: _selectedIndex == index,
                              selectedTileColor: NRCSColors.subNavGray.withValues(alpha: 0.5),
                              onTap: () => _handleTabSelection(tab, index),
                            );
                          },
                        ),
                      ),
                    // Main Content Area
                    Expanded(
                      child: _buildContentArea(controller, isMobile),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }
    );
  }

  void _handleTabSelection(String tab, int index) {
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
    } else if (tab == 'Archive') {
      try {
        final controller = Get.find<StoryController>();
        controller.showArchived.value = true;
        controller.loadStories();
      } catch (e) {
        final controller = Get.put(StoryController());
        controller.showArchived.value = true;
        controller.loadStories();
      }
      Get.toNamed('/stories');
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  Widget _buildDrawer(AdminController controller) {
    return Drawer(
      backgroundColor: Colors.white,
      elevation: 0,
      child: Column(
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Color(0xFF1A237E)),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.admin_panel_settings, size: 64, color: Colors.white),
                  SizedBox(height: 12),
                  Text(
                    'Admin Menu',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          ...List.generate(_tabs.length, (index) {
            final tab = _tabs[index];
            IconData icon;
            switch (tab) {
              case 'Dashboard': icon = Icons.dashboard_outlined; break;
              case 'Users': icon = Icons.people_outline; break;
              case 'Privileges': icon = Icons.security_outlined; break;
              case 'Desks': icon = Icons.desk_outlined; break;
              case 'Story States': icon = Icons.low_priority; break;
              case 'Configurations': icon = Icons.settings_outlined; break;
              case 'Audit Logs': icon = Icons.history; break;
              default: icon = Icons.folder_outlined;
            }

            return ListTile(
              leading: Icon(icon, color: _selectedIndex == index ? const Color(0xFF1A237E) : Colors.grey),
              title: Text(
                tab, 
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: _selectedIndex == index ? const Color(0xFF1A237E) : Colors.black87
                )
              ),
              selected: _selectedIndex == index,
              onTap: () {
                Get.back(); // Close drawer
                _handleTabSelection(tab, index);
              },
            );
          }),
          const Spacer(),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            onTap: () {
              // Add logout logic
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildContentArea(AdminController controller, bool isMobile) {
    switch (_selectedIndex) {
      case 0:
        return _buildAdminHome(controller, isMobile);
      default:
        return _buildAdminHome(controller, isMobile);
    }
  }

  Widget _buildAdminHome(AdminController controller, bool isMobile) {
    return Container(
      color: const Color(0xFFF8F9FA),
      child: SingleChildScrollView(
        padding: EdgeInsets.all(isMobile ? 16.0 : 32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'System Overview',
              style: TextStyle(
                fontSize: isMobile ? 24 : 32,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF1A237E),
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Monitor system health and administrative activities.',
              style: TextStyle(fontSize: isMobile ? 13 : 15, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 32),
            Obx(() {
              final stats = [
                _buildStatCard(
                  'Total Users',
                  '${controller.totalUsersCount.value}',
                  icon: Icons.people_outline,
                  isSelected: controller.selectedStat.value == 'users',
                  onTap: () => controller.selectStat('users'),
                ),
                _buildStatCard(
                  'Active Today',
                  '${controller.activeTodayCount.value}',
                  icon: Icons.person_pin_circle_outlined,
                  color: Colors.green,
                  isSelected: controller.selectedStat.value == 'active',
                  onTap: () => controller.selectStat('active'),
                ),
                _buildStatCard(
                  'Stories Today',
                  '${controller.storiesTodayCount.value}',
                  icon: Icons.article_outlined,
                  isSelected: controller.selectedStat.value == 'stories',
                  onTap: () => controller.selectStat('stories'),
                ),
                _buildStatCard(
                  'Active Rundowns',
                  '${controller.activeRundownsCount.value}',
                  icon: Icons.view_list_outlined,
                  color: NRCSColors.activeOrange,
                  isSelected: controller.selectedStat.value == 'rundowns',
                  onTap: () => controller.selectStat('rundowns'),
                ),
              ];

              if (isMobile) {
                return Column(
                  children: stats.map((s) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: s,
                  )).toList(),
                );
              }

              return Row(
                children: stats.map((s) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: s,
                  ),
                )).toList(),
              );
            }),
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
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1A237E),
                ),
              );
            }),
            const SizedBox(height: 16),
            Container(
              height: 500, // Fixed height for the list area in the scroll view
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Obx(() {
                final selection = controller.selectedStat.value;
                if (selection == 'none') {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.touch_app_outlined, size: 48, color: Colors.grey.shade200),
                        const SizedBox(height: 16),
                        Text('Click a card above to see details', style: TextStyle(color: Colors.grey.shade400)),
                      ],
                    ),
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
          ],
        ),
      ),
    );  }

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

  Widget _buildStatCard(String title, String value, {IconData? icon, Color? color, bool isSelected = false, VoidCallback? onTap}) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? (color ?? const Color(0xFF1A237E)) : Colors.transparent,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              if (icon != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: (color ?? const Color(0xFF1A237E)).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color ?? const Color(0xFF1A237E), size: 20),
                ),
                const SizedBox(width: 16),
              ],
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF1A237E),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

