import 'dart:convert';
import 'dart:math';
import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';

class NotificationService {
  FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

  static const String serverKey = 'AAAAKpR1cYA:APA91bF6I5RtFTbxe_y8QXwIyTBszaoZuEb8wxSeqQWTZhIUMFEIHZ8jlxsDUlVPb8wyZuuuXEmYkcZVcd8vEzHQfE-9FPHKSyKbcZrxcQ75bTVYDP6i6MnjCuHv6VGmkzsWZMQR7RWV';


  static getTokenAndUpdate(String currentUser) async {
    FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
    String? token = await firebaseMessaging.getToken();
    print("FirebaseMessaging token: $token");
    await FirebaseFirestore.instance.collection('users')
        .doc(currentUser)
        .update({'token': token});
  }

  broadcastNotification(List<String> tokens, String title, String body) async {
    await firebaseMessaging.requestPermission(
        sound: true,
        badge: true,
        alert: true,
        provisional: false
    );
    await post(
      Uri.parse('https://fcm.googleapis.com/fcm/send'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'key=$serverKey',
        // replace $serverToken with your firebase messaging server token
      },
      body: jsonEncode(
        <String, dynamic>{
          'notification': <String, dynamic>{
            'body': body,
            'title': title
          },
          'priority': 'high',
          'data': <String, dynamic>{
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'id': '${Random().nextInt(100)}',
            'status': 'done',
            'view': 'orders'},
          'registration_ids': [tokens],
        },
      ),
    );
  }
}