import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:home_service_app/main.dart';
import 'package:home_service_app/provider/booking_provider.dart';
import 'package:home_service_app/utils/route_generator.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

bool isForegroundMessage = false;

class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final storage = const FlutterSecureStorage();

  Future<void> initialize() async {
    // Request permission
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print("User granted permission");
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print("User granted provisional permission");
    } else {
      print("User declined or has not accepted permission");
      return;
    }

    // Get device token
    String? token = await _messaging.getToken();
    print("FCM Token: $token");
    await storage.write(key: "fcm_token", value: token);

    // Handle notifications in different states
    handleNotifications();

    // Handle notification when app is launched via notification
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        navigateToPage(message);
      }
    });
  }

  void handleNotifications() {
    // Foreground notifications
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      Logger().d('Foreground message received: ${message.notification?.title}');
      Logger().d('Message body: ${message.notification?.body}');

      // Optionally show a dialog for foreground notifications
      showGlobalNotification(message);
    });

    // Background notification tap
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Background notification clicked!');
      navigateToPage(message);
    });
  }

  void showGlobalNotification(RemoteMessage message) {
    final notification = message.notification;
    final android = message.notification?.android;
    final data = message.data;
    String? targetPage = data['targetPage'];
    String? value = data['value'];

    if (notification != null && android != null && !isForegroundMessage) {
      if (navigatorKey.currentContext != null) {
        showDialog(
          context: navigatorKey.currentContext!,
          builder: (context) => AlertDialog(
            title: Text(notification.title!),
            content: Text(notification.body!),
            actions: [
              TextButton(onPressed: () {}, child: const Text('Dismiss')),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  if (targetPage != null) {
                    if (targetPage == 'details') {
                      Navigator.of(navigatorKey.currentContext!,
                              rootNavigator: true)
                          .pushNamed('/details');
                    } else if (targetPage == 'profile') {
                      Navigator.of(navigatorKey.currentContext!,
                              rootNavigator: true)
                          .pushNamed('/customer_profile');
                    } else if (targetPage == 'booking' && value != null) {
                      Provider.of<BookingProvider>(navigatorKey.currentContext!,
                              listen: false)
                          .fetchSingleBooking(int.parse(value));
                      Navigator.of(navigatorKey.currentContext!,
                              rootNavigator: true)
                          .pushNamed(
                        RouteGenerator.detailBookingPage,
                      );
                    } else {
                      print("Unknown targetPage: $targetPage");
                    }
                  }
                },
                child: const Text('Go to the page'),
              ),
            ],
          ),
        );
        isForegroundMessage = true;
      }
    }
  }

  void navigateToPage(RemoteMessage message) {
    // Use the data payload to determine the page to navigate to
    final data = message.data;
    Logger().d(message);
    String? targetPage = data['targetPage'];
    String? value = data['value'];

    if (targetPage != null) {
      if (targetPage == 'details') {
        Navigator.of(navigatorKey.currentContext!, rootNavigator: true)
            .pushNamed('/details');
      } else if (targetPage == 'profile') {
        Navigator.of(navigatorKey.currentContext!, rootNavigator: true)
            .pushNamed('/customer_profile');
      } else if (targetPage == 'booking' && value != null) {
        Provider.of<BookingProvider>(navigatorKey.currentContext!,
                listen: false)
            .fetchSingleBooking(int.parse(value));
        Navigator.of(navigatorKey.currentContext!, rootNavigator: true)
            .pushNamed(
          RouteGenerator.detailBookingPage,
        );
      } else {
        print("Unknown targetPage: $targetPage");
      }
    }
  }
}
