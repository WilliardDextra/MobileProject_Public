import 'package:flutter/material.dart';

class AppStateProvider extends ChangeNotifier {
  int _selectedIndex = 2;
  String _userName = '';

  int get selectedIndex => _selectedIndex;
  String get userName => _userName;

  set selectedIndex(int value) {
    if (_selectedIndex == value) return;
    _selectedIndex = value;
    notifyListeners();
  }

  set userName(String value) {
    if (_userName == value) return;
    _userName = value;
    notifyListeners();
  }
}
