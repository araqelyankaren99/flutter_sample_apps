import 'package:flutter_sample_apps/constants.dart';
import 'package:flutter_sample_apps/middlewares/extension/bottom_bar_extension.dart';
import 'package:flutter_sample_apps/models/order.dart';
import 'package:flutter_sample_apps/screens/order_view/bloc/order_view_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BottomBar extends StatelessWidget {
  const BottomBar(this.order, this.orderStatus,
      {this.showLoadingAccept = false, this.showLoadingCancel = false,});
  final Order order;
  final OrderStatus orderStatus;
  final bool showLoadingAccept;

  final bool showLoadingCancel;
  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Positioned.fill(
        bottom: 10 * rh(context),
        child: Align(
            alignment: Alignment.bottomCenter,
            child: orderStatus.getBottomBar(
                context, BlocProvider.of<OrderViewBloc>(context), order,
                showLoadingAccept: showLoadingAccept,
                showLoadingCancel: showLoadingCancel,),),
      )
    ],);
  }
}
