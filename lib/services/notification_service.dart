import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  
  factory NotificationService() {
    return _instance;
  }
  
  NotificationService._internal();

  Future<void> initialize() async {
    const AndroidInitializationSettings initializationSettingsAndroid = 
      AndroidInitializationSettings('@mipmap/ic_launcher');
      
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );
    
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
    );
  }

  Future<void> showBalanceNotification({
    required String title,
    required String body,
    required double balance,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
        'balance_alerts',
        'Balance Alerts',
        channelDescription: 'Notifications related to your account balance',
        importance: Importance.high,
        priority: Priority.high,
      );
    
    const NotificationDetails platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);
    
    await flutterLocalNotificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title,
      body,
      platformChannelSpecifics,
      payload: balance.toString(),
    );
  }

// Add this method to your NotificationService class
Future<void> showSpendingThresholdNotification({
  required String category,
  required double spent,
  required double threshold,
}) async {
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'spending_alerts',
      'Spending Alerts',
      channelDescription: 'Notifications about your spending habits',
      importance: Importance.high,
      priority: Priority.high,
    );
  
  const NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);
  
  await flutterLocalNotificationsPlugin.show(
    DateTime.now().millisecondsSinceEpoch.remainder(100000),
    'Spending Alert',
    'You\'ve spent $spent on $category, which is over your threshold of $threshold.',
    platformChannelSpecifics,
    payload: 'spending_threshold',
  );
}
  // Similar implementations for other notification types...
}