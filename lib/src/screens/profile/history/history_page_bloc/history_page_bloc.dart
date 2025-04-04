import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sample_apps/src/middlewares/repositories/graph_ql_repository.dart';
import 'package:flutter_sample_apps/src/models/order.dart';
import 'package:flutter_sample_apps/src/screens/profile/history/history_page_bloc/history_page_event.dart';
import 'package:flutter_sample_apps/src/screens/profile/history/history_page_bloc/histroy_page_state.dart';

class HistoryPageBloc extends Bloc<HistoryPageEvent, HistoryPageState> {
  HistoryPageBloc() : super(HistoryPageInitialState()) {
    on<GetUserOrdersEvent>(_getUserOrdersEventToState);
  }

  final GraphQlRepository _graphQlRepository = GraphQlRepository();
  List<Order> _ordersList = [];

  List<Order> get ordersList => _ordersList;

  Future<void> _getUserOrdersEventToState(
      GetUserOrdersEvent event, Emitter<HistoryPageState> emit) async {
    emit(UserOrdersLoadingState());

    try {
      final _queryResult = await _graphQlRepository.userOrders();

      final data = _queryResult.data;
      if (data != null) {
        _ordersList = data['sortUserOrdersWithState']
            .map<Order>((json) => Order.fromJson(json))
            .toList();
      }

      emit(UserOrdersLoadedState());
    } catch (e) {
      emit(UserOrdersLoadErrorState(errorMessage: e.toString()));
      emit(HistoryPageInitialState());
    }
  }
}
