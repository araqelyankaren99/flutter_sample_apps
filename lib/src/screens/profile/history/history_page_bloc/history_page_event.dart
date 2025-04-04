import 'package:equatable/equatable.dart';

abstract class HistoryPageEvent extends Equatable {
  const HistoryPageEvent();

  @override
  List<Object> get props => [];
}

class GetUserOrdersEvent extends HistoryPageEvent {
  const GetUserOrdersEvent();

  @override
  List<Object> get props => [];
}
