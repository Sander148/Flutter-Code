import 'package:flutter/material.dart';

import 'chat_screen.dart';
import 'habi_colors.dart';
import 'job_store.dart';
import 'message_store.dart';
import 'my_applications_screen.dart';
import 'notification_store.dart';

/// Notifications: opens from the bell on the Home screen.
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key, required this.userName});

  final String userName;

  void _open(BuildContext context, AppNotification n) {
    NotificationStore.instance.markRead(n.id);

    if (n.kind == NotificationKind.status) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => MyApplicationsScreen(userName: userName),
        ),
      );
      return;
    }

    var conversationId = n.conversationId;
    if (conversationId == null) {
      final job = n.jobId == null ? null : JobStore.instance.byId(n.jobId!);
      final other = n.otherUser;
      if (job == null || other == null) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: const Text('This job is no longer available.'),
              behavior: SnackBarBehavior.floating,
              backgroundColor: HabiColors.navyLight,
            ),
          );
        return;
      }
      conversationId = MessageStore.instance
          .startOrGet(
            jobId: job.id,
            jobTitle: job.title,
            poster: job.postedBy,
            applicant: other,
          )
          .id;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChatScreen(
          conversationId: conversationId!,
          userName: userName,
        ),
      ),
    );
  }

  IconData _icon(NotificationKind kind) {
    switch (kind) {
      case NotificationKind.application:
        return Icons.person_add_alt_1_outlined;
      case NotificationKind.status:
        return Icons.update;
      case NotificationKind.message:
        return Icons.chat_bubble_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HabiColors.navy,
      appBar: AppBar(
        backgroundColor: HabiColors.navy,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Notifications',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        actions: [
          TextButton(
            onPressed: () => NotificationStore.instance.markAllRead(userName),
            style: TextButton.styleFrom(foregroundColor: HabiColors.gold),
            child: const Text('Mark all read'),
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/habi_bg.jpg', fit: BoxFit.cover),
          Container(color: HabiColors.navy.withAlpha(225)),
          SafeArea(
            child: ListenableBuilder(
              listenable: NotificationStore.instance,
              builder: (context, _) {
                final items = NotificationStore.instance.listFor(userName);
                if (items.isEmpty) return _buildEmpty();
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  itemCount: items.length,
                  itemBuilder: (context, i) => _buildItem(context, items[i]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItem(BuildContext context, AppNotification n) {
    return GestureDetector(
      onTap: () => _open(context, n),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: HabiColors.navy.withAlpha(200),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: n.read
                ? HabiColors.cream.withAlpha(60)
                : HabiColors.gold.withAlpha(160),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: HabiColors.navyLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(_icon(n.kind), color: HabiColors.gold, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          n.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      if (!n.read)
                        Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            color: HabiColors.gold,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    n.body,
                    style: TextStyle(
                      fontSize: 14,
                      color: HabiColors.cream.withAlpha(220),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    formatTimeAgo(n.time),
                    style: TextStyle(
                      fontSize: 12,
                      color: HabiColors.cream.withAlpha(150),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.notifications_none,
              color: HabiColors.gold,
              size: 44,
            ),
            const SizedBox(height: 12),
            const Text(
              'No notifications yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'New applications, messages and updates will show up here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: HabiColors.cream.withAlpha(200),
              ),
            ),
          ],
        ),
      ),
    );
  }
}