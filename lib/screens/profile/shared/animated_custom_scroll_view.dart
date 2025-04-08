import 'package:flutter_sample_apps/models/order.dart';
import 'package:flutter_sample_apps/screens/order_view/bloc/order_view_bloc.dart';
import 'package:flutter_sample_apps/screens/order_view/order_view.dart';
import 'package:flutter_sample_apps/screens/order_view/view_trip.dart';
import 'package:flutter_sample_apps/screens/profile/live_orders/live_orders_bloc/live_orders_bloc.dart';
import 'package:flutter_sample_apps/screens/profile/live_orders/live_orders_bloc/live_orders_event.dart';
import 'package:flutter_sample_apps/screens/profile/live_orders/live_orders_bloc/live_orders_state.dart';
import 'package:flutter_sample_apps/screens/profile/order/appearing_btm_sheet_extension.dart';
import 'package:flutter_sample_apps/screens/profile/order/order_card_widget.dart';
import 'package:flutter_sample_apps/shared/connectivity/connection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AnimatedCustomScrollView extends StatefulWidget {
  const AnimatedCustomScrollView({
    required this.unconfirmedOrders,
    required this.onRefresh,
  });
  final Future<void> Function()? onRefresh;
  final List<Order> unconfirmedOrders;
  @override
  _AnimatedCustomScrollViewState createState() =>
      _AnimatedCustomScrollViewState();
}

class _AnimatedCustomScrollViewState extends State<AnimatedCustomScrollView>
    with TickerProviderStateMixin {
  OrderViewBloc get _orderViewBloc => BlocProvider.of<OrderViewBloc>(context);
  LiveOrdersBloc get _liveOrderBloc => BlocProvider.of<LiveOrdersBloc>(context);

  late final AnimationController _animationController = AnimationController(
    duration: const Duration(milliseconds: 500),
    vsync: this,
  );
  late final Animation<double> _animation = CurvedAnimation(
    parent: _animationController,
    curve: Curves.linear,
  );
  List<int> confirmedIndexList = [];
  Order? confirmedOrder;

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<LiveOrdersBloc, LiveOrdersState>(
          listener: _liveOrdersListener,
        ),
        BlocListener<OrderViewBloc, OrderViewState>(
            listener: _orderViewListener,),
      ],
      child: CustomScrollView(physics: _getScrollPhysics(), slivers: <Widget>[
        CupertinoSliverRefreshControl(
          onRefresh: widget.onRefresh,
        ),
        SliverFadeTransition(
          opacity: _animation,
          sliver: SliverList(delegate: _getSliverChildDelegate()),
        ),
      ],),
    );
  }

  ScrollPhysics? _getScrollPhysics() {
    return const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics());
  }

  SliverChildDelegate _getSliverChildDelegate() {
    return SliverChildBuilderDelegate(
      (BuildContext context, int index) {
        return OrderCardWidget(
            order: widget.unconfirmedOrders[index],
            orderInfos: _orderInfos(index),
            isActive: !confirmedIndexList.contains(index),
            hasDivider: true,
            confirmButtonLoading: confirmedIndexList.contains(index),
            userOrderStatusType: UserOrderStatusType.unconfirmed,
            onConfirmTap: () =>
                Connection.checker(context, onDone: () => _onConfirmTap(index)),
            onViewTripTap: () => Connection.checker(context,
                onDone: () =>
                    _navigateViewTrip(widget.unconfirmedOrders[index]),),);
      },
      childCount: widget.unconfirmedOrders.length,
    );
  }

  List<OrderInfo> _orderInfos(int index) {
    final orderInfo = [OrderInfo.road];
    if (widget.unconfirmedOrders[index].comment != '') {
      orderInfo.add(OrderInfo.comment);
    }
    if (widget.unconfirmedOrders[index].user?.car != null) {
      orderInfo.add(OrderInfo.car);
    }
    orderInfo.add(OrderInfo.payment);
    return orderInfo;
  }

  /// This function confirm selected order
  void _onConfirmTap(int index) {
    if (confirmedOrder == null) {
      confirmedOrder = widget.unconfirmedOrders[index];
      if (!confirmedIndexList.contains(index)) {
        confirmedIndexList.add(index);
      } else {
        confirmedIndexList.remove(index);
        confirmedOrder = null;
      }
      setState(() {});
      _orderViewBloc
          .add(ConfirmOrderEvent(orderId: widget.unconfirmedOrders[index].id));
    }
  }

  /// This function navigate to view screen
  void _navigateViewTrip(Order order) {
    if (confirmedOrder == null) {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => BlocProvider.value(
                  value: _orderViewBloc,
                  child: ViewTrip(order: order),
                ),),
      );
    }
  }

  void _liveOrdersListener(context, state) {
    if (state is UnconfirmedOrdersLoadedState) {
      if (state.unconfirmedOrders.isEmpty) {
        _animationController.reverse();
      } else {
        _animationController.forward();
      }
    }
  }

  void _orderViewListener(context, state) {
    if (state is OrderStatusChangedState) {
      if (state.orderStatus == OrderStatus.confirmed) {
        _liveOrderBloc
          ..add(const UpdateDriverLocationEvent())
          ..add(const GetUnconfirmedOrdersEvent());
        if (confirmedOrder != null) {
          _navigateOrderView(confirmedOrder!);
        }
        confirmedIndexList.clear();
        confirmedOrder = null;
        setState(() {});
      }
    }
    if (state is CannotConfirmOrderState) {
      confirmedOrder = null;
      confirmedIndexList.clear();
      confirmedOrder = null;
      setState(() {});
    }
  }

  /// This function navigate to order screen
  void _navigateOrderView(Order order, {bool alreadyConfirmed = false}) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => BlocProvider.value(
                value: _orderViewBloc,
                child: OrderView(
                  order: order,
                  alreadyConfirmed: alreadyConfirmed,
                ),
              ),),
    );
  }
}
