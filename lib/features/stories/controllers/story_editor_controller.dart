// features/stories/controllers/story_editor_controller.dart
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:chamdtech_nrcs/features/stories/models/story_model.dart';
import 'package:chamdtech_nrcs/core/models/attachment_model.dart';
import 'package:chamdtech_nrcs/features/stories/services/story_service.dart';
import 'package:chamdtech_nrcs/features/auth/services/auth_service.dart';
import 'package:chamdtech_nrcs/features/stories/controllers/story_controller.dart';
import 'package:chamdtech_nrcs/core/constants/app_constants.dart';
import 'package:chamdtech_nrcs/core/models/notification_model.dart';
import 'package:chamdtech_nrcs/core/services/notification_service.dart';
import 'package:chamdtech_nrcs/features/auth/models/user_model.dart';
import 'package:chamdtech_nrcs/app/routes/app_routes.dart';
import 'package:uuid/uuid.dart';

class StoryEditorController extends GetxController {
  final StoryService _storyService = Get.find<StoryService>();
  final AuthService _authService = Get.find<AuthService>();
  final NotificationService _notificationService = Get.find<NotificationService>();

  final titleController = TextEditingController();
  final slugController = TextEditingController();
  final durationController = TextEditingController(text: '0');
  
  late quill.QuillController anchorQuillController;
  late quill.QuillController notesQuillController;
  
  final isLoading = false.obs;
  final isSaving = false.obs;
  final lastSaved = Rxn<DateTime>();
  
  final storyTitle = ''.obs;
  final durationText = '0'.obs;
  final attachments = <AttachmentModel>[].obs; // Reactive attachments list
  final selectedCategory = ''.obs; // Selected story category
  final versionText = 'First Version'.obs;
  final anchorWordCount = 0.obs;
  final notesWordCount = 0.obs;
  final formattedDuration = '00:00:00'.obs;

  StoryModel? existingStory;
  Timer? _autoSaveTimer;

  // Get current user for permission checks
  get currentUser => _authService.currentUser.value;

  // Generate dropdown items with correct styling
  List<DropdownMenuItem<String>> get categoryDropdownItems {
    return AppConstants.storyCategories.map((cat) {
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
              style: TextStyle(
                fontSize: 14, 
                fontWeight: FontWeight.w500,
                color: Get.isDarkMode ? Colors.white70 : Colors.black87,
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  Color _categoryColor(String category) {
    switch (category) {
      case 'Local News':                return Colors.blue;
      case 'Politics':                  return Colors.purple;
      case 'Sports':                    return Colors.green;
      case 'Foreign':                   return Colors.orange;
      case 'Business & Finance':        return Colors.teal;
      case 'Breaking News':             return Colors.red;
      case 'Technology':                return Colors.indigo;
      case 'Environment':               return Colors.green.shade800;
      case 'Health':                    return Colors.pink;
      case 'Entertainment & Lifestyle': return Colors.amber;
      default:                          return Colors.grey;
    }
  }

  @override
  void onInit() {
    super.onInit();
    
    if (Get.arguments != null && Get.arguments is StoryModel) {
      existingStory = Get.arguments as StoryModel;
      titleController.text = existingStory!.title;
      storyTitle.value = existingStory!.title;
      slugController.text = existingStory!.slug;
      durationController.text = existingStory!.duration.toString();
      durationText.value = existingStory!.duration.toString();
      selectedCategory.value = existingStory!.category;
      
      if (existingStory!.version > 1) {
        versionText.value = 'Version ${existingStory!.version}';
      }
      
      // Load attachments
      attachments.assignAll(existingStory!.attachments);
      
      // Load content
      _loadContent(existingStory!.content);
    } else {
      anchorQuillController = quill.QuillController.basic();
      notesQuillController = quill.QuillController.basic();
      
      // Pre-fill category if passed from the New Story popup
      if (Get.arguments != null && Get.arguments is Map && Get.arguments['category'] != null) {
        selectedCategory.value = Get.arguments['category'];
      }
    }

    // Start auto-save
    _autoSaveTimer = Timer.periodic(AppConstants.autoSaveInterval, (_) => autoSave());
    
    // Listen for title changes and updates
    titleController.addListener(() {
      storyTitle.value = titleController.text;
      _onTitleChanged();
    });
    
    durationController.addListener(() {
      durationText.value = durationController.text;
    });

    // Add text listeners for word count and duration
    anchorQuillController.document.changes.listen((_) => _updateMetrics());
    notesQuillController.document.changes.listen((_) => _updateMetrics());
    
    // Initial calculation
    _updateMetrics();
  }

  void _updateMetrics() {
    final anchorText = anchorQuillController.document.toPlainText().trim();
    final notesText = notesQuillController.document.toPlainText().trim();
    
    // Anchor Words
    int ancWords = 0;
    if (anchorText.isNotEmpty) {
      ancWords = anchorText.split(RegExp(r'\s+')).where((word) => word.isNotEmpty).length;
    }
    anchorWordCount.value = ancWords;
    
    // Notes Words
    int ntsWords = 0;
    if (notesText.isNotEmpty) {
      ntsWords = notesText.split(RegExp(r'\s+')).where((word) => word.isNotEmpty).length;
    }
    notesWordCount.value = ntsWords;
    
    // Calculate duration strictly from Anchor text (3 words per second)
    if (ancWords == 0) {
      formattedDuration.value = '00:00:00';
      durationText.value = '0';
      if (durationController.text != '0') durationController.text = '0';
    } else {
      final seconds = (ancWords / 3).ceil();
      final d = Duration(seconds: seconds);
      final h = d.inHours.toString().padLeft(2, '0');
      final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
      final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
      formattedDuration.value = '$h:$m:$s';
      
      durationText.value = seconds.toString();
      if (durationController.text != seconds.toString()) {
        durationController.text = seconds.toString();
      }
    }
  }

  void _loadContent(String contentJson) {
    try {
      final decoded = jsonDecode(contentJson);
      final anchorDoc = quill.Document.fromJson(decoded['anchor'] ?? []);
      final notesDoc = quill.Document.fromJson(decoded['notes'] ?? []);
      
      anchorQuillController = quill.QuillController(
        document: anchorDoc,
        selection: const TextSelection.collapsed(offset: 0),
      );
      
      notesQuillController = quill.QuillController(
        document: notesDoc,
        selection: const TextSelection.collapsed(offset: 0),
      );
    } catch (e) {
      anchorQuillController = quill.QuillController.basic();
      notesQuillController = quill.QuillController.basic();
    }
  }

  void _onTitleChanged() {
    if (slugController.text.isEmpty && titleController.text.isNotEmpty) {
      slugController.text = titleController.text
          .toLowerCase()
          .replaceAll(RegExp(r'[^a-z0-9]'), '-');
    }
  }

  String _serializeContent() {
    return jsonEncode({
      'anchor': anchorQuillController.document.toDelta().toJson(),
      'notes': notesQuillController.document.toDelta().toJson(),
    });
  }

  Future<void> autoSave() async {
    if (titleController.text.isEmpty || isSaving.value) return;
    await saveStory(isAutoSave: true);
  }

  Future<void> saveStory({bool isAutoSave = false, String? nextStage}) async {
    if (titleController.text.isEmpty) return;

    // Validate category is selected (skip during auto-save to avoid spamming)
    if (!isAutoSave && selectedCategory.value.isEmpty) {
      Get.snackbar(
        'Category Required',
        'Please select a category before saving.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.1),
        colorText: Colors.red,
        duration: const Duration(seconds: 3),
      );
      return;
    }

    if (!isAutoSave) isLoading.value = true;
    isSaving.value = true;

    final user = _authService.currentUser.value;
    if (user == null) return;

    final now = DateTime.now();

    // Increment version on manual saves for existing stories
    int newVersion = existingStory?.version ?? 1;
    if (!isAutoSave && existingStory != null) {
      newVersion++;
    }

    final story = (existingStory ?? StoryModel(
      id: const Uuid().v4(),
      title: titleController.text,
      slug: slugController.text,
      content: _serializeContent(),
      authorId: user.id,
      authorName: user.displayName,
      status: AppConstants.statusDraft,
      createdAt: now,
      updatedAt: now,
    )).copyWith(
      title: titleController.text,
      slug: slugController.text,
      content: _serializeContent(),
      duration: int.tryParse(durationController.text) ?? 0,
      updatedAt: now,
      stage: nextStage ?? existingStory?.stage,
      version: newVersion,
      attachments: attachments.toList(),
      category: selectedCategory.value,
      assignedToId: existingStory?.assignedToId,
      assignedToName: existingStory?.assignedToName,
    );

    final success = existingStory != null 
        ? await _storyService.updateStory(story)
        : await _storyService.createStory(story) != null;

    if (success) {
      existingStory = story;
      lastSaved.value = now;
      
      if (existingStory!.version > 1) {
        versionText.value = 'Version ${existingStory!.version}';
      } else {
        versionText.value = 'First Version';
      }

      if (!isAutoSave) {
        Get.snackbar(
          'Saved', 
          'Story saved successfully.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withValues(alpha: 0.1),
          colorText: Colors.green.shade800,
        );
      }
    } else if (!isAutoSave) {
      Get.snackbar(
        'Error', 
        'Failed to save story.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.1),
        colorText: Colors.red,
      );
    }

    isSaving.value = false;
    if (!isAutoSave) {
      isLoading.value = false;
      if (success) {
        Get.back();
      }
    }
  }

  void handleNew() {
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Create New Story?', style: TextStyle(color: Color(0xFF1A237E), fontWeight: FontWeight.bold)),
        content: const Text('If you have unsaved changes in this story, they will be auto-saved.', style: TextStyle(color: Color(0xFF263238))),
        actions: [
          TextButton(
            onPressed: () => Get.back(), 
            child: const Text('Cancel', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          ),
          TextButton(
            onPressed: () {
              Get.back(); // close dialog
              autoSave(); // auto save current
              Get.back(); // exit current editor
              Get.find<StoryController>().createNewStory();
            }, 
            child: const Text('Proceed', style: TextStyle(color: Color(0xFF1A237E), fontWeight: FontWeight.bold)),
          ),
        ],
      )
    );
  }

  Future<void> handleCopy() async {
    if (existingStory == null) {
      Get.snackbar('Cannot Copy', 'Please save the story first before copying.', snackPosition: SnackPosition.BOTTOM);
      return;
    }
    isLoading.value = true;
    try {
      final copy = existingStory!.copyWith(
        id: const Uuid().v4(),
        title: '${existingStory!.title} (Copy)',
        status: AppConstants.statusDraft,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await _storyService.createStory(copy);
      Get.snackbar('Copied', 'Story copied successfully.', snackPosition: SnackPosition.BOTTOM);
      // Close current editor, open the copy
      Get.back();
      Get.toNamed('/story/editor', arguments: copy);
    } catch (e) {
      Get.snackbar('Error', 'Failed to copy story.', snackPosition: SnackPosition.BOTTOM);
    }
    isLoading.value = false;
  }

  Future<void> handleDelete() async {
    if (existingStory == null) {
      Get.back(); // It's a new, unsaved story. Just close the editor.
      return;
    }

    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Delete Story', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
        content: const Text('Are you sure you want to delete this story? This action cannot be undone.', style: TextStyle(color: Color(0xFF263238))),
        actions: [
          TextButton(
            onPressed: () => Get.back(), 
            child: const Text('Cancel', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () async {
              Get.back(); // hide dialog
              isLoading.value = true;
              try {
                await _storyService.deleteStory(existingStory!.id);
                isLoading.value = false;
                Get.back(); // exit editor
                Get.snackbar('Deleted', 'Story has been deleted.', snackPosition: SnackPosition.BOTTOM);
              } catch (e) {
                isLoading.value = false;
                Get.snackbar('Error', 'Failed to delete story.', snackPosition: SnackPosition.BOTTOM);
              }
            }, 
            child: const Text('Delete'),
          ),
        ],
      )
    );
  }

  Future<void> showAssignDialog() async {
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Assign Story', style: TextStyle(color: Color(0xFF1A237E), fontWeight: FontWeight.bold)),
        content: SizedBox(
          width: 300,
          child: StreamBuilder<List<UserModel>>(
            stream: _authService.getUsersStream(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final users = snapshot.data ?? [];
              return ListView.builder(
                shrinkWrap: true,
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFF1A237E).withValues(alpha: 0.1),
                      child: Text(user.displayName[0].toUpperCase(), style: const TextStyle(color: Color(0xFF1A237E))),
                    ),
                    title: Text(user.displayName, style: const TextStyle(color: Color(0xFF263238), fontWeight: FontWeight.bold)),
                    subtitle: Text(user.role, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                    onTap: () {
                      Get.back();
                      assignStory(user);
                    },
                  );
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Close', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          ),
        ],
      )
    );
  }

  Future<void> assignStory(UserModel user) async {
    if (existingStory == null) {
      Get.snackbar('Error', 'Save the story before assigning.');
      return;
    }

    try {
      final updatedStory = existingStory!.copyWith(
        assignedToId: user.id,
        assignedToName: user.displayName,
        updatedAt: DateTime.now(),
      );
      
      await _storyService.updateStory(updatedStory);
      existingStory = updatedStory;

      // Send notification
      final currentUser = _authService.currentUser.value;
      await _notificationService.sendNotification(NotificationModel(
        id: const Uuid().v4(),
        userId: user.id,
        type: 'story_update',
        title: 'Story Assigned',
        message: '${currentUser?.displayName ?? "Someone"} assigned you the story: "${updatedStory.title}"',
        createdAt: DateTime.now(),
        actionUrl: '${AppRoutes.storyEditor}?id=${updatedStory.id}',
        data: {'storyId': updatedStory.id},
      ));

      Get.snackbar('Assigned', 'Story assigned to ${user.displayName}');
    } catch (e) {
      Get.snackbar('Error', 'Failed to assign story: $e');
    }
  }

  void showComingSoon(String feature) {
    Get.snackbar(
      '$feature Pending', 
      'The $feature module is currently under active development and will be available soon.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.blue.withValues(alpha: 0.1),
      colorText: Colors.blue.shade900,
      duration: const Duration(seconds: 3),
    );
  }

  void addAttachment(AttachmentModel attachment) {
    attachments.add(attachment);
    saveStory(isAutoSave: true);
  }

  void removeAttachment(String attachmentId) {
    attachments.removeWhere((a) => a.id == attachmentId);
    saveStory(isAutoSave: true);
  }

  Future<void> approveStory() async {
    if (existingStory == null) {
      Get.snackbar('Error', 'Cannot approve a new story. Please save first.', snackPosition: SnackPosition.BOTTOM);
      return;
    }
    
    isLoading.value = true;
    try {
      await saveStory(isAutoSave: true);
      final success = await _storyService.approveStory(existingStory!.id);
      if (success) {
        Get.back();
      }
    } catch (e) {
      // Error handled by service
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> submitStory() async {
    if (existingStory == null) {
      Get.snackbar('Error', 'Please save the story as a draft first before submitting.', snackPosition: SnackPosition.BOTTOM);
      return;
    }

    isLoading.value = true;
    try {
      // Auto-save any changes before submitting
      await saveStory(isAutoSave: true);
      
      final success = await _storyService.submitStory(existingStory!.id);
      if (success) {
        // Refresh local state
        final updatedStory = await _storyService.getStoryById(existingStory!.id);
        if (updatedStory != null) {
          existingStory = updatedStory;
        }
        Get.back(); // exit editor or just refresh? Usually NRCS exit after submission
      }
    } catch (e) {
      // Error handled by service
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    _autoSaveTimer?.cancel();
    titleController.dispose();
    slugController.dispose();
    durationController.dispose();
    anchorQuillController.dispose();
    notesQuillController.dispose();
    super.onClose();
  }
}
