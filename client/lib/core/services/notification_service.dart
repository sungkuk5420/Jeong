import 'dart:convert';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../firebase_options.dart';
import 'supabase_service.dart';

// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

class NotificationService {
  static final _messaging = FirebaseMessaging.instance;
  static final _localNotifications = FlutterLocalNotificationsPlugin();

  static const _androidChannel = AndroidNotificationChannel(
    'jeong_default',
    'Jeong Notifications',
    description: 'Default notification channel for Jeong app',
    importance: Importance.high,
  );

  static Future<void> initialize() async {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

    // Set background handler
    FirebaseMessaging.onBackgroundMessage(
        _firebaseMessagingBackgroundHandler);

    // Request permission
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      debugPrint('Push notifications denied');
      return;
    }

    // Initialize local notifications (for foreground)
    await _localNotifications.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      ),
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // Create Android notification channel
    if (Platform.isAndroid) {
      await _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(_androidChannel);
    }

    // Listen to foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle notification tap (app in background)
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

    // Save FCM token to Supabase profile
    await _saveFcmToken();

    // Listen for token refresh
    _messaging.onTokenRefresh.listen((token) => _saveFcmToken(token: token));
  }

  static Future<void> _saveFcmToken({String? token}) async {
    final fcmToken = token ?? await _messaging.getToken();
    final userId = SupabaseService.userId;

    if (fcmToken != null && userId != null) {
      await SupabaseService.profiles().update({
        'fcm_token': fcmToken,
      }).eq('id', userId);
    }
  }

  static void _handleForegroundMessage(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;

    _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _androidChannel.id,
          _androidChannel.name,
          channelDescription: _androidChannel.description,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      payload: jsonEncode(message.data),
    );
  }

  static void _handleNotificationTap(RemoteMessage message) {
    // Navigate based on notification data
    final placeId = message.data['place_id'];
    if (placeId != null) {
      // Will be handled by GoRouter navigation
      debugPrint('Navigate to place: $placeId');
    }
  }

  static void _onNotificationTap(NotificationResponse response) {
    if (response.payload != null) {
      final data = jsonDecode(response.payload!) as Map<String, dynamic>;
      final placeId = data['place_id'];
      if (placeId != null) {
        debugPrint('Navigate to place: $placeId');
      }
    }
  }

  // Subscribe to topic
  static Future<void> subscribeTo(String topic) async {
    await _messaging.subscribeToTopic(topic);
  }

  // Unsubscribe from topic
  static Future<void> unsubscribeFrom(String topic) async {
    await _messaging.unsubscribeFromTopic(topic);
  }
}
