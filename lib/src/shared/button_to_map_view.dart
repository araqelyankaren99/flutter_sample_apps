import 'package:flutter_sample_apps/src/middlewares/connectivity/connectivity.dart';
import 'package:flutter_sample_apps/src/middlewares/notifiers/location.dart';
import 'package:flutter_sample_apps/src/models/order.dart';
import 'package:flutter_sample_apps/src/screens/map_view/select_address_map_view/bloc/main_bloc.dart';
import 'package:flutter_sample_apps/src/screens/map_view/select_address_map_view/main_view.dart';
import 'package:flutter_sample_apps/src/shared/svg_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

class ButtonToMapVIew extends StatefulWidget {
  const ButtonToMapVIew({required this.order, required this.isDestination});
  final Order order;
  final bool isDestination;
  @override
  _ButtonToMapVIewState createState() => _ButtonToMapVIewState();
}

class _ButtonToMapVIewState extends State<ButtonToMapVIew> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => widget.order.state == OrderStatus.none ||
              widget.order.state == OrderStatus.canceled
          ? _navigateToMapScreen(widget.isDestination)
          : null,
      child: Row(
        children: [
          _renderPinSvg(widget.isDestination),
          _renderSearchSvg(widget.isDestination)
        ],
      ),
    );
  }

  Widget _renderSearchSvg(bool isDestination) {
    return const Padding(
      padding: EdgeInsets.all(8.0),
      child: SvgIcon(IconName.search),
    );
  }

  Widget _renderPinSvg(isDestination) {
    return const Padding(
        padding: EdgeInsets.all(8.0), child: SvgIcon(IconName.pin));
  }

  void _navigateToMapScreen(isDestination) {
    Connection.checker(context,
        onDone: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) {
                return BlocProvider.value(
                    value: BlocProvider.of<MainBloc>(context),
                    child: ChangeNotifierProvider.value(
                      value: Provider.of<LocationNotifier>(context),
                      child: MainView(fromDestination: isDestination),
                    ));
              }),
            ).then((value) {
              if (!value) {
                Future.delayed(const Duration(milliseconds: 500),
                    () => Connection.showEntry(context));
              }
            }));
  }
}
