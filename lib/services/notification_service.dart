import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    try {
      // Request permission for notifications
      NotificationSettings settings = await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: true,
        provisional: false,
        sound: true,
      );

      // Initialize local notifications for Android
      const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

      final InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);

      await _flutterLocalNotificationsPlugin.initialize(initializationSettings);

      // Get FCM token
      String? token = await _firebaseMessaging.getToken();
      print("FCM Token: $token");

      // Handle messages when app is in foreground
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print('Got a message whilst in the foreground!');
        print('Message data: ${message.data}');

        if (message.notification != null) {
          print('Message also contained a notification: ${message.notification}');
          showNotification(
            message.notification?.title ?? 'SafeHer Alert',
            message.notification?.body ?? 'Emergency notification',
          );
        }
      });

      // Handle background messages
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    } catch (e) {
      print('Notification initialization error: $e');
    }
  }

  @pragma('vm:entry-point')
  static Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    await Firebase.initializeApp();
    print("Handling a background message: ${message.messageId}");

    // Show notification for background messages
    if (message.notification != null) {
      showNotification(
        message.notification?.title ?? 'SafeHer Alert',
        message.notification?.body ?? 'Emergency notification',
      );
    }
  }

  static Future<void> showNotification(String title, String body) async {
    try {
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
        'safeher_emergency_channel', // channel id
        'SafeHer Emergency', // channel name
        channelDescription: 'Emergency alerts and notifications',
        importance: Importance.max,
        priority: Priority.high,
        ticker: 'ticker',
        playSound: true,
      );

      const NotificationDetails platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);

      await _flutterLocalNotificationsPlugin.show(
        0,
        title,
        body,
        platformChannelSpecifics,
        payload: 'emergency',
      );
    } catch (e) {
      print('Error showing notification: $e');
    }
  }

  static Future<void> sendEmergencyNotification(String title, String body) async {
    await showNotification(title, body);
  }

  // For SOS alerts
  static Future<void> sendSOSNotification(String userName, String location) async {
    await showNotification(
      '🚨 SOS Alert from $userName',
      'Emergency alert activated! Location: $location',
    );
  }

  // For safe walk completion
  static Future<void> sendSafeWalkNotification(String destination) async {
    await showNotification(
      '✅ Safe Walk Completed',
      'You have reached $destination safely',
    );
  }
}