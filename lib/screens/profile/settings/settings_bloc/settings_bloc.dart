import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:flutter_sample_apps/middlewares/repositories/graph_ql_repository.dart';
import 'package:flutter_sample_apps/screens/profile/settings/settings_bloc/settings_event.dart';
import 'package:flutter_sample_apps/screens/profile/settings/settings_bloc/settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  SettingsBloc() : super(SettingsInitialState());
  final GraphQlRepository _graphQlRepository = GraphQlRepository();

  @override
  Stream<SettingsState> mapEventToState(
    SettingsEvent event,
  ) async* {
    if (event is ChangePhoneNumberEvent) {
      yield ChangePhoneNumberState();
      yield SettingsInitialState();
    }

    if (event is ChangeLanguageEvent) {
      yield ChangeLanguageState();
      yield SettingsInitialState();
    }

    if (event is AboutApplicationEvent) {
      yield SettingsLoadingState();
      yield* getAboutAppTextEventToState(event);
    }
  }

  Stream<SettingsState> getAboutAppTextEventToState(
      AboutApplicationEvent event,) async* {
    try {
      final queryResult = await _graphQlRepository.getAbout();
      final data = queryResult.data;
      if (data != null) {
        final String aboutAppText = data['about'] as String;
        yield AboutAppTextLoadedState(aboutAppText: aboutAppText);
      }
    } catch (e) {
      yield AboutAppLoadErrorState(errorMessage: e.toString());
    }
    yield SettingsInitialState();
  }
}
