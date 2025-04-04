import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sample_apps/main.dart';
import 'package:flutter_sample_apps/src/home_screen_initialization.dart';
import 'package:flutter_sample_apps/src/middlewares/connectivity/connectivity.dart';

mixin ConnectionMixin<T extends StatefulWidget> on State<T> {
  /// Listen Connection and page change if needed
  Future<void> connectionListener() async {
    final isDeviceConnected = await Connection().check();

    if (!isDeviceConnected) {
      Connectivity().onConnectivityChanged.listen((status) async {
        if (status != ConnectivityResult.none) {
          final _homeScreenType = await initHomeScreen();

          if (_homeScreenType == HomeScreenType.mapView) {
            return;
          }

          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
                builder: (BuildContext context) =>
                    MyApp(homeScreenType: _homeScreenType)),
            (Route route) => false,
          );
        }
      });
    }
  }
}
