import 'package:flutter_sample_apps/src/shared/next_button.dart';
import 'package:flutter/material.dart';

class UserActionResultDialog {
  UserActionResultDialog({required this.context});
  BuildContext context;

  void show(
      {required bool dismissOnTap, required String editNotificationText}) {
    showDialog(
      context: context,
      barrierDismissible: dismissOnTap,
      builder: (context) {
        _closeAfter(context, dismissOnTap);
        return AlertDialog(
          title: Text(
            editNotificationText,
            textAlign: TextAlign.center,
          ),
          content: _content(dismissOnTap),
        );
      },
    );
  }

  Widget? _content(bool dismissOnTap) {
    return dismissOnTap
        ? NextButton(
            onPress: () => Navigator.pop(context),
            text: 'OK',
            textColor: Colors.white,
          )
        : null;
  }

  void _closeAfter(BuildContext context, bool dismissOnTap) {
    if (!dismissOnTap) {
      Future.delayed(const Duration(seconds: 1), () {
        Navigator.pop(context);
      });
    }
  }
}
