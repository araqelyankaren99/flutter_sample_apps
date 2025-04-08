import 'package:flutter_sample_apps/constants.dart' as constants;
import 'package:flutter_sample_apps/shared/next_button.dart';
import 'package:flutter_sample_apps/style.dart';
import 'package:flutter/material.dart';

class CustomAlertDialog {
  static void show(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.all(20 * constants.rw(context)),
              child: Text(
                'Please, try again later',
                style: getStyle(fontSize: 16, weight: FontWeight.w500),
              ),
            ),
            Padding(
              padding:
                  EdgeInsets.symmetric(vertical: 10 * constants.rh(context)),
              child: NextButton(
                color: dodgerBlueColor,
                onPress: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                text: 'OK',
                textColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
