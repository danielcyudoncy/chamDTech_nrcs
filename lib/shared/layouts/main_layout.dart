// shared/layouts/main_layout.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:chamdtech_nrcs/app/config/theme_config.dart';
import 'package:chamdtech_nrcs/shared/layouts/responsive_layout.dart';
import 'package:chamdtech_nrcs/features/auth/services/auth_service.dart';
import 'package:chamdtech_nrcs/core/constants/app_constants.dart';

class MainLayout extends StatelessWidget {
  final Widget child;
  final String? title;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final bool showDrawer;

  const MainLayout({
    super.key,
    required this.child,
    this.title,
    this.actions,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.showDrawer = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveLayout.isDesktop(context);
    
    return Scaffold(
      appBar: isDesktop && title == null
          ? null
          : AppBar(
              title: title != null ? Text(title!) : null,
              actions: actions,
              leading: !isDesktop && showDrawer
                  ? Builder(
                      builder: (context) => IconButton(
                        icon: const Icon(Icons.menu),
                        onPressed: () => Scaffold.of(context).openDrawer(),
                      ),
                    )
                  : null,
            ),
      drawer: !isDesktop && showDrawer ? _buildSidebar(context) : null,
      body: Row(
        children: [
          if (isDesktop && showDrawer) 
            Container(
              width: 260,
              decoration: BoxDecoration(
                border: Border(
                  right: BorderSide(
                    color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
                  ),
                ),
              ),
              child: _buildSidebar(context),
            ),
          Expanded(
            child: child,
          ),
        ],
      ),
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
    );
  }

  Widget _buildSidebar(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      child: Column(
        children: [
          _buildSidebarHeader(context),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _SidebarItem(
                  icon: Icons.dashboard_outlined,
                  label: 'Dashboard',
                  onTap: () => Get.toNamed('/dashboard'),
                  isActive: Get.currentRoute == '/dashboard',
                ),
                _SidebarItem(
                  icon: Icons.article_outlined,
                  label: 'Stories',
                  onTap: () => Get.toNamed('/stories'),
                  isActive: Get.currentRoute == '/stories',
                ),
                _SidebarItem(
                  icon: Icons.view_list_outlined,
                  label: 'Rundowns',
                  onTap: () => Get.toNamed('/rundowns'),
                  isActive: Get.currentRoute == '/rundowns',
                ),
                _SidebarItem(
                  icon: Icons.assignment_outlined,
                  label: 'Assignments',
                  onTap: () => Get.toNamed('/assignments'),
                  isActive: Get.currentRoute == '/assignments',
                ),
                const Divider(height: 32, indent: 16, endIndent: 16),
                _SidebarItem(
                  icon: Icons.settings_outlined,
                  label: 'Settings',
                  onTap: () => Get.toNamed('/settings'),
                  isActive: Get.currentRoute == '/settings',
                ),
                Obx(() {
                  final user = Get.find<AuthService>().currentUser.value;
                  if (user?.role == AppConstants.roleAdmin) {
                    return _SidebarItem(
                      icon: Icons.admin_panel_settings_outlined,
                      label: 'Admin',
                      onTap: () => Get.toNamed('/admin'),
                      isActive: Get.currentRoute.startsWith('/admin'),
                    );
                  }
                  return const SizedBox.shrink();
                }),
              ],
            ),
          ),
          _buildSidebarFooter(context),
        ],
      ),
    );
  }

  Widget _buildSidebarHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      alignment: Alignment.centerLeft,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: ThemeConfig.primaryColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.bolt,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'NRCS',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarFooter(BuildContext context) {
    final authService = Get.find<AuthService>();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
          ),
        ),
      ),
      child: Obx(() {
        final user = authService.currentUser.value;
        return Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: ThemeConfig.primaryColor,
              backgroundImage: (user?.photoUrl != null && user!.photoUrl!.isNotEmpty) 
                  ? NetworkImage(user.photoUrl!) 
                  : null,
              child: (user?.photoUrl == null || user!.photoUrl!.isEmpty)
                  ? Text(
                      (user?.displayName.isNotEmpty ?? false)
                          ? user!.displayName[0].toUpperCase()
                          : 'U',
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    user?.displayName ?? 'User',
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    user?.isOnline ?? false ? 'Online' : 'Offline',
                    style: TextStyle(
                      color: user?.isOnline ?? false ? Colors.green : Colors.grey,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.logout, size: 20),
              onPressed: () => authService.signOut(),
            ),
          ],
        );
      }),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isActive;

  const _SidebarItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? ThemeConfig.primaryColor.withValues(alpha: 0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 22,
                color: isActive ? ThemeConfig.primaryColor : theme.iconTheme.color?.withValues(alpha: 0.7),
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                  color: isActive ? ThemeConfig.primaryColor : theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
