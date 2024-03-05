import 'package:firebase_messaging/firebase_messaging.dart';

Future<void> handleBackgroundMessage(RemoteMessage message) async {
  print("MESSAGE TITLE: ${message.notification?.title}");
  print("MESSAGE BODY: ${message.notification?.body}");
  print("message payload: ${message.data}");

}

class FirebaseApi {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    Future<void> initNotifications() async {
      await messaging.requestPermission();
      final fCMToken = await messaging.getToken(); // I should store this token somewhere
      print('FCM Token: $fCMToken');
      FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
    }
}