import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// Background message handler for FCM
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Initialize Firebase if needed for background operations
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Error initializing Firebase in background handler: $e');
  }
  debugPrint('Handling a background message: ${message.messageId}');
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  FirebaseMessaging? _firebaseMessaging;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    // 1. Initialize Flutter Local Notifications
    try {
      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      
      const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );

      const InitializationSettings initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _localNotifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          debugPrint('Notification clicked: ${response.payload}');
        },
      );
      
      // Request permission on Android 13+
      await _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();

      debugPrint('Local notifications initialized successfully');
    } catch (e) {
      debugPrint('Error initializing local notifications: $e');
    }

    // 2. Initialize Firebase Messaging (wrapped in try-catch to prevent app crash if Firebase config is absent)
    try {
      await Firebase.initializeApp();
      _firebaseMessaging = FirebaseMessaging.instance;
      
      // Set background handler
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      // Request FCM permissions
      NotificationSettings settings = await _firebaseMessaging!.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );
      
      debugPrint('User granted push permission: ${settings.authorizationStatus}');

      // Get FCM token
      String? token = await _firebaseMessaging!.getToken();
      debugPrint('FCM Token: $token');

      // Listen to token refreshes
      _firebaseMessaging!.onTokenRefresh.listen((newToken) {
        debugPrint('FCM Token Refreshed: $newToken');
      });

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('Received foreground message: ${message.notification?.title}');
        
        // Show as a local notification since FCM doesn't show alerts when in the foreground
        if (message.notification != null) {
          showLocalNotification(
            id: message.hashCode,
            title: message.notification!.title ?? 'New Notification',
            body: message.notification!.body ?? '',
            payload: message.data.toString(),
          );
        }
      });

      // Handle when the user taps on a notification and the app is opened from background
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        debugPrint('App opened via push notification: ${message.data}');
      });

      // Handle initial message when the app is opened from terminated state
      RemoteMessage? initialMessage = await _firebaseMessaging!.getInitialMessage();
      if (initialMessage != null) {
        debugPrint('App launched via push notification: ${initialMessage.data}');
      }

      debugPrint('Firebase Messaging initialized successfully');
    } catch (e) {
      debugPrint('FCM is not configured or failed to initialize: $e');
      debugPrint('Running in local-notifications-only mode.');
    }

    _isInitialized = true;
  }

  // Helper method to show a local notification on demand
  Future<void> showLocalNotification({
    int id = 0,
    required String title,
    required String body,
    String? payload,
  }) async {
    try {
      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'eco_sevaks_channel',
        'Eco-Sevaks Notifications',
        channelDescription: 'Notifications related to Eco-Sevaks events and actions',
        importance: Importance.max,
        priority: Priority.high,
        ticker: 'ticker',
      );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const NotificationDetails platformDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _localNotifications.show(
        id,
        title,
        body,
        platformDetails,
        payload: payload,
      );
    } catch (e) {
      debugPrint('Error showing local notification: $e');
    }
  }
}
