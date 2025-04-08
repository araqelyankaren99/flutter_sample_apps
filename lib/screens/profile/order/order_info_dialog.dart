import 'package:flutter_sample_apps/constants.dart' as constants;
import 'package:flutter_sample_apps/models/order.dart';
import 'package:flutter_sample_apps/screens/profile/order/order_card_widget.dart';
import 'package:flutter_sample_apps/shared/app_bar_widget.dart';
import 'package:flutter_sample_apps/shared/next_button.dart';
import 'package:flutter_sample_apps/style.dart';
import 'package:flutter/material.dart';

typedef OnButtonTap = void Function();

class ShowOrderDialog {
  ShowOrderDialog(
      {required this.context,
      required this.order,
      required this.callback,
      required this.buttonText,});
  final BuildContext context;
  final Order order;
  final OnButtonTap callback;
  final String buttonText;
  OrderStatus get _orderStatus => order.state ?? OrderStatus.none;

  void showOrderFullInformation() {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding:
              EdgeInsets.symmetric(horizontal: 20 * constants.rw(context)),
          backgroundColor: blackHazeColor,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _renderAppBar(),
                OrderCardWidget(
                  order: order,
                  hasDivider: true,
                  orderInfos: const [
                    OrderInfo.road,
                  ],
                ),
                OrderCardWidget(
                  order: order,
                  hasDivider: true,
                  orderInfos: const [
                    OrderInfo.orderDate,
                    OrderInfo.orderTime,
                  ],
                ),
                OrderCardWidget(
                  order: order,
                  hasDivider: true,
                  orderInfos: const [
                    OrderInfo.driver,
                    OrderInfo.payment,
                  ],
                ),
                _renderBottomButton(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _renderBottomButton() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10 * constants.rh(context)),
      child: NextButton(
        onPress: callback,
        text: buttonText,
        textColor: Colors.white,
      ),
    );
  }

  Widget _renderAppBar() {
    return Container(
      color: Colors.white,
      margin: EdgeInsets.all(5 * constants.rw(context)),
      child: AppBarWidget(
        prefixWidget: Text(
          _orderStatus.getString(),
          style: getStyle(color: azureRadianceColor, weight: FontWeight.w500),
        ),
        titleStyle: getStyle(fontSize: 22, weight: FontWeight.w500),
        titleText: 'Order',
      ),
    );
  }
}
