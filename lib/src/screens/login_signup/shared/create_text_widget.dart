import 'package:flutter/material.dart';
import 'package:flutter_sample_apps/src/style.dart';

class CreateTextWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Text(
      'Create free account to join the Drivehop',
      style:
          getStyle(color: codGrayColor, fontSize: 12, weight: FontWeight.w500),
    );
  }
}
