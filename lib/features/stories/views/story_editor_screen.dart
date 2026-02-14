import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:chamDTech_nrcs/features/stories/controllers/story_editor_controller.dart';
import 'package:chamDTech_nrcs/core/models/attachment_model.dart';
import 'package:chamDTech_nrcs/core/constants/app_constants.dart';
import 'package:chamDTech_nrcs/core/utils/permission_helpers.dart';
import 'package:chamDTech_nrcs/features/stories/models/story_model.dart';
import 'package:intl/intl.dart';

class StoryEditorScreen extends StatelessWidget {
  const StoryEditorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(StoryEditorController());

    return Scaffold(
      backgroundColor: const Color(0xFFE0E0E0),
      appBar: _buildAppBar(context, controller),
      body: Column(
        children: [
          _buildActionToolbar(context, controller),
          _buildMetadataBar(context, controller),
          Expanded(
            child: Row(
              children: [
                // Notes Editor (Left)
                Expanded(
                  flex: 2,
                    child: _buildSplittedEditor(
                    context,
                    controller,
                    title: 'Notes',
                    titleColor: const Color(0xFF1976D2),
                    quillController: controller.notesQuillController,
                    placeholder: 'Production notes, instructions...',
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
                    title: 'Anchor',
                    titleColor: const Color(0xFF1976D2),
                    quillController: controller.anchorQuillController,
                    placeholder: 'Anchor script goes here...',
                  ),
                ),
              ],
            ),
          ),
          _buildStatusFooter(context, controller),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, StoryEditorController controller) {
    return AppBar(
      title: Obx(() => Text(
        controller.storyTitle.value.isNotEmpty ? controller.storyTitle.value : 'New Story',
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      )),
      backgroundColor: const Color(0xFF263238),
      toolbarHeight: 40,
      actions: [
        Obx(() => controller.isSaving.value 
          ? const Center(child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
            ))
          : const SizedBox()),
        IconButton(
          icon: const Icon(Icons.close, size: 20),
          onPressed: () => Get.back(),
        ),
      ],
    );
  }

  Widget _buildActionToolbar(BuildContext context, StoryEditorController controller) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _ToolbarButton(icon: Icons.add_box_outlined, label: 'New', onTap: () {}),
            _ToolbarButton(icon: Icons.save_outlined, label: 'Save', onTap: () => controller.saveStory()),
            
            // Approve button (only for authorized users)
            if (PermissionHelpers.canApproveStory(controller.currentUser))
              _ToolbarButton(icon: Icons.check_circle_outline, label: 'Approve', onTap: () {
                // TODO: Implement approve logic
              }),

            _ToolbarButton(icon: Icons.copy_outlined, label: 'Copy', onTap: () {}),
            
            // Delete button (permission based)
            if (PermissionHelpers.canDeleteStory(controller.currentUser, controller.existingStory ?? StoryModel(
              id: '', 
              title: controller.titleController.text, 
              slug: '', 
              content: '', 
              authorId: controller.currentUser?.id ?? '', 
              authorName: '', 
              status: AppConstants.statusDraft, 
              createdAt: DateTime.now(), 
              updatedAt: DateTime.now()
            )))
              _ToolbarButton(icon: Icons.delete_outline, label: 'Delete', onTap: () {}),

            _ToolbarButton(icon: Icons.move_to_inbox_outlined, label: 'Move', onTap: () {}),
            _ToolbarButton(icon: Icons.link, label: 'Link', onTap: () {}),
            _ToolbarButton(icon: Icons.attach_file, label: 'Attachments', onTap: () => _showAttachmentsDialog(context, controller)),
            
            // Assign button (permission based)
            if (PermissionHelpers.canAssignStory(controller.currentUser))
              _ToolbarButton(icon: Icons.assignment_ind_outlined, label: 'Assign', onTap: () {}),

            _ToolbarButton(icon: Icons.history, label: 'Log', onTap: () {}),
            _ToolbarButton(icon: Icons.print_outlined, label: 'Print', onTap: () {}),
            const SizedBox(width: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.orange),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text('Powerview', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 12)),
            ),
            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildMetadataBar(BuildContext context, StoryEditorController controller) {
    return Container(
      color: const Color(0xFFF5F5F5),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: TextField(
              controller: controller.titleController,
              decoration: const InputDecoration(
                hintText: 'Enter Story Title...',
                isDense: true,
                border: InputBorder.none,
                fillColor: Colors.transparent,
                hintStyle: TextStyle(fontSize: 18, color: Colors.grey),
              ),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1B5E20)),
            ),
          ),
          const SizedBox(width: 16),
          _MetadataField(label: 'MASTER:', value: 'First Version', icon: Icons.check_box),
          const SizedBox(width: 16),
          _MetadataField(label: 'WORDS:', value: '250', icon: Icons.text_fields),
          const SizedBox(width: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFCFD8DC),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Obx(() => Text(
              '${controller.durationText.value} (00:00:00)',
              style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 13),
            )),
          ),
        ],
      ),
    );
  }

  Widget _buildSplittedEditor(
    BuildContext context,
    StoryEditorController controller, {
    required String title,
    required Color titleColor,
    required quill.QuillController quillController,
    required String placeholder,
  }) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          color: titleColor,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          child: Row( // Changed child to Row to accommodate multiple widgets
            children: [
              Text(
                title,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
              ),
              const Spacer(), // Pushes buttons to the right
              // Action Buttons based on permissions
              if (PermissionHelpers.canApproveStory(controller.currentUser))
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Approve logic
                    },
                    icon: const Icon(Icons.check, size: 16),
                    label: const Text('Approve'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                
              if (PermissionHelpers.canDeleteStory(controller.currentUser, controller.existingStory ?? StoryModel(
                id: '', 
                title: '', 
                slug: '', 
                content: '', 
                authorId: controller.currentUser?.id ?? '', 
                authorName: '', 
                status: 'draft', 
                createdAt: DateTime.now(), 
                updatedAt: DateTime.now()
              )))
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // Delete logic
                       Get.back();
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
        quill.QuillSimpleToolbar(
          controller: quillController,
          config: const quill.QuillSimpleToolbarConfig(
            showAlignmentButtons: false,
            showSmallButton: true,
            multiRowsDisplay: false,
          ),
        ),
        Expanded(
          child: Container(
            color: const Color(0xFFECEFF1),
            padding: const EdgeInsets.all(12),
            child: quill.QuillEditor.basic(
              controller: quillController,
              config: quill.QuillEditorConfig(
                placeholder: placeholder,
                padding: EdgeInsets.zero,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusFooter(BuildContext context, StoryEditorController controller) {
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
          const Text('CAPS', style: TextStyle(color: Colors.grey, fontSize: 11)),
          const SizedBox(width: 16),
          const Icon(Icons.keyboard_arrow_up, color: Colors.white70, size: 16),
        ],
      ),
    );
  }


  void _showAttachmentsDialog(BuildContext context, StoryEditorController controller) {
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
                          onPressed: () => controller.removeAttachment(attachment.id),
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
}

class _ToolbarButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ToolbarButton({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: Colors.blue[800]),
            Text(label, style: TextStyle(fontSize: 10, color: Colors.blue[900])),
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

  const _MetadataField({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87)),
        const SizedBox(width: 4),
        Icon(icon, size: 14, color: Colors.grey[700]),
        const SizedBox(width: 2),
        Text(value, style: const TextStyle(fontSize: 12, color: Colors.black)),
      ],
    );
  }
}
