import 'package:flutter/material.dart';
import 'package:home_service_app/provider/notification_provider.dart';
import 'package:home_service_app/provider/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Notifications'),
        actions: [
          user != null
              ? TextButton(
                  onPressed: () {
                    Provider.of<NotificationProvider>(context, listen: false)
                        .markAllAsRead(user.id);
                  },
                  child: const Text('Mark All As Read',
                      style: TextStyle(color: Colors.blue)))
              : const SizedBox.shrink(),
        ],
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, notificationProvider, child) {
          if (notificationProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (notificationProvider.notifications.isEmpty) {
            return Center(
              child: Text(
                'You have no notifications',
                style: TextStyle(
                  fontSize: 22.sp,
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          }
          return Padding(
            padding: EdgeInsets.only(top: 16.h),
            child: ListView.builder(
              itemCount: notificationProvider.notifications.length,
              itemBuilder: (context, index) {
                final notification = notificationProvider.notifications[index];
                return Container(
                  margin: EdgeInsets.symmetric(vertical: 2.h, horizontal: 16.w),
                  padding: EdgeInsets.only(
                      left: 2.w, top: 16.h, right: 16.w, bottom: 8.h),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: EdgeInsets.only(right: 8.w),
                        child: Transform.scale(
                          scale: 1.2,
                          child: Checkbox(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                            activeColor: Colors.blue,
                            checkColor: Colors.white,
                            value: notification.readStatus,
                            onChanged: (bool? value) {
                              if (value != null) {
                                notificationProvider
                                    .markAsRead(notification.id);
                              }
                            },
                          ),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            notification.title,
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                              letterSpacing: 0.5,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            notification.message,
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.black54,
                              height: 1.5,
                              letterSpacing: 0.2,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          TextButton(
                            onPressed: () {
                              notificationProvider.markAsRead(notification.id);
                              notificationProvider.navigateToPage(
                                  context, notification.relatedEntityId);
                            },
                            child: Text(
                              'View Details',
                              style: TextStyle(
                                  fontSize: 14.sp, color: Colors.blue),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
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
