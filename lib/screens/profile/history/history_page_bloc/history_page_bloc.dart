import 'package:flutter_sample_apps/middlewares/repositories/graph_ql_repository.dart';
import 'package:flutter_sample_apps/models/order.dart';
import 'package:flutter_sample_apps/screens/profile/history/history_page_bloc/history_page_event.dart';
import 'package:flutter_sample_apps/screens/profile/history/history_page_bloc/histroy_page_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HistoryPageBloc extends Bloc<HistoryPageEvent, HistoryPageState> {
  HistoryPageBloc() : super(HistoryPageInitialState());
  final GraphQlRepository _graphQlRepository = GraphQlRepository();
  List<Order> _ordersList = [];
  double _amount = 0;
  double get amount => _amount;
  List<Order> get ordersList => _ordersList;

  @override
  Stream<HistoryPageState> mapEventToState(HistoryPageEvent event) async* {
    if (event is GetUserOrdersEvent) {
      yield* getUserOrdersEventToState(event);
    }
  }

  Stream<HistoryPageState> getUserOrdersEventToState(
      GetUserOrdersEvent event,) async* {
    yield UserOrdersLoadingState();
    try {
      final queryResult = await _graphQlRepository.getDriverOrders();

      final data = queryResult.data;
      if (data != null) {
        _ordersList = (data['sortDriverOrdersWithState'] as List<Map<String,dynamic>>)
            .map<Order>((json) => Order.fromJson(json))
            .toList();
        _amount = _ordersList
            .where((i) => i.state == OrderStatus.finished)
            .fold(0, (sum, item) => sum + item.amount);
      }

      yield UserOrdersLoadedState();
    } catch (e) {
      yield UserOrdersLoadErrorState(errorMessage: e.toString());
      yield HistoryPageInitialState();
    }
  }
}
