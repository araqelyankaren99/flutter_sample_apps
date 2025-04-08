
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

extension StringSizeExtension on String {
  /// One line height of text
  double heightOfText(BuildContext context, TextStyle textStyle) {
    final constraints = BoxConstraints(
      maxHeight: MediaQuery.of(context).size.height,
    );

    final renderParagraph = RenderParagraph(
      TextSpan(
        text: this,
        style: textStyle,
      ),
      textDirection: TextDirection.ltr,
      textScaleFactor: MediaQuery.of(context).textScaleFactor,
      maxLines: 1,
    )..layout(constraints);

    final textlen = renderParagraph
        .getMinIntrinsicHeight(textStyle.fontSize ?? 13)
        .ceilToDouble();

    return textlen;
  }

// This method will return phone number without scopeis
  String phoneNumberWithoutScope() {
    return replaceAll('(', '').replaceAll(')', '').replaceAll('-', '');
  }

  //This method removes brackets from string
  String removeBrackets() {
    return replaceAll(
            RegExp(
              '{',
            ),
            '',)
        .replaceAll(
            RegExp(
              '}',
            ),
            '',);
  }

  String smsCodeVerifyPinParser() {
    return RegExp(r'(\d{6})').stringMatch(this) ?? '';
  }

  /// This method checks pin code is valid or not
  bool isValidPin() {
    return length == 6;
  }
}
