import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../widgets/msgBody.dart';

class ChatMsg extends StatelessWidget {
  final String msgTxt;
  final String msgFrom;

  ChatMsg(this.msgTxt, this.msgFrom);

  @override
  Widget build(BuildContext context) {
    return msgFrom == FirebaseAuth.instance.currentUser!.uid
        ? msgBody(
            Color(0xFFD9DCF6),
            50.0,
            10.0,
            true,
            SelectableText(
              msgTxt,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 15,
              ),
            ),
          )
        : msgBody(
            Color(0xFFF8D0D8),
            10.0,
            50.0,
            false,
            SelectableText(
              msgTxt,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 15,
              ),
            ),
          );
  }
}
