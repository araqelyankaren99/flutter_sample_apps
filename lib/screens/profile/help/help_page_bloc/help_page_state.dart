import 'package:flutter_sample_apps/screens/profile/shared/expansion_item.dart';
import 'package:equatable/equatable.dart';

abstract class HelpPageState extends Equatable {
  @override
  List<Object> get props => [];
}

class HelpPageInitialState extends HelpPageState {
  HelpPageInitialState();

  @override
  List<Object> get props => [];
}

class FAQsLoadingState extends HelpPageState {
  FAQsLoadingState();

  @override
  List<Object> get props => [];
}

class FAQsLoadedState extends HelpPageState {
  FAQsLoadedState({required this.expansionItems});

  final List<ExpansionItem> expansionItems;

  @override
  List<Object> get props => [expansionItems];
}

class FAQsLoadErrorState extends HelpPageState {
  FAQsLoadErrorState({required this.errorMessage});

  final String errorMessage;

  @override
  List<Object> get props => [errorMessage];
}
