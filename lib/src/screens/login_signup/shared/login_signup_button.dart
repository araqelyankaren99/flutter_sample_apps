import 'package:flutter_sample_apps/src/constants.dart' as constants;
import 'package:flutter/material.dart';
import 'package:flutter_sample_apps/src/style.dart';

class LoginAndSignUpButton extends StatelessWidget {
  const LoginAndSignUpButton(
      {required this.onPress,
      required this.text,
      this.color = cadetBlueColor,
      this.textColor = codGrayColor,
      this.padding,});

  final Color color;
   final Color textColor;
  final Function() onPress;
  final String text;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPress,
      child: DecoratedBox(
          decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(5 * constants.rh(context)),),
        child: Padding(
        padding: padding ??
            EdgeInsets.symmetric(
              vertical: 15 * constants.rh(context),
            ),
        child: Text(text,
            textAlign: TextAlign.center,
            style: getStyle(
                color: textColor, fontSize: 12, weight: FontWeight.w500,),),
      ),
    ),);
  }
}
