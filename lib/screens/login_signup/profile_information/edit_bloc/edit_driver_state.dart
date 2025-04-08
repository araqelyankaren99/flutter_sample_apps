import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

abstract class EditDriverState extends Equatable {
  @override
  List<Object> get props => [];
}

class EditDriverInitialState extends EditDriverState {
  EditDriverInitialState();

  @override
  List<Object> get props => [];
}

class EditDriverLoadingState extends EditDriverState {}

class DriverEditErrorState extends EditDriverState {
  DriverEditErrorState({required this.message});
  final String message;
}

class DriverIsEditedState extends EditDriverState {
  DriverIsEditedState({required this.id});
  final String id;

  @override
  List<Object> get props => [id];
}

class EditLoadingIndicator extends EditDriverState {
  EditLoadingIndicator({required this.precent});
  final _id = const Uuid().v4();
  final double precent;
  @override
  List<Object> get props => [precent, _id];
}

class IsEditableState extends EditDriverState {
  IsEditableState({required this.isProve});
  final bool isProve;
  @override
  List<Object> get props => [isProve];
}
