import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:flutter_sample_apps/src/middlewares/repositories/graph_ql_repository.dart';
import 'package:flutter_sample_apps/src/screens/profile/settings/settings_bloc/settings_event.dart';
import 'package:flutter_sample_apps/src/screens/profile/settings/settings_bloc/settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  SettingsBloc() : super(SettingsInitialState()) {
    on<ChangePhoneNumberEvent>(_changePhoneNumberEventToState);
    on<ChangeLanguageEvent>(_changeLanguageEvent);
    on<AboutApplicationEvent>(_aboutApplicationEvent);
  }

  final GraphQlRepository _graphQlRepository = GraphQlRepository();

  Future<void> _changePhoneNumberEventToState(
      ChangePhoneNumberEvent event, Emitter<SettingsState> emit) async {
    emit(ChangePhoneNumberState());
    emit(SettingsInitialState());
  }

  Future<void> _changeLanguageEvent(
      ChangeLanguageEvent event, Emitter<SettingsState> emit) async {
    emit(ChangeLanguageState());
    emit(SettingsInitialState());
  }

  Future<void> _aboutApplicationEvent(
      AboutApplicationEvent event, Emitter<SettingsState> emit) async {
    emit(SettingsLoadingState());
    try {
      final _queryResult = await _graphQlRepository.getAbout();

      if (_queryResult.hasException) {
        final exception = _queryResult.exception;
        if (exception != null) {
          final _errorMessage = exception.graphqlErrors.first.toString();
          emit(AboutAppLoadErrorState(errorMessage: _errorMessage));
        }

        emit(SettingsInitialState());
        return;
      }
      final data = _queryResult.data;
      if (data != null) {
        final String _aboutAppText = data['about'];
        emit(AboutAppTextLoadedState(aboutAppText: _aboutAppText));
      }

      emit(SettingsInitialState());
    } catch (e) {
      AboutAppLoadErrorState(errorMessage: 'Something went wrong');
      throw Exception('Something went wrong');
    }
  }
}
