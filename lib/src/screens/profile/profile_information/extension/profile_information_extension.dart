import 'package:flutter_sample_apps/src/screens/login_signup/profile_information/user_info_bloc/user_info_bloc.dart';
import 'package:flutter_sample_apps/src/screens/login_signup/profile_information/user_info_bloc/user_info_event.dart';
import 'package:flutter_sample_apps/src/screens/profile/profile_information/extension/profile_info_type_enum.dart';
import 'package:flutter_sample_apps/src/screens/profile/profile_information/profile_information.dart';
import 'package:flutter/material.dart';

extension ProfileInfoStateAddition on ProfileInformationClassState {
  Function(String)? onChange(
      {required ProfileInfoType profileInfoType,
      required UserInfoBloc userInfoBloc}) {
    switch (profileInfoType) {
      case ProfileInfoType.firstName:
        return (val) {
          user.firstName = val;
          userInfoBloc.add(UserValidationEvent(user: user));
        };
      case ProfileInfoType.lastName:
        return (val) {
          user.lastName = val;
          userInfoBloc.add(UserValidationEvent(user: user));
        };
      case ProfileInfoType.email:
        return (val) {
          user.email = val;
          userInfoBloc.add(UserValidationEvent(user: user));
        };
      case ProfileInfoType.date:
        break;
    }
    return null;
  }

  TextInputAction? inputAction({required ProfileInfoType profileInfoType}) {
    final firstName = user.firstName;
    final lastName = user.lastName;
    final birthDate = user.birthDate;
    switch (profileInfoType) {
      case ProfileInfoType.firstName:
        if (lastName != null && birthDate != null) {
          if (lastName.isEmpty || birthDate.isNotEmpty) {
            return TextInputAction.next;
          }
        }
        return TextInputAction.done;
      case ProfileInfoType.lastName:
        if (birthDate != null && firstName != null) {
          if (birthDate.isEmpty || firstName.isEmpty) {
            return TextInputAction.next;
          }
        }
        return TextInputAction.done;

      case ProfileInfoType.date:
        break;
      case ProfileInfoType.email:
        return TextInputAction.done;
    }
    return null;
  }

  void onComplete(
      {required ProfileInfoType profileInfoType,
      required UserInfoBloc userInfoBloc}) {
    switch (profileInfoType) {
      case ProfileInfoType.firstName:
        final lastName = user.lastName;
        if (lastName != null) {
          if (lastName.isEmpty) {
            FocusScope.of(context).nextFocus();
            break;
          }
        }
        FocusScope.of(context).unfocus();
        break;
      case ProfileInfoType.lastName:
        final birthDate = user.birthDate;
        if (birthDate != null) {
          if (birthDate.isEmpty) {
            userInfoBloc.add(const AddBirthDateEvent());
          }
        }
        FocusScope.of(context).unfocus();
        break;
      case ProfileInfoType.date:
        break;
      case ProfileInfoType.email:
        FocusScope.of(context).unfocus();
        break;
    }
  }
}
