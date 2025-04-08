import 'package:flutter_sample_apps/models/driver.dart';
import 'package:equatable/equatable.dart';

abstract class EditDriverEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class EditDriver extends EditDriverEvent {
  EditDriver({required this.driver});
  final Driver driver;
  @override
  List<Object> get props => [driver];
}

class CheckIsProve extends EditDriverEvent {}
