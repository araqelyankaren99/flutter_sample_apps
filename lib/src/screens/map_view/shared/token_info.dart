import 'package:shared_preferences/shared_preferences.dart';

class TokenInfo {
  TokenInfo._();

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();

    final tokenExpiredTime = prefs.getInt('tokenExpiredTime');
    final refreshTokenExpiredTime = prefs.getInt('refreshTokenExpiredTime');
    final currentTime = DateTime.now().millisecondsSinceEpoch / 1000.toInt();

    if (tokenExpiredTime != null) {
      if (currentTime < tokenExpiredTime) {
        return prefs.getString('token');
      } else if (refreshTokenExpiredTime != null) {
        if (currentTime < refreshTokenExpiredTime) {
          return prefs.getString('refreshToken');
        } else {
          _removeAll();
          return null;
        }
      } else {
        prefs.remove('token');
        return null;
      }
    }
    return null;
  }
}

Future<void> _removeAll() async {
  await SharedPreferences.getInstance()
    ..remove('token')
    ..remove('tokenExpiredTime')
    ..remove('refreshToken')
    ..remove('refreshTokenExpiredTime');
}
