import 'package:flutter/material.dart';

class AppStateProvider extends ChangeNotifier {
  int _selectedIndex = 2;
  String _userName = '';
  String _email = '';
  String _phone = '';
  String _address = '';
  String _role = '';
  int? _userId;
  int? _merchantId;
  int _coins = 0;

  int get selectedIndex => _selectedIndex;
  String get userName => _userName;
  String get email => _email;
  String get phone => _phone;
  String get address => _address;
  String get role => _role;
  int? get userId => _userId;
  int? get merchantId => _merchantId;
  int get coins => _coins;

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

  set email(String value) {
    if (_email == value) return;
    _email = value;
    notifyListeners();
  }

  set phone(String value) {
    if (_phone == value) return;
    _phone = value;
    notifyListeners();
  }

  set address(String value) {
    if (_address == value) return;
    _address = value;
    notifyListeners();
  }

  set role(String value) {
    if (_role == value) return;
    _role = value;
    notifyListeners();
  }

  set userId(int? value) {
    if (_userId == value) return;
    _userId = value;
    notifyListeners();
  }

  set merchantId(int? value) {
    if (_merchantId == value) return;
    _merchantId = value;
    notifyListeners();
  }

  set coins(int value) {
    if (_coins == value) return;
    _coins = value;
    notifyListeners();
  }
}
