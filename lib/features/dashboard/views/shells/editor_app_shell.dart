// features/dashboard/views/shells/editor_app_shell.dart
import 'package:chamdtech_nrcs/features/auth/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:chamdtech_nrcs/features/dashboard/controllers/editor_dashboard_controller.dart';
import 'package:chamdtech_nrcs/features/stories/views/widgets/nrcs_layout.dart';
import 'package:chamdtech_nrcs/features/dashboard/controllers/desk_controller.dart';
import 'package:chamdtech_nrcs/features/dashboard/views/widgets/editorial_desks_view.dart';
import 'package:chamdtech_nrcs/features/stories/models/story_model.dart';
import 'package:chamdtech_nrcs/features/stories/services/story_service.dart';
import 'package:chamdtech_nrcs/core/constants/app_constants.dart';
import 'package:chamdtech_nrcs/features/notifications/views/widgets/notifications_tab.dart';

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
  void initState() {
    super.initState();
    // Check if we were passed a specific tab to open
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = Get.arguments;
      if (args is Map && args['tab'] != null) {
        final String tabName = args['tab'];
        final index = _tabs.indexOf(tabName);
        if (index != -1) {
          _handleTabSelection(tabName, index);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Initialize controller for the shell
    final controller = Get.put(EditorDashboardController());

    return LayoutBuilder(builder: (context, constraints) {
      final isMobile = constraints.maxWidth < 1100;

      return Scaffold(
        key: GlobalKey<ScaffoldState>(),
        backgroundColor: Colors.white,
        appBar: isMobile
            ? AppBar(
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
                shape: const Border(
                    bottom:
                        BorderSide(color: NRCSColors.borderGray, width: 0.5)),
              )
            : null,
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
                  border: Border(
                      bottom:
                          BorderSide(color: NRCSColors.borderGray, width: 0.5)),
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
                          right: BorderSide(
                              color: NRCSColors.borderGray, width: 8),
                        ),
                      ),
                      child: ListView.builder(
                        itemCount: _tabs.length,
                        itemBuilder: (context, index) {
                          final tab = _tabs[index];
                          IconData icon;
                          switch (tab) {
                            case 'Dashboard':
                              icon = Icons.dashboard_outlined;
                              break;
                            case 'Review Queue':
                              icon = Icons.rate_review_outlined;
                              break;
                            case 'Desks':
                              icon = Icons.desk_outlined;
                              break;
                            case 'Archive':
                              icon = Icons.archive_outlined;
                              break;
                            case 'Notifications':
                              icon = Icons.notifications_none;
                              break;
                            default:
                              icon = Icons.folder_outlined;
                          }
                          return ListTile(
                            leading: Icon(icon,
                                color: _selectedIndex == index
                                    ? const Color(0xFF1A237E)
                                    : Colors.grey.shade600),
                            title: Text(tab,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: _selectedIndex == index
                                        ? const Color(0xFF1A237E)
                                        : Colors.black87)),
                            selected: _selectedIndex == index,
                            selectedTileColor:
                                NRCSColors.subNavGray.withValues(alpha: 0.5),
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
    });
  }

  void _handleTabSelection(String tab, int index) {
    if (tab == 'Desks') {
      try {
        final deskController = Get.find<DeskController>();
        deskController.selectedDeskId.value = '';
      } catch (e) {
        // DeskController might not be put yet
      }
      setState(() => _selectedIndex = index);
    } else if (tab == 'Archive') {
      setState(() => _selectedIndex = index);
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
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          ...List.generate(_tabs.length, (index) {
            final tab = _tabs[index];
            IconData icon;
            switch (tab) {
              case 'Dashboard':
                icon = Icons.dashboard_outlined;
                break;
              case 'Review Queue':
                icon = Icons.rate_review_outlined;
                break;
              case 'Desks':
                icon = Icons.desk_outlined;
                break;
              case 'Notifications':
                icon = Icons.notifications_none;
                break;
              default:
                icon = Icons.folder_outlined;
            }

            return ListTile(
              leading: Icon(icon,
                  color: _selectedIndex == index
                      ? const Color(0xFF1A237E)
                      : Colors.grey),
              title: Text(tab,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _selectedIndex == index
                          ? const Color(0xFF1A237E)
                          : Colors.black87)),
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
            title: const Text('Logout',
                style:
                    TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            onTap: () {
              Get.back(); // Close drawer first
              final AuthService authService = Get.find<AuthService>();
              authService.signOut();
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildContentArea(
      EditorDashboardController controller, bool isMobile) {
    switch (_selectedIndex) {
      case 0: // Dashboard
        return _buildEditorHome(controller, isMobile);
      case 1: // Review Queue
        return _buildReviewQueue(controller, isMobile);
      case 2: // Desks
        return _buildEditorialDesks(controller, isMobile);
      case 3: // Archive
        return _buildArchiveView(controller, isMobile);
      case 4: // Notifications
        return const NotificationsTab();
      default:
        return _buildEditorHome(controller, isMobile);
    }
  }

  Widget _buildReviewQueue(
      EditorDashboardController controller, bool isMobile) {
    return Container(
      color: const Color(0xFFF8F9FA),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(isMobile ? 16.0 : 32.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Review Queue',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1A237E),
                  ),
                ),
                Text(
                  'Stories awaiting your approval or edit.',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          Expanded(
            child: Obx(() {
              final pending = controller.pendingStories;
              final inEdit = controller.copyEditStories;
              final other = controller.allStories
                  .where((s) =>
                      s.status != AppConstants.statusArchived &&
                      !pending.any((p) => p.id == s.id) &&
                      !inEdit.any((e) => e.id == s.id))
                  .toList();

              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (pending.isEmpty && inEdit.isEmpty && other.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.rate_review_outlined,
                          size: 64, color: Colors.grey.shade200),
                      const SizedBox(height: 16),
                      Text('No stories found',
                          style: TextStyle(
                              color: Colors.grey.shade400,
                              fontWeight: FontWeight.w500)),
                    ],
                  ),
                );
              }

              return ListView(
                padding:
                    EdgeInsets.symmetric(horizontal: isMobile ? 16.0 : 32.0),
                children: [
                  if (pending.isNotEmpty) ...[
                    _buildSectionHeader('PENDING REVIEW', Colors.orange),
                    ...pending.map((s) => Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: _buildStoryListTile(controller, s),
                        )),
                    const SizedBox(height: 24),
                  ],
                  if (inEdit.isNotEmpty) ...[
                    _buildSectionHeader('IN COPY EDIT', Colors.blue),
                    ...inEdit.map((s) => Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: _buildStoryListTile(controller, s),
                        )),
                    const SizedBox(height: 24),
                  ],
                  if (other.isNotEmpty) ...[
                    _buildSectionHeader('ALL ACTIVE STORIES', Colors.grey),
                    ...other.map((s) => Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: _buildStoryListTile(controller, s),
                        )),
                  ],
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0, top: 8.0),
      child: Row(
        children: [
          Container(width: 4, height: 16, color: color),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color.withValues(alpha: 0.8),
              letterSpacing: 1.1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArchiveView(
      EditorDashboardController controller, bool isMobile) {
    return Container(
      color: const Color(0xFFF8F9FA),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(isMobile ? 16.0 : 32.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Archived Stories',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1A237E),
                  ),
                ),
                Text(
                  'Stories that have been retired or completed.',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          Expanded(
            child: Obx(() {
              final archived = controller.allStories
                  .where((s) => s.status == AppConstants.statusArchived)
                  .toList();

              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (archived.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.archive_outlined,
                          size: 64, color: Colors.grey.shade200),
                      const SizedBox(height: 16),
                      Text('No stories in archive',
                          style: TextStyle(
                              color: Colors.grey.shade400,
                              fontWeight: FontWeight.w500)),
                    ],
                  ),
                );
              }

              return ListView.separated(
                padding:
                    EdgeInsets.symmetric(horizontal: isMobile ? 16.0 : 32.0),
                itemCount: archived.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final story = archived[index];
                  return _buildStoryListTile(controller, story,
                      isArchive: true);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  void _showStoryContent(BuildContext context, StoryModel story) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(story.title.isEmpty ? 'Untitled' : story.title),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Author: ${story.authorName}',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 12)),
              const Divider(height: 32),
              Text(
                Get.find<StoryService>().getPlainTextFromQuill(story.content),
                style: const TextStyle(fontSize: 16, height: 1.5),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CLOSE'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Get.toNamed('/story/editor', arguments: story);
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A237E)),
            child: const Text('OPEN IN EDITOR',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildStoryListTile(
      EditorDashboardController controller, StoryModel story,
      {bool isArchive = false}) {
    final timeFormat = DateFormat('HH:mm');
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ListTile(
        onTap: isArchive
            ? () => _showStoryContent(context, story)
            : () => controller.startCopyEdit(story),
        title: Text(story.title.isEmpty ? 'Untitled' : story.title,
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: NRCSColors.textDark)),
        subtitle: Text(
          '${story.authorName} • ${timeFormat.format(story.updatedAt)}',
          style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _getStatusColor(story.status).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            story.status.toUpperCase(),
            style: TextStyle(
                color: _getStatusColor(story.status),
                fontSize: 10,
                fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Colors.green.shade700;
      case 'pending':
        return Colors.orange.shade800;
      case 'rejected':
        return Colors.red.shade700;
      case 'draft':
        return Colors.blue.shade700;
      case 'archived':
        return Colors.grey.shade700;
      default:
        return Colors.blueGrey.shade600;
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
              style: TextStyle(
                  fontSize: isMobile ? 13 : 15, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 32),
            Obx(() {
              if (controller.isLoading.value) {
                return const Center(
                    child: Padding(
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
                        Icon(Icons.inbox_outlined,
                            size: 48, color: Colors.grey.shade100),
                        const SizedBox(height: 16),
                        Text(
                          'No stories available',
                          style: TextStyle(
                              color: Colors.grey.shade400,
                              fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: stories.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final story = stories[index];
                    final timeFormat = DateFormat('HH:mm');

                    return InkWell(
                      onTap: () => controller.startCopyEdit(story),
                      onSecondaryTapDown: (details) => controller.showStoryMenu(
                          context, story, details.globalPosition),
                      onLongPress: () {
                        // Fallback for mobile context menu
                      },
                      customBorder: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade200),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    story.title.isEmpty
                                        ? 'Untitled'
                                        : story.title,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: Color(0xFF263238)),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Text(
                                        story.authorName,
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey.shade500),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                          width: 4,
                                          height: 4,
                                          decoration: BoxDecoration(
                                              color: Colors.grey.shade300,
                                              shape: BoxShape.circle)),
                                      const SizedBox(width: 8),
                                      Text(
                                        timeFormat.format(story.updatedAt),
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey.shade500),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right,
                                size: 18, color: Colors.grey),
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

  Widget _buildEditorialDesks(
      EditorDashboardController controller, bool isMobile) {
    return EditorialDesksView(isMobile: isMobile);
  }
}
