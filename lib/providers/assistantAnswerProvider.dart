import 'package:flutter/material.dart';

class AssistantAnswer with ChangeNotifier {
  String _assistantAnswer = "";
  String get assistantAnswer => _assistantAnswer;

  ChangeValue(value) {
    _assistantAnswer = value;
    notifyListeners();
  }
}
