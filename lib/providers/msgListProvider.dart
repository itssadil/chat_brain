import 'package:flutter/material.dart';

class MsgListProvider with ChangeNotifier {
  List<Map<String, dynamic>> _myMsg = [];
  List<Map<String, dynamic>> get myMsg => _myMsg;
  addMsgValue(sender, msgValue) {
    Map<String, dynamic> newData = {
      'sender': sender,
      'msgValue': msgValue,
    };

    _myMsg.insert(0, newData);
    notifyListeners();
  }
}
