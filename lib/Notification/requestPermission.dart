import 'dart:math';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:usage_stats/usage_stats.dart';

class NotificationServices{
 FirebaseMessaging messaging =FirebaseMessaging.instance;

 final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

 Future<void> initLocalNotification(BuildContext context, RemoteMessage message) async {
   const AndroidInitializationSettings androidInitializationSettings = AndroidInitializationSettings("@mipmap/ic_launcher");
   final InitializationSettings initializationSettings = InitializationSettings(
     android: androidInitializationSettings,
   );

   await _flutterLocalNotificationsPlugin.initialize(
     initializationSettings,
     onDidReceiveNotificationResponse: (NotificationResponse notificationResponse) {
       // Handle notification tap
     },
   );
 }


 Future<void> requestPermission() async {
   NotificationSettings settings = await messaging.requestPermission(
     alert: true,
     announcement: true,
     badge: true,
     carPlay: true,
     provisional: true,
     sound: true,
     criticalAlert: true,
   );

   if(settings.authorizationStatus==AuthorizationStatus.authorized){
    print("permission granetd");

   }else if (settings.authorizationStatus==AuthorizationStatus.provisional){
     print("permission provissional");
   }else{
     print("Denied permsision");
   }

 }

   Future<void> getUsagePermission() async{
     await UsageStats.grantUsagePermission();
   }

   void firebaseInit(){
   FirebaseMessaging.onMessage.listen((message){
     showNotification(message);

   });
   }

 Future<void> showNotification(RemoteMessage message) async {
   AndroidNotificationChannel channel = AndroidNotificationChannel(
     Random.secure().nextInt(100000).toString(),
     "High Importance Notification",
     importance: Importance.max,
   );

   AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
     channel.id,
     channel.name,
     channelDescription: "Your channel description",
     importance: Importance.high,
     priority: Priority.high,
     ticker: "ticker",
   );

   NotificationDetails notificationDetails = NotificationDetails(
     android: androidNotificationDetails,
   );

   await _flutterLocalNotificationsPlugin.show(
     0,
     message.notification?.title ?? '',
     message.notification?.body ?? '',
     notificationDetails,
   );
 }


Future<void> getAccessToken() async{
    await messaging.getToken().then((token){
     print("token is $token");
   });

}

}