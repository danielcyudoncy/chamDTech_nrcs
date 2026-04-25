import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:chamdtech_nrcs/features/dashboard/controllers/desk_controller.dart';
import 'package:chamdtech_nrcs/features/stories/models/desk_model.dart';
import 'package:chamdtech_nrcs/features/stories/models/story_model.dart';
import 'package:chamdtech_nrcs/features/stories/views/widgets/nrcs_layout.dart';
import 'package:chamdtech_nrcs/core/constants/app_constants.dart';
import 'package:intl/intl.dart';

class EditorialDesksView extends StatelessWidget {
  final bool isMobile;
  final Widget? headerActions;

  const EditorialDesksView({
    super.key,
    required this.isMobile,
    this.headerActions,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DeskController());

    return Obx(() {
      if (controller.selectedDeskId.value.isEmpty) {
        return _buildDeskGrid(controller);
      } else {
        return _buildDeskStoryList(controller);
      }
    });
  }

  Widget _buildDeskGrid(DeskController controller) {
    return Container(
      color: const Color(0xFFF8F9FA),
      child: SingleChildScrollView(
        padding: EdgeInsets.all(isMobile ? 16.0 : 32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            isMobile 
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Editorial Desks',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1A237E),
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (headerActions != null) headerActions!,
                  ],
                )
              : Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Editorial Desks',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1A237E),
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Select a desk to manage scripts and rundowns.',
                          style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                    const Spacer(),
                    if (headerActions != null) headerActions!,
                    const SizedBox(width: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.filter_list, size: 18, color: Colors.grey.shade600),
                          const SizedBox(width: 8),
                          Text(
                            '${controller.desks.length} DESKS',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
            const SizedBox(height: 32),
            if (controller.isLoadingDesks.value)
              const Center(child: Padding(padding: EdgeInsets.symmetric(vertical: 80), child: CircularProgressIndicator()))
            else if (controller.desks.isEmpty)
              _buildEmptyState()
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: isMobile ? 1 : (Get.width > 1600 ? 4 : 3),
                  crossAxisSpacing: isMobile ? 12 : 24,
                  mainAxisSpacing: isMobile ? 12 : 24,
                  childAspectRatio: isMobile ? (Get.width < 600 ? 3.0 : 2.2) : 1.5,
                ),
                itemCount: controller.desks.length,
                itemBuilder: (context, index) => _buildDeskCard(controller.desks[index], controller),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeskCard(DeskModel desk, DeskController controller) {
    final color = _getDeskColor(desk.name);
    final icon = _getDeskIcon(desk.name);
    
    // Calculate count directly from allStories for maximum reactivity
    final isCategory = AppConstants.storyCategories.contains(desk.id);
    final scriptCount = controller.allStories.where((s) {
      if (s.status == AppConstants.statusArchived) return false;
      return isCategory ? s.category == desk.id : s.deskId == desk.id;
    }).length;

    return InkWell(
      onTap: () => controller.selectDesk(desk.id),
      borderRadius: BorderRadius.circular(isMobile ? 20 : 28),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(isMobile ? 20 : 28),
          boxShadow: [BoxShadow(color: color.withValues(alpha: 0.08), blurRadius: isMobile ? 16 : 24, offset: isMobile ? const Offset(0, 8) : const Offset(0, 12))],
          border: Border.all(color: Colors.grey.shade100, width: 1),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(isMobile ? 20 : 28),
          child: Stack(
            children: [
              Positioned(right: -20, top: -20, child: Icon(icon, size: 140, color: color.withValues(alpha: 0.03))),
              Padding(
                padding: EdgeInsets.all(isMobile ? 12 : 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: EdgeInsets.all(isMobile ? 8 : 14),
                          decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(isMobile ? 10 : 18)),
                          child: Icon(icon, color: color, size: isMobile ? 16 : 24),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(color: color.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(20)),
                          child: Text('$scriptCount SCRIPTS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: color, letterSpacing: 0.5)),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Text(desk.name, style: TextStyle(fontSize: isMobile ? 18 : 22, fontWeight: FontWeight.w800, color: const Color(0xFF1A237E), letterSpacing: -0.5)),
                    if (!isMobile) const SizedBox(height: 6),
                    if (!isMobile) Text(desk.description ?? 'Editorial Workspace', maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.grey.shade500, fontSize: 13, height: 1.4, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDeskStoryList(DeskController controller) {
    final selectedDesk = controller.desks.firstWhere((d) => d.id == controller.selectedDeskId.value);
    final color = _getDeskColor(selectedDesk.name);

    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 32, vertical: 24),
          color: Colors.white,
          child: Row(
            children: [
              IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => controller.selectDesk('')),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(selectedDesk.name.toUpperCase(), style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: color, letterSpacing: -0.5)),
                  Text('${controller.deskStories.length} active scripts in this desk', style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
                ],
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: controller.deskStories.isEmpty
              ? _buildEmptyScriptsState()
              : ListView.separated(
                  padding: EdgeInsets.all(isMobile ? 16 : 32),
                  itemCount: controller.deskStories.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) => _buildStoryTile(controller.deskStories[index]),
                ),
        ),
      ],
    );
  }

  Widget _buildStoryTile(StoryModel story) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Text(story.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Row(
            children: [
              Icon(Icons.person_outline, size: 14, color: Colors.grey.shade600),
              const SizedBox(width: 4),
              Text(story.authorName, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
              const SizedBox(width: 16),
              Icon(Icons.access_time, size: 14, color: Colors.grey.shade600),
              const SizedBox(width: 4),
              Text(DateFormat('MMM dd, HH:mm').format(story.updatedAt), style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
            ],
          ),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Get.toNamed('/story/editor', arguments: story),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.desk_outlined, size: 80, color: Colors.grey.shade200),
          const SizedBox(height: 24),
          const Text('No Editorial Desks Found', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1A237E))),
          const SizedBox(height: 8),
          Text('Editorial categories will appear here automatically.', style: TextStyle(color: Colors.grey.shade500)),
        ],
      ),
    );
  }

  Widget _buildEmptyScriptsState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.article_outlined, size: 64, color: Colors.grey.shade100),
          const SizedBox(height: 16),
          Text('No scripts in this desk yet', style: TextStyle(color: Colors.grey.shade400, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  IconData _getDeskIcon(String name) {
    final n = name.toLowerCase();
    if (n.contains('local')) return Icons.location_on_outlined;
    if (n.contains('politics')) return Icons.gavel_outlined;
    if (n.contains('sports')) return Icons.sports_basketball_outlined;
    if (n.contains('foreign')) return Icons.public_outlined;
    if (n.contains('business')) return Icons.business_center_outlined;
    if (n.contains('breaking')) return Icons.bolt;
    if (n.contains('tech')) return Icons.biotech_outlined;
    if (n.contains('env')) return Icons.eco_outlined;
    if (n.contains('health')) return Icons.health_and_safety_outlined;
    if (n.contains('ent')) return Icons.movie_filter_outlined;
    return Icons.desk_outlined;
  }

  Color _getDeskColor(String name) {
    final n = name.toLowerCase();
    if (n.contains('local')) return Colors.blue.shade700;
    if (n.contains('politics')) return Colors.purple.shade700;
    if (n.contains('sports')) return Colors.green.shade700;
    if (n.contains('foreign')) return Colors.orange.shade800;
    if (n.contains('business')) return Colors.teal.shade700;
    if (n.contains('breaking')) return Colors.red.shade700;
    if (n.contains('tech')) return Colors.indigo.shade700;
    if (n.contains('env')) return Colors.green.shade900;
    if (n.contains('health')) return Colors.pink.shade700;
    if (n.contains('ent')) return Colors.amber.shade900;
    return const Color(0xFF1A237E);
  }
}
