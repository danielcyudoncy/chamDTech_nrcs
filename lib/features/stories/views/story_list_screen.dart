// features/stories/views/story_list_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:chamdtech_nrcs/features/stories/controllers/story_controller.dart';
import 'package:chamdtech_nrcs/features/stories/models/story_model.dart';
import 'package:chamdtech_nrcs/features/stories/services/story_service.dart';
import 'package:chamdtech_nrcs/core/utils/date_utils.dart' as core_date_utils;
import 'package:chamdtech_nrcs/features/stories/views/widgets/nrcs_layout.dart';

class StoryListScreen extends StatefulWidget {
  const StoryListScreen({super.key});

  @override
  State<StoryListScreen> createState() => _StoryListScreenState();
}

class _StoryListScreenState extends State<StoryListScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Map<String, List<StoryModel>> _groupStoriesByDate(List<StoryModel> stories) {
    final Map<String, List<StoryModel>> grouped = {
      'TODAY': [],
      'YESTERDAY': [],
      'PREVIOUS 7 DAYS': [],
      'OLDER': [],
    };

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final lastWeek = today.subtract(const Duration(days: 7));

    for (var story in stories) {
      final date = DateTime(
          story.updatedAt.year, story.updatedAt.month, story.updatedAt.day);

      if (date == today) {
        grouped['TODAY']!.add(story);
      } else if (date == yesterday) {
        grouped['YESTERDAY']!.add(story);
      } else if (date.isAfter(lastWeek)) {
        grouped['PREVIOUS 7 DAYS']!.add(story);
      } else {
        grouped['OLDER']!.add(story);
      }
    }

    grouped.removeWhere((key, value) => value.isEmpty);
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final StoryController controller = Get.put(StoryController());

    return NRCSAppShell(
      title: controller.showArchived.value ? 'Archive' : 'Workspace',
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
      sidebar: Container(
        color: Colors.white,
        child: Column(
          children: [
            _buildSidebarHeader(controller),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (controller.stories.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          controller.showArchived.value
                              ? Icons.archive_outlined
                              : Icons.folder_open_outlined,
                          size: 48,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          controller.showArchived.value
                              ? 'Archive is empty'
                              : 'No stories found',
                          style: TextStyle(color: Colors.grey.shade500),
                        ),
                      ],
                    ),
                  );
                }

                final groupedStories = _groupStoriesByDate(controller.stories);

                return ListView.builder(
                  itemCount: groupedStories.length,
                  padding: const EdgeInsets.only(bottom: 24),
                  itemBuilder: (context, index) {
                    final dateKey = groupedStories.keys.elementAt(index);
                    final storiesInGroup = groupedStories[dateKey]!;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
                          child: Text(
                            dateKey,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: Colors.grey.shade600,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                        ...storiesInGroup.map((story) {
                          return Obx(() => _PremiumStoryCard(
                                story: story,
                                isSelected: controller.selectedStoryId.value ==
                                    story.id,
                                onTap: () {
                                  controller.selectedStoryId.value = story.id;
                                },
                              ));
                        }),
                      ],
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
      body: Obx(() {
        final selectedStory = controller.selectedStory;
        if (selectedStory == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A237E).withValues(alpha: 0.05),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.article_outlined,
                      size: 64,
                      color: const Color(0xFF1A237E).withValues(alpha: 0.5)),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Select a story',
                  style: TextStyle(
                      color: Color(0xFF1A237E),
                      fontSize: 22,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Choose a story from the list to view its details',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                ),
              ],
            ),
          );
        }

        return _DetailPanelView(story: selectedStory, controller: controller);
      }),
    );
  }

  Widget _buildSidebarHeader(StoryController c) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE0E0E0), width: 1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Obx(() => Text(
                    c.showArchived.value ? 'Archive' : 'Workspace',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF1A237E),
                      letterSpacing: -0.5,
                    ),
                  )),
              Obx(() => Text(
                    '${c.stories.length} items',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade500,
                    ),
                  )),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  onChanged: (v) => c.setSearchQuery(v),
                  style: const TextStyle(color: Colors.black, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Search stories...',
                    hintStyle: TextStyle(color: Colors.grey.shade500),
                    prefixIcon: Icon(Icons.search,
                        size: 20, color: Colors.grey.shade400),
                    isDense: true,
                    filled: true,
                    fillColor: const Color(0xFFF5F7FA),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _buildSortDropdown(c),
            ],
          ),
          const SizedBox(height: 16),
          _buildFilterChips(c),
        ],
      ),
    );
  }

  Widget _buildSortDropdown(StoryController c) {
    return Obx(() {
      return Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F7FA),
          borderRadius: BorderRadius.circular(10),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: c.sortBy.value,
            icon: Icon(Icons.sort, size: 18, color: Colors.grey.shade600),
            style: const TextStyle(
                color: Colors.black87,
                fontSize: 13,
                fontWeight: FontWeight.w600),
            dropdownColor: Colors.white,
            onChanged: (String? newValue) {
              if (newValue != null) c.setSortBy(newValue);
            },
            items: const [
              DropdownMenuItem(value: 'newest', child: Text('Newest')),
              DropdownMenuItem(value: 'oldest', child: Text('Oldest')),
              DropdownMenuItem(value: 'title_asc', child: Text('A-Z')),
              DropdownMenuItem(value: 'title_desc', child: Text('Z-A')),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildFilterChips(StoryController c) {
    final filters = ['all', 'draft', 'pending', 'approved', 'rejected'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((filter) {
          return Obx(() {
            final isSelected = c.currentFilter.value == filter;
            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: InkWell(
                onTap: () => c.setFilter(filter),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF1A237E)
                        : Colors.white,
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF1A237E)
                          : Colors.grey.shade300,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    filter.toUpperCase(),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                      color: isSelected ? Colors.white : Colors.grey.shade700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            );
          });
        }).toList(),
      ),
    );
  }
}

class _PremiumStoryCard extends StatelessWidget {
  final StoryModel story;
  final bool isSelected;
  final VoidCallback onTap;

  const _PremiumStoryCard({
    required this.story,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(story.status);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFE8EAF6) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? const Color(0xFF3F51B5) : Colors.transparent,
          width: 1.5,
        ),
        boxShadow: isSelected
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  offset: const Offset(0, 2),
                  blurRadius: 4,
                )
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 4,
                  height: 40,
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              story.title.isEmpty ? 'Untitled Story' : story.title,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: isSelected
                                    ? const Color(0xFF1A237E)
                                    : const Color(0xFF263238),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            DateFormat('HH:mm').format(story.updatedAt),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.category, size: 12, color: Colors.grey.shade400),
                          const SizedBox(width: 4),
                          Text(
                            story.category,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            story.status.toUpperCase(),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: statusColor,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Colors.green.shade600;
      case 'pending':
        return Colors.orange.shade700;
      case 'rejected':
        return Colors.red.shade600;
      case 'archived':
        return Colors.grey.shade600;
      default:
        return Colors.blue.shade600;
    }
  }
}

class _DetailPanelView extends StatelessWidget {
  final StoryModel story;
  final StoryController controller;

  const _DetailPanelView({required this.story, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF8F9FA),
      child: Column(
        children: [
          _buildStickyActionBar(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(40.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _DetailHeader(story: story),
                  const SizedBox(height: 32),
                  _DetailMeta(story: story),
                  const SizedBox(height: 32),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(40),
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
                            color: Color(0xFF90A4AE),
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 24),
                        SelectableText(
                          story.content.isEmpty
                              ? 'No content for this story.'
                              : Get.find<StoryService>()
                                  .getPlainTextFromQuill(story.content),
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
          ),
        ],
      ),
    );
  }

  Widget _buildStickyActionBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            offset: const Offset(0, 2),
            blurRadius: 4,
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A237E).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.article, color: Color(0xFF1A237E), size: 20),
              ),
              const SizedBox(width: 16),
              const Text(
                'Story Details',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1A237E),
                ),
              ),
            ],
          ),
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  final content = story.content.isEmpty
                      ? 'No content available.'
                      : Get.find<StoryService>().getPlainTextFromQuill(story.content);
                  Clipboard.setData(ClipboardData(text: content)).then((_) {
                    Get.snackbar(
                      'Copied',
                      'Story content copied to clipboard',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: const Color(0xFF1A237E),
                      colorText: Colors.white,
                    );
                  });
                },
                icon: const Icon(Icons.copy_all, size: 18),
                label: const Text('Copy Text'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF1A237E),
                  elevation: 0,
                  side: const BorderSide(color: Color(0xFFE0E0E0)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(width: 12),
              if (controller.showArchived.value) ...[
                if (controller.isAdmin) ...[
                  ElevatedButton.icon(
                    onPressed: () => controller.deleteStory(story.id),
                    icon: const Icon(Icons.delete_forever, size: 18),
                    label: const Text('Delete'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.red.shade700,
                      elevation: 0,
                      side: BorderSide(color: Colors.red.shade200),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                ElevatedButton.icon(
                  onPressed: () => controller.unarchiveStory(story.id),
                  icon: const Icon(Icons.unarchive, size: 18),
                  label: const Text('Unarchive'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A237E),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ] else ...[
                ElevatedButton.icon(
                  onPressed: () => controller.archiveStory(story.id),
                  icon: const Icon(Icons.archive_outlined, size: 18),
                  label: const Text('Archive'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.red.shade700,
                    elevation: 0,
                    side: BorderSide(color: Colors.red.shade200),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () => Get.toNamed('/story/editor', arguments: story),
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: const Text('Edit Story'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A237E),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _DetailHeader extends StatelessWidget {
  final StoryModel story;
  const _DetailHeader({required this.story});

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
                color: _getCategoryColor(story.category).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                story.category.toUpperCase(),
                style: TextStyle(
                  color: _getCategoryColor(story.category),
                  fontWeight: FontWeight.w800,
                  fontSize: 10,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            if (story.parentStoryId != null) ...[
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.call_split, size: 12, color: Colors.orange.shade800),
                    const SizedBox(width: 4),
                    Text(
                      'RE-EDITED VERSION',
                      style: TextStyle(
                        color: Colors.orange.shade800,
                        fontWeight: FontWeight.w800,
                        fontSize: 10,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ]
          ],
        ),
        const SizedBox(height: 16),
        Text(
          story.title.isEmpty ? 'Untitled Story' : story.title,
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1A237E),
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }
}

class _DetailMeta extends StatelessWidget {
  final StoryModel story;
  const _DetailMeta({required this.story});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            offset: const Offset(0, 4),
            blurRadius: 10,
          )
        ],
      ),
      child: Wrap(
        spacing: 40,
        runSpacing: 24,
        children: [
          _ModernMetaItem(
              label: 'Author',
              value: story.authorName,
              icon: Icons.person_outline),
          _ModernMetaItem(
            label: 'Status',
            value: story.status.toUpperCase(),
            icon: Icons.info_outline,
            valueColor: _getStatusColor(story.status),
          ),
          _ModernMetaItem(
            label: 'Updated',
            value: core_date_utils.DateUtils.formatDateTime(story.updatedAt),
            icon: Icons.history,
          ),
          _ModernMetaItem(
            label: 'Word Count',
            value: '${Get.find<StoryController>().calculateWordCount(story.content)} words',
            icon: Icons.text_fields,
          ),
          _ModernMetaItem(
            label: 'Duration',
            value: core_date_utils.DateUtils.formatDuration(story.duration),
            icon: Icons.timer_outlined,
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Colors.green.shade600;
      case 'pending':
        return Colors.orange.shade700;
      case 'rejected':
        return Colors.red.shade600;
      case 'archived':
        return Colors.grey.shade600;
      default:
        return Colors.blue.shade600;
    }
  }
}

class _ModernMetaItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? valueColor;

  const _ModernMetaItem({
    required this.label,
    required this.value,
    required this.icon,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F7FA),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: const Color(0xFF546E7A)),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label.toUpperCase(),
              style: const TextStyle(
                fontSize: 10,
                color: Color(0xFF90A4AE),
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: valueColor ?? const Color(0xFF263238),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

Color _getCategoryColor(String category) {
  switch (category) {
    case 'Local News':
      return Colors.blue.shade700;
    case 'Politics':
      return Colors.purple.shade700;
    case 'Sports':
      return Colors.green.shade700;
    case 'Foreign':
      return Colors.orange.shade700;
    case 'Business & Finance':
      return Colors.teal.shade700;
    case 'Breaking News':
      return Colors.red.shade700;
    case 'Technology':
      return Colors.indigo.shade700;
    case 'Environment':
      return Colors.green.shade900;
    case 'Health':
      return Colors.pink.shade700;
    case 'Entertainment & Lifestyle':
      return Colors.amber.shade800;
    default:
      return Colors.grey.shade700;
  }
}
