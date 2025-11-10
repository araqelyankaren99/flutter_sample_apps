import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService with ChangeNotifier {
  static const _isLoggindKey = 'is_loggined';

  final SharedPreferences _preferences;

  AuthService(this._preferences);

  // Getter for current state
  bool get isLoggedIn => _preferences.getBool(_isLoggindKey) ?? false;

  // Login method
  Future<void> login() async {
    print('login');
    await _preferences.setBool(_isLoggindKey, true);
    notifyListeners();
  }

  // Logout method
  Future<void> logout() async {
    print('logout');
    await _preferences.setBool(_isLoggindKey, false);
    notifyListeners();
  }
}