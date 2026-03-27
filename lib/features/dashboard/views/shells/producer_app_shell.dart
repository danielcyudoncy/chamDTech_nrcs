// features/dashboard/views/shells/producer_app_shell.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:chamdtech_nrcs/features/stories/views/widgets/nrcs_layout.dart';
import 'package:chamdtech_nrcs/app/routes/app_routes.dart';
import 'package:chamdtech_nrcs/features/auth/services/auth_service.dart';
import 'package:chamdtech_nrcs/core/constants/app_constants.dart';
import 'package:chamdtech_nrcs/features/dashboard/controllers/producer_dashboard_controller.dart';
import 'package:chamdtech_nrcs/features/stories/controllers/story_controller.dart';

class ProducerAppShell extends StatefulWidget {
  const ProducerAppShell({super.key});

  @override
  State<ProducerAppShell> createState() => _ProducerAppShellState();
}

class _ProducerAppShellState extends State<ProducerAppShell> {
  int _selectedIndex = 0;

  final List<String> _tabs = [
    'Operational Dashboard',
    'Rundowns',
    'Story Pool',
    'Archive',
    'Reports',
    'Notifications'
  ];

  @override
  Widget build(BuildContext context) {
    // Initialize controllers
    final controller = Get.put(ProducerDashboardController());
    final authService = Get.find<AuthService>();
    final isDirector = authService.currentUser.value?.role == AppConstants.roleDirector;
    final workspaceTitle = isDirector ? 'DIRECTOR WORKSPACE' : 'PRODUCER WORKSPACE';

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
            title: Text(
              workspaceTitle,
              style: const TextStyle(
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
                // Sub-header displaying Summary
                Container(
                  height: 40,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(bottom: BorderSide(color: NRCSColors.borderGray, width: 0.5)),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 24),
                      Text(
                        workspaceTitle,
                        style: const TextStyle(
                          color: NRCSColors.textDark,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          letterSpacing: 1.1,
                        ),
                      ),
                      const Spacer(),
                      Obx(() => Text(
                        'Today\'s Total Air Time: ${controller.formatDuration(controller.totalAirTimeSeconds.value)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: NRCSColors.topNavBlue,
                        ),
                      )),
                      const SizedBox(width: 24),
                    ],
                  ),
                ),
              ],
              if (!isDirector) const NRCSToolbar(),
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
                              case 'Operational Dashboard': icon = Icons.dashboard_outlined; break;
                              case 'Rundowns': icon = Icons.view_list_outlined; break;
                              case 'Story Pool': icon = Icons.pool_outlined; break;
                              case 'Archive': icon = Icons.archive_outlined; break;
                              case 'Reports': icon = Icons.assessment_outlined; break;
                              case 'Notifications': icon = Icons.notifications_none; break;
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
    if (tab == 'Rundowns') {
      Get.toNamed(AppRoutes.rundownList);
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

  Widget _buildDrawer(ProducerDashboardController controller) {
    final authService = Get.find<AuthService>();
    final isDirector = authService.currentUser.value?.role == AppConstants.roleDirector;
    
    return Drawer(
      backgroundColor: Colors.white,
      elevation: 0,
      child: Column(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: Color(0xFF1A237E)),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.video_settings, size: 64, color: Colors.white),
                  const SizedBox(height: 12),
                  Text(
                    isDirector ? 'Director Menu' : 'Producer Menu',
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          ...List.generate(_tabs.length, (index) {
            final tab = _tabs[index];
            IconData icon;
            switch (tab) {
              case 'Operational Dashboard': icon = Icons.dashboard_outlined; break;
              case 'Rundowns': icon = Icons.view_list_outlined; break;
              case 'Story Pool': icon = Icons.pool_outlined; break;
              case 'Reports': icon = Icons.assessment_outlined; break;
              case 'Notifications': icon = Icons.notifications_none; break;
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

  Widget _buildContentArea(ProducerDashboardController controller, bool isMobile) {
    switch (_selectedIndex) {
      case 0: // Dashboard
        return _buildProducerHome(controller, isMobile);
      case 2: // Story Pool
        return _buildStoryPoolViewer(controller, isMobile);
      case 4: // Reports
        return const Center(child: Text('Operational Reports'));
      case 5: // Notifications
        return const Center(child: Text('System Notifications'));
      default:
        return _buildProducerHome(controller, isMobile);
    }
  }

  Widget _buildProducerHome(ProducerDashboardController controller, bool isMobile) {
    final authService = Get.find<AuthService>();
    final isDirector = authService.currentUser.value?.role == AppConstants.roleDirector;

    return Container(
      color: const Color(0xFFF8F9FA),
      child: SingleChildScrollView(
        padding: EdgeInsets.all(isMobile ? 16.0 : 32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Operational Overview',
                        style: TextStyle(
                          fontSize: isMobile ? 24 : 32,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF1A237E),
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Manage rundowns and monitor story air time.',
                        style: TextStyle(fontSize: isMobile ? 13 : 15, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
                if (!isMobile && !isDirector)
                  ElevatedButton.icon(
                    onPressed: () => controller.createNewRundown(context),
                    icon: const Icon(Icons.add, size: 20),
                    label: const Text('CREATE RUNDOWN'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A237E),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 32),
            if (isMobile) ...[
              _buildRundownsSection(controller, isMobile),
              const SizedBox(height: 24),
              _buildMiniStoryPoolSection(controller, isMobile),
            ] else ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: _buildRundownsSection(controller, isMobile),
                  ),
                  const SizedBox(width: 32),
                  Expanded(
                    flex: 1,
                    child: _buildMiniStoryPoolSection(controller, isMobile),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRundownsSection(ProducerDashboardController controller, bool isMobile) {
    return Container(
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
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A237E).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.view_list, color: Color(0xFF1A237E), size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                'Today\'s Rundowns',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1A237E),
                ),
              ),
              const Spacer(),
              Obx(() => Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A237E).withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${controller.activeRundowns.length}',
                  style: const TextStyle(
                    color: Color(0xFF1A237E),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              )),
            ],
          ),
          const SizedBox(height: 24),
          Obx(() {
            if (controller.isLoading.value) {
              return const Center(child: Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: CircularProgressIndicator(),
              ));
            }

            if (controller.activeRundowns.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Column(
                    children: [
                      Icon(Icons.list_alt_outlined, size: 48, color: Colors.grey.shade100),
                      const SizedBox(height: 16),
                      Text(
                        'No active rundowns today',
                        style: TextStyle(color: Colors.grey.shade400, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              );
            }

            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.activeRundowns.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final rundown = controller.activeRundowns[index];
                return InkWell(
                  onTap: () => controller.openRundownBuilder(rundown),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade100),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                rundown.name, 
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF263238))
                              ),
                            ),
                            _buildStatusBadge(rundown.status),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 16,
                          runSpacing: 8,
                          children: [
                            _InfoChip(icon: Icons.schedule, label: DateFormat('hh:mm a').format(rundown.scheduledTime)),
                            _InfoChip(icon: Icons.article_outlined, label: '${rundown.storyIds.length} Stories'),
                            _InfoChip(icon: Icons.timer_outlined, label: controller.formatDuration(rundown.targetDuration)),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }),
        ],
      ),
    );
  }

  Widget _buildMiniStoryPoolSection(ProducerDashboardController controller, bool isMobile) {
    return Container(
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
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A237E).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.pool, color: Color(0xFF1A237E), size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                'Ready Pool',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1A237E),
                ),
              ),
              const Spacer(),
              Obx(() => Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A237E).withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${controller.readyToAirStories.length}',
                  style: const TextStyle(
                    color: Color(0xFF1A237E),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              )),
            ],
          ),
          const SizedBox(height: 24),
          Obx(() {
            if (controller.readyToAirStories.isEmpty && !controller.isLoading.value) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Column(
                    children: [
                      Icon(Icons.waves_outlined, size: 48, color: Colors.grey.shade100),
                      const SizedBox(height: 16),
                      Text(
                        'Pool is empty',
                        style: TextStyle(color: Colors.grey.shade400, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              );
            }

            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.readyToAirStories.length > 5 ? 5 : controller.readyToAirStories.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final story = controller.readyToAirStories[index];
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F9FA),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        story.title.isEmpty ? 'Untitled Story' : story.title,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF263238)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.timer_outlined, size: 12, color: Colors.grey.shade400),
                          const SizedBox(width: 4),
                          Text(
                            '${(story.duration ~/ 60).toString().padLeft(2, '0')}:${(story.duration % 60).toString().padLeft(2, '0')}',
                            style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            );
          }),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () {
                setState(() => _selectedIndex = 2); // Switch to Story Pool tab
              },
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF1A237E),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('View Full Story Pool', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoryPoolViewer(ProducerDashboardController controller, bool isMobile) {
    return Container(
      color: const Color(0xFFF8F9FA),
      child: SingleChildScrollView(
        padding: EdgeInsets.all(isMobile ? 16.0 : 32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Story Pool Explorer',
              style: TextStyle(
                fontSize: isMobile ? 24 : 32,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF1A237E),
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 32),
            _buildMiniStoryPoolSection(controller, isMobile),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'on-air': color = Colors.red.shade600; break;
      case 'locked': color = Colors.orange.shade700; break;
      case 'completed': color = Colors.green.shade600; break;
      default: color = Colors.blueGrey.shade400;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 9, letterSpacing: 0.5),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.grey.shade400),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
