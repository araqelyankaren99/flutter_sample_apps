import 'package:flutter/material.dart';
import 'package:flutter_sample_apps/src/style.dart';

class CenterText extends StatelessWidget {
  const CenterText({super.key, this.text});
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
