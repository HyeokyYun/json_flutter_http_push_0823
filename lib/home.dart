import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;
import 'dart:math';
import 'dart:async';
import 'login.dart';

class HomeScreen extends StatefulWidget {
  final String currentUserId;
  const HomeScreen({Key? key, required this.currentUserId}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState(currentUserId: currentUserId);
}

class _HomeScreenState extends State<HomeScreen> {
  _HomeScreenState({Key? key, required this.currentUserId});

  final String serverKey = 'AAAAKpR1cYA:APA91bF6I5RtFTbxe_y8QXwIyTBszaoZuEb8wxSeqQWTZhIUMFEIHZ8jlxsDUlVPb8wyZuuuXEmYkcZVcd8vEzHQfE-9FPHKSyKbcZrxcQ75bTVYDP6i6MnjCuHv6VGmkzsWZMQR7RWV';
  final currentUserId;
  String? _token;

  bool isSent = false;

  late FirebaseMessaging messaging;

  final GoogleSignIn googleSignIn = GoogleSignIn();

  TextEditingController titleController = TextEditingController();
  TextEditingController bodyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    //NotificationService.getTokenAndUpdate(currentUserId);
    messaging = FirebaseMessaging.instance;
    messaging.getToken().then((value) {
      _token = value;
      print("token: $_token");
      FirebaseFirestore.instance.collection('users').doc(currentUserId).update(
          {'token': _token});
      // FirebaseFirestore.instance.collection('tokens').doc(_token).set(
      //      {'token' : _token});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              Text('User Profile'),
              Text(currentUserId),
              //Text(_token!),
              ElevatedButton(onPressed: () async {
                await FirebaseAuth.instance.signOut();
                await googleSignIn.disconnect();
                await googleSignIn.signOut();
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => LoginPage()));
              },
                  child: Text('Sign Out')),
              TextField(
                decoration: InputDecoration(
                    hintText: 'Title to send...',
                    hintStyle: TextStyle(color: Colors.grey.shade400,)
                ),
                controller: titleController,
              ),
              TextField(
                decoration: InputDecoration(
                    hintText: 'Body text to send...',
                    hintStyle: TextStyle(color: Colors.grey.shade400,)
                ),
                controller: bodyController,
              ),
              ElevatedButton(onPressed: () async {
                //await NotificationService.getAllTokens;
                await sendNotification(titleController.text, bodyController.text);
              },
                  child: Text('Send Message')
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future sendNotification(String title, String message) async {
    List<String> tokens = [];
    await messaging.requestPermission(
        sound: true,
        badge: true,
        alert: true,
        provisional: false
    );
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('users').get();
      querySnapshot.docs.forEach((element){
        tokens.add((element.data() as dynamic)["token"]);
      });
      //if (ds.data()!["token"] != null) {
      if (_token != null) {
        //String userToken = ds.data()!["token"];
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
                'body': message,
                'title': title
              },
              'priority': 'high',
              'data': <String, dynamic>{
                'click_action': 'FLUTTER_NOTIFICATION_CLICK',
                'id': '${Random().nextInt(100)}',
                'status': 'done',
                'view': 'orders'},
              //'to': userToken,
              'registration_ids': tokens
              // 'registration_ids': [
              //   'dGsnZYO9QyCtgaN_VRaJ1y:APA91bF3Ud_wYo7vLyregHcHnCxo3qALNLgHQUvgNZomLcKwSDB2zq4IqLMB9HYkgVjlJ9dYgyoIun3gi0GoryRqUTZ0lTS69CWKs8qe36KlhEWcnpDsbJ46eScwXrtQsyLnq4bHdRJM',
              //   'dypc7BwfQIKGLag7ecQtrp:APA91bFT8p37RGwW21TqT7Ys7bK-iMAgN3S-EZQ3WP7MlXtPABpTHHvr-Z9SYoV3jy9zI8lOcCRDWN8ljhLdIy4E_-wXtoj0T9gs-C-cBktZwRLvzjkptnKcSWrvn7IWKGGAr7shG7k7',
              //   'ce4Udk-qUUqBiI_Ay18rX6:APA91bHKmiqVZgS6MddgMpBqPTfMZKn4yAphyjG1yqukUbPu18_58ujWxwMkbeZplCOPhJkgmGsK6qSR69acPQEJZ9B1tMjYfAbMKyoJwmFqAxL_Xq5szw6a17oR0VkdBEVekpkbpz7N'
              // ]
            },
          ),
        );
      } else {
        print("unable to fetch admin device token from database");
      }
    } catch (e) {
      print("Error in sending notification");
      print(e);
    }
  }
}