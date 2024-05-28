import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoggedIn = false;
  String _currentUserEmail = '';

  String get currentUserEmail => _currentUserEmail;
  bool get isLoggedIn => _isLoggedIn;

  Future<void> initialize() async {
    await _loadLoginStatus();
  }

  Future<void> login() async {
    try {
      await _setLoginStatus(true);
    } catch (e) {
      // Handle error
      print('Login failed: $e');
    }
  }

  Future<void> logout() async {
    try {
      await _setLoginStatus(false);
    } catch (e) {
      // Handle error
      print('Logout failed: $e');
    }
  }

  Future<void> _loadLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    notifyListeners();
  }

  Future<void> _setLoginStatus(bool isLoggedIn) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', isLoggedIn);
    _isLoggedIn = isLoggedIn;
    notifyListeners();
  }

}
