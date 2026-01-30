import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:franchisemarketturkiye/services/deep_link_service.dart';

/// Top-level function to handle background messages
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  developer.log('📬 Background message received', name: 'FCM');
  developer.log('Message ID: ${message.messageId}', name: 'FCM');
}

class FirebaseMessagingService {
  static final FirebaseMessaging _firebaseMessaging =
      FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'high_importance_channel_v2',
    'High Importance Notifications',
    description: 'This channel is used for important notifications.',
    importance: Importance.max,
    playSound: true,
    enableVibration: true,
  );

  /// Initialize Firebase Messaging and Local Notifications
  static Future<void> initialize() async {
    try {
      developer.log('🚀 Initializing Notification Service', name: 'FCM');

      // 1. Request notification permissions (iOS & Android 13+)
      final settings = await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      developer.log(
        '📱 Permission status: ${settings.authorizationStatus}',
        name: 'FCM',
      );

      // 2. Initialize Flutter Local Notifications
      const AndroidInitializationSettings androidInitialize =
          AndroidInitializationSettings('@mipmap/launcher_icon');

      const DarwinInitializationSettings iosInitialize =
          DarwinInitializationSettings(
            requestSoundPermission: true,
            requestBadgePermission: true,
            requestAlertPermission: true,
          );

      const InitializationSettings initializationSettings =
          InitializationSettings(
            android: androidInitialize,
            iOS: iosInitialize,
          );

      await _localNotifications.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          if (response.payload != null) {
            _handlePayload(response.payload!);
          }
        },
      );

      if (Platform.isAndroid) {
        await _localNotifications
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >()
            ?.createNotificationChannel(_channel);
        developer.log('✅ Android Notification Channel Created', name: 'FCM');
      }

      // 3. iOS Foreground Presentation Options
      if (Platform.isIOS) {
        await _firebaseMessaging.setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        );
      }

      // 4. Handle Foreground Messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        developer.log('📨 Foreground message received', name: 'FCM');
        _showNotification(message);
      });

      // 5. Handle notification taps (Background / Terminated)
      FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageNavigation);

      RemoteMessage? initialMessage = await _firebaseMessaging
          .getInitialMessage();
      if (initialMessage != null) {
        developer.log(
          '🔔 App opened from terminated state via FCM',
          name: 'FCM',
        );
        Future.delayed(const Duration(milliseconds: 1000), () {
          _handleMessageNavigation(initialMessage);
        });
      }

      // 6. Token Handling & Topic Subscription
      final token = await _firebaseMessaging.getToken();
      developer.log('🔑 FCM Token: $token', name: 'FCM');

      FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
        developer.log('🔄 FCM Token refreshed: $newToken', name: 'FCM');
      });

      // Subscribe to GorkemTest topic as requested
      await subscribeToTopic('GorkemTest');

      // Background Message Handler
      FirebaseMessaging.onBackgroundMessage(
        _firebaseMessagingBackgroundHandler,
      );

      developer.log('✅ Initialization complete', name: 'FCM');
    } catch (e, stackTrace) {
      developer.log(
        '❌ Error initializing FCM',
        name: 'FCM',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  static void _showNotification(RemoteMessage message) {
    RemoteNotification? notification = message.notification;
    String? title =
        notification?.title ?? message.data['title'] ?? message.data['header'];
    String? body =
        notification?.body ?? message.data['body'] ?? message.data['message'];

    if (title == null && body == null) return;

    _localNotifications.show(
      notification.hashCode,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          icon: '@mipmap/launcher_icon',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
        ),
        iOS: const DarwinNotificationDetails(
          presentSound: true,
          presentAlert: true,
          presentBadge: true,
        ),
      ),
      payload: jsonEncode(message.data),
    );
  }

  static void _handleMessageNavigation(RemoteMessage message) {
    _processNavigation(message.data);
  }

  static void _handlePayload(String payload) {
    try {
      final Map<String, dynamic> data = jsonDecode(payload);
      _processNavigation(data);
    } catch (e) {
      // If it's not JSON, it might be the legacy 'page' string
      _processNavigation({'page': payload});
    }
  }

  static void _processNavigation(Map<String, dynamic> data) {
    developer.log('🚀 Processing Navigation Data: $data', name: 'FCM');
    if (data.isEmpty) return;

    Map<String, dynamic> finalData = Map.from(data);

    // Support nested keysandvalues if present
    if (finalData.containsKey('keysandvalues')) {
      try {
        String jsonStr = finalData['keysandvalues'].toString();
        // Sanitize common malformed JSON issues
        if (jsonStr.contains(': }') || jsonStr.contains(':, }')) {
          jsonStr = jsonStr.replaceAll(RegExp(r':\s*}'), ': null}');
        }
        final nested = jsonDecode(jsonStr);
        if (nested is Map) {
          finalData.addAll(Map<String, dynamic>.from(nested));
        }
      } catch (e) {
        developer.log('❌ Error parsing keysandvalues: $e', name: 'FCM');
      }
    }

    String? type;
    String? id;

    // Support 'page' legacy format
    if (finalData.containsKey('page') && finalData['page'] != null) {
      final String page = finalData['page'];
      final parts = page.split('/');
      type = parts[0];
      id = parts.length > 1 ? parts[1] : null;
    } else {
      type = finalData['type']?.toString();
      id = (finalData['id'] ?? finalData['type_id'])?.toString();
    }

    // Map 'news' to 'kategori' logic
    if (type == 'news') type = 'kategori';

    if (type == null || id == null) {
      developer.log('⚠️ Missing type or ID for navigation', name: 'FCM');
      return;
    }

    DeepLinkService().handleNavigation(type, id);
  }

  static Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      developer.log('📌 Subscribed to topic: $topic', name: 'FCM');
    } catch (e) {
      developer.log('❌ Error subscribing to $topic', name: 'FCM', error: e);
    }
  }

  static Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      developer.log('📌 Unsubscribed from topic: $topic', name: 'FCM');
    } catch (e) {
      developer.log('❌ Error unsubscribing from $topic', name: 'FCM', error: e);
    }
  }
}
