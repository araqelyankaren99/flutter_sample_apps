import 'package:flutter_sample_apps/middlewares/repositories/graph_ql_repository.dart';
import 'package:flutter_sample_apps/models/order.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OrderRepository {
  final GraphQlRepository _graphQlRepository = GraphQlRepository();

  /// Add order id from SharedPreferences
  Future<String?> getStoredId() async {
    final prefs = await SharedPreferences.getInstance();
    final stringValue = prefs.getString('order_id');
    return stringValue;
  }

  /// Add order id to SharedPreferences
  Future<bool> storeId(String token) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.setString('order_id', token);
  }

  /// delete order id from SharedPreferences
  Future<bool> deleteStoreId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.remove('order_id');
  }

  /// Get order by id
  Future<Order?> getOrderById(String orderId) async {
    try {
      final currentOrder = await _graphQlRepository.getOrder(orderId);
      final currentOrderData = currentOrder.data;
      if (currentOrderData != null &&
          currentOrderData['order']['state'] != 'FINISHED') {
        return Order.fromJson(currentOrderData['order'] as Map<String,dynamic>);
      }
    } catch (e) {
      return null;
    }
    return null;
  }
}
