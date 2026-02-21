import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:chamDTech_nrcs/features/auth/services/auth_service.dart';
import 'package:chamDTech_nrcs/features/stories/views/widgets/top_stories_ticker.dart';
import 'package:chamDTech_nrcs/features/stories/views/widgets/breaking_news_ticker.dart';

class NRCSColors {
  static const Color topNavBlue = Color(0xFF0046AD);
  static const Color subNavGray = Color(0xFFE0E0E0);
  static const Color activeOrange = Color(0xFFFF9800);
  static const Color borderGray = Color(0xFF9E9E9E);
  static const Color textDark = Color(0xFF212121);
  static const Color breakingRed = Color(0xFFB71C1C);
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
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const NRCSTopNav(),
          const NRCSSubNav(),
          // Sub-header with back button and title
          Container(
            height: 40,
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: NRCSColors.borderGray, width: 0.5)),
            ),
            child: Row(
              children: [
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.arrow_back, size: 20, color: NRCSColors.topNavBlue),
                  onPressed: () {
                    if (Navigator.canPop(context)) {
                      Get.back();
                    } else {
                      Get.offAllNamed('/stories'); // Fallback to Workspace
                    }
                  },
                  tooltip: 'Back to Workspace',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                if (title != null) ...[
                  const SizedBox(width: 16),
                  Text(
                    title!.toUpperCase(),
                    style: const TextStyle(
                      color: NRCSColors.textDark,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      letterSpacing: 1.1,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (toolbar != null) toolbar!,
          Expanded(
            child: Row(
              children: [
                if (sidebar != null)
                  Container(
                    width: 361,
                    decoration: const BoxDecoration(
                      border: Border(
                        right: BorderSide(color: NRCSColors.borderGray, width: 8),
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
    final Map<String, String> routeMapping = {
      'Workspace': '/stories',
      'wire': '/admin/wire',
      'Desks': '/admin/desks',
      'Rundowns': '/rundowns',
      'Settings': '/settings',
    };

    final tabs = [
      'Workspace', 'wire', 'Desks', 'Rundowns', 'Media', 
      'Social', 'Reports', 'Anc Live', 'Settings'
    ];

    final currentRoute = Get.currentRoute;

    return Container(
      height: 50,
      color: NRCSColors.topNavBlue,
      child: Row(
        children: [
          ...tabs.map((tab) {
            final route = routeMapping[tab];
            bool isActive = false;
            
            if (route != null) {
              isActive = currentRoute == route;
            } else if (tab == 'Workspace' && currentRoute == '/') {
              isActive = true; // Splash/Initial
            }

            return _NavButton(
              label: tab, 
              isActive: isActive,
              onTap: () {
                if (route != null) {
                  if (currentRoute != route) {
                    Get.offAllNamed(route);
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
          }),
          const Spacer(),
          Text(
            _currentTime,
            style: const TextStyle(
              color: Color(0xFFC8E6C9), // Light green like in the image
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(width: 16),
          _UserSection(),
        ],
      ),
    );
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

    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;

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
          Get.snackbar('Events', 'Events calendar - Coming Soon', snackPosition: SnackPosition.BOTTOM);
          break;
        case 'preferences':
          Get.toNamed('/settings');
          break;
        case 'help':
          Get.snackbar('Help', 'Support and Documentation - Coming Soon', snackPosition: SnackPosition.BOTTOM);
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onSecondaryTapDown: (details) => _showWorkspaceMenu(context, details.globalPosition),
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
          alignment: Alignment.center,
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
  @override
  Widget build(BuildContext context) {
    final authService = Get.find<AuthService>();
    
    return Obx(() {
      final user = authService.currentUser.value;
      final displayName = user?.displayName ?? 'Admin';
      final photoUrl = user?.photoUrl;

      return Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            color: const Color(0xFF0D47A1),
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
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: Icon(Icons.notifications_none, color: Colors.white, size: 20),
          ),
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            color: const Color(0xFF0D47A1),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: Colors.white24,
                  backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
                  child: photoUrl == null 
                      ? const Icon(Icons.person, size: 18, color: Colors.white)
                      : null,
                ),
                const SizedBox(width: 8),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    const Text(
                      'Online',
                      style: TextStyle(color: Colors.greenAccent, fontSize: 10),
                    ),
                  ],
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.logout, color: Colors.white70, size: 20),
                  tooltip: 'Logout',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () => authService.signOut(),
                ),
              ],
            ),
          ),
        ],
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
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
                ),
                SizedBox(width: 16),
                BreakingNewsTicker(),
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
                Icon(Icons.trending_up, color: Colors.black54, size: 16),
                SizedBox(width: 8),
                Text(
                  'TRENDING STORIES',
                  style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 11),
                ),
                SizedBox(width: 16),
                TopStoriesTicker(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


class NRCSToolbar extends StatelessWidget {
  const NRCSToolbar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 45,
      color: NRCSColors.subNavGray,
      child: Row(
        children: [
          _ToolbarIcon(icon: Icons.refresh),
          _ToolbarButton(icon: Icons.folder_open, label: 'news'),
          _ToolbarButton(icon: Icons.folder_open, label: 'Politics'),
          _ToolbarSearch(),
          _ToolbarActionButton(label: 'New'),
          _ToolbarActionButton(label: 'Edit'),
          _ToolbarActionButton(label: 'Delete'),
          _ToolbarActionButton(label: 'Copy'),
          _ToolbarActionButton(label: 'Move'),
          _ToolbarActionButton(label: 'Link'),
          _ToolbarActionButton(label: 'Assign'),
          _ToolbarActionButton(label: 'Story Log'),
          _ToolbarActionButton(label: 'Print'),
          _ToolbarActionButton(label: 'Powerview', isBordered: true, borderColor: Colors.red),
          const Expanded(child: SizedBox()),
        ],
      ),
    );
  }
}

class _ToolbarIcon extends StatelessWidget {
  final IconData icon;
  const _ToolbarIcon({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 45,
      height: 45,
      decoration: BoxDecoration(
        border: Border.all(color: NRCSColors.borderGray),
      ),
      child: Icon(icon, size: 24),
    );
  }
}

class _ToolbarButton extends StatelessWidget {
  final IconData icon;
  final String label;

  const _ToolbarButton({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 45,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        border: Border.all(color: NRCSColors.borderGray),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _ToolbarSearch extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      height: 45,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        border: Border.all(color: NRCSColors.borderGray),
      ),
      child: const Row(
        children: [
          Icon(Icons.search, size: 18),
          const SizedBox(width: 4),
          Text('search', style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _ToolbarActionButton extends StatelessWidget {
  final String label;
  final bool isBordered;
  final Color? borderColor;

  const _ToolbarActionButton({
    required this.label, 
    this.isBordered = false,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 45,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        border: isBordered && borderColor != null
            ? Border.all(color: borderColor!, width: 2)
            : Border.all(color: NRCSColors.borderGray),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1976D2)),
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
  final bool isSelected;
  final VoidCallback onTap;

  const NRCSStoryListItem({
    super.key,
    required this.title,
    required this.author,
    required this.time,
    required this.date,
    required this.duration,
    required this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected ? NRCSColors.activeOrange : Colors.white,
          border: const Border(bottom: BorderSide(color: NRCSColors.borderGray)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      fontSize: 14,
                      color: isSelected ? Colors.white : const Color(0xFF0D47A1),
                    ),
                  ),
                ),
                Icon(
                  Icons.videocam, 
                  size: 16, 
                  color: isSelected ? Colors.white : Colors.grey[600]
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.person, size: 12, color: isSelected ? Colors.white70 : Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  author, 
                  style: TextStyle(
                    fontSize: 11, 
                    color: isSelected ? Colors.white70 : Colors.grey[600]
                  )
                ),
                const Spacer(),
                Icon(Icons.access_time, size: 12, color: isSelected ? Colors.white70 : Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  duration, 
                  style: TextStyle(
                    fontSize: 11, 
                    color: isSelected ? Colors.white70 : Colors.grey[600]
                  )
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 12, color: isSelected ? Colors.white70 : Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  '$time $date', 
                  style: TextStyle(
                    fontSize: 11, 
                    color: isSelected ? Colors.white70 : Colors.grey[600]
                  )
                ),
                const Spacer(),
                Icon(Icons.menu, size: 14, color: isSelected ? Colors.white70 : Colors.grey[600]),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
