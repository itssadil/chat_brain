import 'dart:async';

import 'package:chatbrain/ui/homePage.dart';
import 'package:chatbrain/ui/welcome.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class Splash extends StatefulWidget {
  const Splash({Key? key}) : super(key: key);

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    Firebase.initializeApp();
    myTimer();
    // FirebaseAuth.instance.currentUser?.uid != null
    //     ? myTimer()
    //     : WidgetsBinding.instance.addPostFrameCallback((_) {
    //         _showCustomDialog(context);
    //       });

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
      FirebaseAuth.instance.currentUser?.uid != null
          ? Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => HomePage(),
              ),
            )
          : Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => Welcome(),
              ),
            );
    });
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
