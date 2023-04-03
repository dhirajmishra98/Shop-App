import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shop_app/models/http_exception.dart';

const String _webApiKey = 'AIzaSyAJmVsKd0MD9cNYVe-z5dpKxc32nms61cc';

class Auth with ChangeNotifier {
  String? _token;
  String? _userID;
  DateTime? _expiryDate;

  bool get isAuth {
    return token != null;
  }

  String? get token {
    if (_token != null &&
        _expiryDate != null &&
        _expiryDate!.isAfter(DateTime.now())) {
      return _token;
    }
    return null;
  }

  Future<void> _authenticate(
      String email, String password, String segment) async {
    Uri url = Uri.parse(
        'https://identitytoolkit.googleapis.com/v1/accounts:$segment?key=$_webApiKey');
    try {
      final response = await http.post(url,
          body: json.encode({
            'email': email,
            'password': password,
            'returnSecureToken': true,
          }));
      final responseData = json.decode(response.body);
      if (responseData['error'] != null) {
        // print(responseData);
        throw HttpException(responseData['error']['message']);
      }

      _token = responseData['idToken'];
      _userID = responseData['localId'];
      _expiryDate = DateTime.now()
          .add(Duration(seconds: int.parse(responseData['expiresIn'])));
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  Future<void> signUp(String email, String password) async {
    return _authenticate(email, password, 'signUp');
    // Uri url = Uri.parse(
    //     'https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=$_webApiKey');
    // final response = await http.post(url,
    //     body: json.encode({
    //       'email': email,
    //       'password': password,
    //       'returnSecureToken': true,
    //     }));
  }

  Future<void> logIn(String email, String password) async {
    return _authenticate(email, password, 'signInWithPassword');
    // Uri url = Uri.parse(
    //     'https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=$_webApiKey');
    // final response = await http.post(url,
    //     body: json.encode({
    //       'email': email,
    //       'password': password,
    //       'returnSecureToken': true,
    //     }));
  }
}
