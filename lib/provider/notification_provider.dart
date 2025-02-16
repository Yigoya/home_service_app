import 'package:flutter/material.dart';
import 'package:home_service_app/models/notification.dart';
import 'package:home_service_app/services/api_service.dart';
import 'package:logger/logger.dart';

class NotificationProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<NotificationModel> _notifications = [];
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<NotificationModel> get notifications => _notifications;

  void loadNotifications(int userId) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response =
          await _apiService.getRequest('/notifications/unread/$userId');
      _notifications = response.data
          .map<NotificationModel>((n) => NotificationModel.fromJson(n))
          .toList();
      notifyListeners();
    } catch (e) {
      print('Failed to load notifications: $e');
    }
    _isLoading = false;
  }

  void markAsRead(int id) async {
    try {
      final response =
          await _apiService.putRequest('/notifications/$id/mark-as-read', {});
      Logger().d(response.data);

      final notification = _notifications.firstWhere((n) => n.id == id);
      notification.readStatus = true;
      notifyListeners();
    } catch (e) {
      print('Failed to load notifications: $e');
    }
  }

  void markAllAsRead(int userId) async {
    try {
      final response = await _apiService
          .putRequest('/notifications/mark-all-as-read/$userId', {});
      Logger().d(response.data);

      for (var n in _notifications) {
        n.readStatus = true;
      }
      notifyListeners();
    } catch (e) {
      print('Failed to load notifications: $e');
    }
  }

  void navigateToPage(BuildContext context, int relatedEntityId) {
    // Example navigation based on `relatedEntityId`
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     // builder: (context) => SomeOtherPage(relatedEntityId: relatedEntityId),
    //   ),
    // );
  }
}
