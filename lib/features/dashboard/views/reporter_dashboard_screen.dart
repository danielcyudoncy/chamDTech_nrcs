// features/dashboard/views/reporter_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:chamdtech_nrcs/features/stories/services/story_service.dart';
import 'package:chamdtech_nrcs/features/stories/views/widgets/nrcs_layout.dart';
import 'package:chamdtech_nrcs/features/dashboard/controllers/reporter_dashboard_controller.dart';
import 'package:chamdtech_nrcs/features/stories/models/story_model.dart';

class ReporterDashboardScreen extends GetView<ReporterDashboardController> {
  const ReporterDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ReporterDashboardController());

    return NRCSAppShell(
      title: 'Reporter Dashboard',
      toolbar: const NRCSToolbar(),
      body: SelectionArea(
        child: Container(
          color: const Color(0xFFF8F9FA),
          child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context, controller),
              const SizedBox(height: 32),
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
                        _buildQuickStats(controller),
                        const SizedBox(height: 24),
                        _buildActiveStoriesSection(context, controller),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    )),
    );
  }

  Widget _buildHeader(BuildContext context, ReporterDashboardController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'My Workspace',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1A237E),
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Manage your news stories and view approved content.',
              style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
            ),
          ],
        ),
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
                headerStyle: HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  titleTextStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  leftChevronIcon: Icon(Icons.chevron_left, color: Colors.grey.shade600),
                  rightChevronIcon: Icon(Icons.chevron_right, color: Colors.grey.shade600),
                ),
                calendarStyle: CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: const Color(0xFF1A237E).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  todayTextStyle: const TextStyle(color: Color(0xFF1A237E), fontWeight: FontWeight.bold),
                  selectedDecoration: const BoxDecoration(
                    color: Color(0xFF1A237E),
                    shape: BoxShape.circle,
                  ),
                  markerDecoration: const BoxDecoration(
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
                  onTap: () => _showStoryViewer(context, story),
                );
              },
            );
          }),
        ],
      ),
    );
  }

  Widget _buildQuickStats(ReporterDashboardController controller) {
    return Row(
      children: [
        _StatCard(
          label: 'In Draft',
          value: '${controller.draftStories.length}',
          icon: Icons.edit_note,
          color: Colors.blue,
        ),
        const SizedBox(width: 16),
        _StatCard(
          label: 'Pending',
          value: '${controller.submittedStories.length}',
          icon: Icons.hourglass_empty,
          color: Colors.orange,
        ),
        const SizedBox(width: 16),
        _StatCard(
          label: 'Approved',
          value: '${controller.approvedStories.length}',
          icon: Icons.check_circle,
          color: Colors.green,
        ),
      ],
    );
  }

  Widget _buildActiveStoriesSection(BuildContext context, ReporterDashboardController controller) {
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

  void _showStoryViewer(BuildContext context, StoryModel story) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: SelectionArea(
          child: Container(
            width: 800,
            height: 600,
          padding: const EdgeInsets.all(40),
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
                            style: TextStyle(color: Colors.green.shade700, fontWeight: FontWeight.w800, fontSize: 10, letterSpacing: 0.5),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          story.title,
                          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Color(0xFF1A237E), letterSpacing: -0.5),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  _InfoBadge(icon: Icons.person_outline, label: 'Author', value: story.authorName),
                  const SizedBox(width: 24),
                  _InfoBadge(icon: Icons.category_outlined, label: 'Category', value: story.category),
                  const SizedBox(width: 24),
                  _InfoBadge(icon: Icons.history, label: 'Last Updated', value: DateFormat('MMM dd, hh:mm a').format(story.updatedAt)),
                ],
              ),
              const SizedBox(height: 32),
              const Divider(),
              const SizedBox(height: 32),
              const Text(
                'CONTENT',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.grey, letterSpacing: 1),
              ),
              const SizedBox(height: 16),
              Text(
                story.content.isEmpty ? 'No content available.' : _stripQuillJson(story.content),
                style: const TextStyle(fontSize: 16, height: 1.6, color: Color(0xFF263238)),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text('Close'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () {
                      Get.back();
                      controller.editStory(story);
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1A237E), foregroundColor: Colors.white),
                    child: const Text('Edit Story'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    )),
    );
  }

  // Helper to extract text from Quill JSON content
  String _stripQuillJson(String jsonStr) {
    try {
      // Check if it's JSON before trying to parse
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
    return Expanded(
      child: Container(
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
                  Row(
                    children: [
                      Icon(Icons.category_outlined, size: 12, color: Colors.grey.shade400),
                      const SizedBox(width: 4),
                      Text(story.category, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                      const SizedBox(width: 16),
                      Icon(Icons.access_time, size: 12, color: Colors.grey.shade400),
                      const SizedBox(width: 4),
                      Text(DateFormat('hh:mm a').format(story.updatedAt), style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
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
