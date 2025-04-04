import 'package:flutter_sample_apps/main.dart';
import 'package:flutter_sample_apps/src/screens/map_view/shared/token_info.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'middlewares/connectivity/connectivity.dart';
import 'middlewares/repositories/graph_ql_repository.dart';
import 'models/order.dart';

final GraphQlRepository _graphQlRepository = GraphQlRepository();
Order? _order;

Order? get order => _order;

Future<HomeScreenType>  initHomeScreen() async {
  final token = await TokenInfo.getToken();
  return _checkRegistered(token);
}

Future<HomeScreenType> _checkRegistered(String? token) async {
  final isDeviceConnected = await Connection().check();

  if (token == null) {
    return HomeScreenType.logInSignup;
  }

  if (!isDeviceConnected) {
    return HomeScreenType.mapView;
  }

  final isRegistered = await _isRegistered(token);
  if (isRegistered) {
    _order = await _getOrder();
    return HomeScreenType.mapView;
  }
  return HomeScreenType.profileInformation;
}

/// This function true if user registered else false
Future<bool> _isRegistered(String token) async {
  final queryResultForNumber = await _graphQlRepository.getUser(token);
  if (queryResultForNumber.hasException) {
    return false;
  }
  final queryResultForNumberData = queryResultForNumber.data;
  if (queryResultForNumberData != null) {
    if (queryResultForNumberData['thisUser'] == null) {
      return false;
    }
  }

  return true;
}

/// This function return last order information or null(if user have not order)
Future<Order?> _getOrder() async {
  final orderId = await _getOrderIdFromSharedPrefs();
  if (orderId.isNotEmpty) {
    final currentOrder = await _graphQlRepository.getOrder(orderId);
    if (currentOrder != null && currentOrder.state != OrderStatus.none) {
      return currentOrder;
    }
  }
  return null;
}

Future<String> _getOrderIdFromSharedPrefs() async {
  final sharedPreferences = await SharedPreferences.getInstance();
  return sharedPreferences.getString('order_id') ?? '';
}

extension HomeScreenTypeExtension on HomeScreenType {
  Order? getOrder() => this == HomeScreenType.mapView ? order : null;
}
