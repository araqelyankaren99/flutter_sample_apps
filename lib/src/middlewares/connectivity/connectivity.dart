import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'connectivity_widget.dart';

class Connection {
  final Connectivity _connectivity = Connectivity();

  /// This function check internet connection
  Future<bool> check() async {
    var result = ConnectivityResult.none;
    try {
      result = (await _connectivity.checkConnectivity()).first;
    } on PlatformException catch (e) {
      debugPrint(e.toString());
    }
    return result != ConnectivityResult.none;
  }

  /// This function opens alert if not internet connection else do anysinc this callback
  static void checker(BuildContext context, {required VoidCallback onDone}) {
    Connection()
        .check()
        .then((value) => value ? onDone() : Connection.showEntry(context));
  }

  static Future<void> showEntry(BuildContext context) async {
    late OverlayEntry overlayEntry;

    final overlayState = Overlay.of(context);
    overlayEntry = OverlayEntry(
        builder: (context) => Positioned(top: 0, child: ConnectivityWidget()));

    overlayState.insert(overlayEntry);

    await Future.delayed(
        const Duration(seconds: 3), () => overlayEntry.remove());
  }
}
