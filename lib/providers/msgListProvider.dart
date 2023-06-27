import 'package:flutter/material.dart';

class MsgListProvider with ChangeNotifier {
  List<Map<String, dynamic>> _myMsg = [];

  List<Map<String, dynamic>> get myMsg => _myMsg;

  List _ques = [""];

  List get ques => _ques;

  bool _isMe = false;

  bool get isMe => _isMe;

  addMsgValue(sender, msgValue, user) {
    _isMe = user;

    Map<String, dynamic> newData = {
      'sender': sender,
      'msgValue': msgValue,
    };

    if (user) _ques[0] = msgValue;

    _myMsg.insert(0, newData);
    notifyListeners();
  }

  isMeValue(user) {
    _isMe = user;
    notifyListeners();
  }

  clearMsgValue() {
    _myMsg.clear();
    notifyListeners();
  }
}
