// core/services/rbac_service.dart
import 'package:get/get.dart';
import 'package:chamdtech_nrcs/features/auth/services/auth_service.dart';
import 'package:chamdtech_nrcs/features/auth/models/user_model.dart';

/// Role-Based Access Control service.
///
/// Permission keys are stored as:
///   "Category->Group->Permission"  (e.g. "Content Management->Story Operations->Create")
///
/// Admins always bypass all checks.
class RbacService extends GetxService {
  final AuthService _authService = Get.find<AuthService>();

  UserModel? get _user => _authService.currentUser.value;

  // ── Low-level check ────────────────────────────────────────────────────────

  /// Checks a full 3-level key: "Category->Group->Permission"
  bool hasPermission(String category, String group, String permission) {
    final user = _user;
    if (user == null) return false;
    if (user.role == 'admin') return true; // admin bypass

    final key = '$category->$group->$permission';
    return user.permissions[key] ?? false;
  }

  // ── Content Management → Story Operations ─────────────────────────────────

  bool canCreateStory() =>
      hasPermission('Content Management', 'Story Operations', 'Create');

  /// Own-story edit: reporters can always edit their own stories.
  bool canEditStory(String storyAuthorId) {
    final user = _user;
    if (user == null) return false;
    if (user.role == 'admin') return true;
    if (user.id == storyAuthorId) return true; // own story
    return hasPermission('Content Management', 'Story Operations', 'Edit');
  }

  bool canDeleteStory() =>
      hasPermission('Content Management', 'Story Operations', 'Delete');

  bool canArchiveStory() =>
      hasPermission('Content Management', 'Story Operations', 'Archive');

  bool canCopyStory() =>
      hasPermission('Content Management', 'Story Operations', 'Copy');

  bool canMoveStory() =>
      hasPermission('Content Management', 'Story Operations', 'Move');

  bool canLinkStory() =>
      hasPermission('Content Management', 'Story Operations', 'Link');

  // ── Content Management → Metadata ─────────────────────────────────────────

  /// Approve / change story state (e.g., draft → approved)
  bool canChangeStoryState() =>
      hasPermission('Content Management', 'Metadata', 'Change State');

  bool canEditTags() =>
      hasPermission('Content Management', 'Metadata', 'Edit Tags');

  // ── Content Management → Comments ─────────────────────────────────────────

  bool canViewComments() =>
      hasPermission('Content Management', 'Comments', 'View');

  bool canAddComment() =>
      hasPermission('Content Management', 'Comments', 'Add');

  bool canDeleteComment() =>
      hasPermission('Content Management', 'Comments', 'Delete');

  // ── Rundown Operations ─────────────────────────────────────────────────────

  bool canViewRundowns() =>
      hasPermission('Rundown Operations', 'Rundown Basics', 'View');

  bool canCreateRundown() =>
      hasPermission('Rundown Operations', 'Rundown Basics', 'Create');

  bool canEditRundown() =>
      hasPermission('Rundown Operations', 'Rundown Basics', 'Edit');

  bool canDeleteRundown() =>
      hasPermission('Rundown Operations', 'Rundown Basics', 'Delete');

  // ── System Administration → User Management ────────────────────────────────

  bool canViewUsers() =>
      hasPermission('System Administration', 'User Management', 'View Users');

  bool canCreateUsers() =>
      hasPermission('System Administration', 'User Management', 'Create Users');

  bool canEditUsers() =>
      hasPermission('System Administration', 'User Management', 'Edit Users');

  bool canDeleteUsers() =>
      hasPermission('System Administration', 'User Management', 'Delete Users');

  bool canAssignRoles() =>
      hasPermission('System Administration', 'User Management', 'Assign Roles');

  // ── Convenience: is the current user at least a certain role level? ─────────

  bool get isAdmin => _user?.role == 'admin';
  bool get isProducer => _user?.role == 'producer';
  bool get isEditor => _user?.role == 'editor';
  bool get isReporter => _user?.role == 'reporter';
  bool get isAnchor => _user?.role == 'anchor';

  /// Returns true if the user can assign/edit stories belonging to others.
  bool get canManageOthersStories =>
      isAdmin ||
      hasPermission('Content Management', 'Story Operations', 'Edit');
}
