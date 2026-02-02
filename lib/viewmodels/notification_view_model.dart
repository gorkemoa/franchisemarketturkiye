import 'package:flutter/material.dart';
import 'package:franchisemarketturkiye/models/notification.dart';
import 'package:franchisemarketturkiye/services/notification_api_service.dart';

class NotificationViewModel extends ChangeNotifier {
  static final NotificationViewModel _instance =
      NotificationViewModel._internal();
  factory NotificationViewModel() => _instance;
  NotificationViewModel._internal({NotificationApiService? notificationService})
    : _notificationService = notificationService ?? NotificationApiService();

  final NotificationApiService _notificationService;

  List<AppNotification> _notifications = [];
  List<AppNotification> get notifications => _notifications;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> fetchNotifications({int limit = 20}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _notificationService.getNotifications(limit: limit);

    _isLoading = false;
    if (result.isSuccess && result.data != null) {
      _notifications = result.data!;
    } else {
      _errorMessage = result.error ?? 'Bildirimler yüklenirken bir hata oluştu';
    }
    notifyListeners();
  }
}
