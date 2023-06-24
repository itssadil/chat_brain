import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class msgBody extends StatelessWidget {
  final cls;
  final lt;
  final rt;
  final isMe;
  final Widget msgTxt;
  msgBody(this.cls, this.lt, this.rt, this.isMe, this.msgTxt);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        right: rt,
        left: lt,
        top: 10,
      ),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isMe == false) profilePik(0.0, 10.0, isMe),
          Expanded(
            child: Align(
              alignment: isMe ? Alignment.topRight : Alignment.topLeft,
              child: Container(
                padding: EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: cls,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: msgTxt,
              ),
            ),
          ),
          if (isMe) profilePik(10.0, 0.0, isMe),
        ],
      ),
    );
  }

  Widget profilePik(lt, rt, isMe) {
    return Container(
      margin: EdgeInsets.only(left: lt, right: rt),
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        image: isMe
            ? DecorationImage(
                image: NetworkImage(
                  "${FirebaseAuth.instance.currentUser!.photoURL}",
                ),
              )
            : DecorationImage(
                image: AssetImage("assets/images/icon.png"),
              ),
      ),
    );
  }
}
