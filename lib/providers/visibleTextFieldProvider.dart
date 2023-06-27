import 'package:flutter/material.dart';

class VisibleTextField with ChangeNotifier {
  bool _isTextField = true;
  bool get isTextField => _isTextField;

  String _recordText = '';
  String get recordText => _recordText;

  isTextFieldValue(value) {
    _isTextField = value;
    notifyListeners();
  }
}
