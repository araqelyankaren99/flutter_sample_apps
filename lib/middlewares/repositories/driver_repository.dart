import 'package:flutter_sample_apps/middlewares/repositories/graph_ql_repository.dart';
import 'package:flutter_sample_apps/models/driver.dart';
import 'package:flutter_sample_apps/screens/login_signup/shared/token_info.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DriverRepository {
  final GraphQlRepository _graphQlRepository = GraphQlRepository();

  Future<String?> getStoredToken() async {
    final token = await TokenInfo.getToken();
    return token;
  }

  /// This function true if driver registred else false
  Future<String?> isRegistred(String token) async {
    try {
      final _queryResultForNumber = await _graphQlRepository.getDriver(token);
      final queryResultForNumber = _queryResultForNumber.data;
      if (queryResultForNumber!['thisDriver'] == null) {
        return null;
      }
      final phone = queryResultForNumber!['thisDriver']['phone'];
      return phone is String ? phone : null;
    } catch (e) {
      return null;
    }
    return null;
  }

  /// Check is active driver or not
  Future<bool?> isActivated(String token) async {
    try {
      final queryResult = await _graphQlRepository.driverIsActivated(token);

      final data = queryResult.data;
      if (data != null) {
        if (data['thisDriver'] == null) {
          return null;
        }
        final isActive = data['thisDriver']['isActivated'];
        return isActive is bool ? isActive : null;
      }
    } catch (e) {
      return null;
    }
    return null;
  }

  /// Get driver info
  Future<Driver?> getDriverInfo() async {
    final queryResult = await _graphQlRepository.getDriverInfo();
    try {
      final data = queryResult.data;
      if (data != null) {
        final driver = Driver.fromMap(data['thisDriver'] as Map<String,dynamic>);
        final driverAttachment = driver.attachment;
        if (driverAttachment != null) {
          final driverAttachmentDownloadLinks = driverAttachment.downloadLink;

          if (driverAttachmentDownloadLinks != null) {
            var driverAttachmentDownloadLink = '';
            for (final map in driverAttachmentDownloadLinks) {
              if (map.keys.first == 'profileImage') {
                driverAttachmentDownloadLink = map[map.keys.first] ?? '';
              }
            }
            final imageData = await NetworkAssetBundle(
                    Uri.parse(driverAttachmentDownloadLink),)
                .load('');
            driver.profileImageBytes = imageData.buffer.asUint8List();
          }
        }
        return driver;
      }
    } catch (e) {
      return null;
    }
    return null;
  }

  /// This function return number phone or error message or null(if number is not used)
  Future<String?> checkNumber(String token) async {
    try {
      final queryResultForNumber = await _graphQlRepository.getDriver(token);
      final data = queryResultForNumber.data;
      if (data != null) {
        if (queryResultForNumber.data!['thisDriver'] == null) {
          return null;
        }
        return data['thisDriver']['phone'] as String;
      }
    } catch (e) {
      return null;
    }
    return null;
  }

  /// Add token to SharedPreferences
  Future<bool> storeToken(String token,
      {int? tokenExpiredTime,
      String? refreshToken,
      int? refreshTokenExpiredTime,}) async {
    final prefs = await SharedPreferences.getInstance();
    final currentTime = DateTime.now().microsecondsSinceEpoch / 1000;

    if (tokenExpiredTime != null) {
      final _tokenExpiredTime = currentTime.toInt() + tokenExpiredTime;
      prefs.setInt('tokenExpiredTime', _tokenExpiredTime);
    }

    if (refreshToken != null) {
      prefs.setString('refreshToken', refreshToken);
    }

    if (refreshTokenExpiredTime != null) {
      final _refreshTokenExpiredTime =
          currentTime.toInt() + refreshTokenExpiredTime;
      prefs.setInt('refreshTokenExpiredTime', _refreshTokenExpiredTime);
    }
    return prefs.setString('token', token);
  }

  /// Add phone to SharedPreferences
  Future<bool> storePhoneNumber(String phoneNumber) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.setString('phone', phoneNumber);
  }

  /// Get phoneNumber
  Future<String> getPhoneNumber() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getString('phone')!;
  }

  /// Get token
  Future<String> getToken() async {
    final token = await TokenInfo.getToken();
    return token!;
  }
}
