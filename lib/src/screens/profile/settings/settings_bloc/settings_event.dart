import 'package:equatable/equatable.dart';

abstract class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object> get props => [];
}

class ChangePhoneNumberEvent extends SettingsEvent {
  const ChangePhoneNumberEvent();

  @override
  List<Object> get props => [];
}

class ChangeLanguageEvent extends SettingsEvent {
  const ChangeLanguageEvent();

  @override
  List<Object> get props => [];
}

class AboutApplicationEvent extends SettingsEvent {
  const AboutApplicationEvent();

  @override
  List<Object> get props => [];
}
