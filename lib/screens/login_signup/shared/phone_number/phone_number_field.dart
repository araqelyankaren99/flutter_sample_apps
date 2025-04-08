import 'package:flutter_sample_apps/constants.dart' as constants;
import 'package:flutter_sample_apps/screens/login_signup/shared/phone_number/code_number_widget.dart';
import 'package:flutter_sample_apps/screens/login_signup/shared/phone_number/phone_number_widget.dart';
import 'package:flutter_sample_apps/style.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PhoneNumberField extends StatelessWidget {
  const PhoneNumberField({
    required this.controller,
    required this.inputFormatter,
    required this.onClear,
    this.onChange,
    this.padding = EdgeInsets.zero,
  });

  final Function(String)? onChange;
  final Function() onClear;
  final TextEditingController controller;
  final TextInputFormatter inputFormatter;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
        width: double.infinity,
        padding: padding,
        margin: EdgeInsets.symmetric(horizontal: 54 * constants.rw(context)),
        child: Row(
          children: <Widget>[
            Flexible(
              child: CodeNumberWidget(),
            ),
            const SizedBox(
              width: 15,
            ),
            Flexible(
                flex: 4,
                child: Container(
                    color: whiteColor,
                    child: PhoneNumberWidget(
                      inputFormatter: inputFormatter,
                      controller: controller,
                      onChange: onChange,
                      onClear: onClear,
                    ),),)
          ],
        ),);
  }
}
