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

// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/material.dart';
//
// Future<void> _messageHandler(RemoteMessage message) async {
//   print('background message ${message.notification!.body}');
// }
//
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp();
//   FirebaseMessaging.onBackgroundMessage(_messageHandler);
//   runApp(MessagingTutorial());
// }
//
// class MessagingTutorial extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'Firebase Messaging',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: MyHomePage(title: 'Firebase Messaging'),
//     );
//   }
// }
//
// class MyHomePage extends StatefulWidget {
//   MyHomePage({Key? key, this.title}) : super(key: key);
//
//   final String? title;
//
//   @override
//   _MyHomePageState createState() => _MyHomePageState();
// }
//
// class _MyHomePageState extends State<MyHomePage> {
//   late FirebaseMessaging messaging;
//   String? notificationText;
//   @override
//   void initState() {
//     super.initState();
//     messaging = FirebaseMessaging.instance;
//     messaging.subscribeToTopic("messaging");
//     messaging.getToken().then((value) {
//       print("token: ${value}");
//     });
//     FirebaseMessaging.onMessage.listen((RemoteMessage event) {
//       print("message recieved");
//       print(event.notification!.body);
//       print(event.data.values);
//       showDialog(
//           context: context,
//           builder: (BuildContext context) {
//             return AlertDialog(
//               title: Text("Notification"),
//               content: Text(event.notification!.body!),
//               actions: [
//                 TextButton(
//                   child: Text("Ok"),
//                   onPressed: () {
//                     Navigator.of(context).pop();
//                   },
//                 )
//               ],
//             );
//           });
//     });
//     FirebaseMessaging.onMessageOpenedApp.listen((message) {
//       print('Message clicked!');
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.title!),
//       ),
//       body: Center(child: Text("Messaging Tutorial")),
//     );
//   }
// }