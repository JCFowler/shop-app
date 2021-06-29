import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/http_exception.dart';

import '../keys.dart';

class Auth with ChangeNotifier {
  String _token = '';
  DateTime? _expiryDate;
  String _userId = '';
  Timer? _authTimer;

  bool get isAuth {
    return _token.isNotEmpty;
  }

  String get token {
    if ((_expiryDate != null && _expiryDate!.isAfter(DateTime.now())) &&
        _token.isNotEmpty) {
      return _token;
    }
    return '';
  }

  String get userId {
    return _userId;
  }

  Future<void> _authenticate(
      String email, String password, String urlString) async {
    final url = Uri.parse(urlString);
    try {
      final res = await http.post(
        url,
        body: json.encode(
          {
            'email': email,
            'password': password,
            'returnSecureToken': true,
          },
        ),
      );
      final resData = json.decode(res.body);
      if (resData['error'] != null) {
        throw HttpException(resData['error']['message']);
      }

      _token = resData['idToken'];
      _userId = resData['localId'];
      _expiryDate = DateTime.now().add(
        Duration(
          seconds: int.parse(
            resData['expiresIn'],
          ),
        ),
      );
      _autoLogout();
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      final userData = json.encode({
        'token': _token,
        'userId': _userId,
        'expiryDate': _expiryDate!.toIso8601String(),
      });
      prefs.setString('userData', userData);
    } catch (error) {
      throw HttpException(error.toString());
    }
  }

  Future<void> signUp(String email, String password) async {
    return _authenticate(email, password, SIGN_UP_URL);
  }

  Future<void> signIn(String email, String password) async {
    return _authenticate(email, password, SIGN_IN_URL);
  }

  Future<void> logout() async {
    _token = '';
    _userId = '';
    _expiryDate = null;
    if (_authTimer != null) {
      _authTimer!.cancel();
      _authTimer = null;
    }

    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('userData');
  }

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userData')) {
      return false;
    }

    final data =
        json.decode(prefs.getString('userData')!) as Map<String, dynamic>;
    final expireDate = DateTime.parse(data['expiryDate'] as String);

    if (expireDate.isBefore(DateTime.now())) {
      return false;
    }

    _token = data['token'] as String;
    _userId = data['userId'] as String;
    _expiryDate = expireDate;

    notifyListeners();
    _autoLogout();
    return true;
  }

  void _autoLogout() {
    if (_authTimer != null) {
      _authTimer!.cancel();
    }

    final exipreTime = _expiryDate!.difference(DateTime.now()).inSeconds;
    Timer(Duration(seconds: exipreTime), logout);
  }
}
