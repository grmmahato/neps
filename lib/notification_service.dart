import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotificationService{

  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
  FlutterLocalNotificationsPlugin();
  static void createanddisplaynotification(RemoteMessage message) async {
    try {
      final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      NotificationDetails notificationDetails = const NotificationDetails(
        android: AndroidNotificationDetails(
          "High_importance_channel",
          "High_importance_channel",
          importance: Importance.max,
          channelShowBadge: true,
          priority: Priority.high,
        ),
      );
      await _notificationsPlugin.show(
        id,
        message.notification!.title,
        message.notification!.body,
        notificationDetails,
      );
    } on Exception catch (e) {
      print(e);
    }
  }
}





//
// class LocalNotificationServiceIos{
//
//   static final FlutterLocalNotificationsPlugin _notificationsPlugin =
//   FlutterLocalNotificationsPlugin();
//   static void createanddisplaynotification(RemoteMessage message) async {
//     try {
//       final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;
//       NotificationDetails notificationDetails =  NotificationDetails(
//         iOS: IOSNotificationDetails(
//           "High_importance_channel",
//           "High_importance_channel",
//           importance: Importance.max,
//           channelShowBadge: true,
//           priority: Priority.high,
//         ),
//       );
//       await _notificationsPlugin.show(
//         id,
//         message.notification!.title,
//         message.notification!.body,
//         notificationDetails,
//       );
//     } on Exception catch (e) {
//       print(e);
//     }
//   }
// }
//
//
//
//
// IOSNotificationDetails(String s, String t, {required Importance importance, required bool channelShowBadge, required Priority priority}) {
// }
//


