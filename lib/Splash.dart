import 'dart:async';

import 'package:chatbrain/ui/homePage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class Splash extends StatefulWidget {
  const Splash({Key? key}) : super(key: key);

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late Future<FirebaseApp> _firebaseApp;
  bool isLoggedin = false;

  @override
  void initState() {
    super.initState();

    _firebaseApp = Firebase.initializeApp();
    FirebaseAuth.instance.currentUser?.uid != null
        ? myTimer()
        : WidgetsBinding.instance.addPostFrameCallback((_) {
            _showCustomDialog(context);
          });

    _controller = AnimationController(
      duration: Duration(seconds: 1),
      vsync: this,
    );

    _animation = Tween(begin: 0.3, end: 0.5).animate(_controller);

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void myTimer() {
    Timer(Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(),
        ),
      );
    });
  }

  void _googleSignIn() async {
    final googleSignIn = GoogleSignIn();
    final signInAccount = await googleSignIn.signIn();

    final googleAuth = await signInAccount!.authentication;

    final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken, idToken: googleAuth.idToken);

    await FirebaseAuth.instance.signInWithCredential(credential);

    if (FirebaseAuth.instance.currentUser != null) {
      print("Google Sign in Successful");
      print(FirebaseAuth.instance.currentUser!.displayName);
      print(FirebaseAuth.instance.currentUser?.photoURL);
      setState(() {
        isLoggedin = true;
      });
      Navigator.pop(context);
      myTimer();
    } else {
      print("Failed");
    }
  }

  void _showCustomDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Chat Brain'),
          content: ElevatedButton(
            onPressed: () => _googleSignIn(),
            child: Text('Sign in with Google'),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: RotationTransition(
          turns: _animation,
          child: Image.asset(
            "assets/images/icon.png",
            width: MediaQuery.of(context).size.width * 0.3,
          ),
        ),
      ),
    );
  }
}
