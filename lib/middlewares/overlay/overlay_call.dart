import 'dart:async';

import 'package:flutter_sample_apps/shared/connectivity/connectivity_widget.dart';
import 'package:flutter/material.dart';

class OverlayCall {
  OverlayEntry? _overlayEntry;
  Future<void> showEntry({required BuildContext context}) async {
    final overlayState = Overlay.of(context);
    _overlayEntry = OverlayEntry(
        builder: (context) => Positioned(top: 0, child: ConnectivityWidget()),);
    final entry = _overlayEntry;
    if (entry != null) {
      overlayState.insert(entry);
    }
  }

  void remove() {
    _overlayEntry?.remove();
  }
}
