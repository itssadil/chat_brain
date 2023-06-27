import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/msgListProvider.dart';
import '../../widgets/msgSubmit.dart';
import '../chatMsg.dart';

class MsgFromGpt extends StatelessWidget {
  const MsgFromGpt({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    void submitMsg(String text) {
      var chatMsgProvider =
          Provider.of<MsgListProvider>(context, listen: false);
      chatMsgProvider.addMsgValue(
          FirebaseAuth.instance.currentUser!.uid, text, true);
      MsgSubmit.sendMsgToChatGPT(text, context);
    }

    List examples = [
      "Request for leave from boss due to personal emergency.",
      "What are some common mistakes to avoid when writing code?",
      "Explanation of 5*(x-15)=25y with examples.",
      "Got any creative ideas for a 10 year old’s birthday?",
    ];

    return Consumer<MsgListProvider>(
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
                            width: MediaQuery.of(context).size.width * 0.3,
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
              : Stack(
                  children: [
                    Padding(
                      padding: !myMsg.isMe
                          ? EdgeInsets.only(bottom: 8.0)
                          : EdgeInsets.only(bottom: 0.0),
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
                    ),
                    if (!myMsg.isMe)
                      Positioned(
                        bottom: -3,
                        right: -5,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.tealAccent,
                            shape: CircleBorder(),
                          ),
                          onPressed: () {
                            myMsg.isMeValue(true);
                            MsgSubmit.sendMsgToChatGPT(
                                myMsg.myMsg[1]["msgValue"], context);
                          },
                          child: Icon(
                            Icons.replay,
                            color: Colors.black45,
                          ),
                        ),
                      ),
                  ],
                ),
        );
      },
    );
  }
}
