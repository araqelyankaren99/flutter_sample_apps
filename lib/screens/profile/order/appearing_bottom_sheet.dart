import 'package:flutter_sample_apps/models/order.dart';
import 'package:flutter_sample_apps/screens/profile/order/appearing_btm_sheet_extension.dart';
import 'package:flutter_sample_apps/screens/profile/order/order_card_widget.dart';
import 'package:flutter/material.dart';

class AppearingBottomSheetWidget extends StatefulWidget {
  AppearingBottomSheetWidget({required this.userCreatedOrders})
      : super(key: Key(userCreatedOrders.length.toString()));

  final List<Order> userCreatedOrders;

  @override
  _AppearingBottomSheetWidgetState createState() =>
      _AppearingBottomSheetWidgetState();
}

class _AppearingBottomSheetWidgetState
    extends State<AppearingBottomSheetWidget> {
  List<Order> get userCreatedOrdersList => widget.userCreatedOrders;
  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: initalSize(),
      minChildSize: minSize(),
      maxChildSize: maxSize(),
      builder: (BuildContext context, ScrollController scrollController) {
        return ListView.builder(
          physics: const ClampingScrollPhysics(),
          controller: scrollController,
          shrinkWrap: true,
          itemCount: userCreatedOrdersList.length,
          itemBuilder: (BuildContext context, int index) {
            return OrderCardWidget(
              order: userCreatedOrdersList[index],
              orderInfos: const [
                OrderInfo.road,
                OrderInfo.payment,
              ],
              hasDivider: true,
              userOrderStatusType: UserOrderStatusType.unconfirmed,
            );
          },
        );
      },
    );
  }

  double initalSize() {
    if (widget.userCreatedOrders.isEmpty) {
      return 0.1;
    }
    if (widget.userCreatedOrders.length == 1) {
      return 0.3;
    }
    return 0.4;
  }

  double minSize() {
    if (widget.userCreatedOrders.isEmpty) {
      return 0.1;
    }
    if (widget.userCreatedOrders.length == 1) {
      return 0.3;
    }
    return 0.4;
  }

  double maxSize() {
    if (widget.userCreatedOrders.isEmpty) {
      return 0.1;
    } else if (widget.userCreatedOrders.length == 1) {
      return 0.3;
    } else if (widget.userCreatedOrders.length == 2) {
      return 0.6;
    }
    return 0.7;
  }
}
