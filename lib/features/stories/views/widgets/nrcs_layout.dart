// features/stories/views/widgets/nrcs_layout.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:async';
import 'package:chamdtech_nrcs/features/auth/services/auth_service.dart';
import 'package:chamdtech_nrcs/features/stories/controllers/story_controller.dart';
import 'package:chamdtech_nrcs/core/constants/app_constants.dart';
import 'package:chamdtech_nrcs/app/routes/app_routes.dart';
import 'package:chamdtech_nrcs/features/stories/views/widgets/top_stories_ticker.dart';
import 'package:chamdtech_nrcs/features/stories/views/widgets/breaking_news_ticker.dart';
import 'package:chamdtech_nrcs/core/models/notification_model.dart';
import 'package:chamdtech_nrcs/core/services/notification_service.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class NRCSColors {
  static const Color topNavBlue = Color(0xFF2B439B);
  static const Color primaryBlue = Color(0xFF4F6FD2);
  static const Color subNavGray = Color(0xFFF5F5F5);
  static const Color activeOrange = Color(0xFFFF9800);
  static const Color borderGray = Color(0xFFD1D1D1);
  static const Color textDark = Color(0xFF313131);
  static const Color breakingRed = Color(0xFFB61F24);
}

class NRCSAppShell extends StatelessWidget {
  final Widget? sidebar;
  final Widget? body;
  final Widget? toolbar;
  final String? title;

  const NRCSAppShell({
    super.key,
    this.sidebar,
    this.body,
    this.toolbar,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final isMobile = constraints.maxWidth < 1100;

      return Scaffold(
        backgroundColor: Colors.white,
        drawer: isMobile && sidebar != null ? Drawer(width: 300, child: sidebar!) : null,
        appBar: isMobile
            ? AppBar(
                backgroundColor: Colors.white,
                elevation: 0,
                scrolledUnderElevation: 0,
                leading: sidebar != null 
                  ? null // Scaffold will automatically show the menu icon
                  : IconButton(
                    icon: const Icon(Icons.arrow_back, color: Color(0xFF1A237E)),
                    onPressed: () {
                      if (Get.previousRoute.isNotEmpty) {
                        Get.back();
                      } else {
                        final authService = Get.find<AuthService>();
                        final role = authService.currentUser.value?.role ??
                            AppConstants.roleReporter;
                        Get.offAllNamed(_getRoleDashboard(role));
                      }
                    },
                  ),
                title: Text(
                  title?.toUpperCase() ?? 'NRCS',
                  style: const TextStyle(
                    color: Color(0xFF1A237E),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    letterSpacing: 1.1,
                  ),
                ),
                iconTheme: const IconThemeData(color: Color(0xFF1A237E)),
                shape: const Border(
                    bottom:
                        BorderSide(color: NRCSColors.borderGray, width: 0.5)),
              )
            : null,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!isMobile) ...[
              const NRCSTopNav(),
              const NRCSSubNav(),
              // Sub-header with back button and title
              Container(
                height: 40,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(
                      bottom:
                          BorderSide(color: NRCSColors.borderGray, width: 0.5)),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.arrow_back,
                          size: 20, color: NRCSColors.topNavBlue),
                      onPressed: () {
                        if (Get.previousRoute.isNotEmpty) {
                          Get.back();
                        } else {
                          final authService = Get.find<AuthService>();
                          final role = authService.currentUser.value?.role ??
                              AppConstants.roleReporter;
                          Get.offAllNamed(_getRoleDashboard(role));
                        }
                      },
                      tooltip: 'Go Back',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    if (title != null) ...[
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          title!.toUpperCase(),
                          style: const TextStyle(
                            color: NRCSColors.textDark,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            letterSpacing: 1.1,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
            if (toolbar != null) toolbar!,
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (sidebar != null && !isMobile)
                    Container(
                      width: 300,
                      decoration: const BoxDecoration(
                        border: Border(
                          right: BorderSide(
                              color: NRCSColors.borderGray, width: 8),
                        ),
                      ),
                      child: sidebar!,
                    ),
                  if (body != null) Expanded(child: body!),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  static String _getRoleDashboard(String role) {
    switch (role) {
      case AppConstants.roleAdmin:
        return AppRoutes.adminDashboard;
      case AppConstants.roleProducer:
        return AppRoutes.producerDashboard;
      case AppConstants.roleEditor:
        return AppRoutes.editorDashboard;
      case AppConstants.roleAnchor:
        return AppRoutes.anchorDashboard;
      case AppConstants.roleReporter:
      default:
        return AppRoutes.reporterDashboard;
    }
  }
}

class NRCSTopNav extends StatefulWidget {
  const NRCSTopNav({super.key});

  @override
  State<NRCSTopNav> createState() => _NRCSTopNavState();
}

class _NRCSTopNavState extends State<NRCSTopNav> {
  late Timer _timer;
  String _currentTime = '';

  @override
  void initState() {
    super.initState();
    _updateTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _updateTime());
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _updateTime() {
    setState(() {
      _currentTime = DateFormat('HH:mm:ss').format(DateTime.now());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
    final user = Get.find<AuthService>().currentUser.value;
    final role = user?.role ?? AppConstants.roleReporter;

    // Define base route mapping based on our existing logic
    final Map<String, String> routeMapping = {
      'Workspace': '/stories', // Default reporter/general workspace
      'Reporter Dashboard': AppRoutes.reporterDashboard,
      'Editor Dashboard': AppRoutes.editorDashboard,
      'Producer Dashboard': AppRoutes.producerDashboard,
      'Operational Dashboard': AppRoutes.producerDashboard,
      'Anchor Dashboard': AppRoutes.anchorDashboard,
      'Admin Dashboard': AppRoutes.adminDashboard,
      'My Stories':
          '/stories', // Could filter stories logically by current user later
      'Archive': '/stories', // Will use filter
      'Create Story': AppRoutes.storyEditor,
      'Review Queue': '/stories', // Could filter logically later
      'Rundowns': '/rundowns',
      'Desks': '/admin/desks',
      'Users': '/users',
      'Privileges': AppRoutes.adminPrivileges,
      'Story States': AppRoutes.adminStoryState,
      'Audit Logs': AppRoutes.adminAuditTrail,
      'Configurations': AppRoutes.adminConfigurations,
      'Settings': '/settings',
      'Reports': AppRoutes.producerDashboard,
      'Story Pool': AppRoutes.producerDashboard,
      'Notifications': AppRoutes.notifications,
    };

    // Calculate dynamic tabs based on active role permissions
    List<String> tabs = [];
    if (role == AppConstants.roleReporter) {
      tabs = [
        'Reporter Dashboard',
        'My Stories',
        'Create Story',
        'Archive',
        'Notifications'
      ];
    } else if (role == AppConstants.roleEditor) {
      tabs = [
        'Editor Dashboard',
        'Review Queue',
        'Desks',
        'Archive',
        'Notifications'
      ];
    } else if (role == AppConstants.roleProducer) {
      tabs = [
        'Producer Dashboard',
        'Rundowns',
        'Story Pool',
        'Archive',
        'Reports'
      ];
    } else if (role == AppConstants.roleAdmin) {
      tabs = [
        'Admin Dashboard',
        'Users',
        'Privileges',
        'Desks',
        'Story States',
        'Archive',
        'Audit Logs',
        'Configurations'
      ];
    } else if (role == AppConstants.roleAnchor) {
      tabs = ['Anchor Dashboard', 'Rundowns', 'Archive', 'Notifications'];
    } else if (role == AppConstants.roleDirector) {
      tabs = [
        'Operational Dashboard',
        'Rundowns',
        'Story Pool',
        'Archive',
        'Reports',
        'Notifications'
      ];
    } else {
      tabs = ['Workspace', 'Archive', 'Settings'];
    }

    final currentRoute = Get.currentRoute;

    return Container(
      height: 50,
      color: NRCSColors.topNavBlue,
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: tabs.map((tab) {
                  final route = routeMapping[tab];
                  bool isActive = false;

                  // Special-case tabs that share the same route '/stories' (e.g. 'My Stories' and 'Archive').
                  // Use StoryController.showArchived to determine which of those should be active.
                  if (route != null) {
                    if (route == '/stories' &&
                        (tab == 'Archive' ||
                            tab == 'My Stories' ||
                            tab == 'Workspace' ||
                            tab == 'Reporter Dashboard')) {
                      try {
                        final sc = Get.find<StoryController>();
                        if (tab == 'Archive') {
                          isActive = currentRoute == route &&
                              sc.showArchived.value == true;
                        } else {
                          isActive = currentRoute == route &&
                              sc.showArchived.value == false;
                        }
                      } catch (e) {
                        // If StoryController isn't available yet, default to marking 'My Stories' as active
                        // when on the stories route to avoid both tabs showing active simultaneously.
                        isActive = currentRoute == route && tab == 'My Stories';
                      }
                    } else if (route == AppRoutes.editorDashboard || 
                               route == AppRoutes.adminDashboard || 
                               route == AppRoutes.producerDashboard) {
                      final args = Get.arguments;
                      if (args is Map && args['tab'] != null) {
                        isActive = (currentRoute == route) && (args['tab'] == tab);
                      } else {
                        // If no tab arg, the primary dashboard button should be active
                        isActive = (currentRoute == route) && 
                                  (tab == 'Editor Dashboard' || 
                                   tab == 'Admin Dashboard' || 
                                   tab == 'Producer Dashboard');
                      }
                    } else {
                      isActive = currentRoute == route;
                    }
                  } else if (tab == 'Workspace' && currentRoute == '/') {
                    isActive = true; // Splash/Initial
                  }

                  return _NavButton(
                    label: tab,
                    isActive: isActive,
                    onTap: () {
                      if (tab == 'Create Story') {
                        try {
                          Get.find<StoryController>().createNewStory();
                        } catch (e) {
                          Get.put(StoryController()).createNewStory();
                        }
                        return;
                      }

                      if (tab == 'Archive') {
                        try {
                          final controller = Get.find<StoryController>();
                          controller.showArchived.value = true;
                          controller.loadStories();
                        } catch (e) {
                          final controller = Get.put(StoryController());
                          controller.showArchived.value = true;
                          controller.loadStories();
                        }
                        if (currentRoute != '/stories') {
                          Get.offAllNamed('/stories');
                        }
                        return;
                      }

                      if (tab == 'My Stories' ||
                          tab == 'Workspace' ||
                          tab == 'Reporter Dashboard') {
                        try {
                          final controller = Get.find<StoryController>();
                          controller.showArchived.value = false;
                          controller.loadStories();
                        } catch (e) {
                          // Controller not initialized yet, will be handled on creation
                        }
                      }

                      if (route != null) {
                        // For dashboard-integrated tabs, if we are an Editor or Admin, we want to stay in the Dashboard
                        // but tell it to open the specific tab.
                        if (tab == 'Desks' || tab == 'Archive' || tab == 'Review Queue') {
                          if (role == AppConstants.roleEditor) {
                            Get.offAllNamed(AppRoutes.editorDashboard, arguments: {'tab': tab});
                            return;
                          } else if (role == AppConstants.roleAdmin) {
                            Get.offAllNamed(AppRoutes.adminDashboard, arguments: {'tab': tab});
                            return;
                          }
                        }

                        if (currentRoute != route) {
                          Get.offAllNamed(route, arguments: {'tab': tab});
                        } else {
                          // Already on the same route - pass the tab argument to switch
                          Get.offAllNamed(route, arguments: {'tab': tab});
                        }
                      } else {
                        Get.snackbar(
                          'Coming Soon',
                          '$tab module is currently under development.',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.white,
                          colorText: NRCSColors.topNavBlue,
                        );
                      }
                    },
                  );
                }).toList(),
              ),
            ),
          ),
          _UserSection(currentTime: _currentTime),
        ],
      ),
    );
    }); // end Obx
  }
}

class _NavButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavButton({
    required this.label,
    required this.onTap,
    this.isActive = false,
  });

  void _showWorkspaceMenu(BuildContext context, Offset position) {
    if (label != 'Workspace') return;

    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;

    showMenu(
      context: context,
      position: RelativeRect.fromRect(
        position & const Size(40, 40), // smaller rect, the touch area
        Offset.zero & overlay.size, // Larger rect, the entire screen
      ),
      items: [
        const PopupMenuItem(
          value: 'mystories',
          child: Row(
            children: [
              Icon(Icons.person_outline, size: 18),
              SizedBox(width: 8),
              Text('MyStories'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'contacts',
          child: Row(
            children: [
              Icon(Icons.contacts_outlined, size: 18),
              SizedBox(width: 8),
              Text('Contacts'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'events',
          child: Row(
            children: [
              Icon(Icons.event_outlined, size: 18),
              SizedBox(width: 8),
              Text('Events'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'preferences',
          child: Row(
            children: [
              Icon(Icons.settings_outlined, size: 18),
              SizedBox(width: 8),
              Text('Preferences'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'help',
          child: Row(
            children: [
              Icon(Icons.help_outline, size: 18),
              SizedBox(width: 8),
              Text('Help'),
            ],
          ),
        ),
      ],
      elevation: 8.0,
    ).then((value) {
      if (value == null) return;

      switch (value) {
        case 'mystories':
          Get.snackbar(
            'MyStories',
            'Personal space for maturing stories. Coming Soon.',
            snackPosition: SnackPosition.BOTTOM,
          );
          break;
        case 'contacts':
          Get.toNamed('/users');
          break;
        case 'events':
          Get.snackbar('Events', 'Events calendar - Coming Soon',
              snackPosition: SnackPosition.BOTTOM);
          break;
        case 'preferences':
          Get.toNamed('/settings');
          break;
        case 'help':
          Get.snackbar('Help', 'Support and Documentation - Coming Soon',
              snackPosition: SnackPosition.BOTTOM);
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onSecondaryTapDown: (details) =>
          _showWorkspaceMenu(context, details.globalPosition),
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.transparent,
            border: const Border(
              right: BorderSide(color: Colors.white24, width: 1),
            ),
          ),
          alignment: Alignment.centerLeft,
          child: Text(
            label,
            style: TextStyle(
              color: isActive ? NRCSColors.topNavBlue : Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}

class _UserSection extends StatelessWidget {
  final String currentTime;
  const _UserSection({required this.currentTime});

  @override
  Widget build(BuildContext context) {
    final authService = Get.find<AuthService>();
    final notificationService = Get.find<NotificationService>();

    return Obx(() {
      final user = authService.currentUser.value;
      final displayName = user?.displayName ?? '';
      final photoUrl = user?.photoUrl;

      return Container(
        height: 50,
        decoration: BoxDecoration(
          color: NRCSColors.topNavBlue.withValues(alpha: 0.9),
          border:
              const Border(left: BorderSide(color: Colors.white24, width: 1)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Time
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                currentTime,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            // Divider
            Container(width: 2, height: 30, color: Colors.white24),
            // chamDTech NRCS
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
              decoration: BoxDecoration(
                color: NRCSColors.breakingRed,
                borderRadius: BorderRadius.circular(2),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'chamDTech',
                    style: TextStyle(color: Colors.white, fontSize: 10),
                  ),
                  Text(
                    'NRCS',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12),
                  ),
                ],
              ),
            ),
            // Divider
            Container(width: 2, height: 30, color: Colors.white24),
            // Notification Bell with Badge
            StreamBuilder<List<NotificationModel>>(
              stream: notificationService.getNotifications(),
              builder: (context, snapshot) {
                final List<NotificationModel> notifications =
                    snapshot.data ?? [];
                final unreadCount =
                    notifications.where((n) => !n.isRead).length;

                return InkWell(
                  onTap: () => Get.toNamed(AppRoutes.notifications),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        const Icon(Icons.notifications_none,
                            color: Colors.white, size: 20),
                        if (unreadCount > 0)
                          Positioned(
                            right: 0,
                            top: 10,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 12,
                                minHeight: 12,
                              ),
                              child: Text(
                                unreadCount > 9 ? '9+' : unreadCount.toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
            // Divider
            Container(width: 2, height: 30, color: Colors.white24),
            // User details and logout
            InkWell(
              onTap: () => Get.toNamed(AppRoutes.profile),
              child: Container(
                height: 50,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 14,
                      backgroundColor: Colors.white24,
                      backgroundImage: photoUrl != null
                          ? CachedNetworkImageProvider(photoUrl)
                          : null,
                      child: photoUrl == null
                          ? const Icon(Icons.person,
                              size: 18, color: Colors.white)
                          : null,
                    ),
                    const SizedBox(width: 8),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 150),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            displayName,
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13),
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (user != null)
                            Text(
                              user.isOnline ? 'Online' : 'Offline',
                              style: TextStyle(
                                color: user.isOnline
                                    ? Colors.greenAccent
                                    : Colors.grey,
                                fontSize: 10,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 4),
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.white70, size: 20),
              tooltip: 'Logout',
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: () => authService.signOut(),
            ),
            const SizedBox(width: 8),
          ],
        ),
      );
    });
  }
}

class NRCSSubNav extends StatelessWidget {
  const NRCSSubNav({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: NRCSColors.borderGray)),
      ),
      child: Column(
        children: [
          Container(
            height: 30,
            color: NRCSColors.breakingRed,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            alignment: Alignment.centerLeft,
            child: const Row(
              children: [
                Icon(Icons.bolt, color: Colors.white, size: 16),
                SizedBox(width: 8),
                Text(
                  'BREAKING NEWS',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 11),
                ),
                SizedBox(width: 16),
                Expanded(child: BreakingNewsTicker()),
              ],
            ),
          ),
          Container(
            height: 30,
            color: NRCSColors.subNavGray,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            alignment: Alignment.centerLeft,
            child: const Row(
              children: [
                Icon(Icons.trending_up, color: NRCSColors.topNavBlue, size: 16),
                SizedBox(width: 8),
                Text(
                  'TRENDING STORIES',
                  style: TextStyle(
                      color: NRCSColors.topNavBlue,
                      fontWeight: FontWeight.bold,
                      fontSize: 11),
                ),
                SizedBox(width: 16),
                Expanded(child: TopStoriesTicker()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class NRCSToolbar extends StatelessWidget {
  final VoidCallback? onRefresh;
  final VoidCallback? onNew;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onCopy;
  final VoidCallback? onMove;
  final VoidCallback? onLink;
  final VoidCallback? onAssign;
  final VoidCallback? onStoryLog;
  final VoidCallback? onPrint;
  final VoidCallback? onPowerview;

  const NRCSToolbar({
    super.key,
    this.onRefresh,
    this.onNew,
    this.onEdit,
    this.onDelete,
    this.onCopy,
    this.onMove,
    this.onLink,
    this.onAssign,
    this.onStoryLog,
    this.onPrint,
    this.onPowerview,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = Get.width < 600;
    
    final buttons = [
      _ToolbarActionButton(label: 'New', onTap: onNew, icon: Icons.add_circle_outline),
      _ToolbarActionButton(label: 'Edit', onTap: onEdit, icon: Icons.edit_outlined),
      _ToolbarActionButton(label: 'Delete', onTap: onDelete, icon: Icons.delete_outline),
      _ToolbarActionButton(label: 'Copy', onTap: onCopy, icon: Icons.copy_outlined),
      _ToolbarActionButton(label: 'Move', onTap: onMove, icon: Icons.move_to_inbox_outlined),
      _ToolbarActionButton(label: 'Link', onTap: onLink, icon: Icons.link),
      _ToolbarActionButton(label: 'Assign', onTap: onAssign, icon: Icons.assignment_ind_outlined),
      _ToolbarActionButton(label: 'Story Log', onTap: onStoryLog, icon: Icons.history),
      _ToolbarActionButton(label: 'Print', onTap: onPrint, icon: Icons.print_outlined),
      _ToolbarActionButton(
        label: 'Powerview',
        isBordered: true,
        borderColor: NRCSColors.activeOrange,
        onTap: onPowerview,
        icon: Icons.remove_red_eye_outlined,
      ),
    ];

    return Container(
      height: isMobile ? 32.h : 48,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(width: 8),
            ...buttons.map((b) => Padding(padding: const EdgeInsets.only(right: 4), child: b)),
            const SizedBox(width: 12),
          ],
        ),
      ),
    );
  }
}

class CategoryToolbar extends StatelessWidget {
  final String? selectedCategory;
  final Function(String)? onCategorySelected;

  const CategoryToolbar({
    super.key,
    this.selectedCategory,
    this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = Get.width < 600;
    final categories = ['All', ...AppConstants.storyCategories];
    
    return Container(
      height: isMobile ? 42.h : 56,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isActive = (cat == 'All' &&
                  (selectedCategory == null ||
                      selectedCategory == 'all' ||
                      selectedCategory == 'All')) ||
              selectedCategory == cat;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: _ModernCategoryChip(
              label: cat,
              isActive: isActive,
              onTap: () => onCategorySelected?.call(cat),
            ),
          );
        },
      ),
    );
  }
}

class _ModernCategoryChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _ModernCategoryChip({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = Get.width < 600;
    final color = _getCategoryColor(label);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: Material(
        color: isActive ? color : Colors.transparent,
        borderRadius: BorderRadius.circular(isMobile ? 20.r : 20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(isMobile ? 20.r : 20),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 10.w : 16, 
              vertical: isMobile ? 4.h : 8
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(isMobile ? 20.r : 20),
              border: Border.all(
                color: isActive ? Colors.transparent : Colors.grey.shade300,
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isActive)
                  const Padding(
                    padding: EdgeInsets.only(right: 6),
                    child:
                        Icon(Icons.check_circle, size: 14, color: Colors.white),
                  ),
                Text(
                  label,
                  style: TextStyle(
                    color: isActive ? Colors.white : const Color(0xFF263238),
                    fontWeight: isActive ? FontWeight.w900 : FontWeight.w700,
                    fontSize: isMobile ? 11.sp : 13,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor(String categoryStr) {
    switch (categoryStr) {
      case 'All':
        return Colors.blueGrey.shade700;
      case 'Local News':
        return Colors.blue.shade700;
      case 'Politics':
        return Colors.purple.shade700;
      case 'Sports':
        return Colors.green.shade700;
      case 'Foreign':
        return Colors.orange.shade700;
      case 'Business & Finance':
        return Colors.teal.shade700;
      case 'Breaking News':
        return Colors.red.shade700;
      case 'Technology':
        return Colors.indigo.shade700;
      case 'Environment':
        return Colors.green.shade900;
      case 'Health':
        return Colors.pink.shade700;
      case 'Entertainment & Lifestyle':
        return Colors.amber.shade800;
      default:
        return Colors.grey.shade700;
    }
  }
}

class _ToolbarActionButton extends StatelessWidget {
  final String label;
  final bool isBordered;
  final Color? borderColor;
  final VoidCallback? onTap;
  final IconData? icon;

  const _ToolbarActionButton({
    required this.label,
    this.isBordered = false,
    this.borderColor,
    this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = Get.width < 600;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 2.w : 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(isMobile ? 8.r : 8),
        child: Container(
          height: isMobile ? 26.h : 36,
          padding: EdgeInsets.symmetric(horizontal: isMobile ? 4.w : 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(isMobile ? 8.r : 8),
            border: isBordered && borderColor != null
                ? Border.all(color: borderColor!, width: 1.5)
                : Border.all(color: Colors.transparent),
            color: isBordered ? Colors.transparent : Colors.grey.shade50,
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon,
                    size: isMobile ? 12.sp : 16,
                    color: isBordered
                        ? (borderColor ?? NRCSColors.primaryBlue)
                        : NRCSColors.primaryBlue),
                SizedBox(width: isMobile ? 2.sp : 6),
              ],
              Text(
                label,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: isMobile ? 8.sp : 12,
                    color: isBordered
                        ? (borderColor ?? NRCSColors.primaryBlue)
                        : NRCSColors.textDark),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NRCSStoryListItem extends StatelessWidget {
  final String title;
  final String author;
  final String time;
  final String date;
  final String duration;
  final String? category;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback? onDelete;
  final String? deleteTooltip;

  const NRCSStoryListItem({
    super.key,
    required this.title,
    required this.author,
    required this.time,
    required this.date,
    required this.duration,
    this.category,
    required this.onTap,
    this.isSelected = false,
    this.onDelete,
    this.deleteTooltip,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? NRCSColors.topNavBlue.withValues(alpha: 0.05)
              : Colors.white,
          border: Border(
            bottom: const BorderSide(color: NRCSColors.borderGray),
            left: BorderSide(
              color: isSelected ? NRCSColors.topNavBlue : Colors.transparent,
              width: 4,
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: isSelected
                              ? NRCSColors.topNavBlue
                              : NRCSColors.textDark,
                        ),
                      ),
                      if (category != null && category!.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: _getCategoryColor(category!)
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            category!.toUpperCase(),
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: _getCategoryColor(category!),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (onDelete != null)
                  IconButton(
                    icon: Icon(Icons.delete_outline,
                        size: 18, color: Colors.red.shade400),
                    onPressed: onDelete,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    tooltip: deleteTooltip ?? 'Archive Story',
                  )
                else
                  Icon(Icons.videocam_outlined,
                      size: 18,
                      color: isSelected
                          ? NRCSColors.topNavBlue
                          : Colors.grey.shade400),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.person_outline,
                    size: 14, color: Colors.grey.shade500),
                const SizedBox(width: 4),
                Text(author,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w500,
                    )),
                const Spacer(),
                Icon(Icons.timer_outlined,
                    size: 14, color: Colors.grey.shade500),
                const SizedBox(width: 4),
                Text(duration,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w500,
                    )),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(Icons.calendar_today_outlined,
                    size: 14, color: Colors.grey.shade500),
                const SizedBox(width: 4),
                Text('$time $date',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w500,
                    )),
                const Spacer(),
                Icon(Icons.more_horiz, size: 14, color: Colors.grey.shade400),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(String categoryStr) {
    switch (categoryStr) {
      case 'Local News':
        return Colors.blue.shade700;
      case 'Politics':
        return Colors.purple.shade700;
      case 'Sports':
        return Colors.green.shade700;
      case 'Foreign':
        return Colors.orange.shade800;
      case 'Business & Finance':
        return Colors.teal.shade700;
      case 'Breaking News':
        return Colors.red.shade700;
      case 'Technology':
        return Colors.indigo.shade700;
      case 'Environment':
        return Colors.green.shade900;
      case 'Health':
        return Colors.pink.shade700;
      case 'Entertainment & Lifestyle':
        return Colors.amber.shade900;
      default:
        return Colors.grey.shade700;
    }
  }
}
