// features/stories/views/story_list_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:chamdtech_nrcs/features/stories/controllers/story_controller.dart';
import 'package:chamdtech_nrcs/features/stories/models/story_model.dart';
import 'package:chamdtech_nrcs/core/utils/date_utils.dart' as core_date_utils;
import 'package:chamdtech_nrcs/features/stories/views/widgets/nrcs_layout.dart';

class StoryListScreen extends StatelessWidget {
  const StoryListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final StoryController controller = Get.put(StoryController());

    return NRCSAppShell(
      title: 'Workspace',
      toolbar: Obx(() => CategoryToolbar(
        selectedCategory: controller.categoryFilter.value,
        onCategorySelected: (cat) {
          if (cat == 'All') {
            controller.setCategoryFilter('all');
          } else {
            controller.setCategoryFilter(cat);
          }
        },
      )),
      sidebar: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return Container(
          color: Colors.white,
          child: Column(
            children: [
              // Search & Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'STORY LIST',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1A237E),
                            letterSpacing: 1,
                          ),
                        ),
                        Text(
                          '${controller.stories.length}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade400,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Story List
              Expanded(
                child: ListView.builder(
                  itemCount: controller.stories.length,
                  itemBuilder: (context, index) {
                    final story = controller.stories[index];
                    return Obx(() => NRCSStoryListItem(
                      title: story.title,
                      author: story.authorName,
                      time: core_date_utils.DateUtils.formatTime(story.updatedAt),
                      date: core_date_utils.DateUtils.formatDate(story.updatedAt),
                      duration: core_date_utils.DateUtils.formatDuration(story.duration),
                      category: story.category,
                      isSelected: controller.selectedStoryId.value == story.id,
                      onTap: () {
                        controller.selectedStoryId.value = story.id;
                      },
                      onDelete: () => controller.archiveStory(story.id),
                    ));
                  },
                ),
              ),
            ],
          ),
        );
      }),
      body: Obx(() {
        final selectedStory = controller.selectedStory;
        if (selectedStory == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.auto_stories_outlined, size: 64, color: Colors.grey.shade200),
                const SizedBox(height: 16),
                const Text(
                  'Select a story to view details',
                  style: TextStyle(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          );
        }

        return Container(
          color: const Color(0xFFF8F9FA),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(40.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _DetailHeader(selectedStory: selectedStory),
                const SizedBox(height: 32),
                _DetailMeta(selectedStory: selectedStory),
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'STORY CONTENT',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: Colors.grey,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        selectedStory.content.isEmpty 
                            ? 'No content for this story.' 
                            : selectedStory.content,
                        style: const TextStyle(
                          fontSize: 17, 
                          height: 1.6,
                          color: Color(0xFF263238),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

class _DetailHeader extends StatelessWidget {
  final StoryModel selectedStory;
  const _DetailHeader({required this.selectedStory});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _getCategoryColor(selectedStory.category).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                selectedStory.category.toUpperCase(),
                style: TextStyle(
                  color: _getCategoryColor(selectedStory.category),
                  fontWeight: FontWeight.w800,
                  fontSize: 10,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => Get.toNamed('/story/editor', arguments: selectedStory),
              tooltip: 'Edit Story',
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          selectedStory.title.isEmpty ? 'Untitled Story' : selectedStory.title,
          style: const TextStyle(
            fontSize: 32, 
            fontWeight: FontWeight.w800,
            color: Color(0xFF1A237E),
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            const Text(
              'MASTER:',
              style: TextStyle(
                fontWeight: FontWeight.w800, 
                color: Color(0xFF1A237E),
                fontSize: 13,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              height: 24,
              width: 24,
              child: Checkbox(
                value: true, 
                onChanged: (_) {},
                activeColor: const Color(0xFF1A237E),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'FIRST VERSION',
              style: TextStyle(
                fontWeight: FontWeight.w600, 
                color: Colors.grey,
                fontSize: 13,
              ),
            ),
            const Spacer(),
           const _HeaderBadge(
              label: 'Words',
              value: '250',
              icon: Icons.text_fields,
            ),
            const SizedBox(width: 16),
            _HeaderBadge(
              label: 'Duration',
              value: core_date_utils.DateUtils.formatDuration(selectedStory.duration),
              icon: Icons.timer_outlined,
            ),
          ],
        ),
      ],
    );
  }
}

class _HeaderBadge extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _HeaderBadge({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: Colors.grey),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label.toUpperCase(), style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.grey.shade400)),
              Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF1A237E))),
            ],
          ),
        ],
      ),
    );
  }
}

class _DetailMeta extends StatelessWidget {
  final StoryModel selectedStory;
  const _DetailMeta({required this.selectedStory});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _ModernMetaItem(label: 'Author', value: selectedStory.authorName, icon: Icons.person_outline),
          _ModernMetaItem(
            label: 'Status', 
            value: selectedStory.status.toUpperCase(), 
            icon: Icons.info_outline,
            valueColor: _getStatusColor(selectedStory.status),
          ),
          _ModernMetaItem(
            label: 'Updated', 
            value: core_date_utils.DateUtils.formatDateTime(selectedStory.updatedAt),
            icon: Icons.history,
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved': return Colors.green.shade600;
      case 'pending': return Colors.orange.shade700;
      case 'rejected': return Colors.red.shade600;
      default: return Colors.blueGrey.shade400;
    }
  }
}

class _ModernMetaItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? valueColor;

  const _ModernMetaItem({required this.label, required this.value, required this.icon, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: Colors.grey.shade400),
            const SizedBox(width: 6),
            Text(
              label.toUpperCase(),
              style: TextStyle(
                fontSize: 10, 
                color: Colors.grey.shade400, 
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: 14, 
            fontWeight: FontWeight.w700,
            color: valueColor ?? const Color(0xFF263238),
          ),
        ),
      ],
    );
  }
}

Color _getCategoryColor(String category) {
  switch (category) {
    case 'Local News':                return Colors.blue.shade700;
    case 'Politics':                  return Colors.purple.shade700;
    case 'Sports':                    return Colors.green.shade700;
    case 'Foreign':                   return Colors.orange.shade700;
    case 'Business & Finance':        return Colors.teal.shade700;
    case 'Breaking News':             return Colors.red.shade700;
    case 'Technology':                return Colors.indigo.shade700;
    case 'Environment':               return Colors.green.shade900;
    case 'Health':                    return Colors.pink.shade700;
    case 'Entertainment & Lifestyle': return Colors.amber.shade800;
    default:                          return Colors.grey.shade700;
  }
}
