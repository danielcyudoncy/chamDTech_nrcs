// features/stories/views/story_editor_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:chamdtech_nrcs/features/stories/controllers/story_editor_controller.dart';
import 'package:chamdtech_nrcs/core/models/attachment_model.dart';
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

    return LayoutBuilder(builder: (context, constraints) {
      final isMobile = constraints.maxWidth < 900;

      return Obx(() => NRCSAppShell(
            title: 'EDITOR WORKSPACE',
        body: DefaultTabController(
          length: 2,
          child: Column(
            children: [
              _buildActionToolbar(context, controller),
              _buildMetadataBar(context, controller, isMobile),
              if (isMobile)
                Container(
                  color: NRCSColors.topNavBlue,
                  child: const TabBar(
                    indicatorColor: Colors.white,
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.white70,
                    tabs: [
                      Tab(text: 'STORY'),
                      Tab(text: 'REPORT INTROS'),
                    ],
                  ),
                ),
              Expanded(
                child: isMobile
                    ? TabBarView(
                        children: [
                          _buildSplittedEditor(
                            context,
                            controller,
                            title: 'Story',
                            titleColor: const Color(0xFF1976D2),
                            quillController: controller.notesQuillController,
                            placeholder: 'Production notes, instructions...',
                            isMobile: true,
                          ),
                          _buildSplittedEditor(
                            context,
                            controller,
                            title: 'Report Intros',
                            titleColor: const Color(0xFF1976D2),
                            quillController: controller.anchorQuillController,
                            placeholder: 'Report intros goes here...',
                            isMobile: true,
                          ),
                        ],
                      )
                    : Row(
                        children: [
                          // Notes Editor (Left)
                          Expanded(
                            flex: 2,
                            child: _buildSplittedEditor(
                              context,
                              controller,
                              title: 'Story',
                              titleColor: const Color(0xFF1976D2),
                              quillController: controller.notesQuillController,
                              placeholder: 'Production notes, instructions...',
                              isMobile: false,
                            ),
                          ),
                          // Divider
                          Container(width: 2, color: Colors.grey[400]),
                          // Anchor Editor (Right)
                          Expanded(
                            flex: 3,
                            child: _buildSplittedEditor(
                              context,
                              controller,
                              title: 'Report Intros',
                              titleColor: const Color(0xFF1976D2),
                              quillController: controller.anchorQuillController,
                              placeholder: 'Report intros goes here...',
                              isMobile: false,
                            ),
                          ),
                        ],
                      ),
              ),
              _buildStatusFooter(context, controller),
            ],
          ),
        ),
      ));
    });
  }

  Widget _buildActionToolbar(
      BuildContext context, StoryEditorController controller) {
    return Container(
      decoration: const BoxDecoration(
        color: NRCSColors.topNavBlue,
        border: Border(bottom: BorderSide(color: Colors.white24, width: 0.5)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _ToolbarButton(
                icon: Icons.add_box_outlined,
                label: 'New',
                onTap: () => controller.handleNew()),
            if (!controller.isReadOnly.value)
              _ToolbarButton(
                  icon: Icons.save_outlined,
                  label: 'Save',
                  onTap: () => controller.saveStory()),

            // Submit button (only for drafts and not read-only)
            if (controller.existingStory?.status == AppConstants.statusDraft && !controller.isReadOnly.value)
              _ToolbarButton(
                icon: Icons.send_outlined,
                label: 'Submit',
                onTap: () => controller.submitStory(),
              ),

            // Approve button (only for authorized users when story is pending and not read-only)
            if (PermissionHelpers.canApproveStory(controller.currentUser) &&
                controller.existingStory?.status == AppConstants.statusPending && !controller.isReadOnly.value)
              _ToolbarButton(
                  icon: Icons.check_circle_outline,
                  label: 'Approve',
                  onTap: () {
                    controller.approveStory();
                  }),

            _ToolbarButton(
                icon: Icons.copy_outlined,
                label: 'Copy',
                onTap: () => controller.handleCopy()),

            // Delete button (permission based)
            if (PermissionHelpers.canDeleteStory(
                controller.currentUser,
                controller.existingStory ??
                    StoryModel(
                        id: '',
                        title: controller.titleController.text,
                        slug: '',
                        content: '',
                        authorId: controller.currentUser?.id ?? '',
                        authorName: '',
                        status: AppConstants.statusDraft,
                        createdAt: DateTime.now(),
                        updatedAt: DateTime.now())))
              _ToolbarButton(
                  icon: Icons.delete_outline,
                  label: 'Delete',
                  onTap: () => controller.handleDelete()),

            _ToolbarButton(
                icon: Icons.move_to_inbox_outlined,
                label: 'Move',
                onTap: () => controller.showComingSoon('Move')),
            _ToolbarButton(
                icon: Icons.link,
                label: 'Link',
                onTap: () => controller.showComingSoon('Link')),
            _ToolbarButton(
                icon: Icons.attach_file,
                label: 'Attachments',
                onTap: () => _showAttachmentsDialog(context, controller)),

            // Assign button (permission based)
            if (PermissionHelpers.canAssignStory(controller.currentUser))
              _ToolbarButton(
                  icon: Icons.assignment_ind_outlined,
                  label: 'Assign',
                  onTap: () => controller.showAssignDialog()),

            _ToolbarButton(
                icon: Icons.history,
                label: 'Log',
                onTap: () => controller.showComingSoon('Story Log')),
            _ToolbarButton(
                icon: Icons.print_outlined,
                label: 'Print',
                onTap: () => controller.showComingSoon('Print')),
            const SizedBox(width: 16),
            InkWell(
              onTap: () => controller.showComingSoon('Powerview'),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.orange),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text('Powerview',
                    style: TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                        fontSize: 12)),
              ),
            ),
            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildMetadataBar(
      BuildContext context, StoryEditorController controller, bool isMobile) {
    if (isMobile) {
      return Container(
        color: NRCSColors.topNavBlue,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: controller.titleController,
              maxLines: 2,
              minLines: 1,
              enabled: !controller.isReadOnly.value,
              decoration: InputDecoration(
                hintText: 'Enter Story Title...',
                isDense: true,
                border: InputBorder.none,
                fillColor: Colors.transparent,
                hintStyle: TextStyle(
                    fontSize: 15, color: Colors.white.withValues(alpha: 0.6)),
              ),
              style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildCategoryDropdown(controller),
                  const SizedBox(width: 8),
                  Obx(() => _MetadataField(
                      label: 'V:',
                      value: controller.versionText.value,
                      icon: Icons.check_box)),
                  const SizedBox(width: 12),
                  Obx(() => _MetadataField(
                      label: 'WORDS:',
                      value:
                          '${controller.anchorWordCount.value} | ${controller.notesWordCount.value}',
                      icon: Icons.text_fields)),
                  const SizedBox(width: 12),
                  Obx(() => Text(
                        controller.formattedDuration.value,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 11),
                      )),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      color: NRCSColors.topNavBlue,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            SizedBox(
              width: 300,
              child: TextField(
                controller: controller.titleController,
                enabled: !controller.isReadOnly.value,
                decoration: InputDecoration(
                  hintText: 'Enter Story Title...',
                  isDense: true,
                  border: InputBorder.none,
                  fillColor: Colors.transparent,
                  hintStyle: TextStyle(
                      fontSize: 18, color: Colors.white.withValues(alpha: 0.6)),
                ),
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ),
          const SizedBox(width: 16),
          _buildCategoryDropdown(controller),
          // ──────────────────────────────────────────────────────────
          const SizedBox(width: 6),
          Obx(() => _MetadataField(
              label: 'MASTER:',
              value: controller.versionText.value,
              icon: Icons.check_box)),
          const SizedBox(width: 16),
          Obx(() => _MetadataField(
              label: 'WORD COUNT:',
              value:
                  '${controller.anchorWordCount.value} ANC | ${controller.notesWordCount.value} NTS',
              icon: Icons.text_fields)),
          const SizedBox(width: 16),
          Obx(() => Text(
                controller.formattedDuration.value,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13),
              )),
          ],
        ),
      ),
    );
  }

  /// Returns a distinct color for each category.
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

  Widget _buildSplittedEditor(
    BuildContext context,
    StoryEditorController controller, {
    required String title,
    required Color titleColor,
    required quill.QuillController quillController,
    required String placeholder,
    required bool isMobile,
  }) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          color: titleColor,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          child: Row(
            // Changed child to Row to accommodate multiple widgets
            children: [
              Text(
                title,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12),
              ),
              const Spacer(), // Pushes buttons to the right
              // Action Buttons based on permissions (hide if read-only)
              if (PermissionHelpers.canApproveStory(controller.currentUser) && !controller.isReadOnly.value)
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ElevatedButton.icon(
                    onPressed: () {
                      controller.approveStory();
                    },
                    icon: const Icon(Icons.check, size: 16),
                    label: const Text('Approve'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),

              if (PermissionHelpers.canDeleteStory(
                  controller.currentUser,
                  controller.existingStory ??
                      StoryModel(
                          id: '',
                          title: '',
                          slug: '',
                          content: '',
                          authorId: controller.currentUser?.id ?? '',
                          authorName: '',
                          status: 'draft',
                          createdAt: DateTime.now(),
                          updatedAt: DateTime.now())) && !controller.isReadOnly.value)
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: OutlinedButton.icon(
                    onPressed: () {
                      controller.handleDelete();
                    },
                    icon: const Icon(Icons.delete, size: 16),
                    label: const Text('Delete'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                    ),
                  ),
                ),
            ],
          ),
        ),
        if (!controller.isReadOnly.value)
          Container(
            color: NRCSColors.topNavBlue,
            child: quill.QuillSimpleToolbar(
              configurations: quill.QuillSimpleToolbarConfigurations(
                controller: quillController,
                showAlignmentButtons: false,
                showSmallButton: true,
                multiRowsDisplay: false,
                buttonOptions: const quill.QuillSimpleToolbarButtonOptions(
                  base: quill.QuillToolbarBaseButtonOptions(
                    iconTheme: quill.QuillIconTheme(
                      iconButtonSelectedData: quill.IconButtonData(
                        color: Colors.white,
                      ),
                      iconButtonUnselectedData: quill.IconButtonData(
                        color: Colors.white70,
                      ),
                    ),
                  ),
                  fontFamily: quill.QuillToolbarFontFamilyButtonOptions(
                    style: TextStyle(fontSize: 12, color: Colors.white),
                  ),
                  fontSize: quill.QuillToolbarFontSizeButtonOptions(
                    style: TextStyle(fontSize: 12, color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
        Expanded(
          child: Container(
            color: const Color(0xFFECEFF1),
            padding: const EdgeInsets.all(12),
            child: Theme(
              data: Theme.of(context).copyWith(
                brightness: Brightness.light,
              ),
              child: quill.QuillEditor.basic(
                configurations: quill.QuillEditorConfigurations(
                  controller: quillController,
                  placeholder: placeholder,
                  padding: EdgeInsets.zero,
                  customStyles: const quill.DefaultStyles(
                    paragraph: quill.DefaultListBlockStyle(
                      TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        height: 1.5,
                      ),
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
        ),
      ],
    );
  }

  Widget _buildStatusFooter(
      BuildContext context, StoryEditorController controller) {
    return Container(
      color: const Color(0xFF37474F),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Obx(() => Text(
                controller.lastSaved.value != null
                    ? 'Last Saved: ${DateFormat('HH:mm:ss').format(controller.lastSaved.value!)}'
                    : 'Not saved yet',
                style: const TextStyle(color: Colors.white70, fontSize: 11),
              )),
          const Spacer(),
          const Text('CAPS',
              style: TextStyle(color: Colors.grey, fontSize: 11)),
          const SizedBox(width: 16),
          const Icon(Icons.keyboard_arrow_up, color: Colors.white70, size: 16),
        ],
      ),
    );
  }

  void _showAttachmentsDialog(
      BuildContext context, StoryEditorController controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Attachments'),
        content: SizedBox(
          width: 500,
          height: 400,
          child: Column(
            children: [
              Expanded(
                child: Obx(() {
                  if (controller.attachments.isEmpty) {
                    return const Center(child: Text('No attachments'));
                  }
                  return ListView.builder(
                    itemCount: controller.attachments.length,
                    itemBuilder: (context, index) {
                      final attachment = controller.attachments[index];
                      return ListTile(
                        leading: Icon(_getIconForType(attachment.type)),
                        title: Text(attachment.name),
                        subtitle: Text(attachment.formattedSize),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () =>
                              controller.removeAttachment(attachment.id),
                        ),
                      );
                    },
                  );
                }),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  // Mock add attachment for now
                  final attachment = AttachmentModel(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    name: 'Mock Attachment.jpg',
                    type: 'image',
                    url: 'https://example.com/image.jpg',
                    sizeBytes: 1024 * 1024,
                    uploadedAt: DateTime.now(),
                    uploadedBy: controller.currentUser?.id ?? 'unknown',
                  );
                  controller.addAttachment(attachment);
                },
                icon: const Icon(Icons.add),
                label: const Text('Add Attachment'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  IconData _getIconForType(String type) {
    if (type.startsWith('image')) return Icons.image;
    if (type.startsWith('video')) return Icons.videocam;
    if (type.startsWith('audio')) return Icons.audiotrack;
    return Icons.insert_drive_file;
  }

  Widget _buildCategoryDropdown(StoryEditorController controller) {
    return Obx(() {
      final selected = controller.selectedCategory.value;
      final isEmpty = selected.isEmpty;
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
        decoration: BoxDecoration(
          color: isEmpty ? Colors.red.withValues(alpha: 0.05) : Colors.white,
          border: Border.all(
            color: isEmpty ? Colors.red.shade300 : Colors.grey.shade400,
            width: isEmpty ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: selected.isEmpty ? null : selected,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF263238),
            ),
            hint: Text(
              'Select Category',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isEmpty ? Colors.red.shade400 : Colors.grey.shade600,
              ),
            ),
            icon: Icon(
              Icons.arrow_drop_down,
              color: isEmpty ? Colors.red.shade400 : Colors.grey[700],
            ),
            isDense: true,
            dropdownColor: Colors.white,
            items: AppConstants.storyCategories.map((cat) {
              final color = _categoryColor(cat);
              return DropdownMenuItem<String>(
                value: cat,
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      cat,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF263238),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            onChanged: controller.isReadOnly.value 
                ? null 
                : (value) {
                    if (value != null) {
                      controller.selectedCategory.value = value;
                    }
                  },
          ),
        ),
      );
    });
  }
}

class _ToolbarButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ToolbarButton(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: Colors.white),
            Text(label,
                style: const TextStyle(fontSize: 10, color: Colors.white70)),
          ],
        ),
      ),
    );
  }
}

class _MetadataField extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _MetadataField(
      {required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white70)),
        const SizedBox(width: 4),
        Icon(icon, size: 14, color: Colors.white),
        const SizedBox(width: 2),
        Text(value, style: const TextStyle(fontSize: 12, color: Colors.white)),
      ],
    );
  }
}
