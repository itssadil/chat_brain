import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../providers/msgListProvider.dart';

class MsgSubmit {
  static void sendMsgToChatGPT(String msgForGpt, context) async {
    String assistantAnswer = "";
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
}
