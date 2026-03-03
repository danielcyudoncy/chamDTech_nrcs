import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:chamDTech_nrcs/features/dashboard/controllers/reporter_dashboard_controller.dart';
import 'package:chamDTech_nrcs/features/stories/models/story_model.dart';
import 'package:chamDTech_nrcs/features/stories/views/widgets/nrcs_layout.dart';
import 'package:chamDTech_nrcs/core/constants/app_constants.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Workflow groups definition
// ─────────────────────────────────────────────────────────────────────────────
enum _StoryGroup {
  drafts,
  submitted,
  needsRevision,
  approved,
  archived,
}

extension _StoryGroupExt on _StoryGroup {
  String get label {
    switch (this) {
      case _StoryGroup.drafts:        return 'Drafts';
      case _StoryGroup.submitted:     return 'Submitted';
      case _StoryGroup.needsRevision: return 'Needs Revision';
      case _StoryGroup.approved:      return 'Approved';
      case _StoryGroup.archived:      return 'Archived';
    }
  }

  IconData get icon {
    switch (this) {
      case _StoryGroup.drafts:        return Icons.edit_note;
      case _StoryGroup.submitted:     return Icons.send_time_extension;
      case _StoryGroup.needsRevision: return Icons.error_outline;
      case _StoryGroup.approved:      return Icons.verified;
      case _StoryGroup.archived:      return Icons.archive_outlined;
    }
  }

  Color get color {
    switch (this) {
      case _StoryGroup.drafts:        return NRCSColors.topNavBlue;
      case _StoryGroup.submitted:     return Colors.orange.shade700;
      case _StoryGroup.needsRevision: return Colors.red.shade700;
      case _StoryGroup.approved:      return Colors.green.shade700;
      case _StoryGroup.archived:      return Colors.grey.shade600;
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Main Widget
// ─────────────────────────────────────────────────────────────────────────────
class MyStoriesTab extends StatefulWidget {
  final ReporterDashboardController controller;

  const MyStoriesTab({super.key, required this.controller});

  @override
  State<MyStoriesTab> createState() => _MyStoriesTabState();
}

class _MyStoriesTabState extends State<MyStoriesTab>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<_StoryGroup> _groups = _StoryGroup.values;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _groups.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<StoryModel> _storiesForGroup(_StoryGroup group) {
    switch (group) {
      case _StoryGroup.drafts:        return widget.controller.draftStories;
      case _StoryGroup.submitted:     return widget.controller.submittedStories;
      case _StoryGroup.needsRevision: return widget.controller.rejectedStories;
      case _StoryGroup.approved:      return widget.controller.approvedStories;
      case _StoryGroup.archived:      return widget.controller.archivedStories;
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.controller;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Header row ────────────────────────────────────────────────────────
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(
              bottom: BorderSide(color: NRCSColors.borderGray, width: 0.5),
            ),
          ),
          child: Row(
            children: [
              Text(
                'My Stories',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: NRCSColors.topNavBlue,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () => c.createNewStory(),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('New Story'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: NRCSColors.topNavBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 10),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6)),
                ),
              ),
            ],
          ),
        ),

        // ── Tab Bar ───────────────────────────────────────────────────────────
        Obx(() {
          return Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              labelColor: NRCSColors.topNavBlue,
              unselectedLabelColor: Colors.grey.shade600,
              labelStyle: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 13),
              indicatorColor: NRCSColors.topNavBlue,
              indicatorWeight: 3,
              tabs: _groups.map((g) {
                final count = _storiesForGroup(g).length;
                final hasAlert = g == _StoryGroup.needsRevision && count > 0;
                return Tab(
                  child: Row(
                    children: [
                      Icon(g.icon, size: 16, color: g.color),
                      const SizedBox(width: 6),
                      Text(g.label),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: hasAlert
                              ? Colors.red.shade700
                              : g.color.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '$count',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: hasAlert ? Colors.white : g.color,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          );
        }),

        // ── Tab Content ───────────────────────────────────────────────────────
        Expanded(
          child: c.isLoading.value
              ? const Center(child: CircularProgressIndicator())
              : TabBarView(
                  controller: _tabController,
                  children: _groups
                      .map((g) => _StoryGroupList(
                            group: g,
                            controller: c,
                          ))
                      .toList(),
                ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Per-group story list
// ─────────────────────────────────────────────────────────────────────────────
class _StoryGroupList extends StatelessWidget {
  final _StoryGroup group;
  final ReporterDashboardController controller;

  const _StoryGroupList(
      {required this.group, required this.controller});

  List<StoryModel> get stories {
    switch (group) {
      case _StoryGroup.drafts:        return controller.draftStories;
      case _StoryGroup.submitted:     return controller.submittedStories;
      case _StoryGroup.needsRevision: return controller.rejectedStories;
      case _StoryGroup.approved:      return controller.approvedStories;
      case _StoryGroup.archived:      return controller.archivedStories;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final list = stories;
      if (list.isEmpty) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(group.icon, size: 48, color: Colors.grey.shade400),
              const SizedBox(height: 12),
              Text(
                'No ${group.label.toLowerCase()} stories',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
              ),
              if (group == _StoryGroup.drafts) ...[
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => controller.createNewStory(),
                  icon: const Icon(Icons.add),
                  label: const Text('Create Your First Story'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: NRCSColors.topNavBlue,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ],
          ),
        );
      }

      return ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: list.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          return _StoryCard(
            story: list[index],
            group: group,
            controller: controller,
          );
        },
      );
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Individual Story Card
// ─────────────────────────────────────────────────────────────────────────────
class _StoryCard extends StatelessWidget {
  final StoryModel story;
  final _StoryGroup group;
  final ReporterDashboardController controller;

  const _StoryCard(
      {required this.story,
      required this.group,
      required this.controller});

  bool get _isApproved => group == _StoryGroup.approved;
  bool get _canEditBasic =>
      group == _StoryGroup.drafts || group == _StoryGroup.needsRevision;
  bool get _canSubmit =>
      group == _StoryGroup.drafts || group == _StoryGroup.needsRevision;
  bool get _canDelete => group == _StoryGroup.drafts;
  bool get _showRevisionBanner => group == _StoryGroup.needsRevision;

  @override
  Widget build(BuildContext context) {
    final timeFormat = DateFormat('HH:mm');
    final dateFormat = DateFormat('MMM dd, yyyy');
    final durationStr =
        '${(story.duration ~/ 60).toString().padLeft(2, '0')}:${(story.duration % 60).toString().padLeft(2, '0')}';

    return Obx(() {
      // Reactively check rundown lock status for approved stories
      final isRundownLocked =
          _isApproved && controller.isStoryEditLocked(story.id);

      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: _showRevisionBanner
                ? Colors.red.shade200
                : isRundownLocked
                    ? Colors.orange.shade300
                    : NRCSColors.borderGray,
            width: (_showRevisionBanner || isRundownLocked) ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Revision alert banner ────────────────────────────────────────
            if (_showRevisionBanner)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(7)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.feedback_outlined,
                        size: 14, color: Colors.red.shade700),
                    const SizedBox(width: 6),
                    Text(
                      'Returned by editor — revision required',
                      style: TextStyle(
                          fontSize: 12,
                          color: Colors.red.shade700,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),

            // ── Rundown-locked banner ────────────────────────────────────────
            if (isRundownLocked)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(7)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.lock, size: 14, color: Colors.orange.shade800),
                    const SizedBox(width: 6),
                    Text(
                      'Locked in rundown — editing disabled',
                      style: TextStyle(
                          fontSize: 12,
                          color: Colors.orange.shade800,
                          fontWeight: FontWeight.w600),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade100,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.orange.shade300),
                      ),
                      child: Text(
                        'VIEW ONLY',
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange.shade800),
                      ),
                    ),
                  ],
                ),
              ),

            // ── Approved (editable) banner ───────────────────────────────────
            if (_isApproved && !isRundownLocked)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(7)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle_outline,
                        size: 14, color: Colors.green.shade700),
                    const SizedBox(width: 6),
                    Text(
                      story.approvedBy != null
                          ? 'Approved by ${story.approvedBy}'
                          : 'Approved — ready for air',
                      style: TextStyle(
                          fontSize: 12,
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),

            // ── Main card body ───────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          story.title.isEmpty ? 'Untitled Story' : story.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Color(0xFF1A237E),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _StatusBadge(status: story.status),
                    ],
                  ),
                  const SizedBox(height: 8),

                  Wrap(
                    spacing: 16,
                    runSpacing: 4,
                    children: [
                      _MetaChip(
                          icon: Icons.folder_outlined,
                          label: story.deskId ?? 'No Desk'),
                      _MetaChip(
                          icon: Icons.video_label, label: story.format),
                      _MetaChip(
                          icon: Icons.timer_outlined, label: durationStr),
                      _MetaChip(
                          icon: Icons.update,
                          label:
                              '${timeFormat.format(story.updatedAt)} · ${dateFormat.format(story.updatedAt)}'),
                      if (story.version > 1)
                        _MetaChip(
                            icon: Icons.history,
                            label: 'v${story.version}'),
                      if (story.linkedRundownId != null)
                        _MetaChip(
                            icon: Icons.playlist_play,
                            label: 'In rundown'),
                    ],
                  ),

                  // ── Action buttons ─────────────────────────────────────────
                  const SizedBox(height: 12),
                  const Divider(height: 1),
                  const SizedBox(height: 8),

                  if (_canEditBasic || _canSubmit || _canDelete)
                    Row(
                      children: [
                        if (_canEditBasic)
                          _ActionButton(
                            label: 'Edit',
                            icon: Icons.edit_outlined,
                            color: NRCSColors.topNavBlue,
                            onTap: () => controller.editStory(story),
                          ),
                        if (_canEditBasic && _canSubmit)
                          const SizedBox(width: 8),
                        if (_canSubmit)
                          _ActionButton(
                            label: group == _StoryGroup.needsRevision
                                ? 'Resubmit'
                                : 'Submit for Review',
                            icon: Icons.send_outlined,
                            color: Colors.green.shade700,
                            onTap: () {
                              if (group == _StoryGroup.needsRevision) {
                                controller.resubmitStory(story);
                              } else {
                                controller.submitStory(story);
                              }
                            },
                          ),
                        const Spacer(),
                        if (_canDelete)
                          _ActionButton(
                            label: 'Delete',
                            icon: Icons.delete_outline,
                            color: Colors.red.shade600,
                            onTap: () =>
                                controller.deleteStory(context, story),
                            outlined: true,
                          ),
                      ],
                    )
                  else if (_isApproved)
                    // Approved story — edit gated by rundown lock
                    Row(
                      children: [
                        _ActionButton(
                          label: isRundownLocked ? 'Locked — View Only' : 'Edit',
                          icon: isRundownLocked
                              ? Icons.lock_outline
                              : Icons.edit_outlined,
                          color: isRundownLocked
                              ? Colors.orange.shade700
                              : NRCSColors.topNavBlue,
                          onTap: () => controller.tryEditApprovedStory(
                              context, story),
                        ),
                      ],
                    )
                  else
                    // Other view-only groups (submitted, archived)
                    Row(
                      children: [
                        Icon(Icons.lock_outline,
                            size: 14, color: NRCSColors.topNavBlue),
                        const SizedBox(width: 4),
                        Text(
                          group == _StoryGroup.submitted
                              ? 'Locked — awaiting editor review'
                              : 'Read only',
                          style: TextStyle(
                              fontSize: 12, color: NRCSColors.topNavBlue),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────────────────────
class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status) {
      case AppConstants.statusDraft:    color = Colors.grey.shade600; break;
      case AppConstants.statusPending:  color = Colors.orange.shade700; break;
      case AppConstants.statusApproved: color = Colors.green.shade700; break;
      case AppConstants.statusRejected: color = Colors.red.shade700; break;
      case AppConstants.statusArchived: color = Colors.blueGrey; break;
      default:                          color = Colors.grey.shade600;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
            fontSize: 10, fontWeight: FontWeight.bold, color: color),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _MetaChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: NRCSColors.topNavBlue),
        const SizedBox(width: 3),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: NRCSColors.textDark),
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
  final bool outlined;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
    this.outlined = false,
  });

  @override
  Widget build(BuildContext context) {
    if (outlined) {
      return OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 15, color: color),
        label: Text(label, style: TextStyle(color: color, fontSize: 13)),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: color.withOpacity(0.5)),
          padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6)),
        ),
      );
    }
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 15, color: Colors.white),
      label: Text(label,
          style: const TextStyle(color: Colors.white, fontSize: 13)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        elevation: 0,
      ),
    );
  }
}
