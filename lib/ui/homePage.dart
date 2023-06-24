import 'dart:convert';

import 'package:chatbrain/ui/chatMsg.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../apis/chatApi.dart';
import '../providers/msgListProvider.dart';
import '../widgets/msgBody.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController _myMsgController = TextEditingController();

  void submitMsg(String text) {
    var chatMsgProvider = Provider.of<MsgListProvider>(context, listen: false);
    chatMsgProvider.addMsgValue(
        FirebaseAuth.instance.currentUser!.uid, _myMsgController.text, true);
    sendMsgToChatGPT(_myMsgController.text);
    _myMsgController.clear();
  }

  void sendMsgToChatGPT(String msgForGpt) async {
    // var result = await FirebaseFirestore.instance.collection('myApi').get();
    // if (result.docs[0][""]) {}
    Uri uri = Uri.parse("https://api.openai.com/v1/chat/completions");

    Map<String, dynamic> body = {
      "model": "gpt-3.5-turbo",
      "messages": [
        {"role": "user", "content": msgForGpt}
      ],
      "max_tokens": 500,
    };

    final response = await http.post(
      uri,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer ${APIKey.apiKey}",
      },
      body: json.encode(body),
    );

    Map<String, dynamic> parsedResponse = json.decode(response.body);

    String reply = parsedResponse["choices"][0]["message"]["content"];
    String sender = parsedResponse["choices"][0]["message"]["role"];

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
                                borderRadius: BorderRadius.circular(20),
                              ),
                              contentPadding: EdgeInsets.all(10),
                              labelText: "Message",
                              suffixIcon: IconButton(
                                icon: Icon(Icons.send),
                                onPressed: () =>
                                    submitMsg(_myMsgController.text),
                              ),
                            ),
                            // onSubmitted: (value) => myMsg.addMsgValue(value),
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
