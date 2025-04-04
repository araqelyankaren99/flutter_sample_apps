import 'package:flutter_sample_apps/src/constants.dart' as constants;
import 'package:flutter_sample_apps/src/middlewares/extensions/string.dart';
import 'package:flutter_sample_apps/src/models/order.dart';
import 'package:flutter_sample_apps/src/shared/card_item.dart';
import 'package:flutter_sample_apps/src/shared/heights_calculations.dart';
import 'package:flutter_sample_apps/src/shared/svg_icon.dart';
import 'package:flutter_sample_apps/src/style.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:marquee/marquee.dart';

final intl.DateFormat _outputFormatDate = intl.DateFormat(dateFormatDefault);
final intl.DateFormat _outputFormatTime = intl.DateFormat('HH:mm');

extension CardExtension on CardTitle {
  bool hasTextOverflow(String text, TextStyle style,
      {double minWidth = 0,
      double maxWidth = double.infinity,
      int maxLines = 2}) {
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: maxLines,
      textDirection: TextDirection.ltr,
    )..layout(minWidth: minWidth, maxWidth: maxWidth);
    return textPainter.didExceedMaxLines;
  }

  Widget _renderComplexMarquee(String street) {
    return Marquee(
      text: street,
      style: requestTextFieldsStyle,
      crossAxisAlignment: CrossAxisAlignment.start,
      blankSpace: 20.0,
      pauseAfterRound: const Duration(seconds: 1),
      accelerationDuration: const Duration(seconds: 1),
      accelerationCurve: Curves.linear,
      decelerationDuration: const Duration(milliseconds: 500),
      decelerationCurve: Curves.easeOut,
    );
  }

  Widget getContent(BuildContext context, Order order) {
    switch (this) {
      case CardTitle.from:
        return order.from.isNotEmpty
            ? hasTextOverflow(order.from, requestTextFieldsStyle,
                    maxLines: 1,
                    maxWidth: HeightsCalculations.marqueeMaxWidth(context))
                ? _renderComplexMarquee(order.from)
                : Text(
                    order.from,
                    maxLines: 1,
                    style: requestTextFieldsStyle,
                  )
            : Container();
      case CardTitle.destination:
        return order.destination.isNotEmpty
            ? hasTextOverflow(order.destination, requestTextFieldsStyle,
                    maxLines: 1,
                    maxWidth: HeightsCalculations.marqueeMaxWidth(context))
                ? _renderComplexMarquee(order.destination)
                : Text(
                    order.destination,
                    maxLines: 1,
                    style: requestTextFieldsStyle,
                  )
            : Container();

      case CardTitle.dateTime:
        return Row(
          children: [
            Container(
              padding: const EdgeInsets.only(right: 8.0),
              child: Text(
                _outputFormatDate.format(order.dueDate),
                style: requestTextFieldsStyle,
              ),
            ),
            Expanded(
              child: Text(
                _outputFormatTime.format(order.dueDate),
                style: requestTextFieldsStyle,
              ),
            ),
          ],
        );
      case CardTitle.comment:
        final _comment = order.comment;
        return Text(
          _comment != null
              ? _comment.length >= 20
                  ? '${_comment.substring(0, 15)}...'
                  : _comment
              : '',
          style: requestTextFieldsStyle,
        );

      case CardTitle.contactDriver:
        return Text(
          'Contact Driver',
          style: getStyle(color: azureRadianceColor),
        );
      case CardTitle.driver:
        return Text(
          '${order.driver?.firstName} ${order.driver?.lastName}',
          style: getStyle(color: blackColor),
        );
      case CardTitle.payment:
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Padding(
                  padding: EdgeInsets.only(right: 15.0 * constants.rw(context)),
                  child: Text(
                    '\$${order.amount}',
                    style: requestTextFieldsStyle,
                  ),
                ),
                Text(
                  '${order.mile?.toStringAsFixed(1)} miles',
                  style: requestTextFieldsStyle,
                ),
              ],
            ),
            Padding(
                padding: EdgeInsets.only(
                    right: '\$${order.baseFare?.toString() ?? '25.0'}'
                                .heightOfText(context, requestTextFieldsStyle) /
                            2 +
                        8),
                child: Text(
                    order.baseFare != null
                        ? '\$${order.baseFare?.toString()}'
                        : '',
                    style: requestTextFieldsStyle))
          ],
        );
      default:
        return Container();
    }
  }

  String getTitle() {
    switch (this) {
      case CardTitle.from:
        return 'From';
      case CardTitle.destination:
        return 'Destination';
      case CardTitle.dateTime:
        return 'Date/Time';
      case CardTitle.comment:
        return 'Comment';
      case CardTitle.driver:
        return 'Driver';
      case CardTitle.contactDriver:
        return '';
      case CardTitle.payment:
        return 'Payment';
      case CardTitle.baseFare:
        return 'Base Fare';
    }
  }

  Widget? getPrefixWidget() {
    if (this == CardTitle.driver) {
      return const SizedBox(
          height: 16, width: 16, child: SvgIcon(IconName.driver));
    } else if (this == CardTitle.contactDriver) {
      return const SizedBox(
          height: 16, width: 16, child: SvgIcon(IconName.phone));
    } else if (this == CardTitle.payment) {
      return const SizedBox(
          height: 16, width: 16, child: SvgIcon(IconName.payment));
    } else if (this == CardTitle.comment) {
      return const SvgIcon(IconName.comment);
    } else if (this == CardTitle.dateTime) {
      return const SizedBox(
          height: 16, width: 16, child: SvgIcon(IconName.calendar));
    }
    return null;
  }
}
