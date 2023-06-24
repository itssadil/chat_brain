import 'package:flutter/material.dart';

class ChatMsg extends StatelessWidget {
  final String msgTxt;
  final String msgFrom;
  ChatMsg(this.msgTxt, this.msgFrom);

  @override
  Widget build(BuildContext context) {
    return msgFrom == "user"
        ? msgBody(
            Alignment.bottomRight,
            Color(0xFFD9DCF6),
            10.0,
            50.0,
          )
        : msgBody(
            Alignment.bottomLeft,
            Color(0xFFF8D0D8),
            50.0,
            10.0,
          );
  }

  Widget msgBody(myAlign, cls, rt, lt) {
    return Align(
      alignment: myAlign,
      child: Container(
        margin: EdgeInsets.only(
          right: rt,
          left: lt,
          top: 10,
        ),
        padding: EdgeInsets.all(7),
        decoration: BoxDecoration(
          color: cls,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          msgTxt,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}
