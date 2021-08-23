import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:json_flutter_http_push_0819/push_noti.dart';
import 'home.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;


  User? currentUser;
  bool notiYes = true;
  bool isLoading = false;

  Future<void> signIn() async {
    this.setState(() {
      isLoading = true;
    });

    GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn();
    if(googleSignInAccount == null){
      Fluttertoast.showToast(msg: "Can not init google sign in");
      this.setState(() {
        isLoading = false;
      });
    } else {
      GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;
      OAuthCredential oAuthCredential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken
      );

      currentUser = (await firebaseAuth.signInWithCredential(oAuthCredential)).user;

      if(currentUser == null){
        Fluttertoast.showToast(msg: "Sign In FAIL");
        this.setState(() {
          isLoading = false;
        });
      } else {
        final QuerySnapshot addUser =
            await FirebaseFirestore.instance.collection('users').where('id', isEqualTo: currentUser!.uid).get();
        final List<DocumentSnapshot> documents = addUser.docs;
        if(documents.length == 0){
          FirebaseFirestore.instance.collection('users').doc(currentUser!.uid).set({
            'userName' : currentUser!.displayName,
            'phtoUrl': currentUser!.photoURL,
            'uid': currentUser!.uid,
            'createTime': DateTime.now().millisecondsSinceEpoch.toString(),
            'noti' : notiYes
          });
          Navigator.push(context, MaterialPageRoute(builder: (context) => HomeScreen(currentUserId: currentUser!.uid)));
        }
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Padding(
        padding: EdgeInsets.all(24),
        child: Center(
          child: ElevatedButton(
            onPressed: (){
              signIn();
            }, child: Text('Google Login'),
          ),
        ),
      ),
    );
  }
}
