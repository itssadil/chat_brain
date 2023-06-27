import 'package:flutter/material.dart';

class SpeachToTextProvider with ChangeNotifier {
  bool _isListening = false;
  bool get isListening => _isListening;

  String _recordText = "";
  String get recordText => _recordText;

  isListeningValue(value) {
    _isListening = value;
    notifyListeners();
  }

  changeRecordText(value) {
    _recordText = value;
    notifyListeners();
  }
}
