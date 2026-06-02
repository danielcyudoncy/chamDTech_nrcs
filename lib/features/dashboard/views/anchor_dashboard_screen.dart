// features/dashboard/views/anchor_dashboard_screen.dart
import 'package:chamdtech_nrcs/features/auth/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'dart:convert';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:chamdtech_nrcs/features/stories/views/widgets/nrcs_layout.dart';
import 'package:chamdtech_nrcs/app/routes/app_routes.dart';

import 'package:chamdtech_nrcs/features/stories/models/story_model.dart';
import 'package:chamdtech_nrcs/features/stories/controllers/story_controller.dart';
import 'package:chamdtech_nrcs/features/dashboard/controllers/anchor_dashboard_controller.dart';
import 'package:chamdtech_nrcs/features/dashboard/views/widgets/story_pool_widget.dart';

class AnchorDashboardScreen extends GetView<AnchorDashboardController> {
  const AnchorDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AnchorDashboardController());

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
                  'ANCHOR DASHBOARD',
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
        body: SelectionArea(
          child: Column(
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
                        bottom: BorderSide(
                            color: NRCSColors.borderGray, width: 0.5)),
                  ),
                  child: const Row(
                    children: [
                      SizedBox(width: 24),
                      Text(
                        'ANCHOR DASHBOARD',
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
              Obx(() => CategoryToolbar(
                    selectedCategory: controller.selectedCategory.value,
                    onCategorySelected: (cat) => controller.selectCategory(cat),
                  )),
              Expanded(
                child: _buildContentArea(controller, isMobile),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildDrawer(AnchorDashboardController controller) {
    final String currentRoute = Get.currentRoute;
    const Color selectedColor = Color(0xFF1A237E);
    const Color unselectedColor = Color(0xFF455A64);
    const TextStyle selectedStyle =
        TextStyle(fontWeight: FontWeight.bold, color: selectedColor);
    const TextStyle unselectedStyle =
        TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF263238));

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
                  Icon(Icons.record_voice_over_outlined,
                      size: 64, color: Colors.white),
                  SizedBox(height: 12),
                  Text(
                    'Anchor Menu',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.dashboard_outlined,
                color: currentRoute == AppRoutes.anchorDashboard
                    ? selectedColor
                    : unselectedColor),
            title: Text('Dashboard',
                style: currentRoute == AppRoutes.anchorDashboard
                    ? selectedStyle
                    : unselectedStyle),
            onTap: () {
              Get.back();
              if (currentRoute != AppRoutes.anchorDashboard) {
                Get.offNamed(AppRoutes.anchorDashboard);
              }
            },
          ),
          ListTile(
            leading: Icon(Icons.view_list_outlined,
                color: currentRoute == AppRoutes.rundownList
                    ? selectedColor
                    : unselectedColor),
            title: Text('Rundowns',
                style: currentRoute == AppRoutes.rundownList
                    ? selectedStyle
                    : unselectedStyle),
            onTap: () {
              Get.back();
              if (currentRoute != AppRoutes.rundownList) {
                Get.toNamed(AppRoutes.rundownList);
              }
            },
          ),
          ListTile(
            leading: Icon(Icons.archive_outlined,
                color: currentRoute == AppRoutes.storyList
                    ? selectedColor
                    : unselectedColor),
            title: Text('Archive',
                style: currentRoute == AppRoutes.storyList
                    ? selectedStyle
                    : unselectedStyle),
            onTap: () {
              Get.back();
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
            },
          ),
          ListTile(
            leading: Icon(Icons.notifications_none,
                color: currentRoute == AppRoutes.notifications
                    ? selectedColor
                    : unselectedColor),
            title: Text('Notifications',
                style: currentRoute == AppRoutes.notifications
                    ? selectedStyle
                    : unselectedStyle),
            onTap: () {
              Get.back();
              Get.toNamed(AppRoutes.notifications);
            },
          ),
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
      AnchorDashboardController controller, bool isMobile) {
    return Container(
      color: const Color(0xFFF8F9FA),
      child: Obx(() => Padding(
            padding: EdgeInsets.all(isMobile ? 16.0 : 32.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            controller.selectedCategory.value,
                            style: TextStyle(
                              fontSize: isMobile ? 24 : 28,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF1A237E),
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Showing ${controller.stories.length} stories in this category',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!isMobile) _buildHeaderStats(controller),
                  ],
                ),
                const SizedBox(height: 32),
                if (isMobile) ...[
                  _buildHeaderStats(controller),
                  const SizedBox(height: 24),
                ],
                Expanded(
                  child: isMobile
                      ? Column(
                          children: [
                            Expanded(
                              child: controller.isLoading.value
                                  ? const Center(
                                      child: CircularProgressIndicator())
                                  : controller.stories.isEmpty
                                      ? _buildEmptyState()
                                      : ListView.separated(
                                          itemCount: controller.stories.length,
                                          separatorBuilder: (context, index) =>
                                              const SizedBox(height: 16),
                                          itemBuilder: (context, index) {
                                            final story =
                                                controller.stories[index];
                                            return _ModernStoryCard(
                                                story: story,
                                                isMobile: isMobile);
                                          },
                                        ),
                            ),
                            const SizedBox(height: 24),
                            const Expanded(child: StoryPoolWidget()),
                          ],
                        )
                      : Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 2,
                              child: controller.isLoading.value
                                  ? const Center(
                                      child: CircularProgressIndicator())
                                  : controller.stories.isEmpty
                                      ? _buildEmptyState()
                                      : ListView.separated(
                                          itemCount: controller.stories.length,
                                          separatorBuilder: (context, index) =>
                                              const SizedBox(height: 16),
                                          itemBuilder: (context, index) {
                                            final story =
                                                controller.stories[index];
                                            return _ModernStoryCard(
                                                story: story,
                                                isMobile: isMobile);
                                          },
                                        ),
                            ),
                            const SizedBox(width: 32),
                            const Expanded(
                              flex: 1,
                              child: StoryPoolWidget(),
                            ),
                          ],
                        ),
                ),
              ],
            ),
          )),
    );
  }

  Widget _buildHeaderStats(AnchorDashboardController controller) {
    return Row(
      children: [
        _StatItem(
          label: 'Total',
          value: '${controller.stories.length}',
          icon: Icons.article_outlined,
        ),
        const SizedBox(width: 24),
        _StatItem(
          label: 'Today',
          value:
              '${controller.stories.where((s) => s.updatedAt.day == DateTime.now().day).length}',
          icon: Icons.today_outlined,
          color: Colors.green.shade700,
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Color(0xFFF1F3F4),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.auto_stories_outlined,
                size: 64, color: Color(0xFF90A4AE)),
          ),
          const SizedBox(height: 24),
          const Text(
            'No stories found',
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A237E)),
          ),
          const SizedBox(height: 8),
          const Text(
            'There are no stories created under this category yet.',
            style: TextStyle(
                color: Color(0xFF546E7A),
                fontSize: 15,
                fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

class _ModernStoryCard extends StatelessWidget {
  final StoryModel story;
  final bool isMobile;

  const _ModernStoryCard({required this.story, this.isMobile = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showIntroDialog(context, story),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: EdgeInsets.all(isMobile ? 16.0 : 20.0),
            child: Row(
              children: [
                // Leading Indicator
                if (!isMobile) ...[
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8EAF6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.description_outlined,
                        color: Color(0xFF3F51B5)),
                  ),
                  const SizedBox(width: 20),
                ],
                // Main Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              story.title.isEmpty
                                  ? 'Untitled Story'
                                  : story.title,
                              style: TextStyle(
                                fontSize: isMobile ? 15 : 17,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF263238),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          _buildStatusBadge(story.status),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 16,
                        runSpacing: 8,
                        children: [
                          _InfoChip(
                              icon: Icons.person_outline,
                              label: story.authorName),
                          _InfoChip(
                              icon: Icons.access_time,
                              label:
                                  DateFormat('HH:mm').format(story.updatedAt)),
                          _InfoChip(
                              icon: Icons.calendar_today_outlined,
                              label:
                                  DateFormat('MMM dd').format(story.updatedAt)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Icon(Icons.chevron_right,
                    color: Colors.grey.shade300, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showIntroDialog(BuildContext context, StoryModel story) {
    String intro = 'No intro available.';
    try {
      if (story.content.isNotEmpty) {
        final contentJson = jsonDecode(story.content);
        if (contentJson['anchor'] != null) {
          final anchorDoc = quill.Document.fromJson(contentJson['anchor']);
          final plainText = anchorDoc.toPlainText().trim();
          if (plainText.isNotEmpty) {
            intro = plainText;
          }
        }
      }
    } catch (e) {
      // Ignore errors, use default message
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: _buildModernIntroDialog(context, intro),
        );
      },
    );
  }

  Widget _buildModernIntroDialog(BuildContext context, String intro) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      width: MediaQuery.of(context).size.width * 0.8,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: const BoxDecoration(
              color: Color(0xFF1A237E),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'STORY INTRO',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.1,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                  tooltip: 'Close',
                ),
              ],
            ),
          ),
          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(40.0),
              child: Text(
                intro,
                style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF263238),
                  height: 1.4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'approved':
        color = Colors.green.shade600;
        break;
      case 'pending':
        color = Colors.orange.shade700;
        break;
      case 'rejected':
        color = Colors.red.shade600;
        break;
      default:
        color = Colors.blueGrey.shade400;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
            color: color,
            fontWeight: FontWeight.w800,
            fontSize: 9,
            letterSpacing: 0.5),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? color;

  const _StatItem(
      {required this.label,
      required this.value,
      required this.icon,
      this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color ?? const Color(0xFF546E7A)),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label.toUpperCase(),
                style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFF455A64),
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1)),
            Text(value,
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF1A237E))),
          ],
        ),
      ],
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
        Icon(icon, size: 14, color: const Color(0xFF455A64)),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF263238),
              fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
