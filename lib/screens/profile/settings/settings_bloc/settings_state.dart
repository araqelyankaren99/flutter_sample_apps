import 'package:equatable/equatable.dart';

abstract class SettingsState extends Equatable {
  @override
  List<Object> get props => [];
}

class SettingsInitialState extends SettingsState {
  SettingsInitialState();

  @override
  List<Object> get props => [];
}

class ChangePhoneNumberState extends SettingsState {
  ChangePhoneNumberState();

  @override
  List<Object> get props => [];
}

class ChangeLanguageState extends SettingsState {
  ChangeLanguageState();

  @override
  List<Object> get props => [];
}

class AboutAppTextLoadedState extends SettingsState {
  AboutAppTextLoadedState({required this.aboutAppText});

  final String aboutAppText;

  @override
  List<Object> get props => [aboutAppText];
}

class AboutAppLoadErrorState extends SettingsState {
  AboutAppLoadErrorState({required this.errorMessage});

  final String errorMessage;

  @override
  List<Object> get props => [errorMessage];
}

class SettingsLoadingState extends SettingsState {
  SettingsLoadingState();

  @override
  List<Object> get props => [];
}
