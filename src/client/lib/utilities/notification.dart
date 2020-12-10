import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
AndroidInitializationSettings initializationSettingsAndroid;
IOSInitializationSettings initializationSettingsIOS;
InitializationSettings initializationSettings;
NotificationDetails platformChannelSpecifics;
createNotification(String title, String body) async {
  if (flutterLocalNotificationsPlugin == null) {
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    initializationSettingsAndroid = AndroidInitializationSettings('app_icon');
    initializationSettingsIOS = IOSInitializationSettings();
    initializationSettings = InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
    );
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      "0",
      "Notifications",
      "All notifications goes this channel.",
      color: Colors.blue,
      priority: Priority.High,
    );

    var iOSPlatformChannelSpecifics = IOSNotificationDetails();

    platformChannelSpecifics = NotificationDetails(
      androidPlatformChannelSpecifics,
      iOSPlatformChannelSpecifics,
    );
  }

  await flutterLocalNotificationsPlugin.schedule(
    0,
    title,
    body,
    DateTime.now(),
    platformChannelSpecifics,
  );
}
