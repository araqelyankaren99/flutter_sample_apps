import 'package:flutter_sample_apps/src/constants.dart' as constants;
import 'package:flutter_sample_apps/src/middlewares/extensions/string.dart';
import 'package:flutter_sample_apps/src/shared/heights_calculations.dart';
import 'package:flutter_sample_apps/src/style.dart';
import 'package:flutter/material.dart';

extension BottomSheetTypeExtension on BottomSheetType {
  double getHeight(
      {required BuildContext context,
      required double errorMessageSpace,
      OrderStatusType orderStatusType = OrderStatusType.waiting}) {
    switch (this) {
      case BottomSheetType.none:
        return 0;
      case BottomSheetType.withDriver:
        return 2 * (90 * constants.rw(context) - errorMessageSpace);
      case BottomSheetType.withDriverAndStatus:
        return (2 * (90 * constants.rw(context) - errorMessageSpace)) +
            (60 * constants.rw(context)) +
            orderStatusType
                .getString()
                .heightOfText(context, getStyle(color: azureRadianceColor));
      case BottomSheetType.unconfirmed:
        return 0;
      case BottomSheetType.rate:
        return (2 * (90 * constants.rw(context) - errorMessageSpace)) +
            (60 * constants.rw(context)) +
            orderStatusType
                .getString()
                .heightOfText(context, getStyle(color: azureRadianceColor));
    }
  }

  double getMinSize(
      {required BuildContext context,
      required double amount,
      required double errorTextHeight,
      required double btnTextHeight}) {
    return HeightsCalculations.minChildSize(
        context: context,
        amount: amount,
        errorTextHeight: errorTextHeight,
        btnTextHeight: btnTextHeight);
  }

  double getMaxSize(
      {required BuildContext context,
      required double amount,
      required OrderStatusType orderStatusType,
      required double errorTextHeight,
      required double btnTextHeight}) {
    switch (this) {
      case BottomSheetType.none:
        return HeightsCalculations.maxChildSize(
            context: context,
            amount: amount,
            errorTextHeight: errorTextHeight,
            btnTextHeight: btnTextHeight,
            bottomSheetType: this,
            orderStatusType: orderStatusType);
      case BottomSheetType.unconfirmed:
        return HeightsCalculations.minChildSize(
          context: context,
          amount: amount,
          errorTextHeight: errorTextHeight,
          btnTextHeight: btnTextHeight,
        );
      case BottomSheetType.withDriver:
        return HeightsCalculations.maxChildSize(
            context: context,
            amount: amount,
            errorTextHeight: errorTextHeight,
            btnTextHeight: btnTextHeight,
            bottomSheetType: this,
            orderStatusType: orderStatusType);
      case BottomSheetType.withDriverAndStatus:
        return HeightsCalculations.maxChildSize(
            context: context,
            amount: amount,
            errorTextHeight: errorTextHeight,
            btnTextHeight: btnTextHeight,
            bottomSheetType: this);
      case BottomSheetType.rate:
        return HeightsCalculations.maxChildSize(
            context: context,
            amount: amount,
            errorTextHeight: errorTextHeight,
            btnTextHeight: btnTextHeight,
            bottomSheetType: this);
    }
  }
}

extension OrderStatusTypeExtension on OrderStatusType {
  String getString() {
    switch (this) {
      case OrderStatusType.finished:
        return 'Finished';
      case OrderStatusType.started:
        return 'Driving';
      case OrderStatusType.waiting:
        return 'Driver waits you';
      case OrderStatusType.confirmed:
        return 'Accepted';
      case OrderStatusType.none:
      case OrderStatusType.fromCanceled:
      case OrderStatusType.fromFinished:
        return '';
      case OrderStatusType.rate:
        return '';
    }
  }
}

enum BottomSheetType {
  withDriver,
  withDriverAndStatus,
  unconfirmed,
  none,
  rate
}

enum OrderStatusType {
  started,
  waiting,
  finished,
  confirmed,
  none,
  fromFinished,
  fromCanceled,
  rate
}
