import 'package:flutter/material.dart';

class InternetNotifier {
  InternetNotifier._();

  static ValueNotifier<bool> internetNotifier = ValueNotifier<bool>(true);

  static void loseInternet() {
    internetNotifier.value = false;
  }

  static void connectInternet() {
    internetNotifier.value = true;
  }

  static bool get hasInternet => internetNotifier.value;
}
