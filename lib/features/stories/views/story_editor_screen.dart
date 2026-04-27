// features/stories/views/story_editor_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:chamdtech_nrcs/features/stories/controllers/story_editor_controller.dart';
import 'package:chamdtech_nrcs/core/constants/app_constants.dart';
import 'package:chamdtech_nrcs/core/utils/permission_helpers.dart';
import 'package:chamdtech_nrcs/features/stories/models/story_model.dart';
import 'package:intl/intl.dart';

import 'package:chamdtech_nrcs/features/stories/views/widgets/nrcs_layout.dart';

class StoryEditorScreen extends StatelessWidget {
  const StoryEditorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(StoryEditorController());

    return Obx(() {
      // Accessing reactive variables at the top to ensure Obx listens to them
      controller.isReadOnly.value;
      controller.formattedDuration.value;
      controller.anchorWordCount.value;
      controller.notesWordCount.value;

      return NRCSAppShell(
        title: 'STORY EDITOR',
        body: LayoutBuilder(builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 900;
          return Container(
            color: const Color(0xFFF5F7FB),
            child: Column(
              children: [
                _buildModernHeader(context, controller, isMobile),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        flex: 5,
                        child:
                            _buildMainWorkspace(context, controller, isMobile),
                      ),
                      if (!isMobile)
                        Container(
                          width: 280,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border(
                                left: BorderSide(color: Colors.grey.shade200)),
                          ),
                          child: _buildMetricsSidebar(context, controller),
                        ),
                    ],
                  ),
                ),
                _buildModernFooter(context, controller),
              ],
            ),
          );
        }),
      );
    });
  }

  Widget _buildModernHeader(
      BuildContext context, StoryEditorController controller, bool isMobile) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A237E), // Deep professional blue
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller.titleController,
                  enabled: !controller.isReadOnly.value,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Story Title...',
                    border: InputBorder.none,
                    hintStyle: TextStyle(color: Colors.white70),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              _buildStatusBadge(controller.existingStory?.status ?? 'draft',
                  isDarkBackground: true),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildCategoryChip(controller, isDarkBackground: true),
              const SizedBox(width: 12),
              Container(width: 1, height: 24, color: Colors.white24),
              const SizedBox(width: 12),
              _buildModernActionButtons(context, controller, isMobile),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMainWorkspace(
      BuildContext context, StoryEditorController controller, bool isMobile) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          if (isMobile)
            Container(
              color: Colors.white,
              child: const TabBar(
                indicatorColor: Color(0xFF1A237E),
                labelColor: Color(0xFF1A237E),
                unselectedLabelColor: Colors.grey,
                indicatorSize: TabBarIndicatorSize.label,
                labelStyle:
                    TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                tabs: [
                  Tab(text: 'STORY CONTENT'),
                  Tab(text: 'REPORT INTROS'),
                ],
              ),
            ),
          Expanded(
            child: isMobile
                ? TabBarView(
                    children: [
                      _buildModernEditorPanel(
                        context,
                        controller,
                        title: 'Story Content',
                        icon: Icons.article_outlined,
                        quillController: controller.notesQuillController,
                        placeholder: 'Write your story content here...',
                      ),
                      _buildModernEditorPanel(
                        context,
                        controller,
                        title: 'Report Intros',
                        icon: Icons.mic_none,
                        quillController: controller.anchorQuillController,
                        placeholder: 'Write report intros here...',
                      ),
                    ],
                  )
                : Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildModernEditorPanel(
                            context,
                            controller,
                            title: 'Story Content',
                            icon: Icons.article_outlined,
                            quillController: controller.notesQuillController,
                            placeholder: 'Write your story content here...',
                          ),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          child: _buildModernEditorPanel(
                            context,
                            controller,
                            title: 'Report Intros',
                            icon: Icons.mic_none,
                            quillController: controller.anchorQuillController,
                            placeholder: 'Write report intros here...',
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

  Widget _buildModernEditorPanel(
    BuildContext context,
    StoryEditorController controller, {
    required String title,
    required IconData icon,
    required quill.QuillController quillController,
    required String placeholder,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
            ),
            child: Row(
              children: [
                Icon(icon, size: 18, color: const Color(0xFF1A237E)),
                const SizedBox(width: 10),
                Text(
                  title.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1A237E),
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
          if (!controller.isReadOnly.value)
            quill.QuillSimpleToolbar(
              configurations: quill.QuillSimpleToolbarConfigurations(
                controller: quillController,
                showAlignmentButtons: false,
                showSmallButton: true,
                multiRowsDisplay: false,
                buttonOptions: const quill.QuillSimpleToolbarButtonOptions(
                  base: quill.QuillToolbarBaseButtonOptions(
                    iconTheme: quill.QuillIconTheme(
                      iconButtonSelectedData:
                          quill.IconButtonData(color: Color(0xFF1A237E)),
                    ),
                  ),
                ),
              ),
            ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: quill.QuillEditor.basic(
                configurations: quill.QuillEditorConfigurations(
                  controller: quillController,
                  placeholder: placeholder,
                  padding: EdgeInsets.zero,
                  customStyles: const quill.DefaultStyles(
                    paragraph: quill.DefaultListBlockStyle(
                      TextStyle(color: Colors.black, fontSize: 16, height: 1.5),
                      quill.VerticalSpacing(0, 0),
                      quill.VerticalSpacing(0, 0),
                      null,
                      null,
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

  Widget _buildMetricsSidebar(
      BuildContext context, StoryEditorController controller) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'STORY METRICS',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              color: Colors.grey,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 24),
          _buildMetricCard(
            'Estimated Duration',
            controller.formattedDuration.value,
            Icons.timer_outlined,
            const Color(0xFF1A237E),
          ),
          const SizedBox(height: 16),
          _buildMetricCard(
            'Anchor Words',
            '${controller.anchorWordCount.value}',
            Icons.mic_none,
            Colors.orange,
          ),
          const SizedBox(height: 16),
          _buildMetricCard(
            'Story Words',
            '${controller.notesWordCount.value}',
            Icons.text_snippet_outlined,
            Colors.blue,
          ),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildMetricCard(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.bold)),
              Text(value,
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w900, color: color)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status, {bool isDarkBackground = false}) {
    Color color;
    switch (status.toLowerCase()) {
      case 'approved':
        color = Colors.green;
        break;
      case 'pending':
        color = Colors.orange;
        break;
      case 'draft':
        color = isDarkBackground ? Colors.blue.shade200 : Colors.blue;
        break;
      case 'rejected':
        color = Colors.red;
        break;
      default:
        color = isDarkBackground ? Colors.grey.shade400 : Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDarkBackground ? 0.2 : 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(
            status.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              color: isDarkBackground ? Colors.white : color,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernActionButtons(
      BuildContext context, StoryEditorController controller, bool isMobile) {
    return Expanded(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            if (!controller.isReadOnly.value) ...[
              ElevatedButton.icon(
                onPressed: () => controller.saveStory(),
                icon: const Icon(Icons.save_outlined, size: 18),
                label: const Text('SAVE DRAFT'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A237E),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(width: 12),
              if (controller.existingStory?.status == AppConstants.statusDraft)
                ElevatedButton.icon(
                  onPressed: () => controller.submitStory(),
                  icon: const Icon(Icons.send_outlined, size: 18),
                  label: const Text('SUBMIT'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo.shade400,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              if (PermissionHelpers.canApproveStory(controller.currentUser) &&
                  controller.existingStory?.status ==
                      AppConstants.statusPending)
                ElevatedButton.icon(
                  onPressed: () => controller.approveStory(),
                  icon: const Icon(Icons.check_circle_outline, size: 18),
                  label: const Text('APPROVE'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                ),
            ],
            const SizedBox(width: 12),
            _buildIconButton(
                Icons.copy_all, 'Copy', () => controller.handleCopy()),
            _buildIconButton(
                Icons.history, 'Logs', () => controller.showComingSoon('Logs')),
            if (PermissionHelpers.canDeleteStory(controller.currentUser,
                controller.existingStory ?? StoryModel.empty()))
              _buildIconButton(Icons.delete_outline, 'Delete',
                  () => controller.handleDelete(),
                  color: Colors.red),
          ],
        ),
      ),
    );
  }

  Widget _buildIconButton(IconData icon, String label, VoidCallback onTap,
      {Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Tooltip(
        message: label,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (color ?? Colors.grey).withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: color ?? Colors.grey.shade700),
          ),
        ),
      ),
    );
  }

  Widget _buildModernFooter(
      BuildContext context, StoryEditorController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade100)),
      ),
      child: Row(
        children: [
          Text(
            controller.lastSaved.value != null
                ? 'Autosaved at ${DateFormat('hh:mm:ss a').format(controller.lastSaved.value!)}'
                : 'Changes not saved',
            style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 11,
                fontWeight: FontWeight.w600),
          ),
          const Spacer(),
          Text(
            'V${controller.versionText.value}',
            style: const TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 10,
                color: Color(0xFF1A237E)),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(StoryEditorController controller,
      {bool isDarkBackground = false}) {
    final selected = controller.selectedCategory.value;
    final color = _categoryColor(selected);
    final displayColor = isDarkBackground ? Colors.white : color;

    return InkWell(
      onTap: controller.isReadOnly.value
          ? null
          : () => _showCategoryPicker(controller),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: isDarkBackground ? 0.3 : 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
              color: isDarkBackground
                  ? Colors.white24
                  : color.withValues(alpha: 0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.category_outlined, size: 14, color: displayColor),
            const SizedBox(width: 8),
            Text(
              selected.isEmpty ? 'SELECT CATEGORY' : selected.toUpperCase(),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: displayColor,
                letterSpacing: 0.5,
              ),
            ),
            if (!controller.isReadOnly.value) ...[
              const SizedBox(width: 4),
              Icon(Icons.keyboard_arrow_down, size: 14, color: displayColor),
            ],
          ],
        ),
      ),
    );
  }

  void _showCategoryPicker(StoryEditorController controller) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Story Category',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A237E)),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: AppConstants.storyCategories.map((cat) {
                final color = _categoryColor(cat);
                return InkWell(
                  onTap: () {
                    controller.selectedCategory.value = cat;
                    Get.back();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: controller.selectedCategory.value == cat
                          ? color
                          : color.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: color.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      cat,
                      style: TextStyle(
                        color: controller.selectedCategory.value == cat
                            ? Colors.white
                            : color,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  static Color _categoryColor(String category) {
    switch (category) {
      case 'Local News':
        return Colors.blue;
      case 'Politics':
        return Colors.purple;
      case 'Sports':
        return Colors.green;
      case 'Foreign':
        return Colors.orange;
      case 'Business & Finance':
        return Colors.teal;
      case 'Breaking News':
        return Colors.red;
      case 'Technology':
        return Colors.indigo;
      case 'Environment':
        return Colors.green.shade800;
      case 'Health':
        return Colors.pink;
      case 'Entertainment & Lifestyle':
        return Colors.amber;
      default:
        return Colors.grey;
    }
  }
}
