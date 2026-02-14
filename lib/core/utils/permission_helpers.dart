import 'package:chamDTech_nrcs/features/auth/models/user_model.dart';
import 'package:chamDTech_nrcs/features/stories/models/story_model.dart';

class PermissionHelpers {
  // Check if user can edit a specific story
  static bool canEditStory(UserModel? currentUser, StoryModel story) {
    if (currentUser == null) return false;

    // Admin can edit anything
    if (currentUser.role == 'admin') return true;

    // Producer can edit anything
    if (currentUser.role == 'producer') return true;

    // Author can edit their own story
    if (currentUser.id == story.authorId) return true;

    // Check specific permission
    return currentUser.permissions['edit_story'] ?? false;
  }

  // Check if user can approve stories
  static bool canApproveStory(UserModel? currentUser) {
    if (currentUser == null) return false;

    // Admin and producers can approve
    if (['admin', 'producer', 'editor'].contains(currentUser.role)) {
      return true;
    }

    // Check specific permission
    return currentUser.permissions['approve_story'] ?? false;
  }

  // Check if user can delete a story
  static bool canDeleteStory(UserModel? currentUser, StoryModel story) {
    if (currentUser == null) return false;

    // Admin can delete anything
    if (currentUser.role == 'admin') return true;

    // Producer can delete anything
    if (currentUser.role == 'producer') return true;

    // Author can delete their own draft stories
    if (currentUser.id == story.authorId && story.status == 'draft') {
      return true;
    }

    return false;
  }

  // Check if user can manage other users
  static bool canManageUsers(UserModel? currentUser) {
    if (currentUser == null) return false;
    return currentUser.role == 'admin';
  }

  // Check if user can create rundowns
  static bool canCreateRundown(UserModel? currentUser) {
    if (currentUser == null) return false;

    if (['admin', 'producer'].contains(currentUser.role)) {
      return true;
    }

    return currentUser.permissions['create_rundown'] ?? false;
  }

  // Check if user can edit rundowns
  static bool canEditRundown(UserModel? currentUser, String rundownProducerId) {
    if (currentUser == null) return false;

    // Admin can edit anything
    if (currentUser.role == 'admin') return true;

    // Producer who created it can edit
    if (currentUser.id == rundownProducerId) return true;

    // Check specific permission
    return currentUser.permissions['edit_rundown'] ?? false;
  }

  // Check if user can lock/unlock rundowns
  static bool canLockRundown(UserModel? currentUser) {
    if (currentUser == null) return false;

    if (['admin', 'producer'].contains(currentUser.role)) {
      return true;
    }

    return currentUser.permissions['lock_rundown'] ?? false;
  }

  // Check if user can take over a locked story (hierarchy-based)
  static bool canTakeoverStory(UserModel? currentUser, UserModel storyOwner) {
    if (currentUser == null) return false;

    // Admin can always takeover
    if (currentUser.role == 'admin') return true;

    // Use hierarchy index from UserModel
    return currentUser.canTakeOver(storyOwner);
  }

  // Check if user can view story
  static bool canViewStory(UserModel? currentUser, StoryModel story) {
    if (currentUser == null) return false;

    // Everyone can view approved stories
    if (story.status == 'approved') return true;

    // Admin and producers can view anything
    if (['admin', 'producer'].contains(currentUser.role)) {
      return true;
    }

    // Author can view their own stories
    if (currentUser.id == story.authorId) return true;

    return false;
  }

  // Check if user can assign stories
  static bool canAssignStory(UserModel? currentUser) {
    if (currentUser == null) return false;

    if (['admin', 'producer'].contains(currentUser.role)) {
      return true;
    }

    return currentUser.permissions['assign_story'] ?? false;
  }

  // Check if user can manage desks
  static bool canManageDesks(UserModel? currentUser) {
    if (currentUser == null) return false;

    if (['admin', 'producer'].contains(currentUser.role)) {
      return true;
    }

    return currentUser.permissions['manage_desks'] ?? false;
  }

  // Check if user can view analytics
  static bool canViewAnalytics(UserModel? currentUser) {
    if (currentUser == null) return false;

    if (['admin', 'producer'].contains(currentUser.role)) {
      return true;
    }

    return currentUser.permissions['view_analytics'] ?? false;
  }

  // Get user's effective permissions (role + custom permissions)
  static Map<String, bool> getEffectivePermissions(UserModel user) {
    final permissions = Map<String, bool>.from(user.permissions);

    // Add role-based permissions
    if (user.role == 'admin') {
      permissions.addAll({
        'edit_story': true,
        'approve_story': true,
        'delete_story': true,
        'manage_users': true,
        'create_rundown': true,
        'edit_rundown': true,
        'lock_rundown': true,
        'assign_story': true,
        'manage_desks': true,
        'view_analytics': true,
      });
    } else if (user.role == 'producer') {
      permissions.addAll({
        'edit_story': true,
        'approve_story': true,
        'create_rundown': true,
        'edit_rundown': true,
        'lock_rundown': true,
        'assign_story': true,
        'manage_desks': true,
        'view_analytics': true,
      });
    } else if (user.role == 'editor') {
      permissions.addAll({
        'approve_story': true,
      });
    }

    return permissions;
  }
}
