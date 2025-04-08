import 'package:flutter_sample_apps/style.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PhoneNumberWidget extends StatelessWidget {
  const PhoneNumberWidget({
    required this.controller,
    required this.inputFormatter,
    required this.onClear,
    this.onChange,
  });

  final Function(String)? onChange;
  final Function() onClear;
  final TextEditingController controller;
  final TextInputFormatter inputFormatter;

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      TextFormField(
          autofocus: true,
          maxLength: 13,
          controller: controller,
          onChanged: onChange,
          inputFormatters: [inputFormatter],
          keyboardType: TextInputType.phone,
          keyboardAppearance: Brightness.light,
          style: getStyle(
              color: codGrayColor, fontSize: 16, weight: FontWeight.w500,),
          decoration: const InputDecoration(
              counterText: '',
              enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: spunPearlColor),),
              focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: codGrayColor),),
              filled: false,),),
      Container(
          alignment: Alignment.topRight,
          child: IconButton(
            alignment: Alignment.centerRight,
            padding: EdgeInsets.zero,
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onPressed: () => onClear(),
            icon: const Icon(
              Icons.clear,
              color: spunPearlColor,
            ),
          ),),
    ],);
  }
}
