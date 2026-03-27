import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:chamdtech_nrcs/core/models/notification_model.dart';
import 'package:chamdtech_nrcs/core/services/notification_service.dart';
import 'package:chamdtech_nrcs/features/auth/services/auth_service.dart';
import 'package:chamdtech_nrcs/app/routes/app_routes.dart';
import 'package:chamdtech_nrcs/core/constants/app_constants.dart';
import 'package:chamdtech_nrcs/features/stories/views/widgets/nrcs_layout.dart';
import 'package:chamdtech_nrcs/features/notifications/views/widgets/notification_card.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notificationService = Get.find<NotificationService>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: StreamBuilder<List<NotificationModel>>(
        stream: notificationService.getNotifications(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final notifications = snapshot.data ?? [];

          return CustomScrollView(
            slivers: [
              _buildSliverAppBar(context, notificationService, notifications),
              if (notifications.isEmpty)
                _buildEmptyState()
              else
                ..._buildNotificationGroups(notifications),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context, NotificationService service, List<NotificationModel> notifications) {
    final hasUnread = notifications.any((n) => !n.isRead);

    return SliverAppBar(
      floating: true,
      pinned: true,
      snap: true,
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: NRCSColors.topNavBlue),
        onPressed: () {
          try {
            if (Navigator.of(context).canPop()) {
              Get.back();
            } else {
              final authService = Get.find<AuthService>();
              final role = authService.currentUser.value?.role ?? AppConstants.roleReporter;
              final homeRoute = AppRoutes.getRouteForRole(role);
              Get.offAllNamed(homeRoute);
            }
          } catch (e) {
            Get.offAllNamed('/');
          }
        },
      ),
      title: const Text(
        'Notifications',
        style: TextStyle(
          color: NRCSColors.textDark,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
      actions: [
        if (hasUnread)
          TextButton(
            onPressed: () => service.markAllAsRead(),
            child: const Text('Mark all as read'),
          ),
        const SizedBox(width: 8),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          color: Colors.grey.shade200,
          height: 1,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.notifications_off_outlined,
                size: 64,
                color: Colors.grey.shade300,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No notifications yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'We\'ll notify you when something important happens.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildNotificationGroups(List<NotificationModel> notifications) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    final groups = <String, List<NotificationModel>>{
      'Today': [],
      'Yesterday': [],
      'Earlier': [],
    };

    for (final notification in notifications) {
      final date = DateTime(
        notification.createdAt.year,
        notification.createdAt.month,
        notification.createdAt.day,
      );

      if (date == today) {
        groups['Today']!.add(notification);
      } else if (date == yesterday) {
        groups['Yesterday']!.add(notification);
      } else {
        groups['Earlier']!.add(notification);
      }
    }

    final slivers = <Widget>[];

    groups.forEach((title, items) {
      if (items.isNotEmpty) {
        slivers.add(
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: Colors.grey.shade500,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),
        );

        slivers.add(
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => NotificationCard(notification: items[index]),
              childCount: items.length,
            ),
          ),
        );
      }
    });

    return slivers;
  }
}
