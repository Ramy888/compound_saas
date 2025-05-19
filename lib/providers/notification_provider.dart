import 'package:flutter/material.dart';
import '../models/notification_model.dart';
import '../services/notification_service.dart';

enum NotificationOperationStatus {
  initial,
  loading,
  success,
  error
}

class NotificationProvider extends ChangeNotifier {
  final NotificationService _notificationService = NotificationService();
  NotificationOperationStatus _status = NotificationOperationStatus.initial;
  String? _error;
  bool _isLoading = false;

  NotificationOperationStatus get status => _status;
  String? get error => _error;
  bool get isLoading => _isLoading;

  Stream<List<NotificationModel>> getNotifications({bool activeOnly = true}) {
    return _notificationService.getNotifications(activeOnly: activeOnly);
  }

  Future<void> sendNotification(NotificationModel notification) async {
    try {
      _setLoading(true);
      _status = NotificationOperationStatus.loading;
      await _notificationService.sendNotification(notification);
      _status = NotificationOperationStatus.success;
    } catch (e) {
      _error = e.toString();
      _status = NotificationOperationStatus.error;
      rethrow;
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  Future<void> scheduleNotification(NotificationModel notification) async {
    try {
      _setLoading(true);
      _status = NotificationOperationStatus.loading;
      await _notificationService.scheduleNotification(notification);
      _status = NotificationOperationStatus.success;
    } catch (e) {
      _error = e.toString();
      _status = NotificationOperationStatus.error;
      rethrow;
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  Future<void> toggleNotificationStatus(String notificationId, bool isActive) async {
    try {
      _setLoading(true);
      await _notificationService.toggleNotificationStatus(notificationId, isActive);
      _status = NotificationOperationStatus.success;
    } catch (e) {
      _error = e.toString();
      _status = NotificationOperationStatus.error;
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void resetStatus() {
    _status = NotificationOperationStatus.initial;
    _error = null;
    notifyListeners();
  }
}