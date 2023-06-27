import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:lottie/lottie.dart';

import 'homePage.dart';

class Welcome extends StatefulWidget {
  const Welcome({Key? key}) : super(key: key);

  @override
  State<Welcome> createState() => _WelcomeState();
}

class _WelcomeState extends State<Welcome> {
  void _googleSignIn() async {
    final googleSignIn = GoogleSignIn();
    final signInAccount = await googleSignIn.signIn();

    final googleAuth = await signInAccount!.authentication;

    final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken, idToken: googleAuth.idToken);

    await FirebaseAuth.instance.signInWithCredential(credential);

    if (FirebaseAuth.instance.currentUser != null) {
      print("Google Sign in Successful");

      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('uid', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
          .get();

      if (querySnapshot.docs.isEmpty) {
        FirebaseFirestore.instance.collection('users').add({
          'name': FirebaseAuth.instance.currentUser?.displayName,
          'uid': FirebaseAuth.instance.currentUser?.uid,
          'isDark': 2,
        }).then((value) {
          print('Item added to Firestore');
        }).catchError((error) {
          print('Failed to add item: $error');
        });
      } else {
        print('Value already exists in Firestore');
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(),
        ),
      );
    } else {
      print("Failed");
    }
  }

  final _controller = PageController(initialPage: 0);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Container(
            height: MediaQuery.of(context).size.height -
                MediaQuery.of(context).padding.top,
            padding: EdgeInsets.symmetric(vertical: 10),
            child: PageView(
              physics: NeverScrollableScrollPhysics(),
              controller: _controller,
              children: [
                welcomeBody(
                  "Hi, I'm ",
                  'ChatBrain ',
                  "your virtual AI assistant.",
                  'assets/json/lottie1.json',
                  "Welcome to the new era of AI-powered conversations with ChatBrain AI.",
                  1,
                  "Let's go!",
                ),
                welcomeBody(
                  "Curious? ",
                  'Ask ChatBrain',
                  "",
                  'assets/json/lottie3.json',
                  "ChatBrain is a versatile AI powerhouse capable of generating new ideas, coding solutions, crafting compelling essays, and much more.",
                  2,
                  "Next",
                ),
                welcomeBody(
                  "Help us ",
                  'grow',
                  "",
                  'assets/json/lottie4.json',
                  "We value your review as it empowers us to grow and enhance our app experience.",
                  3,
                  "Next",
                ),
                welcomeBody(
                  "Sign in with ",
                  'Google',
                  "",
                  'assets/json/lottie2.json',
                  "Join a community and connect with like-minded users.",
                  4,
                  "Sign in",
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget welcomeBody(
    String rTxt1,
    rTxt2,
    rTxt3,
    lottie,
    subTxt,
    index,
    btnTxt,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(
                text: rTxt1,
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.black,
                ),
                children: <TextSpan>[
                  TextSpan(
                    text: rTxt2,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              rTxt3,
              style: TextStyle(
                fontSize: 20,
                color: Colors.black45,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        Lottie.asset(lottie),
        Text(
          subTxt,
          style: TextStyle(
            color: Colors.black54,
            fontStyle: FontStyle.italic,
          ),
        ),
        if (index == 1)
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              aiAdvantage("Powered by GPT3.5", Alignment.topLeft),
              aiAdvantage(
                  "Provides quick and accurate answers", Alignment.topCenter),
              aiAdvantage("Vast information database", Alignment.topLeft),
              aiAdvantage(
                  "Generates imaginative responses", Alignment.topRight),
            ],
          ),
        if (index == 2)
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              QuesModel(
                "Meth",
                "What's the sum of angles in a triangle?",
                Colors.black54,
                Colors.tealAccent,
              ),
              QuesModel(
                "Science",
                "How do black holes form and behave?",
                Colors.tealAccent,
                Colors.black54,
              ),
              QuesModel(
                "Essay",
                "Write an academic essay on...",
                Colors.black54,
                Colors.tealAccent,
              ),
              QuesModel(
                "Leave",
                'Request for leave from boss due to emergency.',
                Colors.tealAccent,
                Colors.black54,
              ),
            ],
          ),
        if (index == 3)
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              review("Contribute to a better user experience."),
              review("Empower us to meet your needs better."),
              review("Maximize the app's value with your review."),
              review("Drive positive changes with your feedback."),
            ],
          ),
        if (index == 4)
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _googleSignIn(),
                child: Text(btnTxt),
              ),
            ),
          ),
        if (index != 4)
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  _controller.animateToPage(
                    index,
                    duration: Duration(seconds: 1),
                    curve: Curves.easeInOut,
                  );
                },
                child: Text(btnTxt),
              ),
            ),
          ),
      ],
    );
  }

  Widget review(txt) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
          color: Colors.black54, borderRadius: BorderRadius.circular(5)),
      child: Text(
        txt,
        style: TextStyle(
          color: Colors.tealAccent,
          fontWeight: FontWeight.bold,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }

  Widget QuesModel(
    String qType,
    ques,
    clr1,
    clr2,
  ) {
    return Row(
      children: [
        Container(
          margin: EdgeInsets.symmetric(vertical: 10),
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
              color: clr2, borderRadius: BorderRadius.circular(5)),
          child: Text(
            qType,
            style: TextStyle(
              color: clr1,
              fontWeight: FontWeight.bold,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
        SizedBox(width: 10),
        Expanded(
          child: Container(
            margin: EdgeInsets.symmetric(vertical: 10),
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: clr1, borderRadius: BorderRadius.circular(5)),
            child: Text(
              ques,
              style: TextStyle(
                color: clr2,
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget aiAdvantage(String txt, AlignmentGeometry al) {
    return Align(
      alignment: al,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 10),
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
            color: Colors.tealAccent, borderRadius: BorderRadius.circular(5)),
        child: Text(
          txt,
          style: TextStyle(
            color: Colors.black54,
            fontWeight: FontWeight.bold,
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
    );
  }
}
