import 'package:flutter_sample_apps/main.dart';
import 'package:flutter_sample_apps/middlewares/repositories/connection_repository.dart';
import 'package:flutter_sample_apps/middlewares/repositories/driver_repository.dart';
import 'package:flutter_sample_apps/middlewares/repositories/order_repository.dart';
import 'package:flutter_sample_apps/models/order.dart';
import 'package:flutter_sample_apps/screens/login_signup/shared/token_info.dart';

final DriverRepository _driverRepository = DriverRepository();
final OrderRepository _orderRepository = OrderRepository();
final ConnectionRepository _connectionRepository = ConnectionRepository();
Future<Map<HomeScreenType, Object?>> initHomeScreen() async {
  final token = await TokenInfo.getToken();
  return _checkRegistred(token);
}

Future<Map<HomeScreenType, Object?>> _checkRegistred(String? token) async {
  if (token == null) {
    return {HomeScreenType.logInSignup: null};
  }
  final isDeviceConnected = await _connectionRepository.hasConnection();
  if (isDeviceConnected) {
    try {
      final isRegistred = await _driverRepository.isRegistred(token);
      if (isRegistred != null) {
        final isActive = await _driverRepository.isActivated(token);
        if (isActive != null) {
          if (!isActive) {
            final driver = await _driverRepository.getDriverInfo();
            return {HomeScreenType.profileInformation: driver};
          }
          final order = await getOrder();
          return {HomeScreenType.liveOrders: order};
        }
      }
      return {HomeScreenType.profileInformation: null};
    } catch (e) {
      final order = await getOrder();
      return {HomeScreenType.liveOrders: order};
    }
  }
  final order = await getOrder();
  return {HomeScreenType.liveOrders: order};
}

Future<Order?> getOrder() async {
  Order? order;
  final orderId = await _orderRepository.getStoredId();
  if (orderId != null && orderId.isNotEmpty) {
    order = await _orderRepository.getOrderById(orderId);
  }
  return order;
}
