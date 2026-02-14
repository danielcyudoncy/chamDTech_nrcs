import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:chamDTech_nrcs/features/stories/models/story_model.dart';
import 'package:chamDTech_nrcs/core/models/attachment_model.dart';
import 'package:chamDTech_nrcs/features/stories/services/story_service.dart';
import 'package:chamDTech_nrcs/features/auth/services/auth_service.dart';
import 'package:chamDTech_nrcs/core/constants/app_constants.dart';
import 'package:uuid/uuid.dart';

class StoryEditorController extends GetxController {
  final StoryService _storyService = Get.find<StoryService>();
  final AuthService _authService = Get.find<AuthService>();

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
  
  StoryModel? existingStory;
  Timer? _autoSaveTimer;

  // Get current user for permission checks
  get currentUser => _authService.currentUser.value;

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
      
      // Load attachments
      attachments.assignAll(existingStory!.attachments);
      
      // Load content
      _loadContent(existingStory!.content);
    } else {
      anchorQuillController = quill.QuillController.basic();
      notesQuillController = quill.QuillController.basic();
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

    if (!isAutoSave) isLoading.value = true;
    isSaving.value = true;

    final user = _authService.currentUser.value;
    if (user == null) return;

    final now = DateTime.now();
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
      attachments: attachments.toList(),
    );

    final success = existingStory != null 
        ? await _storyService.updateStory(story)
        : await _storyService.createStory(story) != null;

    if (success) {
      existingStory = story;
      lastSaved.value = now;
    }

    isSaving.value = false;
    if (!isAutoSave) {
      isLoading.value = false;
      Get.back();
    }
  }

  void addAttachment(AttachmentModel attachment) {
    attachments.add(attachment);
    saveStory(isAutoSave: true);
  }

  void removeAttachment(String attachmentId) {
    attachments.removeWhere((a) => a.id == attachmentId);
    saveStory(isAutoSave: true);
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
