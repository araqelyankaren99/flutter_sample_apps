import 'package:flutter_sample_apps/style.dart';
import 'package:flutter/material.dart';

class CenterText extends StatelessWidget {
  const CenterText({this.text});
  final String? text;
  @override
  Widget build(BuildContext context) {
    return Text(
      text ?? '',
      style: getStyle(
        weight: FontWeight.w500,
        color: codGrayColor,
        fontSize: 16,
      ),
    );
  }
}
