import 'package:chatbrain/providers/assistantAnswerProvider.dart';
import 'package:chatbrain/providers/msgListProvider.dart';
import 'package:chatbrain/providers/speechToTextProvider.dart';
import 'package:chatbrain/providers/visibleTextFieldProvider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'Splash.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MsgListProvider()),
        ChangeNotifierProvider(create: (_) => SpeachToTextProvider()),
        ChangeNotifierProvider(create: (_) => VisibleTextField()),
        ChangeNotifierProvider(create: (_) => AssistantAnswer()),
      ],
      child: MyApp(),
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
