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
                    child: Align(
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
                              suffixIcon: GestureDetector(
                                child: Icon(Icons.mic),
                                onLongPress: () async {
                                  var LongPressPro =
                                      Provider.of<SpeachToTextProvider>(context,
                                          listen: false);
                                  LongPressPro.isListeningValue(true);
                                  var available =
                                      await speechToText.initialize();
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
                            // onSubmitted: (value) => myMsg.addMsgValue(value),
                          ),
                        ),
                        ElevatedButton(
                          child: Icon(
                            Icons.send,
                            size: 20,
                          ),
                          onPressed: () {
                            if (_myMsgController.text != "")
                              submitMsg(_myMsgController.text);
                          },
                          style: ElevatedButton.styleFrom(
                            shape: CircleBorder(),
                            padding: EdgeInsets.all(12),
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
