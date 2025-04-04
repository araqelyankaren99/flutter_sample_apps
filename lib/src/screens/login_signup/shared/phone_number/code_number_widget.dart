import 'package:flutter/material.dart';
import 'package:flutter_sample_apps/src/style.dart';

class CodeNumberWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Container(
          alignment: Alignment.topCenter,
          width: double.infinity,
          margin: const EdgeInsets.only(right: 10),
          child: TextFormField(
              textAlign: TextAlign.center,
              initialValue: '+1',
              enabled: false,
              style: getStyle(
                  color: codGrayColor, fontSize: 16, weight: FontWeight.w500),
              decoration: const InputDecoration(
                enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: spunPearlColor)),
                filled: false,
              ))),
      Container(
          margin: const EdgeInsets.only(left: 20),
          alignment: Alignment.topRight,
          child: IconButton(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            icon: const Icon(Icons.arrow_drop_down, color: codGrayColor),
            onPressed: () {},
          )),
    ]);
  }
}
