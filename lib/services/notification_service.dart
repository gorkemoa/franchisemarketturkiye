import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:franchisemarketturkiye/services/deep_link_service.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

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

  // Mükerrer bildirimleri engellemek için cache
  static final Set<String> _processedMessageIds = {};

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
            defaultPresentAlert: true, // Ön planda uyarıyı göster
            defaultPresentSound: true, // Ön planda sesi çal
            defaultPresentBadge: true, // Ön planda rozeti güncelle
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
          alert:
              true, // Uygulama açıkken uyarının sistem tarafından da gösterilmesini sağla
          badge: true,
          sound: true,
        );
      }

      // 4. Handle Foreground Messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        final String? msgId = message.messageId;
        if (msgId != null) {
          if (_processedMessageIds.contains(msgId)) {
            developer.log('♻️ Message already processed: $msgId', name: 'FCM');
            return;
          }
          _processedMessageIds.add(msgId);
          // Cache'i temiz tut (son 100 mesaj)
          if (_processedMessageIds.length > 100) {
            _processedMessageIds.remove(_processedMessageIds.first);
          }
        }

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

      // iOS için yerel bildirim iznini açıkça iste (Ön planda banner için kritik)
      if (Platform.isIOS) {
        final bool? granted = await _localNotifications
            .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin
            >()
            ?.requestPermissions(alert: true, badge: true, sound: true);
        developer.log(
          '🍎 iOS Local Notification Permission: $granted',
          name: 'FCM',
        );
      }

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

  static Future<void> _showNotification(RemoteMessage message) async {
    RemoteNotification? notification = message.notification;
    String? title =
        notification?.title ?? message.data['title'] ?? message.data['header'];
    String? body =
        notification?.body ?? message.data['body'] ?? message.data['message'];
    String? imageUrl =
        (message.data['image_url'] ??
                notification?.android?.imageUrl ??
                notification?.apple?.imageUrl)
            ?.toString();

    if (title == null && body == null) return;

    BigPictureStyleInformation? bigPictureStyle;
    String? largeIconPath;

    if (imageUrl != null && imageUrl.isNotEmpty) {
      try {
        developer.log(
          '🖼️ Downloading image for notification: $imageUrl',
          name: 'FCM',
        );
        // Uzantıyı linkten belirle (png mi jpg mi?)
        final String extension = imageUrl.toLowerCase().contains('.png')
            ? 'png'
            : 'jpg';
        final String imagePath = await _downloadAndSaveFile(
          imageUrl,
          'notification_img_${DateTime.now().millisecondsSinceEpoch}.$extension',
        );
        largeIconPath = imagePath;

        final int fileSize = await File(imagePath).length();
        developer.log(
          '💾 File saved: $imagePath ($fileSize bytes)',
          name: 'FCM',
        );

        bigPictureStyle = BigPictureStyleInformation(
          FilePathAndroidBitmap(imagePath),
          largeIcon: FilePathAndroidBitmap(imagePath),
          contentTitle: title,
          summaryText: body,
        );
        developer.log('✅ Image downloaded successfully', name: 'FCM');

        // iOS için dosyanın diskte tam olarak hazırlandığından emin olmak için kısa bir bekleme
        if (Platform.isIOS) {
          await Future.delayed(const Duration(milliseconds: 500));
        }
      } catch (e) {
        developer.log(
          '❌ Error downloading notification image: $e',
          name: 'FCM',
        );
      }
    }

    final int notificationId =
        notification?.hashCode ??
        (message.messageId != null
            ? message.messageId.hashCode
            : DateTime.now().millisecond);

    try {
      // iOS için dosya varlığını kontrol et
      if (Platform.isIOS && largeIconPath != null) {
        final file = File(largeIconPath);
        if (!await file.exists()) {
          developer.log(
            '⚠️ Image file missing before display: $largeIconPath',
            name: 'FCM',
          );
        } else {
          developer.log(
            '👍 Image file confirmed at: $largeIconPath',
            name: 'FCM',
          );
        }
      }

      developer.log(
        '🔔 Triggering local notification: ID $notificationId (Title: $title)',
        name: 'FCM',
      );
      await _localNotifications.show(
        notificationId,
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
            styleInformation: bigPictureStyle,
          ),
          iOS: DarwinNotificationDetails(
            presentSound: true,
            presentAlert: true,
            presentBadge: true,
            presentBanner: true, // Açıkça banner gösterilmesini iste
            presentList: true, // Bildirim merkezinde listelenmesini iste
            interruptionLevel: InterruptionLevel.active, // Aktif uyarı
            attachments: (largeIconPath != null)
                ? [
                    DarwinNotificationAttachment(
                      largeIconPath,
                      identifier:
                          'image_${DateTime.now().millisecondsSinceEpoch}',
                    ),
                  ]
                : null,
          ),
        ),
        payload: jsonEncode(message.data),
      );
      developer.log('✅ Local notification displayed', name: 'FCM');
    } catch (e) {
      developer.log('❌ Error showing local notification: $e', name: 'FCM');
    }
  }

  static Future<String> _downloadAndSaveFile(
    String url,
    String fileName,
  ) async {
    try {
      // iOS için Documents directory daha güvenlidir
      final Directory directory = Platform.isIOS
          ? await getApplicationDocumentsDirectory()
          : await getTemporaryDirectory();

      final String filePath = '${directory.path}/$fileName';
      final response = await http
          .get(
            Uri.parse(url),
            headers: {
              'User-Agent':
                  'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
              'Accept':
                  'image/avif,image/webp,image/apng,image/svg+xml,image/*,*/*;q=0.8',
            },
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final String? contentType = response.headers['content-type'];
        developer.log('📄 Download Content-Type: $contentType', name: 'FCM');

        final File file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);
        return filePath;
      } else {
        throw Exception('Download failed with status: ${response.statusCode}');
      }
    } catch (e) {
      developer.log('❌ Image download error: $e', name: 'FCM');
      rethrow;
    }
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
    String? linkUrl = finalData['link_url']?.toString();

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
      // Sadece görsel içeren test mesajları için log kirliliğini engelle
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
