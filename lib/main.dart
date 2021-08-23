import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'login.dart';

Future<void> _backMessage(RemoteMessage message) async {
  print('background message ${message.notification}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_backMessage);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Json Notification Demo',
      theme: ThemeData(
        primaryColor: Colors.deepPurpleAccent,
      ),
      home: LoginPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}