import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sample_apps/src/middlewares/connectivity/internet_notifier.dart';
import 'package:flutter_sample_apps/src/middlewares/repositories/graph_ql_repository.dart';
import 'package:flutter_sample_apps/src/screens/login_signup/profile_information/sign_up_bloc/sign_up_event.dart';
import 'package:flutter_sample_apps/src/screens/login_signup/profile_information/sign_up_bloc/sign_up_state.dart';
import 'package:flutter_sample_apps/src/screens/map_view/shared/token_info.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignUpBloc extends Bloc<SignUpEvent, SignUpState> {
  SignUpBloc() : super(SignUpInitialState()) {
    on<CreateUserEvent>(_createUserEventToState);
    on<CheckConnectivityEvent>(_onCheckConnectivityEventToState);
  }

  StreamSubscription<InternetConnectionStatus>? _connectionSubscription;
  final GraphQlRepository _graphQlRepository = GraphQlRepository();

  Future<void> _createUserEventToState(
      CreateUserEvent event, Emitter<SignUpState> emit) async {
    emit(SignUpLoadingState());
    final user = event.user..phone = await _getPhoneNumber();
    final _token = await _getToken();
    if (_token != null) {
      try {
        final _queryResult = await _graphQlRepository.createUserProfile(
            token: _token, user: user);

        final exception = _queryResult.exception;
        if (_queryResult.hasException && exception != null) {
          emit(UserCreateErrorState(
              errorMessage: exception.graphqlErrors.first.message));

          return;
        }
        final id = _queryResult.data?['createUserProfile']['id'] as String?;
        if (id != null) {
          emit(UserCreatedState(id: id));
        } else {
          UserCreateErrorState(errorMessage: 'User create failed');
        }
      } catch (e) {
        emit(UserCreateErrorState(errorMessage: 'User create failed'));
        throw Exception('User create failed');
      }
    } else {
      emit(UserCreateErrorState(errorMessage: 'User create failed'));
    }
  }

  Future<String?> _getPhoneNumber() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getString('phone');
  }

  Future<String?> _getToken() async {
    final token = await TokenInfo.getToken();
    return token;
  }

  FutureOr<void> _onCheckConnectivityEventToState(CheckConnectivityEvent event, Emitter<SignUpState> emit) {
    final connectionChecker = InternetConnectionChecker();
    _connectionSubscription = connectionChecker.onStatusChange.listen(
          (InternetConnectionStatus connectionStatus) {
        if (connectionStatus == InternetConnectionStatus.connected) {
          InternetNotifier.connectInternet();
        } else if (connectionStatus == InternetConnectionStatus.disconnected) {
          InternetNotifier.loseInternet();
        }
      },
    );
  }

  @override
  Future<void> close() async{
    _connectionSubscription?.cancel();
    return super.close();
  }
}
