import 'dart:convert';

import 'package:chatbrain/ui/chatMsg.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../providers/msgListProvider.dart';
import '../providers/speechToTextProvider.dart';
import '../widgets/msgBody.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController _myMsgController = TextEditingController();
  SpeechToText speechToText = SpeechToText();

  String assistantAnswer = "";

  List examples = [
    "Request for leave due to personal emergency.",
    "What are some common mistakes to avoid when writing code?",
    "Explanation of 5*(x-15)=25y with examples.",
    "Got any creative ideas for a 10 year old’s birthday?",
  ];

  void submitMsg(String text) {
    var chatMsgProvider = Provider.of<MsgListProvider>(context, listen: false);
    chatMsgProvider.addMsgValue(
        FirebaseAuth.instance.currentUser!.uid, text, true);
    sendMsgToChatGPT(text);
    _myMsgController.clear();
  }

  void sendMsgToChatGPT(String msgForGpt) async {
    var result = await FirebaseFirestore.instance.collection('myApi').get();
    Uri uri = Uri.parse("https://api.openai.com/v1/chat/completions");

    Map<String, dynamic> body = {
      "model": "gpt-3.5-turbo",
      "messages": [
        {"role": "assistant", "content": assistantAnswer},
        {"role": "user", "content": msgForGpt}
      ],
      "max_tokens": 500,
    };

    final response = await http.post(
      uri,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer ${result.docs[0]["apiKey"]}",
      },
      body: json.encode(body),
    );

    Map<String, dynamic> parsedResponse = json.decode(response.body);

    String reply = parsedResponse["choices"][0]["message"]["content"];
    String sender = parsedResponse["choices"][0]["message"]["role"];
    assistantAnswer = reply;

    var chatMsgProvider = Provider.of<MsgListProvider>(context, listen: false);
    chatMsgProvider.addMsgValue(sender, reply, false);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: Text("Chat Brain"),
          centerTitle: true,
          actions: [
            Consumer<MsgListProvider>(
              builder: (context, myMsg, child) {
                return myMsg.myMsg.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          myMsg.clearMsgValue();
                          myMsg.isMeValue(false);
                        },
                        icon: Icon(Icons.replay),
                      )
                    : Center();
              },
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Consumer<MsgListProvider>(
                builder: (context, myMsg, child) {
                  return Expanded(
                    child: myMsg.myMsg.isEmpty
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Image.asset(
                                      "assets/images/icon.png",
                                      width: MediaQuery.of(context).size.width *
                                          0.3,
                                    ),
                                    SizedBox(height: 10),
                                    Text(
                                      "Examples",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 10),
                              Expanded(
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: examples.length,
                                  itemBuilder: (context, index) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 20.0,
                                      ),
                                      child: ElevatedButton(
                                        onPressed: () {
                                          submitMsg(examples[index]);
                                        },
                                        child: Text(
                                          examples[index],
                                          style: TextStyle(color: Colors.black),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.tealAccent,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          )
                        : Align(
                            alignment: Alignment.bottomRight,
                            child: ListView.builder(
                              reverse: true,
                              shrinkWrap: true,
                              itemCount: myMsg.myMsg.length,
                              itemBuilder: (context, index) {
                                return ChatMsg(myMsg.myMsg[index]["msgValue"],
                                    myMsg.myMsg[index]["sender"]);
                              },
                            ),
                          ),
                  );
                },
              ),
              Consumer<MsgListProvider>(
                builder: (context, myMsg, child) {
                  return Align(
                    alignment: Alignment.bottomLeft,
                    child: myMsg.isMe
                        ? msgBody(
                            Color(0xFFF8D0D8),
                            10.0,
                            50.0,
                            false,
                            SizedBox(
                              width: 50,
                              child: SpinKitThreeInOut(
                                color: Colors.lightBlue,
                                size: 20.0,
                              ),
                            ),
                          )
                        : Center(),
                  );
                },
              ),
              Consumer<SpeachToTextProvider>(
                builder: (context, isListening, child) {
                  return isListening.isListening
                      ? Center(child: Text(isListening.recordText))
                      : Center();
                },
              ),
              Consumer<MsgListProvider>(
                builder: (context, myMsg, child) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8.0,
                      vertical: 10,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _myMsgController,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              contentPadding: EdgeInsets.all(10),
                              labelText: "Send a message",
                              hintText: "Message...",
                              suffixIcon: IconButton(
                                icon: Icon(
                                  Icons.send,
                                  size: 20,
                                ),
                                onPressed: () {
                                  if (_myMsgController.text != "")
                                    submitMsg(_myMsgController.text);
                                },
                              ),
                            ),
                            // onSubmitted: (value) => myMsg.addMsgValue(value),
                          ),
                        ),
                        SizedBox(width: 5),
                        CircleAvatar(
                          child: GestureDetector(
                            child: Icon(Icons.mic),
                            onLongPress: () async {
                              var LongPressPro =
                                  Provider.of<SpeachToTextProvider>(context,
                                      listen: false);
                              LongPressPro.isListeningValue(true);
                              var available = await speechToText.initialize();
                              if (available) {
                                speechToText.listen(onResult: (result) {
                                  LongPressPro.changeRecordText(
                                      result.recognizedWords);
                                });
                              }
                            },
                            onLongPressUp: () {
                              var LongPressPro =
                                  Provider.of<SpeachToTextProvider>(context,
                                      listen: false);
                              submitMsg(LongPressPro.recordText);
                              LongPressPro.isListeningValue(false);
                              LongPressPro.changeRecordText("");
                              speechToText.cancel();
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
