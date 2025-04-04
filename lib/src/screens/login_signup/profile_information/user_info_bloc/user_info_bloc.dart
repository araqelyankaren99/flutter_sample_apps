import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sample_apps/src/middlewares/repositories/validation_repository.dart';
import 'package:flutter_sample_apps/src/screens/login_signup/profile_information/user_info_bloc/user_info_event.dart';
import 'package:flutter_sample_apps/src/screens/login_signup/profile_information/user_info_bloc/user_info_state.dart';

class UserInfoBloc extends Bloc<UserInfoEvent, UserInfoState> {
  UserInfoBloc() : super(UserInfoInitialState()) {
    on<UserInfoInitialEvent>(_userInfoInitialEventToState);
    on<AddBirthDateEvent>(_addBirthDateEventToState);
    on<ChooseBirthDateEvent>(_chooseBirthDateEventToState);
    on<UserValidationEvent>(_userValidationEventToState);
    on<UserInfoLoadingEvent>(_userInfoLoadingEventToState);
  }

  final ValidationRepository _validationRepository = ValidationRepository();

  Future<void> _userInfoInitialEventToState(
      UserInfoInitialEvent event, Emitter<UserInfoState> emit) async {
    emit(UserInfoInitialState());
  }

  Future<void> _addBirthDateEventToState(
      AddBirthDateEvent event, Emitter<UserInfoState> emit) async {
    emit(AddingBirthDateState());
  }

  Future<void> _chooseBirthDateEventToState(
      ChooseBirthDateEvent event, Emitter<UserInfoState> emit) async {
    emit(AddedBirthDateState(birthDate: event.birthDate));
  }

  Future<void> _userValidationEventToState(
      UserValidationEvent event, Emitter<UserInfoState> emit) async {
    emit(UserInfoLoadingState());
    var errorMessages = <String, String>{};
    if (!_validationRepository.isFilled(event.user.firstName)) {
      errorMessages['firstName'] = 'First name must not be empty ';
    }
    if (!_validationRepository.isFilled(event.user.lastName)) {
      errorMessages['lastName'] = 'Last name must not be empty';
    }

    if (!_validationRepository.isFilled(event.user.birthDate)) {
      errorMessages['birthDate'] = 'Birthday must not be empty';
    }
    if (!_validationRepository.isEmail(event.user.email)) {
      errorMessages['email'] = 'Incorrect email';
    }

    if (errorMessages.isNotEmpty) {
      emit(UserInvalidState(error: errorMessages));
      errorMessages = <String, String>{};
      return;
    }

    emit(UserValidState(user: event.user));
  }

  Future<void> _userInfoLoadingEventToState(
      UserInfoLoadingEvent event, Emitter<UserInfoState> emit) async {
    emit(UserInfoLoadingState());
  }
}
