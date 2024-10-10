import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:logger/logger.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:permission_handler/permission_handler.dart';
import 'package:medicare/features/reminder/logger.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin
      _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  static int _lastNotificationId = 0;

  static Future<void> initialize() async {
    logger.i("Initializing notification service...");
    //request permission for notifications
    await _requestNotificationPermission();
    logger.i("Notification permission requested");
    // Initialize time zone
    tz.initializeTimeZones();
    logger.i("Time zone initialized");

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings(
            'flutter_logo'); // Change the icon as needed

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse:
          (NotificationResponse notificationResponse) {
        // Handle notification tap
        _onNotificationTap(notificationResponse.payload);
      },
    );

    // Create notification channels
    await _createNotificationChannels();
  }

  static Future<void> _requestNotificationPermission() async {
    final status = await Permission.notification.request();
    if (status.isDenied) {
      // The permission has been denied, you can show an explanation to the user
      logger.i("Notification permission denied.");
    } else if (status.isPermanentlyDenied) {
      // The permission is permanently denied, you can open app settings
      logger.i(
          "Notification permission permanently denied. Please enable it in settings.");
      openAppSettings();
    } else {
      // The permission is granted
      logger.i("Notification permission granted.");
    }
  }

  static Future<void> _createNotificationChannels() async {
    const AndroidNotificationChannel highPriorityChannel =
        AndroidNotificationChannel(
            'high_priority_channel', // id
            'High Priority Notifications', // title
            description:
                'This channel is used for high priority notifications.',
            importance: Importance.max // Max importance for high priority
            );

    const AndroidNotificationChannel mediumPriorityChannel =
        AndroidNotificationChannel(
      'medium_priority_channel', // id
      'Medium Priority Notifications', // title
      description: 'This channel is used for medium priority notifications.',
      importance: Importance.defaultImportance, // Medium importance
    );

    const AndroidNotificationChannel lowPriorityChannel =
        AndroidNotificationChannel(
      'low_priority_channel', // id
      'Low Priority Notifications', // title
      description: 'This channel is used for low priority notifications.',
      importance: Importance.low, // Low importance
    );

    // Register the channels with the notifications plugin
    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(highPriorityChannel);
    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(mediumPriorityChannel);
    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(lowPriorityChannel);
  }

  //helper to convert datetime to TZDateTime
  static tz.TZDateTime _convertToTZDateTime(DateTime dateTime) {
    final tz.TZDateTime scheduledDate = tz.TZDateTime.from(
      dateTime,
      tz.local, // Use the device's local time zone
    );
    return scheduledDate;
  }

  static Future<void> scheduleNotification(String title, String body,
      DateTime scheduledTime, String priority) async {
    AndroidNotificationDetails androidPlatformChannelSpecifics;

    int notificationId = _lastNotificationId++;

    if (priority == 'High') {
      androidPlatformChannelSpecifics = const AndroidNotificationDetails(
          'high_priority_channel', // Channel ID
          'High Priority Notifications',
          importance: Importance.max,
          priority: Priority.high,
          icon: 'flutter_logo');
    } else if (priority == 'Medium') {
      androidPlatformChannelSpecifics = const AndroidNotificationDetails(
          'medium_priority_channel', // Channel ID
          'Medium Priority Notifications',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          icon: 'flutter_logo');
    } else {
      androidPlatformChannelSpecifics = const AndroidNotificationDetails(
          'low_priority_channel', // Channel ID
          'Low Priority Notifications',
          importance: Importance.low,
          priority: Priority.low,
          icon: 'flutter_logo');
    }

    NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    // Log notification details before scheduling
    logger.i(
        "Scheduling notification with title: $title, body: $body, time: $scheduledTime, priority: $priority");

    // Convert DateTime to TZDateTime
    final tz.TZDateTime tzScheduledTime = _convertToTZDateTime(scheduledTime);
    try {
      await _flutterLocalNotificationsPlugin.zonedSchedule(
        notificationId, // Notification ID
        title,
        body,
        tzScheduledTime,
        platformChannelSpecifics,
        androidScheduleMode: AndroidScheduleMode
            .exactAllowWhileIdle, // Updated from androidAllowWhileIdle
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents:
            DateTimeComponents.time, // Notification based on time
        payload:
            'Reminder tapped', // Optional: pass a payload to handle tap action
      );
      logger.i('Notification scheduled successfully');
    } catch (e) {
      logger.e("Error sceduling notificatins: $e");
    }
  }

  // This method will be called when a notification is tapped
  static void _onNotificationTap(String? payload) {
    // Handle the payload here, navigate to the specific screen or display details
    if (payload != null) {
      logger.i('Notification payload: $payload');
      // You can navigate to a specific screen using a navigator key or context
      // Navigator.pushNamed(context, '/someRoute', arguments: payload);
    }
  }
}
