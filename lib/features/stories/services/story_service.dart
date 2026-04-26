// features/stories/services/story_service.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:get/get.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:chamdtech_nrcs/core/constants/app_constants.dart';
import 'package:chamdtech_nrcs/core/services/firebase_service.dart';
import 'package:chamdtech_nrcs/features/stories/models/story_model.dart';
import 'package:chamdtech_nrcs/features/auth/services/auth_service.dart';
import 'package:chamdtech_nrcs/core/models/activity_log_model.dart';
import 'package:chamdtech_nrcs/core/services/activity_log_service.dart';
import 'package:uuid/uuid.dart';
import 'package:chamdtech_nrcs/features/auth/models/user_model.dart';
import 'package:chamdtech_nrcs/core/services/notification_service.dart';
import 'package:chamdtech_nrcs/app/routes/app_routes.dart';
import 'package:chamdtech_nrcs/features/rundowns/services/rundown_service.dart';

class StoryService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseService.firestore;
  final FirebaseDatabase _database = FirebaseService.database;

  final AuthService _authService = Get.find<AuthService>();
  final ActivityLogService _activityLogService = Get.put(ActivityLogService());
  final NotificationService _notificationService =
      Get.find<NotificationService>();

  // Get stories by category
  Stream<List<StoryModel>> getStoriesByCategory(String category) {
    return _firestore
        .collection(AppConstants.storiesCollection)
        .where('category', isEqualTo: category)
        .snapshots()
        .map((snapshot) {
      final docs =
          snapshot.docs.map((doc) => StoryModel.fromJson(doc.data())).toList();
      docs.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      return docs;
    });
  }

  // Get all stories
  Stream<List<StoryModel>> getStories() {
    return _firestore
        .collection(AppConstants.storiesCollection)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => StoryModel.fromJson(doc.data()))
            .toList());
  }

  // Lock a story for editing
  Future<bool> lockStory(String storyId) async {
    final user = _authService.currentUser.value;
    if (user == null) return false;

    try {
      final lockRef = _database.ref('${AppConstants.storyLocksPath}/$storyId');
      final snapshot = await lockRef.get();

      if (snapshot.exists) {
        final lockData = Map<String, dynamic>.from(snapshot.value as Map);
        if (lockData['userId'] == user.id) return true; // Already locked by me

        // Potential takeover check
        // This is handled via takeoverStory specifically
        return false;
      }

      await lockRef.set({
        'userId': user.id,
        'userName': user.displayName,
        'role': user.role,
        'lockedAt': ServerValue.timestamp,
      });

      // Also update Firestore for persistent state
      await _firestore
          .collection(AppConstants.storiesCollection)
          .doc(storyId)
          .update({
        'lockedBy': user.id,
        'lockedAt': FieldValue.serverTimestamp(),
      });

      // Cleanup on disconnect
      lockRef.onDisconnect().remove();

      return true;
    } catch (e) {
      return false;
    }
  }

  // Release story lock
  Future<void> releaseStory(String storyId) async {
    final user = _authService.currentUser.value;
    if (user == null) return;

    try {
      final lockRef = _database.ref('${AppConstants.storyLocksPath}/$storyId');
      final snapshot = await lockRef.get();

      if (snapshot.exists) {
        final lockData = Map<String, dynamic>.from(snapshot.value as Map);
        if (lockData['userId'] == user.id) {
          await lockRef.remove();
          await _firestore
              .collection(AppConstants.storiesCollection)
              .doc(storyId)
              .update({
            'lockedBy': null,
            'lockedAt': null,
          });
        }
      }
    } catch (e) {
      Get.log('Error releasing story lock: $e');
    }
  }

  // Hierarchical takeover
  Future<bool> takeoverStory(String storyId) async {
    final currentUser = _authService.currentUser.value;
    if (currentUser == null) return false;

    try {
      final lockRef = _database.ref('${AppConstants.storyLocksPath}/$storyId');
      final snapshot = await lockRef.get();

      if (snapshot.exists) {
        final lockData = Map<String, dynamic>.from(snapshot.value as Map);

        // Fetch current owner's role from Firestore or use the one in lockData
        final ownerRole = lockData['role'] ?? 'reporter';

        // Use a temp user model to compare hierarchy
        final ownerTemp = UserModel(
          id: lockData['userId'],
          email: '',
          displayName: lockData['userName'] ?? 'Unknown',
          role: ownerRole,
          createdAt: DateTime.now(),
        );

        if (currentUser.canTakeOver(ownerTemp)) {
          // Force lock
          await lockRef.set({
            'userId': currentUser.id,
            'userName': currentUser.displayName,
            'role': currentUser.role,
            'lockedAt': ServerValue.timestamp,
          });

          await _firestore
              .collection(AppConstants.storiesCollection)
              .doc(storyId)
              .update({
            'lockedBy': currentUser.id,
            'lockedAt': FieldValue.serverTimestamp(),
          });

          return true;
        }
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Get stories by desk
  Stream<List<StoryModel>> getStoriesByDesk(String deskId) {
    return _firestore
        .collection(AppConstants.storiesCollection)
        .where('deskId', isEqualTo: deskId)
        .snapshots()
        .map((snapshot) {
      final docs =
          snapshot.docs.map((doc) => StoryModel.fromJson(doc.data())).toList();
      docs.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      return docs;
    });
  }

  // Get my stories
  Stream<List<StoryModel>> getMyStories() {
    final userId = _authService.currentUser.value?.id;
    if (userId == null) return Stream.value([]);

    return _firestore
        .collection(AppConstants.storiesCollection)
        .where('authorId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      final docs =
          snapshot.docs.map((doc) => StoryModel.fromJson(doc.data())).toList();
      docs.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      return docs;
    });
  }

  // Get story by ID
  Future<StoryModel?> getStoryById(String storyId) async {
    try {
      final doc = await _firestore
          .collection(AppConstants.storiesCollection)
          .doc(storyId)
          .get();

      if (doc.exists) {
        return StoryModel.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      Get.log('Error getting story: $e');
      return null;
    }
  }

  // Create story
  Future<String?> createStory(StoryModel story) async {
    try {
      await _firestore
          .collection(AppConstants.storiesCollection)
          .doc(story.id)
          .set(story.toJson());

      Get.snackbar(
        'Success',
        'Story created successfully',
        snackPosition: SnackPosition.BOTTOM,
      );

      // Log creation
      final user = _authService.currentUser.value;
      if (user != null) {
        await _activityLogService.logActivity(ActivityLogModel.storyCreated(
          id: const Uuid().v4(),
          userId: user.id,
          userName: user.displayName,
          storyId: story.id,
          storyTitle: story.title,
        ));
      }

      // Broadcast notification
      if (user != null) {
        await _notificationService.broadcastNotification(
          title: 'New Story Created',
          message: '${user.displayName} created a new story: "${story.title}"',
          type: 'story_update',
          actionUrl: '${AppRoutes.storyEditor}?id=${story.id}',
          data: {'storyId': story.id},
        );
      }

      return story.id;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to create story: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
      return null;
    }
  }

  // Update story — with branched editing for editors to preserve original scripts
  Future<String?> updateStory(StoryModel story) async {
    final currentUser = _authService.currentUser.value;
    if (currentUser == null) return null;

    try {
      // ── Branching Logic for Editors/Producers ────────────────────────────────
      // We branch if:
      // 1. Current user is an Editor, Admin, or Producer
      // 2. They are NOT the author of the story
      // 3. This is an ORIGINAL story (parentStoryId is null)
      bool isStaff = currentUser.role == AppConstants.roleEditor ||
          currentUser.role == AppConstants.roleAdmin ||
          currentUser.role == AppConstants.roleProducer;
      bool isNotAuthor = story.authorId != currentUser.id;

      if (isStaff && isNotAuthor && story.parentStoryId == null) {
        // Redirect the save to the re-edited copy instead of the original
        // This ensures the original script remains exactly as sent by the reporter
        Get.log(
            'Branching save for story ${story.id} (Author: ${story.authorId}, User: ${currentUser.id})');
        final copyId =
            await _handleEditorApprovalCopy(story, isFinalApproval: false);
        return copyId;
      }
      // ────────────────────────────────────────────────────────────────────────

      // ── Standard Update Logic ───────────────────────────────────────────────
      // Final safeguard: If we are somehow still trying to update an original story
      // that isn't ours, block content updates.
      if (isStaff && isNotAuthor && story.parentStoryId == null) {
        Get.log('Blocking accidental original update for story ${story.id}');
        return await _handleEditorApprovalCopy(story, isFinalApproval: false);
      }

      // Backend guard check (with local try-catch for permissions)
      if (story.linkedRundownId != null && story.linkedRundownId!.isNotEmpty) {
        try {
          final rundownDoc = await _firestore
              .collection(AppConstants.rundownsCollection)
              .doc(story.linkedRundownId)
              .get();
          if (rundownDoc.exists) {
            final status = rundownDoc.data()?['status'] ?? 'draft';
            if (status == 'locked' || status == 'on-air') {
              Get.snackbar(
                'Editing Blocked',
                'This story is part of a locked rundown and cannot be edited.',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.red.shade50,
                colorText: Colors.red.shade900,
              );
              return null;
            }
          }
        } catch (e) {
          Get.log(
              'Note: Permission error checking rundown ${story.linkedRundownId}.');
        }
      }

      await _firestore
          .collection(AppConstants.storiesCollection)
          .doc(story.id)
          .set(story.toJson(), SetOptions(merge: true));
      return story.id;
    } catch (e) {
      Get.log('Error in updateStory: $e');
      Get.snackbar(
        'Error',
        'Failed to update story: ${e.toString().split(']').last.trim()}',
        snackPosition: SnackPosition.BOTTOM,
      );
      return null;
    }
  }

  // Archive story (soft delete)
  Future<bool> archiveStory(String storyId) async {
    try {
      await _firestore
          .collection(AppConstants.storiesCollection)
          .doc(storyId)
          .update({
        'status': AppConstants.statusArchived,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      Get.snackbar(
        'Success',
        'Story moved to archive',
        snackPosition: SnackPosition.BOTTOM,
      );

      // Log archiving
      final user = _authService.currentUser.value;
      if (user != null) {
        await _activityLogService.logActivity(ActivityLogModel(
          id: const Uuid().v4(),
          userId: user.id,
          userName: user.displayName,
          action: 'archive',
          entityType: 'story',
          entityId: storyId,
          description: 'Archived story',
          timestamp: DateTime.now(),
        ));
      }

      return true;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to archive story: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
  }

  // Delete story (physical delete)
  Future<bool> deleteStory(String storyId) async {
    try {
      await _firestore
          .collection(AppConstants.storiesCollection)
          .doc(storyId)
          .delete();

      Get.snackbar(
        'Success',
        'Story deleted successfully',
        snackPosition: SnackPosition.BOTTOM,
      );

      // Log deletion
      final user = _authService.currentUser.value;
      if (user != null) {
        await _activityLogService.logActivity(ActivityLogModel(
          id: const Uuid().v4(),
          userId: user.id,
          userName: user.displayName,
          action: 'delete',
          entityType: 'story',
          entityId: storyId,
          description: 'Deleted story',
          timestamp: DateTime.now(),
        ));
      }

      return true;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete story: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
  }

  // Approve story
  Future<bool> approveStory(String storyId) async {
    final currentUser = _authService.currentUser.value;
    if (currentUser == null) return false;

    try {
      // Fetch original story data first
      final storyDoc = await _firestore
          .collection(AppConstants.storiesCollection)
          .doc(storyId)
          .get();

      if (!storyDoc.exists) return false;
      final originalStory = StoryModel.fromJson(storyDoc.data()!);

      // Rule: If a script has been approved once and it has been added to rundown,
      // it cannot be approved again.
      if (originalStory.status == AppConstants.statusApproved) {
        final rundownService = Get.find<RundownService>();
        final rundowns = await rundownService.getRundownsForStory(storyId);
        if (rundowns.isNotEmpty) {
          Get.snackbar('Approval Blocked', 'This story is already approved and in a rundown.');
          return false;
        }
      }

      await _firestore
          .collection(AppConstants.storiesCollection)
          .doc(storyId)
          .update({
        'status': AppConstants.statusApproved,
        'stage': AppConstants.stageVerified,
        'approvedBy': currentUser.id,
        'approvedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // If this is a re-edited copy, mark the original as archived so it leaves the editorial queue
      if (originalStory.parentStoryId != null) {
        await _firestore
            .collection(AppConstants.storiesCollection)
            .doc(originalStory.parentStoryId)
            .update({
          'status': AppConstants.statusArchived,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      // ── "Re-edited" Copy Workflow ─────────────────────────────────────────
      // If the approver is staff and NOT the original author
      bool isStaff = currentUser.role == AppConstants.roleEditor ||
          currentUser.role == AppConstants.roleAdmin ||
          currentUser.role == AppConstants.roleProducer;

      if (isStaff &&
          originalStory.authorId != currentUser.id &&
          originalStory.parentStoryId == null) {
        await _handleEditorApprovalCopy(originalStory, isFinalApproval: true);
      }
      // ──────────────────────────────────────────────────────────────────────

      Get.snackbar(
        'Success',
        'Story approved',
        snackPosition: SnackPosition.BOTTOM,
      );

      // Log approval
      final title = originalStory.title;

      await _activityLogService.logActivity(ActivityLogModel.storyApproved(
        id: const Uuid().v4(),
        userId: currentUser.id,
        userName: currentUser.displayName,
        storyId: storyId,
        storyTitle: title,
      ));

      // Notify Creator
      final authorId = originalStory.authorId;
      if (authorId.isNotEmpty) {
        await _notificationService.notifyRelevantUsers(
          userIds: [authorId],
          title: 'Story Approved',
          message:
              'Your story "$title" has been approved by ${currentUser.displayName}',
          type: 'story_update',
          actionUrl: '${AppRoutes.storyEditor}?id=$storyId',
          data: {'storyId': storyId},
        );
      }

      // Notify all Producers
      final producerIds =
          await _authService.getUserIdsByRole(AppConstants.roleProducer);
      if (producerIds.isNotEmpty) {
        await _notificationService.notifyRelevantUsers(
          userIds: producerIds,
          title: 'New Approved Story',
          message:
              'A story "$title" has been approved and is ready for rundown.',
          type: 'story_update',
          actionUrl: '${AppRoutes.storyEditor}?id=$storyId',
          data: {'storyId': storyId},
        );
      }

      return true;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to approve story: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
  }

  /// Handles creating or updating a "re-edited" copy for the original author
  Future<String?> _handleEditorApprovalCopy(StoryModel originalStory,
      {required bool isFinalApproval}) async {
    try {
      // 1. Check if a copy already exists for this original story
      final existingCopies = await _firestore
          .collection(AppConstants.storiesCollection)
          .where('parentStoryId', isEqualTo: originalStory.id)
          .limit(1)
          .get();

      const String reEditedTag = "re-edited by the News editor";
      const String titlePrefix = "[Re-edited] ";
      final String newTitle = originalStory.title.startsWith(titlePrefix)
          ? originalStory.title
          : "$titlePrefix${originalStory.title}";

      // Ensure the tag exists in the list
      List<String> updatedTags = List<String>.from(originalStory.tags);
      if (!updatedTags.contains(reEditedTag)) {
        updatedTags.add(reEditedTag);
      }

      if (existingCopies.docs.isNotEmpty) {
        // 2. Update existing copy
        final copyId = existingCopies.docs.first.id;
        await _firestore
            .collection(AppConstants.storiesCollection)
            .doc(copyId)
            .update({
          'title': newTitle,
          'content': originalStory.content,
          'tags': updatedTags,
          'updatedAt': FieldValue.serverTimestamp(),
          'version': FieldValue.increment(1),
          'status': isFinalApproval
              ? AppConstants.statusApproved
              : originalStory.status,
          'category': originalStory.category,
          'duration': originalStory.duration,
          'attachments':
              originalStory.attachments.map((e) => e.toJson()).toList(),
        });
        return copyId;
      } else {
        // 3. Create new copy
        final newCopyId = const Uuid().v4();
        final newCopy = originalStory.copyWith(
          id: newCopyId,
          title: newTitle,
          parentStoryId: originalStory.id,
          tags: updatedTags,
          updatedAt: DateTime.now(),
          createdAt: DateTime.now(),
          status: isFinalApproval
              ? AppConstants.statusApproved
              : originalStory.status,
        );

        await _firestore
            .collection(AppConstants.storiesCollection)
            .doc(newCopy.id)
            .set(newCopy.toJson());
        return newCopyId;
      }
    } catch (e) {
      Get.log('Error handling editor approval copy: $e');
      return null;
    }
  }

  // Submit story for approval
  Future<bool> submitStory(String storyId) async {
    final userId = _authService.currentUser.value?.id;
    if (userId == null) return false;

    try {
      await _firestore
          .collection(AppConstants.storiesCollection)
          .doc(storyId)
          .update({
        'status': AppConstants.statusPending,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      Get.snackbar(
        'Success',
        'Story submitted for review',
        snackPosition: SnackPosition.BOTTOM,
      );

      // Log submission
      final user = _authService.currentUser.value!;
      final storyDoc = await _firestore
          .collection(AppConstants.storiesCollection)
          .doc(storyId)
          .get();
      final title = storyDoc.data()?['title'] ?? 'Unknown Story';

      await _activityLogService.logActivity(ActivityLogModel(
        id: const Uuid().v4(),
        userId: user.id,
        userName: user.displayName,
        action: 'submit',
        entityType: 'story',
        entityId: storyId,
        description: 'Submitted story for review',
        timestamp: DateTime.now(),
      ));

      // Notify all Editors
      final editorIds =
          await _authService.getUserIdsByRole(AppConstants.roleEditor);
      if (editorIds.isNotEmpty) {
        await _notificationService.notifyRelevantUsers(
          userIds: editorIds,
          title: 'New Story Submitted',
          message: '${user.displayName} submitted a story for review: "$title"',
          type: 'story_update',
          actionUrl: '${AppRoutes.storyEditor}?id=$storyId',
          data: {'storyId': storyId},
        );
      }

      // Notify all Admins
      final adminIds =
          await _authService.getUserIdsByRole(AppConstants.roleAdmin);
      if (adminIds.isNotEmpty) {
        await _notificationService.notifyRelevantUsers(
          userIds: adminIds,
          title: 'New Story Submitted',
          message: '${user.displayName} submitted a story for review: "$title"',
          type: 'story_update',
          actionUrl: '${AppRoutes.storyEditor}?id=$storyId',
          data: {'storyId': storyId},
        );
      }

      return true;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to submit story: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
  }

  // Helper to find a re-edited copy of a story
  Future<StoryModel?> findReEditedCopy(String originalStoryId) async {
    try {
      final snapshot = await _firestore
          .collection(AppConstants.storiesCollection)
          .where('parentStoryId', isEqualTo: originalStoryId)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return StoryModel.fromJson(snapshot.docs.first.data());
      }
      return null;
    } catch (e) {
      Get.log('Error finding re-edited copy: $e');
      return null;
    }
  }

  // Helper to extract text from Quill JSON content
  String getPlainTextFromQuill(String jsonStr) {
    try {
      final decoded = jsonDecode(jsonStr);
      // Try to extract from 'anchor' if it's our split format
      if (decoded is Map &&
          (decoded.containsKey('anchor') || decoded.containsKey('notes'))) {
        String combined = '';
        if (decoded.containsKey('anchor') && decoded['anchor'] is List) {
          final doc = quill.Document.fromJson(decoded['anchor']);
          final text = doc.toPlainText().trim();
          if (text.isNotEmpty) combined += 'REPORT INTRO / ANCHOR:\n$text\n\n';
        }
        if (decoded.containsKey('notes') && decoded['notes'] is List) {
          final doc = quill.Document.fromJson(decoded['notes']);
          final text = doc.toPlainText().trim();
          if (text.isNotEmpty) {
            combined += 'PRODUCTION NOTES / CONTENT:\n$text\n\n';
          }
        }
        if (combined.isNotEmpty) return combined.trim();
      }
      // Otherwise assume it's a standard Quill Delta list
      if (decoded is List || (decoded is Map && decoded.containsKey('ops'))) {
        final doc = quill.Document.fromJson(decoded);
        return doc.toPlainText();
      }
      return jsonStr;
    } catch (e) {
      // Fallback: try to extract any `insert` values from the JSON-like string
      try {
        final matches = RegExp('"insert"s*:s*"([^"]+)"')
            .allMatches(jsonStr)
            .map((m) => m.group(1))
            .where((s) => s != null)
            .cast<String>()
            .toList();
        if (matches.isNotEmpty) return matches.join('\n');

        // Try more tolerant patterns (single quotes, unquoted values)
        final matches2 = RegExp(
                r"'insert'\s*:\s*'([^']+)'|insert\s*:\s*'([^']+)'|insert\s*:\s*([^,\n\}]+)",
                multiLine: true,
                caseSensitive: false)
            .allMatches(jsonStr)
            .map((m) => m.group(1) ?? m.group(2) ?? m.group(3))
            .where((s) => s != null)
            .cast<String>()
            .toList();
        if (matches2.isNotEmpty) return matches2.join('\n');

        // Last resort: remove JSON punctuation to make it more readable
        final stripped = jsonStr
            .replaceAll(RegExp(r'[\{\}\[\]"]'), '')
            .replaceAll(',', '\n');
        return stripped;
      } catch (_) {
        return jsonStr;
      }
    }
  }
}
