import 'package:flutter/material.dart';
import '../core/api_client.dart';
import '../models/app_notification.dart';

class NotificationProvider extends ChangeNotifier {
  final ApiClient _apiClient = ApiClient();
  List<AppNotification> _notifications = [];
  int _unreadCount = 0;
  bool _isLoading = false;

  List<AppNotification> get notifications => _notifications;
  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;

  Future<void> fetchNotifications() async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _apiClient.dio.get('/notifications');
      if (response.statusCode == 200) {
        _notifications = (response.data as List)
            .map((e) => AppNotification.fromJson(e))
            .toList();
      }
    } catch (e) {
      print('Error fetching notifications: $e');
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchUnreadCount() async {
    try {
      final response = await _apiClient.dio.get('/notifications/unread-count');
      if (response.statusCode == 200) {
        _unreadCount = response.data['count'] ?? 0;
        notifyListeners();
      }
    } catch (e) {
      print('Error fetching unread count: $e');
    }
  }

  Future<void> markAsRead(int id) async {
    try {
      await _apiClient.dio.put('/notifications/$id/read');
      final index = _notifications.indexWhere((n) => n.id == id);
      if (index != -1) {
        // Refresh the list after marking as read
        await fetchNotifications();
        await fetchUnreadCount();
      }
    } catch (e) {
      print('Error marking notification as read: $e');
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await _apiClient.dio.put('/notifications/read-all');
      await fetchNotifications();
      _unreadCount = 0;
      notifyListeners();
    } catch (e) {
      print('Error marking all as read: $e');
    }
  }
}
