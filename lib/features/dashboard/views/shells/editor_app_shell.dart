// features/dashboard/views/shells/editor_app_shell.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:chamdtech_nrcs/features/dashboard/controllers/editor_dashboard_controller.dart';
import 'package:chamdtech_nrcs/features/stories/views/widgets/nrcs_layout.dart';
import 'package:chamdtech_nrcs/app/routes/app_routes.dart';
import 'package:chamdtech_nrcs/features/stories/models/story_model.dart';
import 'package:chamdtech_nrcs/features/stories/controllers/story_controller.dart';

class EditorAppShell extends StatefulWidget {
  const EditorAppShell({super.key});

  @override
  State<EditorAppShell> createState() => _EditorAppShellState();
}

class _EditorAppShellState extends State<EditorAppShell> {
  int _selectedIndex = 0;

  final List<String> _tabs = [
    'Dashboard',
    'Review Queue',
    'Desks',
    'Archive',
    'Notifications'
  ];

  @override
  Widget build(BuildContext context) {
    // Initialize controller for the shell
    final controller = Get.put(EditorDashboardController());

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
              'EDITOR WORKSPACE',
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
                        'EDITOR WORKSPACE',
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
                              case 'Review Queue': icon = Icons.rate_review_outlined; break;
                              case 'Desks': icon = Icons.desk_outlined; break;
                              case 'Archive': icon = Icons.archive_outlined; break;
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
    if (tab == 'Desks') {
      Get.toNamed(AppRoutes.adminDesks);
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

  Widget _buildDrawer(EditorDashboardController controller) {
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
                  Icon(Icons.edit_note, size: 64, color: Colors.white),
                  SizedBox(height: 12),
                  Text(
                    'Editor Menu',
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
              case 'Review Queue': icon = Icons.rate_review_outlined; break;
              case 'Desks': icon = Icons.desk_outlined; break;
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

  Widget _buildContentArea(EditorDashboardController controller, bool isMobile) {
    switch (_selectedIndex) {
      case 0: // Dashboard
        return _buildEditorHome(controller, isMobile);
      case 1: // Review Queue
        return const Center(child: Text('Review Queue View'));
      case 2: // Desks
        return const Center(child: Text('Editorial Desks'));
      case 4: // Notifications
        return const Center(child: Text('Notifications'));
      default:
        return _buildEditorHome(controller, isMobile);
    }
  }

  Widget _buildEditorHome(EditorDashboardController controller, bool isMobile) {
    return Container(
      color: const Color(0xFFF8F9FA),
      child: SingleChildScrollView(
        padding: EdgeInsets.all(isMobile ? 16.0 : 32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Editorial Queue',
              style: TextStyle(
                fontSize: isMobile ? 24 : 32,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF1A237E),
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Review and approve stories for publication.',
              style: TextStyle(fontSize: isMobile ? 13 : 15, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 32),
            Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 80),
                  child: CircularProgressIndicator(),
                ));
              }

              if (isMobile) {
                return Column(
                  children: [
                    _buildSection(
                      context: context,
                      controller: controller,
                      title: 'Pending Review',
                      icon: Icons.priority_high,
                      stories: controller.pendingStories,
                      isMobile: isMobile,
                    ),
                    const SizedBox(height: 24),
                    _buildSection(
                      context: context,
                      controller: controller,
                      title: 'In Copy Edit',
                      icon: Icons.edit_document,
                      stories: controller.copyEditStories,
                      isMobile: isMobile,
                    ),
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _buildSection(
                      context: context,
                      controller: controller,
                      title: 'Pending Review',
                      icon: Icons.priority_high,
                      stories: controller.pendingStories,
                      isMobile: isMobile,
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: _buildSection(
                      context: context,
                      controller: controller,
                      title: 'In Copy Edit',
                      icon: Icons.edit_document,
                      stories: controller.copyEditStories,
                      isMobile: isMobile,
                    ),
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required BuildContext context,
    required EditorDashboardController controller,
    required String title,
    required IconData icon,
    required List<StoryModel> stories,
    required bool isMobile,
  }) {
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
                child: Icon(icon, color: const Color(0xFF1A237E), size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1A237E),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A237E).withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${stories.length}',
                  style: const TextStyle(
                    color: Color(0xFF1A237E),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              )
            ],
          ),
          const SizedBox(height: 24),
          stories.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Column(
                      children: [
                        Icon(Icons.inbox_outlined, size: 48, color: Colors.grey.shade100),
                        const SizedBox(height: 16),
                        Text(
                          'No stories available',
                          style: TextStyle(color: Colors.grey.shade400, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: stories.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final story = stories[index];
                    final timeFormat = DateFormat('HH:mm');
                    
                    return InkWell(
                      onTap: () => controller.startCopyEdit(story),
                      onSecondaryTapDown: (details) => controller.showStoryMenu(context, story, details.globalPosition),
                      onLongPress: () {
                         // Fallback for mobile context menu
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade100),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    story.title.isEmpty ? 'Untitled' : story.title,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF263238)),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Text(
                                        story.authorName,
                                        style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(width: 4, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, shape: BoxShape.circle)),
                                      const SizedBox(width: 8),
                                      Text(
                                        timeFormat.format(story.updatedAt),
                                        style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right, size: 18, color: Colors.grey),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ],
      ),
    );
  }
}
