import 'package:equatable/equatable.dart';

abstract class HelpPageEvent extends Equatable {
  const HelpPageEvent();

  @override
  List<Object> get props => [];
}

class GetFAQsEvent extends HelpPageEvent {
  const GetFAQsEvent();

  @override
  List<Object> get props => [];
}
