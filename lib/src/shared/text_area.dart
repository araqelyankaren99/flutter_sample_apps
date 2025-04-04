import 'package:flutter_sample_apps/src/constants.dart' as constants;
import 'package:flutter_sample_apps/src/style.dart';
import 'package:flutter/material.dart';

class TextArea extends StatefulWidget {
  const TextArea({required this.controller, this.hintText, this.hintStyle});
  final TextEditingController controller;
  final String? hintText;
  final TextStyle? hintStyle;
  @override
  _TextAreaState createState() => _TextAreaState();
}

class _TextAreaState extends State<TextArea> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        margin: EdgeInsets.all(15 * constants.rw(context)),
        child: TextField(
          autofocus: true,
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
            suffix: InkWell(
              onTap: () => widget.controller.clear(),
              child: const Icon(Icons.clear),
            ),
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
