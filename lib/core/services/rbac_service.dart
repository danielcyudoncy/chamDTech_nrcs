import 'package:get/get.dart';
import 'package:chamDTech_nrcs/features/auth/services/auth_service.dart';

class RbacService extends GetxService {
  final AuthService _authService = Get.find<AuthService>();

  bool hasPermission(String permission) {
    final user = _authService.currentUser.value;
    if (user == null) return false;
    
    // Super admin shortcut
    if (user.role == 'admin') return true;
    
    return user.permissions[permission] ?? false;
  }

  bool canEditStory(String storyAuthorId) {
    final user = _authService.currentUser.value;
    if (user == null) return false;
    
    if (user.role == 'admin') return true;
    if (hasPermission('Rundown', 'Story Edit')) return true;
    return user.id == storyAuthorId;
  }

  bool canApproveStory() {
    return hasPermission('Script', 'Script Verify');
  }

  bool canManageUsers() {
    return hasPermission('Settings', 'Users');
  }
}
