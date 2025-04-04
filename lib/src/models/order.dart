import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_sample_apps/src/middlewares/extensions/datetime.dart';
import 'package:flutter_sample_apps/src/models/driver.dart';
import 'package:flutter_sample_apps/src/models/invoice.dart';
import 'package:flutter_sample_apps/src/models/user.dart';
import 'package:flutter_sample_apps/src/screens/map_view/select_address_map_view/bloc/main_bloc.dart';
import 'package:flutter_sample_apps/src/screens/profile/order/order_info_dialog.dart';
import 'package:flutter_sample_apps/src/shared/alert_widget.dart';
import 'package:flutter_sample_apps/src/shared/btm_sheet_type_extension.dart';
import 'package:flutter_sample_apps/src/shared/next_button.dart';
import 'package:flutter_sample_apps/src/style.dart';

class Order {
  Order(
      {required this.id,
      required this.amount,
      required this.createdDate,
      required this.destination,
      required this.dueDate,
      required this.from,
      this.comment = '',
      this.driver,
      this.state = OrderStatus.none,
      this.user,
      this.fromLat,
      this.fromLng,
      this.toLat,
      this.toLng,
      this.mile,
      this.invoice,
      this.baseFare,
      this.cancellationAmount});

  factory Order.fromJson(Map<String, dynamic> json) {
    final userJson = json['user'];
    var user = User();
    if (userJson != null) {
      user = User.fromJson(userJson);
    }
    return Order(
        id: json['id'],
        from: json['from'],
        destination: json['destination'],
        createdDate: DateTime.parse(json['createdDate']),
        driver: json['driver'] != null
            ? Driver.fromMap(json['driver'])
            : Driver(
                firstName: '',
                lastName: '',
                birthDate: DateTime.now(),
                city: '',
                id: '',
                phone: '',
              ),
        user: user,
        state: StateExtension.castStringToStatusEnum(json['state'] ?? ''),
        amount: json['amount'].toDouble() ?? 0.0,
        comment: json['comment'][0] ?? '',
        dueDate: DateTime.parse(json['dueDate']),
        fromLat: json['fromLat']?.toDouble() ?? 0.0,
        fromLng: json['fromLng']?.toDouble() ?? 0.0,
        toLat: json['toLat']?.toDouble() ?? 0.0,
        toLng: json['toLng']?.toDouble() ?? 0.0,
        mile: max(json['mile']?.toDouble() ?? 0.0, 0.1),
        invoice:
            json['invoice'] != null ? Invoice.fromJson(json['invoice']) : null);
  }

  String id;
  double amount;
  String? comment;
  DateTime createdDate;
  String destination;
  Driver? driver;
  DateTime dueDate;
  String from;
  OrderStatus? state = OrderStatus.none;
  User? user;
  double? fromLat;
  double? fromLng;
  double? toLat;
  double? toLng;
  double? mile;
  Invoice? invoice;
  double? baseFare;
  double? cancellationAmount;
  void resetOrderData() {
    id = '';
    amount = 0.0;
    createdDate = DateTime.now();
    from = '';

    destination = '';
    dueDate = DateTime.now().get20MinutesLaterRounded();
    comment = '';
    driver?.resetDriverData();
    state = OrderStatus.none;

    fromLat = 0;
    fromLng = 0;
    toLat = 0;
    toLng = 0;
    mile = 0.0;
  }
}

extension StateExtension on OrderStatus {
  static OrderStatus castStringToStatusEnum(String statusString) {
    switch (statusString) {
      case 'UNCONFIRMED':
        return OrderStatus.unconfirmed;
      case 'ACCEPTED':
        return OrderStatus.confirmed;
      case 'WAITING':
        return OrderStatus.awaiting;
      case 'ON ROAD':
        return OrderStatus.onRoad;
      case 'FINISHED':
        return OrderStatus.finished;
      case 'CANCELED':
        return OrderStatus.canceled;
      default:
        return OrderStatus.none;
    }
  }

  String getString() {
    switch (this) {
      case OrderStatus.unconfirmed:
        return 'UNCONFIRMED';
      case OrderStatus.confirmed:
        return 'ACCEPTED';
      case OrderStatus.awaiting:
        return 'WAITING';
      case OrderStatus.onRoad:
        return 'ON ROAD';
      case OrderStatus.finished:
        return 'FINISHED';
      case OrderStatus.canceled:
        return 'CANCELED';
      case OrderStatus.none:
      case OrderStatus.fromCanceled:
      case OrderStatus.fromFinished:
        return '';
      case OrderStatus.rate:
        return '';
    }
  }

  BottomSheetType getBottomSheetType() {
    switch (this) {
      case OrderStatus.unconfirmed:
        return BottomSheetType.unconfirmed;
      case OrderStatus.confirmed:
      case OrderStatus.awaiting:
      case OrderStatus.onRoad:
      case OrderStatus.finished:
        return BottomSheetType.withDriverAndStatus;
      case OrderStatus.none:
      case OrderStatus.canceled:
        return BottomSheetType.none;
      case OrderStatus.fromCanceled:
        return BottomSheetType.none;
      case OrderStatus.fromFinished:
        return BottomSheetType.none;
      case OrderStatus.rate:
        return BottomSheetType.rate;
    }
  }

  OrderStatusType getOrderStatusType() {
    switch (this) {
      case OrderStatus.confirmed:
      case OrderStatus.canceled:
        return OrderStatusType.confirmed;
      case OrderStatus.unconfirmed:
      case OrderStatus.awaiting:
        return OrderStatusType.waiting;
      case OrderStatus.onRoad:
        return OrderStatusType.started;
      case OrderStatus.finished:
        return OrderStatusType.finished;
      case OrderStatus.none:
        return OrderStatusType.none;
      case OrderStatus.fromCanceled:
        return OrderStatusType.fromCanceled;
      case OrderStatus.fromFinished:
        return OrderStatusType.fromFinished;
      case OrderStatus.rate:
        return OrderStatusType.rate;
    }
  }

  Widget getButton(BuildContext context, MainBloc mainBloc,
      {required bool enable, bool showLoading = false}) {
    bool isActive() {
      return mainBloc.order.from.isNotEmpty &&
          mainBloc.order.destination.isNotEmpty;
    }

    switch (this) {
      case OrderStatus.finished:
        return NextButton(
            showLoading: showLoading,
            onPress: () {
              return ShowOrderDialog(
                      context: context,
                      order: mainBloc.order,
                      callback: () {
                        Navigator.pop(context);
                        mainBloc.add(const FinishOrderEvent());
                      },
                      buttonText: 'OK')
                  .showOrderFullInformation();
            },
            text: 'OK',
            textColor: whiteColor);
      case OrderStatus.confirmed:
      case OrderStatus.awaiting:
        return NextButton(
            absorbing: showLoading,
            showLoading: showLoading,
            onPress: () {
              AlertWidget.showConfirmAlertDialog(context,
                  title:
                      'Are you sure you want to cancel this order? You will be charged \$${mainBloc.order.cancellationAmount} for cancel.',
                  accept: 'Yes',
                  cancel: 'No ', onAcceptAction: () {
                mainBloc.add(CancelOrderEvent(order: mainBloc.order));
                Navigator.pop(context);
              });
            },
            text: 'Cancel',
            textColor: whiteColor);

      case OrderStatus.onRoad:
        return Container();

      default:
        return NextButton(
            absorbing: !isActive() || showLoading,
            showLoading: showLoading,
            isActive: isActive(),
            onPress: () {
              if (enable) {
                mainBloc.add(CheckPaymentMethodEvent());
              }
            },
            text: 'Request a driver',
            textColor: whiteColor);
    }
  }
}

enum OrderStatus {
  unconfirmed,
  confirmed,
  awaiting,
  onRoad,
  finished,
  canceled,
  none,
  fromFinished,
  fromCanceled,
  rate
}
