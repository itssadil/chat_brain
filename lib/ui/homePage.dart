import 'dart:convert';

import 'package:chatbrain/ui/chatMsg.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../apis/chatApi.dart';
import '../providers/msgListProvider.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController _myMsgController = TextEditingController();

  void submitMsg(String text) {
    var chatMsgProvider = Provider.of<MsgListProvider>(context, listen: false);
    chatMsgProvider.addMsgValue("user", _myMsgController.text);
    sendMsgToChatGPT(_myMsgController.text);
    _myMsgController.clear();
  }

  void sendMsgToChatGPT(String msgForGpt) async {
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
    chatMsgProvider.addMsgValue(sender, reply);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chat Brain"),
        centerTitle: true,
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
                              onPressed: () => submitMsg(_myMsgController.text),
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
    );
  }
}
