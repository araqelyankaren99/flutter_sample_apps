import 'package:flutter_sample_apps/src/middlewares/repositories/graph_ql_repository.dart';
import 'package:flutter_sample_apps/src/models/user.dart';
import 'package:flutter_sample_apps/src/screens/profile/profile_drawer/profile_drawer_bloc/profile_informaiton_event.dart';
import 'package:flutter_sample_apps/src/screens/profile/profile_drawer/profile_drawer_bloc/profile_information_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileInformationBloc
    extends Bloc<ProfileInformationEvent, ProfileInformationState> {
  ProfileInformationBloc() : super(ProfileInformationInitialState());

  final GraphQlRepository _graphQlRepository = GraphQlRepository();
  Map<String, dynamic> userEditFields = {};

  static User _user = User();
  User get user => _user;

  bool _hasPaymentMethods = false;
  bool get hasPaymentMethods => _hasPaymentMethods;

  @override
  Stream<ProfileInformationState> mapEventToState(
      ProfileInformationEvent event) async* {
    if (event is GetProfileInformationEvent) {
      if (_user.id == null) {
        yield* getMainProfileInformationEventToState(event);
      } else {
        yield ProfileInformationLoaded();
        yield ProfileInformationInitialState();
      }
    }

    if (event is UserEditEvent) {
      yield* editProfileInformationEventToState(event);
    }
    if (event is UserLogOutEvent) {
      yield* userLogOutEventToState(event);
    }
    if (event is UserPhoneNumberChangedEvent) {
      yield* userPhoneNumberChangedEvent(event);
    }
    if (event is CheckPaymentMethodEvent) {
      yield* checkPaymentMethodEventToState(event);
    }
  }

  Stream<ProfileInformationState> checkPaymentMethodEventToState(
      CheckPaymentMethodEvent event) async* {
    yield CheckingPaymentMethodsState();
    try {
      final _queryResult = await _graphQlRepository.hasPaymentMethod();

      if (!_queryResult.hasException) {
        final _data = _queryResult.data;
        if (_data != null) {
          final _paymentMethod = _data['paymentMethods'];
          if (_paymentMethod.length != 0) {
            _hasPaymentMethods = true;
            yield ExistingPaymentMethodsState();
          } else {
            _hasPaymentMethods = false;
            yield NotExistingPaymentMethodsState();
          }
        }
      }
    } catch (e) {
      yield PaymentMethodsFailedState(errorMessage: 'Something went wrong');
      throw Exception('Something went wrong');
    }
  }

  Stream<ProfileInformationState> userPhoneNumberChangedEvent(
      UserPhoneNumberChangedEvent event) async* {
    yield LoadingState();
    if (event.changedPhoneNumber != '') {
      _user.phone = event.changedPhoneNumber;
    }

    yield ProfileInformationLoaded();
    yield ProfileInformationInitialState();
  }

  Stream<ProfileInformationState> userLogOutEventToState(
      UserLogOutEvent event) async* {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove('token');
    await preferences.remove('phone');
    await preferences.remove('order_id');
    await preferences.remove('tokenExpiredTime');
    await preferences.remove('refreshToken');
    await preferences.remove('refreshTokenExpiredTime');
    _user = User();

    yield UserLoggedOutState();
    yield ProfileInformationInitialState();
  }

  Stream<ProfileInformationState> getMainProfileInformationEventToState(
      GetProfileInformationEvent event) async* {
    yield LoadingState();

    final _queryResult = await _graphQlRepository.getUserInfo();
    if (_queryResult.hasException) {
      final exception = _queryResult.exception;
      if (exception != null) {
        final _errorMessage = exception.graphqlErrors.first.toString();
        yield ProfileInformationLoadErrorState(errorMessage: _errorMessage);
      }
      return;
    }
    final data = _queryResult.data;
    if (data != null) {
      _user = User.fromJson(data['thisUser']);
    }

    yield ProfileInformationLoaded();
    yield ProfileInformationInitialState();
  }

  Stream<ProfileInformationState> editProfileInformationEventToState(
      UserEditEvent event) async* {
    yield LoadingState();

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
        yield UserEditErrorState(
            errorMessage: exception.graphqlErrors.first.message);

        return;
      }
      final data = _queryResult.data;
      if (data != null) {
        final user = User.fromJson(data['editUserProfile']);
        yield UserEditSuccessState(editedUser: user);
      }
    }

    yield ProfileInformationInitialState();
  }
}
