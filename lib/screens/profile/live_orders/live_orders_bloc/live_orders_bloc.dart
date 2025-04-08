import 'package:flutter_sample_apps/middlewares/repositories/connection_repository.dart';
import 'package:flutter_sample_apps/middlewares/repositories/graph_ql_repository.dart';
import 'package:flutter_sample_apps/middlewares/repositories/locations_repository.dart';
import 'package:flutter_sample_apps/models/order.dart';
import 'package:flutter_sample_apps/screens/profile/live_orders/live_orders_bloc/live_orders_event.dart';
import 'package:flutter_sample_apps/screens/profile/live_orders/live_orders_bloc/live_orders_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';

class LiveOrdersBloc extends Bloc<LiveOrdersEvent, LiveOrdersState> {
  LiveOrdersBloc() : super(LiveOrdersInitialState());
  final GraphQlRepository _graphQlRepository = GraphQlRepository();
  final ConnectionRepository _connectionRepository = ConnectionRepository();
  final LocationsRepository _locationsRepository = LocationsRepository();
  List<Order> unconfirmedOrders = [];

  @override
  Stream<LiveOrdersState> mapEventToState(
    LiveOrdersEvent event,
  ) async* {
    if (event is GetUnconfirmedOrdersEvent) {
      yield* getUnconfirmedOrdersEventToState();
    }
    if (event is UpdateDriverLocationEvent) {
      yield* updateDriverLocationEventToState();
    }
    if (event is NoInternetEvent) {
      yield NoInternetState();
    }
  }

  Stream<LiveOrdersState> getUnconfirmedOrdersEventToState() async* {
    yield UnconfirmedOrdersLoadingState();
    final isDeviceConnected = await _connectionRepository.hasConnection();
    if (isDeviceConnected) {
      {
        try {
          final queryResult = await _graphQlRepository.unconfirmedOrders();

          final data = queryResult.data;
          if (data != null) {
            unconfirmedOrders = (data['unconfirmedOrders'] as List<Map<String,dynamic>>)
                .map<Order>((json) => Order.fromJson(json))
                .toList();
          }

          unconfirmedOrders.sort((a, b) =>
              a.distanceBetweenDriver.compareTo(b.distanceBetweenDriver),);

          yield UnconfirmedOrdersLoadedState(
              unconfirmedOrders: unconfirmedOrders,);
        } catch (e) {
          yield UnconfirmedOrdersLoadErrorState(errorMessage: e.toString());
          return;
        }
      }
    }
    yield UnconfirmedOrdersLoadErrorState(errorMessage: 'No internet');
    return;
   }

  Stream<LiveOrdersState> updateDriverLocationEventToState() async* {
    final locationData = await _locationsRepository.getCurrentLocation();
    try {
      await _graphQlRepository.updateDriverLocation(
          currentLocation: LatLng(
              locationData.latitude ?? 0.0, locationData.longitude ?? 0.0,),);
    } catch (e) {
      yield LocationUpdateFailedState(
          message: 'Current location has not been updated.',);
    }
  }
}
