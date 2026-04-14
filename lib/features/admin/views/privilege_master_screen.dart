import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:chamdtech_nrcs/features/admin/controllers/privilege_master_controller.dart';
import 'package:chamdtech_nrcs/features/admin/models/role_model.dart';
import 'package:chamdtech_nrcs/features/stories/views/widgets/nrcs_layout.dart';

class PrivilegeMasterScreen extends StatelessWidget {
  const PrivilegeMasterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PrivilegeMasterController());

    return NRCSAppShell(
      title: 'Privilege Management',
      toolbar: _buildToolbar(controller, context),
      sidebar: _buildSidebar(controller),
      body: Obx(() => controller.isEditing.value
          ? _buildMainContent(controller, context)
          : const Center(
              child: Text(
                'Select a role to manage privileges or create a new one',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            )),
    );
  }

  Widget _buildToolbar(PrivilegeMasterController controller, BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: NRCSColors.borderGray, width: 0.5)),
      ),
      child: Row(
        children: [
          ElevatedButton.icon(
            onPressed: () => controller.createNewRole(),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('New Role'),
            style: ElevatedButton.styleFrom(
              backgroundColor: NRCSColors.topNavBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
          ),
          const SizedBox(width: 12),
          Obx(() => OutlinedButton.icon(
                onPressed: controller.selectedRole.value != null
                    ? () => _confirmDelete(context, controller, controller.selectedRole.value!)
                    : null,
                icon: const Icon(Icons.delete_outline, size: 18),
                label: const Text('Delete Role'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                ),
              )),
          const Spacer(),
          SizedBox(
            width: 300,
            child: TextField(
              onChanged: (v) => controller.searchQuery.value = v,
              style: const TextStyle(color: Colors.black),
              decoration: InputDecoration(
                hintText: 'Search permissions...',
                prefixIcon: const Icon(Icons.search, size: 18),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar(PrivilegeMasterController controller) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          color: NRCSColors.subNavGray,
          child: const Row(
            children: [
               Icon(Icons.people_outline, size: 18, color: NRCSColors.topNavBlue),
               SizedBox(width: 8),
               Text(
                'USER ROLES',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: NRCSColors.topNavBlue,
                  letterSpacing: 1.1,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 2,
          child: Obx(() {
            final roles = controller.roles;
            return ListView.separated(
              itemCount: roles.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final role = roles[index];
                return Obx(() => ListTile(
                      selected: controller.selectedRole.value?.id == role.id,
                      selectedTileColor: NRCSColors.primaryBlue.withValues(alpha: 0.05),
                      dense: true,
                      title: Text(
                        role.name,
                        style: TextStyle(
                          fontWeight: controller.selectedRole.value?.id == role.id ? FontWeight.bold : FontWeight.normal,
                          color: controller.selectedRole.value?.id == role.id ? NRCSColors.primaryBlue : NRCSColors.textDark,
                        ),
                      ),
                      subtitle: role.description != null ? Text(role.description!, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11)) : null,
                      onTap: () => controller.selectRole(role),
                    ));
              },
            );
          }),
        ),
        const Divider(height: 8, thickness: 8, color: NRCSColors.borderGray),
        Container(
          padding: const EdgeInsets.all(12),
          color: NRCSColors.subNavGray,
          child: const Row(
            children: [
               Icon(Icons.category_outlined, size: 18, color: NRCSColors.topNavBlue),
               SizedBox(width: 8),
               Text(
                'PRIVILEGE CATEGORIES',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: NRCSColors.topNavBlue,
                  letterSpacing: 1.1,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 3,
          child: ListView(
            children: controller.categories.map((cat) {
              return Obx(() => ListTile(
                    selected: controller.selectedCategory.value == cat,
                    selectedTileColor: NRCSColors.primaryBlue.withValues(alpha: 0.1),
                    dense: true,
                    leading: _getCategoryIcon(cat),
                    title: Text(
                      cat,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: controller.selectedCategory.value == cat ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    onTap: () => controller.selectedCategory.value = cat,
                  ));
            }).toList(),
          ),
        ),
      ],
    );
  }
  Widget _buildMainContent(PrivilegeMasterController controller, BuildContext context) {
    return Column(
      children: [
        // Role Info Header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(color: NRCSColors.borderGray, width: 0.5)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: controller.nameController,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      decoration: const InputDecoration(
                        hintText: 'Role Name (e.g. Senior Producer)',
                        border: InputBorder.none,
                        isDense: true,
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: controller.descriptionController,
                            style: const TextStyle(fontSize: 13, color: Colors.grey),
                            decoration: const InputDecoration(
                              hintText: 'Add a description for this role...',
                              border: InputBorder.none,
                              isDense: true,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text('Inherit from: ', style: TextStyle(fontSize: 12, color: Colors.grey)),
                        Obx(() => DropdownButton<String>(
                          value: controller.parentRoleId.value,
                          hint: const Text('None', style: TextStyle(fontSize: 12)),
                          underline: const SizedBox(),
                          isDense: true,
                          style: const TextStyle(fontSize: 12, color: NRCSColors.primaryBlue),
                          items: [
                            const DropdownMenuItem<String>(value: null, child: Text('None')),
                            ...controller.roles
                                .where((r) => r.id != controller.selectedRole.value?.id)
                                .map((r) => DropdownMenuItem<String>(
                                      value: r.id,
                                      child: Text(r.name),
                                    )),
                          ],
                          onChanged: (v) => controller.onParentRoleChanged(v),
                        )),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: () => controller.save(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: NRCSColors.primaryBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: const Text('Save Changes'),
              ),
            ],
          ),
        ),

        // View Toggle
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(color: NRCSColors.borderGray, width: 0.5)),
          ),
          child: Obx(() => Row(
            children: [
              _buildTabButton(
                label: 'PERMISSIONS',
                isActive: controller.activeView.value == 'Permissions',
                onTap: () => controller.activeView.value = 'Permissions',
              ),
              const SizedBox(width: 8),
              _buildTabButton(
                label: 'ASSOCIATED USERS (${controller.usersInRole.length})',
                isActive: controller.activeView.value == 'Users',
                onTap: () => controller.activeView.value = 'Users',
              ),
            ],
          )),
        ),

        // Content Area
        Expanded(
          child: Obx(() {
            if (controller.activeView.value == 'Users') {
              return _buildUserListSection(controller);
            }

            final category = controller.selectedCategory.value;
            final groups = controller.permissionsState[category] ?? {};
            final query = controller.searchQuery.value.toLowerCase();

            return Container(
              color: const Color(0xFFF9FAFB),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Wrap(
                  spacing: 24,
                  runSpacing: 24,
                  children: groups.keys.where((groupName) {
                    if (query.isEmpty) return true;
                    if (groupName.toLowerCase().contains(query)) return true;
                    return groups[groupName]!.keys.any((p) => p.toLowerCase().contains(query));
                  }).map((groupName) {
                    return _buildPermissionGroup(controller, category, groupName);
                  }).toList(),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildTabButton({required String label, required bool isActive, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isActive ? NRCSColors.primaryBlue : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isActive ? NRCSColors.primaryBlue : Colors.grey,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildUserListSection(PrivilegeMasterController controller) {
    final users = controller.usersInRole;

    if (users.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_off_outlined, size: 48, color: Colors.grey.withValues(alpha: 0.5)),
            const SizedBox(height: 16),
            const Text(
              'No users currently assigned to this role',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return Container(
      color: const Color(0xFFF9FAFB),
      child: ListView.separated(
        padding: const EdgeInsets.all(24),
        itemCount: users.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final user = users[index];
          return Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(color: NRCSColors.borderGray.withValues(alpha: 0.5)),
            ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: NRCSColors.topNavBlue.withValues(alpha: 0.1),
                child: Text(
                  user.displayName.isNotEmpty ? user.displayName[0].toUpperCase() : '?',
                  style: const TextStyle(color: NRCSColors.topNavBlue, fontWeight: FontWeight.bold),
                ),
              ),
              title: Text(user.displayName, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(user.email),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: user.isOnline ? Colors.green.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  user.isOnline ? 'Online' : 'Offline',
                  style: TextStyle(
                    color: user.isOnline ? Colors.green : Colors.grey,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPermissionGroup(PrivilegeMasterController controller, String category, String groupName) {
    return Container(
      width: 320,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: NRCSColors.borderGray.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: NRCSColors.subNavGray,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
              border: Border(bottom: BorderSide(color: NRCSColors.borderGray.withValues(alpha: 0.3))),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    groupName.toUpperCase(),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                      color: NRCSColors.textDark,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                Obx(() {
                   final perms = controller.permissionsState[category]![groupName]!;
                   final allChecked = perms.values.every((v) => v);
                   return InkWell(
                     onTap: () => controller.toggleGroup(category, groupName),
                     child: Text(
                       allChecked ? 'Deselect All' : 'Select All',
                       style: const TextStyle(fontSize: 10, color: NRCSColors.primaryBlue, fontWeight: FontWeight.bold),
                     ),
                   );
                }),
              ],
            ),
          ),
          Obx(() {
            final query = controller.searchQuery.value.toLowerCase();
            final perms = controller.permissionsState[category]![groupName]!;
            final visiblePerms = perms.keys.where((p) => 
              query.isEmpty || 
              groupName.toLowerCase().contains(query) || 
              p.toLowerCase().contains(query)
            ).toList();

            return Column(
              children: visiblePerms.map((permName) {
                return CheckboxListTile(
                  title: Text(
                    permName,
                    style: const TextStyle(fontSize: 13, color: NRCSColors.textDark),
                  ),
                  value: perms[permName],
                  onChanged: (_) => controller.togglePermission(category, groupName, permName),
                  dense: true,
                  visualDensity: VisualDensity.compact,
                  controlAffinity: ListTileControlAffinity.leading,
                  activeColor: NRCSColors.primaryBlue,
                );
              }).toList(),
            );
          }),
        ],
      ),
    );
  }

  Icon _getCategoryIcon(String category) {
    switch (category) {
      case 'Content Management':
        return const Icon(Icons.article_outlined, size: 18);
      case 'Rundown Operations':
        return const Icon(Icons.view_list_outlined, size: 18);
      case 'Newsroom Director':
        return const Icon(Icons.videocam_outlined, size: 18);
      case 'System Administration':
        return const Icon(Icons.settings_suggest_outlined, size: 18);
      case 'Reporting & Analytics':
        return const Icon(Icons.analytics_outlined, size: 18);
      case 'Technical Operations':
        return const Icon(Icons.build_circle_outlined, size: 18);
      default:
        return const Icon(Icons.check_circle_outline, size: 18);
    }
  }

  void _confirmDelete(BuildContext context, PrivilegeMasterController controller, Role role) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Role?'),
        content: Text('Are you sure you want to permanently delete the "${role.name}" role? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              controller.deleteRole(role.id, role.name);
              Get.back();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
