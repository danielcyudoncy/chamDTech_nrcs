import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:chamDTech_nrcs/features/admin/models/privilege_set_model.dart';
import 'package:chamDTech_nrcs/features/admin/services/privilege_service.dart';
import 'package:uuid/uuid.dart';

class PrivilegeMasterController extends GetxController {
  final PrivilegeService _service = Get.put(PrivilegeService());

  var privilegeSets = <PrivilegeSet>[].obs;
  var selectedSet = Rxn<PrivilegeSet>();
  var isEditing = false.obs;
  var nameController = TextEditingController();
  var searchQuery = ''.obs;

  // Reactive map for checkboxes: Group -> Item -> Boolean
  var activePrivileges = <String, Map<String, bool>>{}.obs;

  @override
  void onInit() {
    super.onInit();
    privilegeSets.bindStream(_service.getPrivilegeSets());
    
    // Initialize default structure
    resetPrivileges();
  }

  void resetPrivileges() {
    activePrivileges.value = {
      'Wire': {'Comments': false},
      'Rundown': {
        'Rundown View': false,
        'Rundown Create': false,
        'Rundown Edit': false,
        'Rundown Delete': false,
        'Story Create': false,
        'Story Edit': false,
        'Story Delete': false,
        'Story Skip': false,
        'Story Move': false,
        'Story Copy': false,
        'Story Link': false,
        'Onair/Offair': false,
        'MOS Sync': false,
        'Lock/Unlock': false,
        'Story Reorder': false,
        'Master': false,
        'Download Script': false,
        'Print Story': false,
      },
      'Script': {
        'Script Edit': false,
        'Attach/Order Clips': false,
        'Attach/Order CG': false,
        'Script Verify': false,
        'Story Take over': false,
        'Story Rating': false,
      },
      'Miscellaneous': {
        'Media': false,
        'Trash': false,
        'Breaking': false,
        'Breaking -> Producer': false,
        'Breaking -> Anchor': false,
      },
      'Social': {
        'Twitter': false,
        'Facebook': false,
      },
      'Reports': {
        'Rundowns Reports': false,
        'User Reports': false,
        'Stringer Reports': false,
        'Story Ratings Reports': false,
      },
      'Settings': {
        'Users': false,
        'Audit Trail': false,
        'Privileges Master': false,
        'Desks': false,
        'Wires': false,
        'Story State': false,
        'Show Template': false,
        'Show Master': false,
        'MOS Devices': false,
        'Locations': false,
        'Stringers': false,
        'Designations': false,
        'Format': false,
        'Sub Format': false,
        'Configurations': false,
        'System Configurations': false,
        'Modify': false,
      },
      'Desk': {
        'View': false,
        'New': false,
        'Delete': false,
        'Copy': false,
        'Move': false,
        'Link': false,
        'Edit': false,
      }
    };
  }

  void selectSet(PrivilegeSet? set) {
    selectedSet.value = set;
    if (set != null) {
      nameController.text = set.name;
      // Merge set privileges into activePrivileges
      final newPrivs = Map<String, Map<String, bool>>.from(activePrivileges);
      set.privileges.forEach((group, items) {
        if (newPrivs.containsKey(group)) {
          final castedItems = Map<String, dynamic>.from(items);
          castedItems.forEach((key, value) {
            if (newPrivs[group]!.containsKey(key)) {
              newPrivs[group]![key] = value as bool;
            }
          });
        }
      });
      activePrivileges.value = newPrivs;
      isEditing.value = true;
    } else {
      createNewSet();
    }
  }

  void createNewSet() {
    selectedSet.value = null;
    nameController.clear();
    resetPrivileges();
    isEditing.value = true;
  }

  void togglePrivilege(String group, String item) {
    var newMap = Map<String, Map<String, bool>>.from(activePrivileges);
    newMap[group]![item] = !(newMap[group]![item] ?? false);
    activePrivileges.value = newMap;
  }

  void toggleGroup(String group) {
    var newMap = Map<String, Map<String, bool>>.from(activePrivileges);
    bool allSelected = newMap[group]!.values.every((v) => v);
    newMap[group]!.updateAll((key, value) => !allSelected);
    activePrivileges.value = newMap;
  }

  Future<void> save() async {
    if (nameController.text.isEmpty) {
      Get.snackbar('Error', 'Please provide a name for the privilege set');
      return;
    }

    try {
      final set = PrivilegeSet(
        id: selectedSet.value?.id ?? const Uuid().v4(),
        name: nameController.text.trim(),
        privileges: activePrivileges,
        updatedAt: DateTime.now(),
        createdAt: selectedSet.value?.createdAt ?? DateTime.now(),
      );

      await _service.savePrivilegeSet(set);
      Get.snackbar('Success', 'Privilege set saved successfully');
      isEditing.value = false;
    } catch (e) {
      Get.snackbar('Error', 'Failed to save: $e');
    }
  }

  Future<void> deleteSet(String id) async {
    try {
      await _service.deletePrivilegeSet(id);
      if (selectedSet.value?.id == id) {
        createNewSet();
        isEditing.value = false;
      }
      Get.snackbar('Success', 'Set deleted');
    } catch (e) {
      Get.snackbar('Error', 'Delete failed: $e');
    }
  }
}
