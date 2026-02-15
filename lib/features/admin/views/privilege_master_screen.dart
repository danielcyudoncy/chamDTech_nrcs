import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:chamDTech_nrcs/features/admin/controllers/privilege_master_controller.dart';
import 'package:chamDTech_nrcs/features/admin/models/privilege_set_model.dart';
import 'package:chamDTech_nrcs/features/stories/views/widgets/nrcs_layout.dart';

class PrivilegeMasterScreen extends StatelessWidget {
  const PrivilegeMasterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PrivilegeMasterController());

    return NRCSAppShell(
      body: Row(
        children: [
          // Sidebar
          _buildSidebar(controller),
          const VerticalDivider(width: 1),
          // Form Area
          Expanded(
            child: Obx(() => controller.isEditing.value
                ? _buildForm(controller, context)
                : const Center(child: Text('Select or create a privilege set'))),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar(PrivilegeMasterController controller) {
    return Container(
      width: 250,
      color: Colors.grey[50],
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (v) => controller.searchQuery.value = v,
              decoration: InputDecoration(
                hintText: 'Search...',
                prefixIcon: const Icon(Icons.search, size: 20),
                isDense: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
          Expanded(
            child: Obx(() {
              final sets = controller.privilegeSets.where((s) =>
                  s.name.toLowerCase().contains(controller.searchQuery.value.toLowerCase())).toList();
              return ListView.builder(
                itemCount: sets.length,
                itemBuilder: (context, index) {
                  final set = sets[index];
                  return Obx(() => ListTile(
                        selected: controller.selectedSet.value?.id == set.id,
                        title: Text(set.name),
                        onTap: () => controller.selectSet(set),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline, size: 20, color: Colors.red),
                          onPressed: () => _confirmDelete(context, controller, set),
                        ),
                      ));
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildForm(PrivilegeMasterController controller, BuildContext context) {
    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller.nameController,
                  decoration: const InputDecoration(
                    labelText: 'Privilege Set Name *',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: () => controller.save(),
                icon: const Icon(Icons.save),
                label: const Text('Save Changes'),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        // Grouped Checkboxes
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Wrap(
              spacing: 16,
              runSpacing: 16,
              children: controller.activePrivileges.keys.map((group) {
                return _buildPrivilegeGroup(controller, group, context);
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPrivilegeGroup(PrivilegeMasterController controller, String group, BuildContext context) {
    return Container(
      width: 300,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  group.toUpperCase(),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                Checkbox(
                  value: controller.activePrivileges[group]!.values.every((v) => v),
                  onChanged: (_) => controller.toggleGroup(group),
                ),
              ],
            ),
          ),
          ...controller.activePrivileges[group]!.keys.map((item) {
            return CheckboxListTile(
              title: Text(item, style: const TextStyle(fontSize: 14)),
              value: controller.activePrivileges[group]![item],
              onChanged: (_) => controller.togglePrivilege(group, item),
              controlAffinity: ListTileControlAffinity.leading,
              dense: true,
            );
          }),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, PrivilegeMasterController controller, PrivilegeSet set) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Privilege Set?'),
        content: Text('Are you sure you want to delete "${set.name}"?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              controller.deleteSet(set.id);
              Get.back();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
