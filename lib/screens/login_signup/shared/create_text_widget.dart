import 'package:flutter_sample_apps/style.dart';
import 'package:flutter/material.dart';

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
