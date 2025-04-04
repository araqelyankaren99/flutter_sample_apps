import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sample_apps/src/style.dart';

class PhoneNumberWidget extends StatelessWidget {
  const PhoneNumberWidget(
      {required this.controller,
      required this.inputFormatter,
      required this.onClear,
      this.onChange,
      this.enabled = true});

  final Function(String)? onChange;
  final Function() onClear;
  final TextEditingController controller;
  final TextInputFormatter inputFormatter;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      TextFormField(
          enabled: enabled,
          autofocus: true,
          maxLength: 13,
          controller: controller,
          onChanged: onChange,
          inputFormatters: [inputFormatter],
          keyboardType: TextInputType.phone,
          keyboardAppearance: Brightness.light,
          style: getStyle(
              color: codGrayColor, fontSize: 16, weight: FontWeight.w500),
          decoration: const InputDecoration(
              counterText: '',
              enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: spunPearlColor)),
              focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: codGrayColor)),
              filled: false)),
      AbsorbPointer(
          absorbing: !enabled,
          child: Container(
              alignment: Alignment.topRight,
              child: IconButton(
                alignment: Alignment.centerRight,
                padding: EdgeInsets.zero,
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onPressed: onClear,
                icon: const Icon(
                  Icons.clear,
                  color: spunPearlColor,
                ),
              ))),
    ]);
  }
}
