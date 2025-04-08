import 'package:flutter_sample_apps/constants.dart' as constants;
import 'package:flutter_sample_apps/style.dart';
import 'package:flutter/material.dart';

class TextArea extends StatefulWidget {
  const TextArea({
    required this.controller,
    this.hintText,
    this.hintStyle,
  });
  final TextEditingController controller;
  final String? hintText;
  final TextStyle? hintStyle;
  @override
  _TextAreaState createState() => _TextAreaState();
}

class _TextAreaState extends State<TextArea> {
  late FocusNode myFocusNode;

  @override
  void initState() {
    super.initState();

    myFocusNode = FocusNode();
  }

  @override
  void dispose() {
    myFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        margin: EdgeInsets.all(15 * constants.rw(context)),
        child: TextField(
          enabled: false,
          controller: widget.controller,
          minLines: 10,
          keyboardType: TextInputType.multiline,
          maxLines: 100,
          cursorColor: azureRadianceColor,
          decoration: InputDecoration(
            contentPadding: EdgeInsets.all(15 * constants.rw(context)),
            border: InputBorder.none,
            focusedBorder: InputBorder.none,
            enabledBorder: InputBorder.none,
            errorBorder: InputBorder.none,
            disabledBorder: InputBorder.none,
            hintText: widget.hintText,
            hintStyle: widget.hintStyle,
            filled: true,
            fillColor: Colors.white,
          ),
        ),
      ),
    );
  }
}
