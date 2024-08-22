import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

  class FirebaseApi {
    final _firebaseMessaging = FirebaseMessaging.instance;
    Future<void> intiNotifications() async {
      await _firebaseMessaging.requestPermission();
      FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
      FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
        print('Got a message whilst in the foreground!');
        if (message.notification != null) {
          print('Foreground Title : ${message.notification!.title}');
          print('Foreground Body : ${message.notification!.body}');
        } else {
          print('Foreground message is null something went wrong?!');
        }
        _showNotification(message);
      });
    }
  }

  Future<void> handleBackgroundMessage(RemoteMessage message) async {
    print('Got a message whilst in the Background!');
    if (message.notification != null) {
      print('Background Title : ${message.notification?.title}');
      print('Background Body : ${message.notification?.body}');
    } else {
      print('Background message is null something went wrong?!');
    }
  }

  void _showNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'checkinrubv2',
      'checkinrubv2',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
      icon: 'ic_launcher',
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      0,
      message.notification!.title,
      message.notification!.body,
      platformChannelSpecifics,
    );
  }

