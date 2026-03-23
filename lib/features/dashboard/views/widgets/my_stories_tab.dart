// features/dashboard/views/widgets/my_stories_tab.dart
import 'dart:convert';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:chamdtech_nrcs/features/dashboard/controllers/reporter_dashboard_controller.dart';
import 'package:chamdtech_nrcs/features/stories/models/story_model.dart';
import 'package:chamdtech_nrcs/features/stories/views/widgets/nrcs_layout.dart';
import 'package:chamdtech_nrcs/core/constants/app_constants.dart';

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
  final RxString _searchQuery = ''.obs;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.controller;

    return Row(
      children: [
        // ── Left Side: Story List (Master) ──────────────────────────────────
        Container(
          width: 400,
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(right: BorderSide(color: NRCSColors.borderGray, width: 0.5)),
          ),
          child: Column(
            children: [
              // List Header & Search
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: NRCSColors.borderGray, width: 0.5)),
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
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: NRCSColors.topNavBlue,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_circle, color: NRCSColors.topNavBlue),
                          onPressed: () => c.createNewStory(),
                          tooltip: 'New Story',
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _searchController,
                      onChanged: (v) => _searchQuery.value = v,
                      decoration: InputDecoration(
                        hintText: 'Search stories...',
                        prefixIcon: const Icon(Icons.search, size: 20),
                        isDense: true,
                        filled: true,
                        fillColor: NRCSColors.subNavGray,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Story List
              Expanded(
                child: Obx(() {
                  if (c.isLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final filteredStories = c.allMyStories.where((s) {
                    final query = _searchQuery.value.toLowerCase();
                    return s.title.toLowerCase().contains(query) ||
                           s.content.toLowerCase().contains(query);
                  }).toList();


                  if (filteredStories.isEmpty) {
                    return const Center(
                      child: Text('No stories found', style: TextStyle(color: Colors.grey)),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: filteredStories.length,
                    separatorBuilder: (context, index) => const Divider(height: 1, indent: 16, endIndent: 16),
                    itemBuilder: (context, index) {
                      final story = filteredStories[index];
                      return Obx(() {
                        final isSelected = c.selectedStory.value?.id == story.id;
                        return _CompactStoryTile(
                          story: story,
                          isSelected: isSelected,
                          onTap: () => c.selectStory(story),
                        );
                      });
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
                    Icon(Icons.description_outlined, size: 64, color: Colors.grey.shade300),
                    const SizedBox(height: 16),
                    Text(
                      'Select a story to view its content',
                      style: TextStyle(color: Colors.grey.shade500, fontSize: 16),
                    ),
                  ],
                ),
              );
            }
            return _StoryDetailView(story: story, controller: c);
          }),
        ),
      ],
    );
  }
}


// ─────────────────────────────────────────────────────────────────────────────
// Compact Story Tile for Sidebar
// ─────────────────────────────────────────────────────────────────────────────
class _CompactStoryTile extends StatelessWidget {
  final StoryModel story;
  final bool isSelected;
  final VoidCallback onTap;

  const _CompactStoryTile({
    required this.story,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final timeFormat = DateFormat('HH:mm');
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? NRCSColors.primaryBlue.withValues(alpha: 0.05) : Colors.transparent,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    story.title.isEmpty ? 'Untitled' : story.title,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                      fontSize: 14,
                      color: isSelected ? NRCSColors.primaryBlue : NRCSColors.textDark,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  timeFormat.format(story.updatedAt),
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                _StatusIndicator(status: story.status),
                const SizedBox(width: 8),
                Text(
                  story.format,
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                ),
                const Spacer(),
                Icon(
                  Icons.chevron_right,
                  size: 16,
                  color: isSelected ? NRCSColors.primaryBlue : Colors.grey.shade300,
                ),
              ],
            ),
          ],
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
    final dateFormat = DateFormat('EEEE, MMMM dd, yyyy · HH:mm');
    final durationStr = '${(story.duration ~/ 60).toString().padLeft(2, '0')}:${(story.duration % 60).toString().padLeft(2, '0')}';
    
    final plainText = _getPlainText(story.content);
    final wordCount = _calculateWordCount(plainText);

    return Column(

      children: [
        // Action Bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(color: NRCSColors.borderGray, width: 0.5)),
          ),
          child: Row(
            children: [
              _ActionButton(
                label: 'Edit Content',
                icon: Icons.edit_document,
                color: NRCSColors.primaryBlue,
                onTap: () => controller.editStory(story),
              ),
              const SizedBox(width: 12),
              _ActionButton(
                label: 'Story Log',
                icon: Icons.history,
                color: Colors.grey.shade700,
                onTap: () => controller.performAction('Story Log'),
              ),
              const Spacer(),
              if (story.status == AppConstants.statusDraft || story.status == AppConstants.statusRejected)
                ElevatedButton(
                  onPressed: () {
                    if (story.status == AppConstants.statusRejected) {
                      controller.resubmitStory(story);
                    } else {
                      controller.submitStory(story);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    foregroundColor: Colors.white,
                    elevation: 0,
                  ),
                  child: Text(story.status == AppConstants.statusRejected ? 'Resubmit' : 'Submit for Review'),
                ),
            ],
          ),
        ),
        // Content Area
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title Area
                Text(
                  story.title.isEmpty ? 'Untitled Story' : story.title,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A237E),
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 16),
                // Metadata Bar
                Wrap(
                  spacing: 24,
                  runSpacing: 8,
                  children: [
                    _DetailMeta(label: 'AUTHOR', value: story.authorName),
                    _DetailMeta(label: 'FORMAT', value: story.format),
                    _DetailMeta(label: 'DURATION', value: durationStr),
                    _DetailMeta(label: 'DESK', value: story.deskId ?? 'None'),
                    _DetailMeta(label: 'VERSION', value: 'v${story.version}'),
                    _DetailMeta(label: 'WORDS', value: '$wordCount'),
                  ],

                ),
                const SizedBox(height: 8),
                Text(
                  'Last updated $dateFormat',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                ),
                const SizedBox(height: 32),
                const Divider(),
                const SizedBox(height: 32),
                // Story Body (The Content)
                Text(
                  plainText.trim().isEmpty ? 'The content of this story is empty.' : plainText,
                  style: const TextStyle(
                    fontSize: 18,
                    height: 1.6,
                    color: NRCSColors.textDark,
                    letterSpacing: 0.2,
                  ),
                ),


                const SizedBox(height: 60), // Extra space at bottom
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _getPlainText(String jsonContent) {
    if (jsonContent.isEmpty) return '';
    try {
      final dynamic decoded = jsonDecode(jsonContent);
      if (decoded is List) {
        return decoded.map((op) => op['insert']?.toString() ?? '').join();
      } else if (decoded is Map && decoded.containsKey('ops')) {
        final ops = decoded['ops'] as List;
        return ops.map((op) => op['insert']?.toString() ?? '').join();
      }
      return jsonContent;
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
  const _DetailMeta({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey.shade500, letterSpacing: 1.2),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: NRCSColors.textDark),
        ),
      ],
    );
  }
}

class _StatusIndicator extends StatelessWidget {
  final String status;
  const _StatusIndicator({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status) {
      case AppConstants.statusDraft:    color = Colors.grey.shade600; break;
      case AppConstants.statusPending:  color = Colors.orange.shade700; break;
      case AppConstants.statusApproved: color = Colors.green.shade700; break;
      case AppConstants.statusRejected: color = Colors.red.shade700; break;
      default:                          color = Colors.grey.shade400;
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          status.toUpperCase(),
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({required this.label, required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: NRCSColors.textDark)),
          ],
        ),
      ),
    );
  }
}

