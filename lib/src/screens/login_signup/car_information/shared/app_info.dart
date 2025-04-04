import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AppInfo {
  AppInfo._(this.phoneInformation, this.version, this.isNewVersion);

  final String phoneInformation;
  final String version;
  final bool isNewVersion;

  static Future<AppInfo> fetchData() async {
    var _phoneInformation = '';
    var _checkPhoneVersion = true;

    final packageInfo = await PackageInfo.fromPlatform();
    final _version = packageInfo.version;

    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      final release = androidInfo.version.release;
      final manufacturer = androidInfo.manufacturer;
      final model = androidInfo.model;
      const phoneModel = 'Android';
      _phoneInformation = '$manufacturer $model - $phoneModel $release';
    }

    if (Platform.isIOS) {
      final iosInfo = await DeviceInfoPlugin().iosInfo;
      final systemName = iosInfo.systemName;
      final version = iosInfo.systemVersion;
      final name = iosInfo.name;
      _checkPhoneVersion = version.compareTo('14.6') != -1;
      _phoneInformation = '$name - $version $systemName';
    }

    return AppInfo._(_phoneInformation, _version, _checkPhoneVersion);
  }
}
