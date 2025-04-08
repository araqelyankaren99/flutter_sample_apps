import 'package:flutter_sample_apps/constants.dart' as constants;
import 'package:flutter_sample_apps/models/order.dart';
import 'package:flutter_sample_apps/screens/order_view/bloc/order_view_bloc.dart';
import 'package:flutter_sample_apps/shared/alert_widget.dart';
import 'package:flutter_sample_apps/shared/connectivity/connection.dart';
import 'package:flutter_sample_apps/shared/next_button.dart';
import 'package:flutter_sample_apps/style.dart';
import 'package:flutter/material.dart';

extension BottomBarExtension on OrderStatus {
  Widget getBottomBar(
      BuildContext context, OrderViewBloc orderViewBloc, Order order,
      {bool showLoadingCancel = false, bool showLoadingAccept = false,}) {
    final cancelButton = Expanded(
      child: NextButton(
          showLoading: showLoadingCancel,
          onPress: () => Connection.checker(context,
              onDone: () => _showCancelOrderAlert(context, showLoadingAccept,
                  showLoadingCancel, orderViewBloc, order,),),
          margin: 10 * constants.rh(context),
          color: Colors.white,
          borderColor: Colors.red,
          text: 'Cancel',
          progressIndicatorColor: Colors.red,
          textColor: Colors.red,),
    );
    final awaitingButton = Expanded(
      child: NextButton(
          onPress: () => Connection.checker(context,
              onDone: () => _onAwaitUserOrder(
                  showLoadingAccept, showLoadingCancel, orderViewBloc, order,),),
          margin: 10 * constants.rh(context),
          text: "I'm already there",
          showLoading: showLoadingAccept,
          textColor: whiteColor,),
    );
    final finishButton = NextButton(
        showLoading: showLoadingAccept,
        onPress: () => Connection.checker(context,
            onDone: () =>
                _onFinishOrder(showLoadingAccept, orderViewBloc, order),),
        margin: 10 * constants.rh(context),
        text: 'Order completed',
        textColor: whiteColor,);
    final onRoadButton = NextButton(
        showLoading: showLoadingAccept,
        onPress: () => Connection.checker(context,
            onDone: () =>
                _onStartOrder(showLoadingAccept, orderViewBloc, order),),
        margin: 10 * constants.rh(context),
        text: 'On road',
        textColor: whiteColor,);
    switch (this) {
      case OrderStatus.awaiting:
        return onRoadButton;

      case OrderStatus.onRoad:
        return finishButton;

      case OrderStatus.finished:
        return Container();
      case OrderStatus.confirmed:
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [cancelButton, awaitingButton],
        );
      default:
        return Container();
    }
  }

  void _showCancelOrderAlert(BuildContext context, bool showLoadingAccept,
      bool showLoadingCancel, OrderViewBloc orderViewBloc, Order order,) {
    if (!showLoadingAccept && !showLoadingCancel) {
      AlertWidget.showConfirmAlertDialog(context,
          title: 'Are you sure you want to cancel?',
          accept: 'Yes',
          cancel: 'No',
          onAcceptAction: () => _onCancelOrder(context, orderViewBloc, order),);
    }
  }

  void _onAwaitUserOrder(bool showLoadingAccept, bool showLoadingCancel,
      OrderViewBloc orderViewBloc, Order order,) {
    if (!showLoadingAccept && !showLoadingCancel) {
      orderViewBloc.add(AwaitUserEvent(orderId: order.id));
    }
  }

  void _onFinishOrder(
      bool showLoadingAccept, OrderViewBloc orderViewBloc, Order order,) {
    if (!showLoadingAccept) {
      orderViewBloc.add(FinishOrderEvent(orderId: order.id));
    }
  }

  void _onStartOrder(
      bool showLoadingAccept, OrderViewBloc orderViewBloc, Order order,) {
    if (!showLoadingAccept) {
      orderViewBloc.add(StartOrderEvent(orderId: order.id));
    }
  }

  void _onCancelOrder(
      BuildContext context, OrderViewBloc orderViewBloc, Order order,) {
    Navigator.pop(context);
    orderViewBloc.add(CancelOrderEvent(orderId: order.id));
  }
}
