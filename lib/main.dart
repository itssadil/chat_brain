import 'package:chatbrain/providers/msgListProvider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'Splash.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => MsgListProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Chat Brain",
      home: Splash(),
    );
  }
}
