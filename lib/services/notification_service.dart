import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    tz.initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings();

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    await _notificationsPlugin.initialize(initializationSettings);
    _isInitialized = true;
  }

  Future<void> showDesktopNotification({
    required String title,
    required String body,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'weatherboo_channel',
      'Weatherboo Notifications',
      channelDescription: 'Weather alerts and updates',
      importance: Importance.high,
      priority: Priority.high,
    );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails();

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await _notificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      platformChannelSpecifics,
    );
  }

  Future<void> sendEmailNotification({
    required String email,
    required String subject,
    required String body,
  }) async {
    // Email notifications would be sent via backend service
    // For now, this is a placeholder for the email notification logic
    // In a real implementation, this would call your backend API or email service
    print('Email notification to: $email');
    print('Subject: $subject');
    print('Body: $body');
  }

  Future<void> sendNotification({
    required String email,
    required String title,
    required String body,
    bool sendEmail = true,
    bool sendDesktop = true,
  }) async {
    if (sendDesktop) {
      await showDesktopNotification(title: title, body: body);
    }

    if (sendEmail) {
      await sendEmailNotification(
        email: email,
        subject: title,
        body: body,
      );
    }
  }
}
