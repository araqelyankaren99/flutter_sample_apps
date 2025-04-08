import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_sample_apps/home_screen_initialization.dart';
import 'package:flutter_sample_apps/middlewares/repositories/connection_repository.dart';
import 'package:flutter_sample_apps/screens/profile/live_orders/network_bloc/network_event.dart';
import 'package:flutter_sample_apps/screens/profile/live_orders/network_bloc/network_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NetworkBloc extends Bloc<NetworkEvent, NetworkState> {
  NetworkBloc() : super(ConnectionInitial());

  StreamSubscription? _subscription;
  bool _isDeviceConnected = false;
  final _connectionRepository = ConnectionRepository();

  @override
  Stream<NetworkState> mapEventToState(NetworkEvent event) async* {
    if (event is CheckConnection) {
      _isDeviceConnected = await _connectionRepository.hasConnection();
      if (_isDeviceConnected) {
        final homeScreenType = await initHomeScreen();
        yield ConnectionSuccess(homeScreen: homeScreenType);
        return;
      } else {
        yield ConnectionFailure();
        add(ListenConnection());
      }
    }
    if (event is ListenConnection) {
      _subscription =
          Connectivity().onConnectivityChanged.listen((status) async {
        _isDeviceConnected = await _connectionRepository.hasConnection();
        if (_isDeviceConnected) {
          final homeScreenType = await initHomeScreen();
          add(ConnectionChanged(
              connection: ConnectionSuccess(
                  homeScreen: homeScreenType, firstCheck: false,),),);
          await _subscription?.cancel();
          return;
        }
      });
    }
    if (event is ConnectionChanged) {
      yield event.connection;
    }
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
