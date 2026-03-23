// features/dashboard/views/anchor_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:chamdtech_nrcs/features/stories/views/widgets/nrcs_layout.dart';
import 'package:chamdtech_nrcs/app/routes/app_routes.dart';

import 'package:chamdtech_nrcs/features/stories/models/story_model.dart';
import 'package:chamdtech_nrcs/features/dashboard/controllers/anchor_dashboard_controller.dart';

class AnchorDashboardScreen extends GetView<AnchorDashboardController> {
  const AnchorDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AnchorDashboardController());

    return Obx(() => NRCSAppShell(
      title: 'Anchor Dashboard',
      toolbar: CategoryToolbar(
        selectedCategory: controller.selectedCategory.value,
        onCategorySelected: (cat) => controller.selectCategory(cat),
      ),
      body: Container(
        color: const Color(0xFFF8F9FA), // Modern soft background
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        controller.selectedCategory.value,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1A237E),
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
                  _buildHeaderStats(controller),
                ],
              ),
              const SizedBox(height: 32),
              Expanded(
                child: controller.isLoading.value
                    ? const Center(child: CircularProgressIndicator())
                    : controller.stories.isEmpty
                        ? _buildEmptyState()
                        : ListView.separated(
                            itemCount: controller.stories.length,
                            separatorBuilder: (context, index) => const SizedBox(height: 16),
                            itemBuilder: (context, index) {
                              final story = controller.stories[index];
                              return _ModernStoryCard(story: story);
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    ));
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
          value: '${controller.stories.where((s) => s.updatedAt.day == DateTime.now().day).length}',
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
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.auto_stories_outlined, size: 64, color: Colors.grey.shade400),
          ),
          const SizedBox(height: 24),
          const Text(
            'No stories found',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF455A64)),
          ),
          const SizedBox(height: 8),
          Text(
            'There are no stories created under this category yet.',
            style: TextStyle(color: Colors.grey.shade500, fontSize: 15),
          ),
        ],
      ),
    );
  }
}

class _ModernStoryCard extends StatelessWidget {
  final StoryModel story;

  const _ModernStoryCard({required this.story});

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
          onTap: () => Get.toNamed(AppRoutes.storyEditor, arguments: story.id),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                // Leading Indicator
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8EAF6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.description_outlined, color: Color(0xFF3F51B5)),
                ),
                const SizedBox(width: 20),
                // Main Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              story.title.isEmpty ? 'Untitled Story' : story.title,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF263238),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          _buildStatusBadge(story.status),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _InfoChip(icon: Icons.person_outline, label: story.authorName),
                          const SizedBox(width: 16),
                          _InfoChip(
                            icon: Icons.access_time, 
                            label: DateFormat('HH:mm').format(story.updatedAt)
                          ),
                          const SizedBox(width: 16),
                          _InfoChip(
                            icon: Icons.calendar_today_outlined, 
                            label: DateFormat('MMM dd').format(story.updatedAt)
                          ),
                          const Spacer(),
                          Text(
                            'v${story.version}',
                            style: TextStyle(
                              fontSize: 12, 
                              fontWeight: FontWeight.bold, 
                              color: Colors.grey.shade400
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Icon(Icons.chevron_right, color: Colors.grey.shade300),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'approved': color = Colors.green.shade600; break;
      case 'pending': color = Colors.orange.shade700; break;
      case 'rejected': color = Colors.red.shade600; break;
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

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? color;

  const _StatItem({required this.label, required this.value, required this.icon, this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color ?? Colors.grey.shade400),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label.toUpperCase(), style: TextStyle(fontSize: 10, color: Colors.grey.shade500, fontWeight: FontWeight.bold, letterSpacing: 1)),
            Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF1A237E))),
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
