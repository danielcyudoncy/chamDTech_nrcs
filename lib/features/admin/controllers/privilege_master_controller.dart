import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:chamdtech_nrcs/features/admin/models/role_model.dart';
import 'package:chamdtech_nrcs/features/admin/services/privilege_service.dart';
import 'package:chamdtech_nrcs/features/auth/models/user_model.dart';
import 'package:uuid/uuid.dart';
import 'dart:async';

class PrivilegeMasterController extends GetxController {
  final PrivilegeService _service = Get.put(PrivilegeService());

  var roles = <Role>[].obs;
  var selectedRole = Rxn<Role>();
  var isEditing = false.obs;
  var nameController = TextEditingController();
  var descriptionController = TextEditingController();
  var parentRoleId = Rxn<String>();
  var searchQuery = ''.obs;
  var selectedCategory = 'Content Management'.obs;
  var activeView = 'Permissions'.obs;
  var usersInRole = <UserModel>[].obs;
  StreamSubscription? _usersSubscription;

  // Reactive map for checkboxes: Category -> Group -> Permission -> Boolean
  // Structure: { category: { group: { permission: value } } }
  var permissionsState = <String, Map<String, Map<String, bool>>>{}.obs;

  final List<String> categories = [
    'Content Management',
    'Rundown Operations',
    'Newsroom Director',
    'System Administration',
    'Reporting & Analytics',
    'Technical Operations',
  ];

  @override
  void onInit() {
    super.onInit();
    roles.bindStream(_service.getRoles());
    resetPermissions();
  }

  void resetPermissions() {
    permissionsState.value = {
      'Content Management': {
        'Story Operations': {
          'Create': false,
          'Edit': false,
          'Delete': false,
          'Move': false,
          'Copy': false,
          'Link': false,
          'Archive': false,
        },
        'Comments': {
          'View': false,
          'Add': false,
          'Delete': false,
        },
        'Metadata': {
          'Edit Tags': false,
          'Change State': false,
        },
      },
      'Rundown Operations': {
        'Rundown Basics': {
          'View': false,
          'Create': false,
          'Edit': false,
          'Delete': false,
        },
        'Morning Shift': {
          'View': false, 'New': false, 'Delete': false, 'Copy': false, 'Move': false, 'Link': false, 'Edit': false,
        },
        'Afternoon Shift': {
          'View': false, 'New': false, 'Delete': false, 'Copy': false, 'Move': false, 'Link': false, 'Edit': false,
        },
        'Evening Shift': {
          'View': false, 'New': false, 'Delete': false, 'Copy': false, 'Move': false, 'Link': false, 'Edit': false,
        },
      },
      'Newsroom Director': {
        'Director Control': {
          'On Air Control': false,
          'Next Story Trigger': false,
          'Camera Switching': false,
          'MOS Control': false,
        },
        'Broadcast Settings': {
          'Channel Config': false,
          'Live Ticker Edit': false,
          'Emergency Alert': false,
        },
      },
      'System Administration': {
        'User Management': {
          'View Users': false,
          'Create Users': false,
          'Edit Users': false,
          'Delete Users': false,
          'Assign Roles': false,
        },
        'System Sync': {
          'MOS Devices': false,
          'Device Control': false,
          'System Configurations': false,
        },
      },
      'Reporting & Analytics': {
        'Reports': {
          'Rundown Reports': false,
          'User Activity': false,
          'Story Ratings': false,
          'Stringer Payments': false,
        },
      },
      'Technical Operations': {
        'Workflow': {
          'Script Editing': false,
          'Device Management': false,
          'Locations': false,
          'Designations': false,
          'Format Management': false,
          'Sub Format': false,
          'Modify Permissions': false,
        },
        'Social Integration': {
          'Twitter': false,
          'Facebook': false,
        },
      }
    };
  }

  void selectRole(Role? role) {
    selectedRole.value = role;
    _usersSubscription?.cancel();
    usersInRole.clear();

    if (role != null) {
      nameController.text = role.name;
      descriptionController.text = role.description ?? '';
      parentRoleId.value = role.parentId;
      
      // Load users
      _usersSubscription = _service.getUsersInRole(role.id).listen((users) {
        usersInRole.value = users;
      });

      // Reset first then merge
      resetPermissions();
      var newState = Map<String, Map<String, Map<String, bool>>>.from(permissionsState);
      
      role.permissions.forEach((category, groups) {
        if (newState.containsKey(category)) {
          groups.forEach((group, perms) {
            if (newState[category]!.containsKey(group)) {
              newState[category]![group]!.addAll(perms);
            } else {
              newState[category]![group] = Map<String, bool>.from(perms);
            }
          });
        }
      });
      permissionsState.value = newState;
      isEditing.value = true;
    } else {
      createNewRole();
    }
  }

  @override
  void onClose() {
    _usersSubscription?.cancel();
    super.onClose();
  }

  void onParentRoleChanged(String? newParentId) {
    if (newParentId == selectedRole.value?.id) return; // Prevent self-inheritance

    parentRoleId.value = newParentId;
    if (newParentId != null) {
      final parentRole = roles.firstWhereOrNull((r) => r.id == newParentId);
      if (parentRole != null) {
        _mergeParentPermissions(parentRole);
      }
    }
  }

  void _mergeParentPermissions(Role parentRole) {
    var newState = Map<String, Map<String, Map<String, bool>>>.from(permissionsState);
    
    parentRole.permissions.forEach((category, groups) {
      if (newState.containsKey(category)) {
        groups.forEach((group, perms) {
          if (newState[category]!.containsKey(group)) {
            // Only override if child currently has 'false' (inheritance)
            // or just merge everything from parent as a base
            perms.forEach((key, value) {
                if (value == true) {
                  newState[category]![group]![key] = true;
                }
            });
          }
        });
      }
    });
    permissionsState.value = newState;
  }

  void createNewRole() {
    selectedRole.value = null;
    nameController.clear();
    descriptionController.clear();
    parentRoleId.value = null;
    resetPermissions();
    isEditing.value = true;
  }

  void togglePermission(String category, String group, String permission) {
    var newState = Map<String, Map<String, Map<String, bool>>>.from(permissionsState);
    bool current = newState[category]![group]![permission] ?? false;
    newState[category]![group]![permission] = !current;
    
    // Dependency logic: If 'Edit', 'Create', or 'Delete' is enabled, 'View' should be enabled
    if (!current && (permission == 'Edit' || permission == 'Create' || permission == 'Delete' || permission == 'Assign Roles' || permission == 'Move' || permission == 'Add')) {
      if (newState[category]![group]!.containsKey('View')) {
        newState[category]![group]!['View'] = true;
      }
      if (newState[category]![group]!.containsKey('View Users')) {
        newState[category]![group]!['View Users'] = true;
      }
    }

    permissionsState.value = newState;
  }

  void toggleGroup(String category, String group) {
    var newState = Map<String, Map<String, Map<String, bool>>>.from(permissionsState);
    bool allSelected = newState[category]![group]!.values.every((v) => v);
    newState[category]![group]!.updateAll((key, value) => !allSelected);
    permissionsState.value = newState;
  }

  void toggleCategory(String category) {
    var newState = Map<String, Map<String, Map<String, bool>>>.from(permissionsState);
    bool allSelected = newState[category]!.values.every((group) => group.values.every((v) => v));
    newState[category]!.forEach((groupName, perms) {
      perms.updateAll((key, value) => !allSelected);
    });
    permissionsState.value = newState;
  }

  Future<void> save() async {
    if (nameController.text.isEmpty) {
      Get.snackbar('Error', 'Please provide a role name');
      return;
    }

    try {
      final role = Role(
        id: selectedRole.value?.id ?? const Uuid().v4(),
        name: nameController.text.trim(),
        description: descriptionController.text.trim(),
        parentId: parentRoleId.value,
        permissions: Map<String, Map<String, Map<String, bool>>>.from(permissionsState),
        updatedAt: DateTime.now(),
        createdAt: selectedRole.value?.createdAt ?? DateTime.now(),
        updatedBy: 'Admin', // In a real app, get current user ID
      );

      await _service.saveRole(
        role, 
        adminId: 'current-admin-id', 
        adminName: 'Admin', 
        prevRole: selectedRole.value
      );
      
      Get.snackbar('Success', 'Role saved successfully');
      isEditing.value = false;
    } catch (e) {
      Get.snackbar('Error', 'Failed to save: $e');
    }
  }

  Future<void> deleteRole(String id, String name) async {
    try {
      await _service.deleteRole(id, adminId: 'current-admin-id', adminName: 'Admin', roleName: name);
      if (selectedRole.value?.id == id) {
        createNewRole();
        isEditing.value = false;
      }
      Get.snackbar('Success', 'Role deleted');
    } catch (e) {
      Get.snackbar('Error', 'Delete failed: $e');
    }
  }
}
