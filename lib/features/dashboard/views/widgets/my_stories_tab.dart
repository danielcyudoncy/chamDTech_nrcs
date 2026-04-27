// features/dashboard/views/widgets/my_stories_tab.dart
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:chamdtech_nrcs/features/dashboard/controllers/reporter_dashboard_controller.dart';
import 'package:chamdtech_nrcs/features/stories/models/story_model.dart';
import 'package:chamdtech_nrcs/features/stories/views/widgets/nrcs_layout.dart';
import 'package:chamdtech_nrcs/core/constants/app_constants.dart';
import 'package:chamdtech_nrcs/features/stories/services/story_service.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Main Widget
// ─────────────────────────────────────────────────────────────────────────────
class MyStoriesTab extends StatefulWidget {
  final ReporterDashboardController controller;

  const MyStoriesTab({super.key, required this.controller});

  @override
  State<MyStoriesTab> createState() => _MyStoriesTabState();
}

class _MyStoriesTabState extends State<MyStoriesTab> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.controller;

    return Container(
      color: const Color(0xFFF8F9FA), // Premium light background
      child: Row(
        children: [
          // ── Left Side: Story List (Master) ──────────────────────────────────
          Container(
            width: 420,
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(right: BorderSide(color: Color(0xFFE0E0E0), width: 1)),
            ),
            child: Column(
              children: [
                // List Header & Search
                _buildHeader(c),
                // Story List
                Expanded(
                  child: Obx(() {
                    if (c.isLoading.value) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final stories = c.filteredAndSortedMyStories;

                    if (stories.isEmpty) {
                      return _buildEmptyState();
                    }

                    // Group stories by date
                    final groupedStories = _groupStoriesByDate(stories);

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: groupedStories.keys.length,
                      itemBuilder: (context, sectionIndex) {
                        final dateKey = groupedStories.keys.elementAt(sectionIndex);
                        final sectionStories = groupedStories[dateKey]!;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 16, bottom: 8, left: 4),
                              child: Text(
                                dateKey,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.grey,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ),
                            ...sectionStories.map((story) {
                              return Obx(() {
                                final isSelected = c.selectedStory.value?.id == story.id;
                                return _PremiumStoryCard(
                                  story: story,
                                  isSelected: isSelected,
                                  onTap: () => c.selectStory(story),
                                );
                              });
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
          // ── Right Side: Story Detail (Detail) ────────────────────────────────
          Expanded(
            child: Obx(() {
              final story = c.selectedStory.value;
              if (story == null) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: NRCSColors.primaryBlue.withValues(alpha: 0.05),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.article_outlined, size: 64, color: NRCSColors.primaryBlue.withValues(alpha: 0.5)),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Select a story',
                        style: TextStyle(color: Color(0xFF1A237E), fontSize: 22, fontWeight: FontWeight.bold),
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
              return _StoryDetailView(story: story, controller: c);
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(ReporterDashboardController c) {
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
              const Text(
                'My Stories',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1A237E),
                  letterSpacing: -0.5,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => c.createNewStory(),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('New'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A237E),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  onChanged: (v) => c.myStoriesSearchQuery.value = v,
                  style: const TextStyle(color: Colors.black, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Search stories...',
                    hintStyle: TextStyle(color: Colors.grey.shade500),
                    prefixIcon: Icon(Icons.search, size: 20, color: Colors.grey.shade400),
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

  Widget _buildSortDropdown(ReporterDashboardController c) {
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
            value: c.myStoriesSortBy.value,
            icon: Icon(Icons.sort, size: 18, color: Colors.grey.shade600),
            style: const TextStyle(color: Colors.black87, fontSize: 13, fontWeight: FontWeight.w600),
            dropdownColor: Colors.white,
            onChanged: (String? newValue) {
              if (newValue != null) c.myStoriesSortBy.value = newValue;
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

  Widget _buildFilterChips(ReporterDashboardController c) {
    const filters = ['all', 'draft', 'pending', 'approved', 'rejected'];
    const filterLabels = {
      'all': 'All Stories',
      'draft': 'Draft',
      'pending': 'Pending',
      'approved': 'Approved',
      'rejected': 'Rejected',
    };
    final filterIcons = {
      'all': Icons.layers_outlined,
      'draft': Icons.edit_note_outlined,
      'pending': Icons.hourglass_top_outlined,
      'approved': Icons.check_circle_outline,
      'rejected': Icons.cancel_outlined,
    };
    final filterColors = {
      'all': const Color(0xFF1A237E),
      'draft': Colors.blue.shade700,
      'pending': Colors.orange.shade700,
      'approved': Colors.green.shade700,
      'rejected': Colors.red.shade700,
    };

    return Obx(() {
      final selected = c.myStoriesFilterStatus.value;
      final selectedColor = filterColors[selected] ?? const Color(0xFF1A237E);

      return Row(
        children: [
          Icon(filterIcons[selected] ?? Icons.layers_outlined,
              size: 16, color: selectedColor),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              height: 38,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: selectedColor.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: selectedColor.withValues(alpha: 0.25)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selected,
                  isExpanded: true,
                  icon: Icon(Icons.keyboard_arrow_down_rounded,
                      size: 18, color: selectedColor),
                  style: TextStyle(
                    color: selectedColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                  dropdownColor: Colors.white,
                  onChanged: (String? newValue) {
                    if (newValue != null) c.myStoriesFilterStatus.value = newValue;
                  },
                  items: filters.map((filter) {
                    final color = filterColors[filter] ?? const Color(0xFF1A237E);
                    return DropdownMenuItem<String>(
                      value: filter,
                      child: Row(
                        children: [
                          Icon(filterIcons[filter], size: 15, color: color),
                          const SizedBox(width: 8),
                          Text(
                            filterLabels[filter] ?? filter.toUpperCase(),
                            style: TextStyle(
                              color: color,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text(
            'No stories found',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black54),
          ),
          const SizedBox(height: 8),
          const Text(
            'Try adjusting your search or filters',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Map<String, List<StoryModel>> _groupStoriesByDate(List<StoryModel> stories) {
    final grouped = <String, List<StoryModel>>{};
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    for (var story in stories) {
      final date = DateTime(story.updatedAt.year, story.updatedAt.month, story.updatedAt.day);
      String key;
      if (date == today) {
        key = 'TODAY';
      } else if (date == yesterday) {
        key = 'YESTERDAY';
      } else if (date.isAfter(today.subtract(const Duration(days: 7)))) {
        key = 'PREVIOUS 7 DAYS';
      } else if (date.year == now.year && date.month == now.month) {
        key = 'THIS MONTH';
      } else {
        key = DateFormat('MMMM yyyy').format(story.updatedAt).toUpperCase();
      }

      grouped.putIfAbsent(key, () => []).add(story);
    }
    return grouped;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Premium Story Tile for Sidebar
// ─────────────────────────────────────────────────────────────────────────────
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
    final timeFormat = DateFormat('hh:mm a');
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFE8EAF6) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? const Color(0xFF1A237E).withValues(alpha: 0.3) : Colors.grey.shade200,
          width: isSelected ? 1.5 : 1,
        ),
        boxShadow: isSelected
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                )
              ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      story.title.isEmpty ? 'Untitled Story' : story.title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: isSelected ? const Color(0xFF1A237E) : const Color(0xFF263238),
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    timeFormat.format(story.updatedAt),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? const Color(0xFF1A237E).withValues(alpha: 0.6) : Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _PremiumStatusBadge(status: story.status),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      story.format,
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey.shade700),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (story.category.isNotEmpty)
                    Expanded(
                      child: Text(
                        story.category,
                        style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                        overflow: TextOverflow.ellipsis,
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

// ─────────────────────────────────────────────────────────────────────────────
// Detailed Story View
// ─────────────────────────────────────────────────────────────────────────────
class _StoryDetailView extends StatelessWidget {
  final StoryModel story;
  final ReporterDashboardController controller;

  const _StoryDetailView({required this.story, required this.controller});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('EEEE, MMMM dd, yyyy · hh:mm a');
    final durationStr =
        '${(story.duration ~/ 60).toString().padLeft(2, '0')}:${(story.duration % 60).toString().padLeft(2, '0')}';

    final plainText = _getPlainText(story.content);
    final wordCount = _calculateWordCount(plainText);

    return Container(
      color: Colors.white,
      child: Column(
        children: [
          // Action Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                )
              ],
            ),
            child: Row(
              children: [
                _PremiumActionButton(
                  label: 'Edit Story',
                  icon: Icons.edit_document,
                  color: Colors.white,
                  backgroundColor: const Color(0xFF1A237E),
                  onTap: () => controller.editStory(story),
                ),
                const SizedBox(width: 12),
                _PremiumActionButton(
                  label: 'Story Log',
                  icon: Icons.history,
                  color: Colors.black87,
                  backgroundColor: Colors.grey.shade100,
                  onTap: () => controller.performAction('Story Log'),
                ),
                const Spacer(),
                if (story.status == AppConstants.statusDraft ||
                    story.status == AppConstants.statusRejected)
                  ElevatedButton.icon(
                    onPressed: () {
                      if (story.status == AppConstants.statusRejected) {
                        controller.resubmitStory(story);
                      } else {
                        controller.submitStory(story);
                      }
                    },
                    icon: const Icon(Icons.send, size: 16),
                    label: Text(story.status == AppConstants.statusRejected
                        ? 'Resubmit'
                        : 'Submit for Review'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade600,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
              ],
            ),
          ),
          // Content Area
          Expanded(
            child: SelectionArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(40),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 800),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Metadata Top Bar
                        Row(
                          children: [
                            _PremiumStatusBadge(status: story.status),
                            const SizedBox(width: 12),
                            Text(
                              'Last updated ${dateFormat.format(story.updatedAt)}',
                              style: TextStyle(color: Colors.grey.shade500, fontSize: 13, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        // Title Area
                        SelectableText(
                          story.title.isEmpty ? 'Untitled Story' : story.title,
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF1A237E),
                            height: 1.2,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 32),
                        // Metadata Cards
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8F9FA),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Wrap(
                            spacing: 40,
                            runSpacing: 24,
                            children: [
                              _DetailMeta(label: 'AUTHOR', value: story.authorName, icon: Icons.person_outline),
                              _DetailMeta(label: 'FORMAT', value: story.format, icon: Icons.movie_creation_outlined),
                              _DetailMeta(label: 'DURATION', value: durationStr, icon: Icons.timer_outlined),
                              _DetailMeta(
                                  label: 'WORKSPACE',
                                  value: story.deskId != null && story.deskId!.isNotEmpty
                                      ? story.deskId!
                                      : (story.category.isNotEmpty
                                          ? story.category
                                          : 'None'),
                                  icon: Icons.workspaces_outline),
                              _DetailMeta(label: 'VERSION', value: 'v${story.version}', icon: Icons.history),
                              _DetailMeta(label: 'WORDS', value: '$wordCount', icon: Icons.text_snippet_outlined),
                            ],
                          ),
                        ),
                        const SizedBox(height: 40),
                        // Story Body (The Content)
                        const Text(
                          'STORY CONTENT',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey.shade200),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.02),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              )
                            ],
                          ),
                          child: SelectableText(
                            plainText.trim().isEmpty
                                ? 'The content of this story is empty.'
                                : plainText,
                            style: const TextStyle(
                              fontSize: 18,
                              height: 1.8,
                              color: Color(0xFF263238),
                            ),
                          ),
                        ),
                        const SizedBox(height: 60), // Extra space at bottom
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getPlainText(String jsonContent) {
    if (jsonContent.isEmpty) return '';
    try {
      final isJson = jsonContent.trim().startsWith('{') ||
          jsonContent.trim().startsWith('[');
      if (!isJson) return jsonContent;
      return Get.find<StoryService>().getPlainTextFromQuill(jsonContent);
    } catch (_) {
      // If it's not JSON, it might be already plain text
      return jsonContent;
    }
  }

  int _calculateWordCount(String text) {
    if (text.trim().isEmpty) return 0;
    return text.trim().split(RegExp(r'\s+')).length;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sub-components & Helpers
// ─────────────────────────────────────────────────────────────────────────────

class _DetailMeta extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _DetailMeta({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Icon(icon, size: 16, color: const Color(0xFF1A237E)),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: Colors.grey.shade500,
                  letterSpacing: 1.2),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF263238)),
            ),
          ],
        ),
      ],
    );
  }
}

class _PremiumStatusBadge extends StatelessWidget {
  final String status;
  const _PremiumStatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    Color bgColor;
    switch (status) {
      case AppConstants.statusDraft:
        color = Colors.blue.shade700;
        bgColor = Colors.blue.shade50;
        break;
      case AppConstants.statusPending:
        color = Colors.orange.shade800;
        bgColor = Colors.orange.shade50;
        break;
      case AppConstants.statusApproved:
        color = Colors.green.shade700;
        bgColor = Colors.green.shade50;
        break;
      case AppConstants.statusRejected:
        color = Colors.red.shade700;
        bgColor = Colors.red.shade50;
        break;
      default:
        color = Colors.grey.shade700;
        bgColor = Colors.grey.shade100;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            status.toUpperCase(),
            style: TextStyle(
                fontSize: 10, fontWeight: FontWeight.w900, color: color, letterSpacing: 0.5),
          ),
        ],
      ),
    );
  }
}

class _PremiumActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final Color backgroundColor;
  final VoidCallback onTap;

  const _PremiumActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.backgroundColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: color,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
