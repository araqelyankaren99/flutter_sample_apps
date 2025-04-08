import 'package:flutter_sample_apps/models/order.dart';
import 'package:flutter_sample_apps/screens/order_view/bloc/order_view_bloc.dart';
import 'package:flutter_sample_apps/screens/order_view/map/google_map.dart';
import 'package:flutter_sample_apps/screens/order_view/order_bottom_bar.dart';
import 'package:flutter_sample_apps/screens/order_view/scrollable_bottom_sheet/scrollable_bottom_sheet.dart';
import 'package:flutter_sample_apps/shared/alert_widget.dart';
import 'package:flutter_sample_apps/style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';

class OrderView extends StatefulWidget {
  const OrderView({required this.order, this.alreadyConfirmed = false});
  final Order order;
  final bool alreadyConfirmed;
  @override
  _OrderViewState createState() => _OrderViewState();
}

class _OrderViewState extends State<OrderView> {
  OrderStatus orderStatus = OrderStatus.none;
  OrderViewBloc get _orderViewBloc => BlocProvider.of<OrderViewBloc>(context);
  @override
  void initState() {
    _drawRoute();
    super.initState();
    if (widget.alreadyConfirmed) {
      _orderViewBloc
        ..add(GetOrderCurrentState(order: widget.order))
        ..add(SubscribeToStates(orderId: widget.order.id));
    } else {
      _showConfirmedAlert();
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
          backgroundColor: blackHazeColor,
          resizeToAvoidBottomInset: true,
          body: Stack(children: [
            BlocListener<OrderViewBloc, OrderViewState>(
                listener: _listener, child: _renderBody(),),
          ],),),
    );
  }

  void _listener(BuildContext context, state) {
    if (state is OrderStatusChangedState) {
      if (state.orderStatus == OrderStatus.onRoad) {
        _orderViewBloc.add(const TrackUserLocationEvent());
      }
      if (state.showAlert) {
        state.orderStatus.getAlert(context);
      }
    }
    if (state is ServerErrorState) {
      AlertWidget().showMessage(context, state.message);
    }
  }

  Widget _renderBody() {
    return Stack(children: [
      GoogleMapWidget(
        initialCameraPosition: LatLng(
            widget.order.fromLat ?? widget.order.toLat ?? 0.0,
            widget.order.fromLng ?? widget.order.toLng ?? 0.0,),
      ),
      ScrollableBottomSheet(
        widget.order,
        key: ObjectKey(widget.order),
      ),
      BlocBuilder<OrderViewBloc, OrderViewState>(builder: (context, state) {
        if (state is OrderStatusChangedState) {
          orderStatus = state.orderStatus;
        }
        return SafeArea(
          child: BottomBar(
            widget.order,
            orderStatus,
            showLoadingAccept: state is ChangingState,
            showLoadingCancel: state is CancelingState,
          ),
        );
      },),
    ],);
  }

  void _drawRoute() {
    _orderViewBloc.add(DrawRouteEvent(
        origin:
            LatLng(widget.order.fromLat ?? 0.0, widget.order.fromLng ?? 0.0),
        destination:
            LatLng(widget.order.toLat ?? 0.0, widget.order.toLng ?? 0.0),),);
  }

  void _showConfirmedAlert() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      OrderStatus.confirmed.getAlert(context);
    });
  }
}
