import 'package:flutter_sample_apps/constants.dart' as constants;
import 'package:flutter_sample_apps/models/order.dart';
import 'package:flutter_sample_apps/screens/order_view/bloc/order_view_bloc.dart';
import 'package:flutter_sample_apps/screens/order_view/map/google_map.dart';
import 'package:flutter_sample_apps/shared/app_bar_widget.dart';
import 'package:flutter_sample_apps/style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ViewTrip extends StatefulWidget {
  const ViewTrip({required this.order});
  final Order order;
  @override
  _ViewTripState createState() => _ViewTripState();
}

class _ViewTripState extends State<ViewTrip> {
  OrderViewBloc get _orderViewBloc => BlocProvider.of<OrderViewBloc>(context);
  @override
  void initState() {
    _orderViewBloc.add(DrawRouteEvent(
        origin:
            LatLng(widget.order.fromLat ?? 0.0, widget.order.fromLng ?? 0.0),
        destination:
            LatLng(widget.order.toLat ?? 0.0, widget.order.toLng ?? 0.0),),);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async => true,
        child: Scaffold(
            backgroundColor: blackHazeColor,
            resizeToAvoidBottomInset: true,
            body: _renderBody(),),);
  }

  Widget _renderBody() {
    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          _renderNavBar(),
          Expanded(
            child: GoogleMapWidget(
              initialCameraPosition: LatLng(
                  widget.order.fromLat ?? widget.order.toLat ?? 0.0,
                  widget.order.fromLng ?? widget.order.toLng ?? 0.0,),
            ),
          ),
        ],
      ),
    );
  }

  Widget _renderNavBar() {
    return AppBarWidget(
      titleText: 'Trip',
      prefixWidget: InkWell(
        splashColor: Colors.transparent,
        focusColor: Colors.transparent,
        highlightColor: Colors.transparent,
        onTap: () => Navigator.pop(context),
        child: Container(
          margin: EdgeInsets.all(15 * constants.rw(context)),
          child: const Icon(
            Icons.arrow_back,
            color: azureRadianceColor,
          ),
        ),
      ),
      titleStyle: appBarTitleStyle,
    );
  }
}
