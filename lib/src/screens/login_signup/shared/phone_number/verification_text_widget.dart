import 'package:flutter_sample_apps/src/constants.dart' as constants;
import 'package:flutter/material.dart';
import 'package:flutter_sample_apps/src/style.dart';

class VerificationTextWidget extends StatelessWidget {
  const VerificationTextWidget(
      {this.text = '', this.padding = EdgeInsets.zero});
  final String text;
  final EdgeInsets padding;
  @override
  Widget build(BuildContext context) {
    return Container(
        width: double.infinity,
        margin: EdgeInsets.symmetric(horizontal: 80 * constants.rw(context)),
        padding: padding,
        child: Text(
          text,
          textAlign: TextAlign.center,
          softWrap: true,
          style: getStyle(
              color: spunPearlColor, fontSize: 12, weight: FontWeight.w500),
        ));
  }
}
