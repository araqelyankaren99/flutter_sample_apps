import 'dart:math';

import 'package:flutter_sample_apps/src/constants.dart' as constants;
import 'package:flutter_sample_apps/src/shared/btm_sheet_type_extension.dart';
import 'package:flutter/material.dart';

class HeightsCalculations {
  HeightsCalculations._();

  static double cardHeight(BuildContext context) {
    return 90 * constants.rw(context) * 3 + 4 * 10 * constants.rw(context);
  }

  static double marqueeMaxWidth(BuildContext context) {
    return MediaQuery.of(context).size.width -
        (3 * 30 * constants.rw(context) +
            18 * constants.rw(context) +
            4 * 10 * constants.rw(context));
  }

  static double errorMessageSpace(
      {required BuildContext context, required double errorTextHeight}) {
    return 3 + errorTextHeight;
  }

  static double cardHeightWithoutErrorMsgSpc(
      {required BuildContext context, required double errorTextHeight}) {
    return cardHeight(context) -
        (2 *
            errorMessageSpace(
                context: context, errorTextHeight: errorTextHeight));
  }

  static double aviableHeight(BuildContext context) =>
      MediaQuery.of(context).size.height -
      MediaQuery.of(context).padding.top -
      MediaQuery.of(context).padding.bottom;

  static double btnHeight(
          {required BuildContext context, required double btnTextHeight}) =>
      15 * constants.rh(context) * 2 + btnTextHeight;
  static double btnPadding(BuildContext context) => 10 * constants.rh(context);
  static double bottomSheetBarHeight(BuildContext context) =>
      50 * constants.rh(context) + 10 * constants.rw(context);

  static double maxChildSize({
    required BuildContext context,
    required double amount,
    required BottomSheetType bottomSheetType,
    required double errorTextHeight,
    required double btnTextHeight,
    OrderStatusType orderStatusType = OrderStatusType.waiting,
  }) =>
      min(
          (bottomSheetBarHeight(context) +
                  cardHeight(context) +
                  cardHeightWithoutErrorMsgSpc(
                          context: context, errorTextHeight: errorTextHeight) *
                      2 /
                      3 +
                  btnHeight(context: context, btnTextHeight: btnTextHeight) -
                  (amount != 0
                      ? 0
                      : (90 * constants.rw(context) -
                          errorMessageSpace(
                              context: context,
                              errorTextHeight: errorTextHeight))) +
                  bottomSheetType.getHeight(
                      context: context,
                      errorMessageSpace: errorMessageSpace(
                          context: context, errorTextHeight: errorTextHeight),
                      orderStatusType: orderStatusType) -
                  10) /
              aviableHeight(context),
          0.95);

  static double minChildSize(
      {required BuildContext context,
      required double amount,
      required double errorTextHeight,
      required double btnTextHeight}) {
    return (cardHeight(context) * 2 / 3 +
            btnHeight(context: context, btnTextHeight: btnTextHeight) +
            btnPadding(context) +
            bottomSheetBarHeight(context)) /
        aviableHeight(context);
  }

  static double scrollableBottomSheetContainerHeight(
          {required BuildContext context,
          required double amount,
          required BottomSheetType bottomSheetType,
          required OrderStatusType orderStatusType,
          required double errorTextHeight,
          required double btnTextHeight}) =>
      cardHeight(context) +
      cardHeightWithoutErrorMsgSpc(
              context: context, errorTextHeight: errorTextHeight) *
          2 /
          3 +
      btnHeight(context: context, btnTextHeight: btnTextHeight) -
      (amount != 0
          ? 0
          : 90 * constants.rw(context) -
              errorMessageSpace(
                  context: context, errorTextHeight: errorTextHeight)) +
      bottomSheetType.getHeight(
          context: context,
          errorMessageSpace: errorMessageSpace(
              context: context, errorTextHeight: errorTextHeight),
          orderStatusType: orderStatusType) -
      10;
}
