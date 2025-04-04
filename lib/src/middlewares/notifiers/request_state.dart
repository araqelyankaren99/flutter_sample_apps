import 'package:flutter/material.dart';
import 'package:flutter_sample_apps/src/models/order.dart';

class RequestState with ChangeNotifier {
  RequestState(this._orderStatus);

  OrderStatus get orderStatus => _orderStatus;
  set orderStatus(OrderStatus orderStatus) {
    final prevOrderStatus = _orderStatus;
    _orderStatus = orderStatus;
    if (prevOrderStatus != orderStatus) {
      notifyListeners();
    }
  }

  OrderStatus _orderStatus = OrderStatus.none;
}
