import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';

import '../providers/msgListProvider.dart';
import 'msgBody.dart';

Widget waitingForMsg() {
  return Consumer<MsgListProvider>(
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
  );
}
