import 'package:flutter/material.dart';
import 'package:home_service_app/provider/notification_provider.dart';
import 'package:provider/provider.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: Consumer<NotificationProvider>(
        builder: (context, notificationProvider, child) {
          return ListView.builder(
            itemCount: notificationProvider.notifications.length,
            itemBuilder: (context, index) {
              final notification = notificationProvider.notifications[index];
              return ListTile(
                title: Text(notification.title),
                subtitle: Text(notification.message),
                trailing: notification.readStatus
                    ? const Icon(Icons.check_circle, color: Colors.green)
                    : const Icon(Icons.circle, color: Colors.red),
                onTap: () {
                  notificationProvider.markAsRead(notification.id);
                  notificationProvider.navigateToPage(
                      context, notification.relatedEntityId);
                },
              );
            },
          );
        },
      ),
    );
  }
}

class SomeOtherPage extends StatelessWidget {
  final int relatedEntityId;

  const SomeOtherPage({super.key, required this.relatedEntityId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Entity Details')),
      body: Center(child: Text('Details for entity $relatedEntityId')),
    );
  }
}
