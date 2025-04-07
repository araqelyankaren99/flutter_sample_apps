import 'package:flutter_sample_apps/src/middlewares/repositories/graph_ql_repository.dart';
import 'package:flutter_sample_apps/src/models/user.dart';
import 'package:flutter_sample_apps/src/screens/profile/profile_drawer/profile_drawer_bloc/profile_informaiton_event.dart';
import 'package:flutter_sample_apps/src/screens/profile/profile_drawer/profile_drawer_bloc/profile_information_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileInformationBloc extends Bloc<ProfileInformationEvent, ProfileInformationState> {
  ProfileInformationBloc() : super(ProfileInformationInitialState()) {
    on<GetProfileInformationEvent>(_onGetProfileInformationEvent);
    on<UserEditEvent>(_onUserEditEvent);
    on<UserLogOutEvent>(_onUserLogOutEvent);
    on<UserPhoneNumberChangedEvent>(_onUserPhoneNumberChangedEvent);
    on<CheckPaymentMethodEvent>(_onCheckPaymentMethodEvent);
  }

  final GraphQlRepository _graphQlRepository = GraphQlRepository();
  Map<String, dynamic> userEditFields = {};

  static User _user = User();
  User get user => _user;

  bool _hasPaymentMethods = false;
  bool get hasPaymentMethods => _hasPaymentMethods;

  // === Event Handlers ===

  Future<void> _onGetProfileInformationEvent(
      GetProfileInformationEvent event,
      Emitter<ProfileInformationState> emit) async {
    if (_user.id == null) {
      emit(LoadingState());

      final _queryResult = await _graphQlRepository.getUserInfo();
      if (_queryResult.hasException) {
        final exception = _queryResult.exception;
        if (exception != null) {
          final _errorMessage = exception.graphqlErrors.first.toString();
          emit(ProfileInformationLoadErrorState(errorMessage: _errorMessage));
        }
        return;
      }

      final data = _queryResult.data;
      if (data != null) {
        _user = User.fromJson(data['thisUser']);
      }

      emit(ProfileInformationLoaded());
      emit(ProfileInformationInitialState());
    } else {
      emit(ProfileInformationLoaded());
      emit(ProfileInformationInitialState());
    }
  }

  Future<void> _onUserEditEvent(
      UserEditEvent event,
      Emitter<ProfileInformationState> emit) async {
    emit(LoadingState());

    if (event.user.firstName != event.userBeforeEditing.firstName) {
      userEditFields['firstName'] = '"${event.user.firstName}"';
    }
    if (event.user.lastName != event.userBeforeEditing.lastName) {
      userEditFields['lastName'] = '"${event.user.lastName}"';
    }

    final birthdayISOString = event.user.birthDate;
    if (birthdayISOString != event.userBeforeEditing.birthDate &&
        birthdayISOString != null) {
      userEditFields['birthDate'] = '"$birthdayISOString"';
    }

    if (event.user.email != event.userBeforeEditing.email) {
      userEditFields['email'] = '"${event.user.email}"';
    }

    if (userEditFields.isNotEmpty) {
      final _queryResult = await _graphQlRepository.editUserProfile(
          userEditedInfoMap: userEditFields);
      userEditFields = {};

      final exception = _queryResult.exception;
      if (_queryResult.hasException && exception != null) {
        emit(UserEditErrorState(
            errorMessage: exception.graphqlErrors.first.message));
        return;
      }

      final data = _queryResult.data;
      if (data != null) {
        final user = User.fromJson(data['editUserProfile']);
        emit(UserEditSuccessState(editedUser: user));
      }
    }

    emit(ProfileInformationInitialState());
  }

  Future<void> _onUserLogOutEvent(
      UserLogOutEvent event,
      Emitter<ProfileInformationState> emit) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove('token');
    await preferences.remove('phone');
    await preferences.remove('order_id');
    await preferences.remove('tokenExpiredTime');
    await preferences.remove('refreshToken');
    await preferences.remove('refreshTokenExpiredTime');

    _user = User();
    emit(UserLoggedOutState());
    emit(ProfileInformationInitialState());
  }

  Future<void> _onUserPhoneNumberChangedEvent(
      UserPhoneNumberChangedEvent event,
      Emitter<ProfileInformationState> emit) async {
    emit(LoadingState());

    if (event.changedPhoneNumber != '') {
      _user.phone = event.changedPhoneNumber;
    }

    emit(ProfileInformationLoaded());
    emit(ProfileInformationInitialState());
  }

  Future<void> _onCheckPaymentMethodEvent(
      CheckPaymentMethodEvent event,
      Emitter<ProfileInformationState> emit) async {
    emit(CheckingPaymentMethodsState());

    try {
      final _queryResult = await _graphQlRepository.hasPaymentMethod();

      if (!_queryResult.hasException) {
        final _data = _queryResult.data;
        if (_data != null) {
          final _paymentMethod = _data['paymentMethods'];
          if (_paymentMethod.isNotEmpty) {
            _hasPaymentMethods = true;
            emit(ExistingPaymentMethodsState());
          } else {
            _hasPaymentMethods = false;
            emit(NotExistingPaymentMethodsState());
          }
        }
      }
    } catch (e) {
      emit(PaymentMethodsFailedState(errorMessage: 'Something went wrong'));
      throw Exception('Something went wrong');
    }
  }
}
