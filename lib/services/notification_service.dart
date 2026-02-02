import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:franchisemarketturkiye/services/deep_link_service.dart';

/// Top-level function to handle background messages
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  developer.log('📬 Background message received', name: 'FCM');
}

class FirebaseMessagingService {
  static final FirebaseMessaging _firebaseMessaging =
      FirebaseMessaging.instance;

  /// Initialize Firebase Messaging
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

      // 2. iOS Foreground Presentation Options
      if (Platform.isIOS) {
        await _firebaseMessaging.setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        );
      }

      // 3. Handle Foreground Messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        developer.log('📨 Foreground message received', name: 'FCM');
        if (message.notification != null) {
          final imageUrl =
              message.notification?.android?.imageUrl ??
              message.notification?.apple?.imageUrl;
          developer.log('🖼️ System Image URL: $imageUrl', name: 'FCM');
        }
      });

      // 4. Handle notification taps (Background / Terminated)
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

      // 5. Token Handling & Topic Subscription
      final token = await _firebaseMessaging.getToken();
      developer.log('🔑 FCM Token: $token', name: 'FCM');

      FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
        developer.log('🔄 FCM Token refreshed: $newToken', name: 'FCM');
      });

      // Subscribe to GorkemTest topic as requested
      await subscribeToTopic('GorkemTest');

      // 6. Background Message Handler
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

  static void _handleMessageNavigation(RemoteMessage message) {
    _processNavigation(message.data);
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
    String? linkUrl = finalData['link_url']?.toString();
    String? targetType = finalData['target_type']?.toString();
    String? itemId = finalData['item_id']?.toString();

    // Handle internal navigation for blog and magazine
    if (itemId != null) {
      if (targetType == 'internal') {
        developer.log(
          '🏠 Internal target detected, navigating to blog: $itemId',
          name: 'FCM',
        );
        DeepLinkService().handleNavigation('blog', itemId);
        return;
      } else if (targetType == 'magazine') {
        developer.log(
          '📖 Magazine target detected, navigating to magazine: $itemId',
          name: 'FCM',
        );
        DeepLinkService().handleNavigation('magazine', itemId);
        return;
      }
    }

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
      if (linkUrl != null && linkUrl.isNotEmpty) {
        developer.log('🔗 Navigating via link_url: $linkUrl', name: 'FCM');
        DeepLinkService().handleUrl(linkUrl);
        return;
      }
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
