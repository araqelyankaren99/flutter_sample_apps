import 'package:flutter_sample_apps/models/driver.dart';
import 'package:flutter_sample_apps/models/user.dart';
import 'package:flutter_sample_apps/shared/alert_widget.dart';
import 'package:flutter_sample_apps/shared/btm_sheet_type_extension.dart';
import 'package:flutter_sample_apps/style.dart';
import 'package:flutter/material.dart';

class Order {
  Order({
    required this.id,
    required this.amount,
    required this.createdDate,
    required this.destination,
    required this.dueDate,
    required this.from,
    required this.km,
    required this.distanceBetweenDriver,
    this.comment = '',
    this.driver,
    this.state = OrderStatus.none,
    this.user,
    this.fromLat,
    this.fromLng,
    this.toLat,
    this.toLng,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as String,
      from: json['from'] as String,
      destination: json['destination'] as String,
      createdDate: DateTime.parse(json['createdDate'] as String ),
      distanceBetweenDriver: (json['distanceBetweenDriver'] as int?)?.toDouble() ?? 0.0,
      driver: json['driver'] != null
          ? Driver.fromMap(json['driver'] as Map<String,dynamic>)
          : Driver(
              firstName: '',
              lastName: '',
              birthDate: DateTime.now(),
              city: '',
              id: '',
              phone: '',
            ),
      user: json['user'] != null ? User.fromJson(json['user'] as Map<String,dynamic>) : User(),
      state: StateExtension.castStringToStatusEnum(json['state'] as String),
      amount: (json['amount'] as int?)?.toDouble() ?? 0.0,
      comment: (json['comment'] as List<dynamic>)[0] as String? ?? '',
      dueDate: DateTime.parse(json['dueDate'] as String),
      fromLat: (json['fromLat'] as int?)?.toDouble() ?? 0.0,
      fromLng: (json['fromLng'] as int?)?.toDouble() ?? 0.0,
      toLat:(json['toLat'] as int?)?.toDouble() ?? 0.0,
      toLng: (json['toLng'] as int?)?.toDouble() ?? 0.0,
      km: (json['km'] as int?)?.toDouble() ?? 0.0,
    );
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
  double km;
  double distanceBetweenDriver;

  void resetOrderData() {
    id = '';
    amount = 0.0;
    createdDate = DateTime.now();
    destination = '';
    dueDate = DateTime.now();
    from = '';
    comment = '';
    driver?.resetDriverData();
    state = OrderStatus.none;

    fromLat = 0;
    fromLng = 0;
    toLat = 0;
    toLng = 0;
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
        return 'CONFIRMED';
      case OrderStatus.awaiting:
        return 'AWAITING';
      case OrderStatus.onRoad:
        return 'ON ROAD';
      case OrderStatus.finished:
        return 'FINISHED';
      case OrderStatus.canceled:
        return 'CANCELED';
      case OrderStatus.none:
      default:
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
      default:
        return BottomSheetType.none;
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
      default:
        return OrderStatusType.fromFinished;
    }
  }

  Widget? statusIcon() {
    switch (this) {
      case OrderStatus.canceled:
        return const Icon(
          Icons.cancel,
          color: Colors.red,
        );
      case OrderStatus.finished:
        return const Icon(
          Icons.check_circle,
          color: azureRadianceColor,
        );
      default:
        return Container();
    }
  }

  void getAlert(BuildContext context) {
    if (this == OrderStatus.awaiting) {
      AlertWidget().acceptAction(context, 'Waiting...');
    }
    if (this == OrderStatus.onRoad) {
      AlertWidget().acceptAction(context, 'Started');
    }
    if (this == OrderStatus.finished) {
      AlertWidget(closeAction: () {
        Navigator.pop(context);
      },).acceptAction(context, 'Finished');
    }
    if (this == OrderStatus.canceled) {
      AlertWidget(closeAction: () {
        Navigator.pop(context);
      },).cancelAction(context, 'Canceled');
    }
    if (this == OrderStatus.confirmed) {
      AlertWidget().acceptAction(context, 'Confirmed');
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
}
