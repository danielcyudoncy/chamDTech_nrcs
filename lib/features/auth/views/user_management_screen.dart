import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:chamDTech_nrcs/features/auth/services/auth_service.dart';
import 'package:chamDTech_nrcs/features/auth/models/user_model.dart';
import 'package:chamDTech_nrcs/features/admin/services/privilege_service.dart';
import 'package:chamDTech_nrcs/features/admin/models/privilege_set_model.dart';
import 'package:chamDTech_nrcs/core/constants/app_constants.dart';
import 'package:intl/intl.dart';

class UserManagementScreen extends StatelessWidget {
  const UserManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // This would normally be in a controller
    final AuthService authService = Get.find<AuthService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('User & Access Control'),
        backgroundColor: const Color(0xFF263238),
      ),
      body: Row(
        children: [
          // Roles/Groups sidebar
          _buildSidebar(),
          // User List
          Expanded(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: StreamBuilder<List<UserModel>>(
                    stream: _getUsersStream(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                      final users = snapshot.data!;
                      return ListView.separated(
                        itemCount: users.length,
                        separatorBuilder: (context, index) => const Divider(height: 1),
                        itemBuilder: (context, index) => _buildUserTile(context, users[index]),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 250,
      color: const Color(0xFFECEFF1),
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('Privilege Masters', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
          _SidebarItem(label: 'Administrators', count: 2, isSelected: true),
          _SidebarItem(label: 'Producers', count: 12),
          _SidebarItem(label: 'Reporters', count: 45),
          _SidebarItem(label: 'Assignmet Desk', count: 8),
          _SidebarItem(label: 'Guest Users', count: 0),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add),
              label: const Text('New Designation'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1976D2),
                minimumSize: const Size(double.infinity, 45),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        children: [
          const Text('All Users', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const Spacer(),
          Flexible(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 300),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search...',
                  prefixIcon: const Icon(Icons.search),
                  isDense: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserTile(BuildContext context, UserModel user) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      leading: Stack(
        children: [
          CircleAvatar(
            backgroundColor: Colors.blue[100],
            child: Text(user.displayName[0].toUpperCase()),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: user.isOnline ? Colors.green : Colors.grey,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ),
        ],
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              user.displayName, 
              style: const TextStyle(fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 12),
          _Badge(label: user.role.replaceAll('_', ' ').toUpperCase(), color: Colors.blue[50]!, textColor: Colors.blue[900]!),
          if (user.privilegeSetId != null) ...[
            const SizedBox(width: 8),
            _Badge(label: 'SET: ${user.privilegeSetId!.substring(0, 4)}', color: Colors.purple[50]!, textColor: Colors.purple[900]!),
          ],
        ],
      ),
      subtitle: Text(user.email),
      onTap: () => _showEditUserDialog(context, user),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('Last seen: ${user.lastSeen != null ? DateFormat('HH:mm').format(user.lastSeen!) : 'Never'}', style: const TextStyle(fontSize: 12)),
              Text(user.isOnline ? 'ONLINE' : 'OFFLINE', style: TextStyle(fontSize: 10, color: user.isOnline ? Colors.green : Colors.grey, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(width: 16),
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => _showEditUserDialog(context, user),
          ),
        ],
      ),
    );
  }

  void _showEditUserDialog(BuildContext context, UserModel user) {
    final PrivilegeService privService = Get.put(PrivilegeService());
    final selectedRole = user.role.obs;
    final selectedPrivilegeSet = user.privilegeSetId.obs;

    Get.dialog(
      AlertDialog(
        title: Text('Edit User: ${user.displayName}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Obx(() => DropdownButtonFormField<String>(
                  value: selectedRole.value,
                  decoration: const InputDecoration(labelText: 'System Role'),
                  items: const [
                    DropdownMenuItem(value: 'admin', child: Text('Admin')),
                    DropdownMenuItem(value: 'producer', child: Text('Producer')),
                    DropdownMenuItem(value: 'editor', child: Text('Editor')),
                    DropdownMenuItem(value: 'reporter', child: Text('Reporter')),
                  ],
                  onChanged: (v) => selectedRole.value = v!,
                )),
            const SizedBox(height: 16),
            StreamBuilder<List<PrivilegeSet>>(
              stream: privService.getPrivilegeSets(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const CircularProgressIndicator();
                final sets = snapshot.data!;
                return Obx(() => DropdownButtonFormField<String?>(
                      value: selectedPrivilegeSet.value,
                      decoration: const InputDecoration(labelText: 'Privilege Master Set'),
                      items: [
                        const DropdownMenuItem(value: null, child: Text('None (Use Default)')),
                        ...sets.map((s) => DropdownMenuItem(value: s.id, child: Text(s.name))),
                      ],
                      onChanged: (v) => selectedPrivilegeSet.value = v,
                    ));
              },
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              // Update user in Firestore
              Get.find<AuthService>().updateUserData(user.id, {
                'role': selectedRole.value,
                'privilegeSetId': selectedPrivilegeSet.value,
              });
              Get.back();
              Get.snackbar('Success', 'User updated');
            },
            child: const Text('Save Changes'),
          ),
        ],
      ),
    );
  }

  // Mock stream for demonstration
  Stream<List<UserModel>> _getUsersStream() {
    return Stream.value([
      UserModel(
        id: '1',
        email: 'admin@chamdtech.com',
        displayName: 'John Executive',
        role: 'admin',
        isOnline: true,
        lastSeen: DateTime.now(),
        createdAt: DateTime.now(),
      ),
      UserModel(
        id: '2',
        email: 'reporter1@chamdtech.com',
        displayName: 'Alice Reporter',
        role: 'reporter',
        isOnline: false,
        lastSeen: DateTime.now().subtract(const Duration(hours: 2)),
        createdAt: DateTime.now(),
      ),
      UserModel(
        id: '3',
        email: 'producer1@chamdtech.com',
        displayName: 'Bob Newsroom',
        role: 'editor',
        isOnline: true,
        lastSeen: DateTime.now(),
        createdAt: DateTime.now(),
      ),
    ]);
  }
}

class _SidebarItem extends StatelessWidget {
  final String label;
  final int count;
  final bool isSelected;

  const _SidebarItem({required this.label, required this.count, this.isSelected = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: isSelected ? Colors.white : Colors.transparent,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(Icons.folder_open, size: 20, color: isSelected ? Colors.blue : Colors.grey[700]),
          const SizedBox(width: 12),
          Text(label, style: TextStyle(color: isSelected ? Colors.blue : Colors.black87, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
          const Spacer(),
          Text(count.toString(), style: TextStyle(color: Colors.grey[600], fontSize: 12)),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  final Color textColor;

  const _Badge({required this.label, required this.color, required this.textColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),
      child: Text(label, style: TextStyle(color: textColor, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}
