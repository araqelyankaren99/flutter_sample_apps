import 'package:flutter_sample_apps/constants.dart' as constants;
import 'package:flutter_sample_apps/middlewares/extension/string.dart';
import 'package:flutter_sample_apps/models/order.dart';
import 'package:flutter_sample_apps/style.dart';
import 'package:flutter/material.dart';

class ScrollHeightCalculation {
  ScrollHeightCalculation._();

  static double maxChildSize(BuildContext context, Order order) {
    return (tableHeight(context, order) + btnHeight(context: context)) /
        screenHeight(context);
  }

  static double minChildSize(BuildContext context, Order order) {
    return (tableMinHeight1(context, order) + btnHeight(context: context)) /
        screenHeight(context);
  }

  static double btnHeight({required BuildContext context}) =>
      10 * constants.rh(context) +
      15 * constants.rh(context) * 2 +
      "ConfirmCancelI'm already there".heightOfText(context, getStyle());

  static double screenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height -
        MediaQuery.of(context).padding.top -
        MediaQuery.of(context).padding.bottom;
  }

  static double orderInfoCellPadding(BuildContext context) {
    return 8.0 * constants.rw(context);
  }

  static double orderInfoCellPaddings(BuildContext context) {
    return orderInfoCellPadding(context);
  }

  static double cardPadding(BuildContext context) {
    return 5.0 * constants.rh(context);
  }

  static double tableHeight(BuildContext context, Order order) {
    return orderInfoCellPadding(context) * 2 * 6 +
        cardPadding(context) * constants.rh(context) * 8 +
        'From'.heightOfText(context, labelTextStyle) +
        order.from.heightOfText(context, requestTextFieldsStyle) +
        orderInfoCellPadding(context) +
        'Destination'.heightOfText(context, labelTextStyle) +
        order.destination.heightOfText(context, requestTextFieldsStyle) +
        order.amount.toString().heightOfText(context, requestTextFieldsStyle) +
        ''.heightOfText(context, labelTextStyle) +
        ''.toString().heightOfText(context, requestTextFieldsStyle) +
        ''.heightOfText(context, labelTextStyle) +
        ''.toString().heightOfText(context, requestTextFieldsStyle);
  }

  static double tableMinHeight1(BuildContext context, Order order) {
    return orderInfoCellPadding(context) * 6 +
        cardPadding(context) * constants.rh(context) * 4 +
        'Payment'.heightOfText(context, labelTextStyle) +
        order.amount.toString().heightOfText(context, requestTextFieldsStyle) +
        ''.heightOfText(context, labelTextStyle) +
        ''.toString().heightOfText(context, requestTextFieldsStyle) +
        ''.heightOfText(context, labelTextStyle) +
        ''.toString().heightOfText(context, requestTextFieldsStyle);
  }

  static bool hasTextOverflow(
      BuildContext context, String text, TextStyle style,
      {double minWidth = 0,
      double maxWidth = double.infinity,
      int maxLines = 2,}) {
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: maxLines,
      textDirection: TextDirection.ltr,
    )..layout(minWidth: minWidth, maxWidth: maxWidth);
    return textPainter.didExceedMaxLines;
  }

  static double maxWidth(BuildContext context) {
    return MediaQuery.of(context).size.width -
        50.0 * constants.rw(context) +
        2 * 5 * constants.rw(context);
  }
}
