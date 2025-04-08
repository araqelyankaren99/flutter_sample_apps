import 'package:equatable/equatable.dart';

abstract class HistoryPageState extends Equatable {
  @override
  List<Object> get props => [];
}

class UserOrdersLoadingState extends HistoryPageState {
  UserOrdersLoadingState();

  @override
  List<Object> get props => [];
}

class HistoryPageInitialState extends HistoryPageState {
  HistoryPageInitialState();

  @override
  List<Object> get props => [];
}

class UserOrdersLoadedState extends HistoryPageState {
  UserOrdersLoadedState();

  @override
  List<Object> get props => [];
}

class UserOrdersLoadErrorState extends HistoryPageState {
  UserOrdersLoadErrorState({required this.errorMessage});

  final String errorMessage;

  @override
  List<Object> get props => [errorMessage];
}
