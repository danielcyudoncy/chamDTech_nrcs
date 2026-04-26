// features/dashboard/views/shells/reporter_app_shell.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:chamdtech_nrcs/features/stories/views/widgets/nrcs_layout.dart';
import 'package:chamdtech_nrcs/features/dashboard/controllers/reporter_dashboard_controller.dart';
import 'package:chamdtech_nrcs/features/stories/models/story_model.dart';
import 'package:chamdtech_nrcs/features/stories/controllers/story_controller.dart';
import 'package:chamdtech_nrcs/features/dashboard/views/widgets/my_stories_tab.dart';
import 'package:chamdtech_nrcs/features/stories/services/story_service.dart';
import 'package:chamdtech_nrcs/features/notifications/views/widgets/notifications_tab.dart';

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
    'Archive',
    'Notifications',
  ];

  void _handleTabSelection(int index) {
    final tab = _tabs[index];
    if (tab == 'Create Story') {
      Get.find<ReporterDashboardController>().createNewStory();
    } else if (tab == 'Archive') {
      // Don't update _selectedIndex here because we're navigating away
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

  @override
  Widget build(BuildContext context) {
    // Initialize controller
    final controller = Get.put(ReporterDashboardController());

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
              'REPORTER WORKSPACE',
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
              ],
              NRCSToolbar(
                onRefresh: () => controller.loadReporterStories(),
                onNew: () => controller.createNewStory(),
                onEdit: () => controller.editSelectedStory(),
                onDelete: () => controller.deleteSelectedStory(context),
                onCopy: () => controller.copySelectedStory(),
                onMove: () => controller.performAction('Move'),
                onLink: () => controller.performAction('Link'),
                onAssign: () => controller.performAction('Assign'),
                onStoryLog: () => controller.performAction('Story Log'),
                onPrint: () => controller.performAction('Print'),
                onPowerview: () => controller.performAction('Powerview'),
              ),
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
                              case 'My Stories': icon = Icons.article_outlined; break;
                              case 'Create Story': icon = Icons.add_circle_outline; break;
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
                              onTap: () => _handleTabSelection(index),
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

  Widget _buildDrawer(ReporterDashboardController controller) {
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
                  Icon(Icons.account_circle, size: 64, color: Colors.white),
                  SizedBox(height: 12),
                  Text(
                    'Reporter Menu',
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
              case 'My Stories': icon = Icons.article_outlined; break;
              case 'Create Story': icon = Icons.add_circle_outline; break;
              case 'Archive': icon = Icons.archive_outlined; break;
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
                _handleTabSelection(index);
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

  Widget _buildContentArea(ReporterDashboardController controller, bool isMobile) {
    switch (_selectedIndex) {
      case 0: // Dashboard
        return _buildReporterHome(controller, isMobile);
      case 1: // My Stories
        return MyStoriesTab(controller: controller);
      case 4: // Notifications
        return const NotificationsTab();
      default:
        return _buildReporterHome(controller, isMobile);
    }
  }

  Widget _buildReporterHome(ReporterDashboardController controller, bool isMobile) {
    return Container(
      color: const Color(0xFFF8F9FA),
      child: SingleChildScrollView(
        padding: EdgeInsets.all(isMobile ? 16.0 : 32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHomeHeader(controller, isMobile),
            const SizedBox(height: 32),
            if (isMobile) ...[
              _buildQuickStats(controller, isMobile),
              const SizedBox(height: 24),
              _buildCalendarCard(controller),
              const SizedBox(height: 24),
              _buildApprovedStoriesList(context, controller),
              const SizedBox(height: 24),
              _buildActiveStoriesSection(controller),
            ] else ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left Column: Calendar & Approved Stories
                  Expanded(
                    flex: 2,
                    child: Column(
                      children: [
                        _buildCalendarCard(controller),
                        const SizedBox(height: 24),
                        _buildApprovedStoriesList(context, controller),
                      ],
                    ),
                  ),
                  const SizedBox(width: 32),
                  // Right Column: My Active Stories & Stats
                  Expanded(
                    flex: 3,
                    child: Column(
                      children: [
                        _buildQuickStats(controller, isMobile),
                        const SizedBox(height: 24),
                        _buildActiveStoriesSection(controller),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHomeHeader(ReporterDashboardController controller, bool isMobile) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'My Workspace',
                style: TextStyle(
                  fontSize: isMobile ? 24 : 32,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1A237E),
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Manage your news stories and view approved content.',
                style: TextStyle(fontSize: isMobile ? 13 : 15, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
        if (!isMobile)
          ElevatedButton.icon(
            onPressed: () => controller.createNewStory(),
            icon: const Icon(Icons.add, size: 20),
            label: const Text('CREATE NEW STORY'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1A237E),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
          ),
      ],
    );
  }

  Widget _buildCalendarCard(ReporterDashboardController controller) {
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
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.calendar_today, size: 18, color: Color(0xFF1A237E)),
              SizedBox(width: 12),
              Text(
                'Schedule',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF1A237E)),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Obx(() => TableCalendar(
                firstDay: DateTime.utc(2024, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: controller.focusedDay.value,
                selectedDayPredicate: (day) => isSameDay(controller.selectedDate.value, day),
                onDaySelected: controller.onDateSelected,
                calendarFormat: CalendarFormat.month,
                daysOfWeekStyle: const DaysOfWeekStyle(
                  weekdayStyle: TextStyle(color: Color(0xFF1A237E), fontWeight: FontWeight.w800, fontSize: 13),
                  weekendStyle: TextStyle(color: Color(0xFFE91E63), fontWeight: FontWeight.w800, fontSize: 13),
                ),
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  titleTextStyle: TextStyle(
                    fontWeight: FontWeight.w800, 
                    fontSize: 18, 
                    color: Color(0xFF1A237E)
                  ),
                  leftChevronIcon: Icon(Icons.chevron_left, color: Color(0xFF1A237E)),
                  rightChevronIcon: Icon(Icons.chevron_right, color: Color(0xFF1A237E)),
                  headerPadding: EdgeInsets.symmetric(vertical: 12),
                ),
                calendarStyle: const CalendarStyle(
                  defaultTextStyle: TextStyle(color: Color(0xFF263238), fontWeight: FontWeight.w600),
                  weekendTextStyle: TextStyle(color: Color(0xFFE91E63), fontWeight: FontWeight.w600),
                  outsideTextStyle: TextStyle(color: Color(0xFFE0E0E0)),
                  todayDecoration: BoxDecoration(
                    color: Color(0xFF1A237E),
                    shape: BoxShape.circle,
                  ),
                  todayTextStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
                  selectedDecoration: BoxDecoration(
                    color: Color(0xFF3F51B5),
                    shape: BoxShape.circle,
                  ),
                  selectedTextStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  markerDecoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                ),
                eventLoader: (day) {
                  return controller.approvedStories
                      .where((s) => isSameDay(s.updatedAt, day))
                      .toList();
                },
              )),
        ],
      ),
    );
  }

  Widget _buildApprovedStoriesList(BuildContext context, ReporterDashboardController controller) {
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Approved Stories',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF1A237E)),
              ),
              Obx(() => Text(
                    DateFormat('MMM dd').format(controller.selectedDate.value),
                    style: TextStyle(color: Colors.grey.shade500, fontWeight: FontWeight.bold, fontSize: 14),
                  )),
            ],
          ),
          const SizedBox(height: 20),
          Obx(() {
            if (controller.approvedStoriesForDate.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Column(
                    children: [
                      Icon(Icons.event_note, size: 48, color: Colors.grey.shade200),
                      const SizedBox(height: 16),
                      Text('No approved stories for this date.', style: TextStyle(color: Colors.grey.shade400)),
                    ],
                  ),
                ),
              );
            }

            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.approvedStoriesForDate.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final story = controller.approvedStoriesForDate[index];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.verified, size: 20, color: Colors.green.shade700),
                  ),
                  title: Text(
                    story.title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    DateFormat('hh:mm a').format(story.updatedAt),
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                  ),
                  onTap: () => _showStoryViewer(context, story, controller),
                );
              },
            );
          }),
        ],
      ),
    );
  }

  Widget _buildQuickStats(ReporterDashboardController controller, bool isMobile) {
    return Obx(() {
      final stats = [
        _StatCard(
          label: 'In Draft',
          value: '${controller.draftStories.length}',
          icon: Icons.edit_note,
          color: Colors.blue,
        ),
        _StatCard(
          label: 'Pending',
          value: '${controller.submittedStories.length}',
          icon: Icons.hourglass_empty,
          color: Colors.orange,
        ),
        _StatCard(
          label: 'Approved',
          value: '${controller.approvedStories.length}',
          icon: Icons.check_circle,
          color: Colors.green,
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
    });
  }

  Widget _buildActiveStoriesSection(ReporterDashboardController controller) {
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
          const Text(
            'Active Workspace',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF1A237E)),
          ),
          const SizedBox(height: 20),
          Obx(() {
            final activeStories = [
              ...controller.draftStories,
              ...controller.submittedStories,
              ...controller.rejectedStories,
            ];

            if (activeStories.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 80),
                  child: Column(
                    children: [
                      Icon(Icons.auto_stories_outlined, size: 64, color: Colors.grey.shade100),
                      const SizedBox(height: 24),
                      Text('No active stories found.', style: TextStyle(color: Colors.grey.shade400, fontSize: 16)),
                    ],
                  ),
                ),
              );
            }

            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: activeStories.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final story = activeStories[index];
                return _ModernStoryRow(
                  story: story,
                  onTap: () => controller.editStory(story),
                );
              },
            );
          }),
        ],
      ),
    );
  }

  void _showStoryViewer(BuildContext context, StoryModel story, ReporterDashboardController controller) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    
    Get.dialog(
      Dialog(
        insetPadding: EdgeInsets.all(isMobile ? 16 : 40),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white, // Explicitly white background
        elevation: 0,
        child: Container(
          width: isMobile ? double.infinity : 800,
          height: isMobile ? MediaQuery.of(context).size.height * 0.8 : 600,
          padding: EdgeInsets.all(isMobile ? 24 : 40),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: SingleChildScrollView(
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
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'APPROVED STORY',
                            style: TextStyle(
                              color: Colors.green.shade700, 
                              fontWeight: FontWeight.w800, 
                              fontSize: 10, 
                              letterSpacing: 0.5
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          story.title,
                          style: TextStyle(
                            fontSize: isMobile ? 22 : 28, 
                            fontWeight: FontWeight.w800, 
                            color: const Color(0xFF1A237E), // Explicit dark navy
                            letterSpacing: -0.5
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.close, color: Color(0xFF1A237E)),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Wrap(
                spacing: 24,
                runSpacing: 16,
                children: [
                  _InfoBadge(icon: Icons.person_outline, label: 'Author', value: story.authorName),
                  _InfoBadge(icon: Icons.category_outlined, label: 'Category', value: story.category),
                  _InfoBadge(
                    icon: Icons.history, 
                    label: 'Last Updated', 
                    value: DateFormat('MMM dd, hh:mm a').format(story.updatedAt)
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Divider(color: Colors.grey.shade200),
              const SizedBox(height: 32),
              const Text(
                'CONTENT',
                style: TextStyle(
                  fontSize: 11, 
                  fontWeight: FontWeight.w800, 
                  color: Color(0xFF90A4AE), // Blue grey for label
                  letterSpacing: 1
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(isMobile ? 16 : 24),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SelectableText(
                  story.content.isEmpty ? 'No content available.' : _stripQuillJson(story.content),
                  style: const TextStyle(
                    fontSize: 16, 
                    height: 1.6, 
                    color: Color(0xFF263238) // Explicit dark charcoal
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Wrap(
                spacing: 16,
                runSpacing: 12,
                alignment: WrapAlignment.end,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    ),
                    child: const Text(
                      'Close', 
                      style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      final content = story.content.isEmpty ? 'No content available.' : _stripQuillJson(story.content);
                      Clipboard.setData(ClipboardData(text: content)).then((_) {
                        Get.snackbar(
                          'Copied', 
                          'Story content copied to clipboard',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: const Color(0xFF1A237E),
                          colorText: Colors.white,
                          margin: const EdgeInsets.all(16),
                        );
                      });
                    },
                    icon: const Icon(Icons.copy_all, size: 18),
                    label: const Text('Copy Content'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A237E), 
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      ),
      barrierColor: Colors.black.withValues(alpha: 0.5), // Dim the background
    );
  }

  // Helper to extract text from Quill JSON content
  String _stripQuillJson(String jsonStr) {
    try {
      final isJson = jsonStr.trim().startsWith('{') || jsonStr.trim().startsWith('[');
      if (!isJson) return jsonStr;
      return Get.find<StoryService>().getPlainTextFromQuill(jsonStr);
    } catch (e) {
      return jsonStr;
    }
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label.toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey.shade500, letterSpacing: 1)),
              Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF1A237E))),
            ],
          ),
        ],
      ),
    );
  }
}

class _ModernStoryRow extends StatelessWidget {
  final StoryModel story;
  final VoidCallback onTap;

  const _ModernStoryRow({required this.story, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade100),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            _buildStatusIndicator(story.status),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    story.title.isEmpty ? 'Untitled Story' : story.title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF263238)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 16,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.category_outlined, size: 12, color: Colors.grey.shade400),
                          const SizedBox(width: 4),
                          Text(story.category, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.access_time, size: 12, color: Colors.grey.shade400),
                          const SizedBox(width: 4),
                          Text(DateFormat('hh:mm a').format(story.updatedAt), style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, size: 20, color: Colors.grey.shade300),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIndicator(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'draft': color = Colors.blue; break;
      case 'pending': color = Colors.orange; break;
      case 'rejected': color = Colors.red; break;
      default: color = Colors.grey;
    }
    return Container(
      width: 4,
      height: 32,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

class _InfoBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoBadge({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 12, color: Colors.grey),
            const SizedBox(width: 6),
            Text(label.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 0.5)),
          ],
        ),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF263238))),
      ],
    );
  }
}
