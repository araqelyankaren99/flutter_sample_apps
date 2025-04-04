import 'package:flutter_sample_apps/src/constants.dart' as constants;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sample_apps/src/style.dart';

class SecurityTextWidget extends StatelessWidget {
  const SecurityTextWidget({super.key, this.padding = EdgeInsets.zero});

  final EdgeInsets padding;
  @override
  Widget build(BuildContext context) {
    return Container(
        alignment: Alignment.center,
        width: double.infinity,
        padding: padding,
        margin: EdgeInsets.symmetric(horizontal: 55 * constants.rw(context)),
        child: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
              text: 'By providing py phone number, I agree and accept the ',
              style: regularBlueTextStyle12,
              children: [
                TextSpan(
                    text: 'Terms use ',
                    style: underlineBlueTextStyle12,
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        constants.launchURL('http://drivehop.com/terms/');
                      }),
                const TextSpan(text: 'and ', style: regularBlueTextStyle12),
                TextSpan(
                    text: 'Privacy policy',
                    style: underlineBlueTextStyle12,
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        constants
                            .launchURL('http://drivehop.com/privacy-policy/');
                      }),
              ]),
        ));
  }
}
