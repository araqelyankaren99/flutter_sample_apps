import 'package:flutter_sample_apps/src/constants.dart' as constants;
import 'package:flutter/material.dart';
import 'package:flutter_sample_apps/src/style.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class PinCodeFields extends StatelessWidget {
  const PinCodeFields(
      {required this.onChanged,
      required this.controller,
      this.padding = EdgeInsets.zero,
      this.onCompleted,
      this.color,
      this.enabled = true,
      this.focusNode});
  final EdgeInsets padding;
  final void Function(String)? onCompleted;
  final void Function(String) onChanged;
  final TextEditingController controller;
  final Color? color;
  final bool enabled;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    final pinTheme = PinTheme(
      borderWidth: 1.0,
      activeColor: color,
      selectedColor: color,
      inactiveColor: blackColor,
      activeFillColor: whiteColor,
      selectedFillColor: whiteColor,
      inactiveFillColor: whiteColor,
      disabledColor: whiteColor,
      fieldWidth: 25 * constants.rw(context),
      fieldHeight: 40 * constants.rh(context),
    );
    final getStyle = TextStyle(
        color: color,
        fontFamily: fontNameDefault,
        fontWeight: FontWeight.w500,
        fontSize: 16);

    return Container(
        width: double.infinity,
        padding: padding,
        margin: EdgeInsets.symmetric(horizontal: 54 * constants.rw(context)),
        child: PinCodeTextField(
          focusNode: focusNode,
          length: 6,
          enabled: enabled,
          textStyle: getStyle,
          autoFocus: true,
          animationType: AnimationType.scale,
          keyboardType: TextInputType.number,
          keyboardAppearance: Brightness.light,
          pinTheme: pinTheme,
          enableActiveFill: true,
          appContext: context,
          autoDismissKeyboard: false,
          onCompleted: onCompleted,
          onChanged: onChanged,
          controller: controller,
        ));
  }
}
