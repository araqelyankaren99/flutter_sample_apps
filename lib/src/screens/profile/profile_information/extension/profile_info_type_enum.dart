import 'package:flutter_sample_apps/src/models/user.dart';
import 'package:flutter/material.dart';

enum ProfileInfoType { firstName, lastName, date, email }

extension ProfileInfoTypeAddition on ProfileInfoType {
  String? getInitialValue(User user) {
    switch (this) {
      case ProfileInfoType.date:
        return user.birthDate;
      case ProfileInfoType.email:
        return user.email;
      case ProfileInfoType.firstName:
        return user.firstName;
      case ProfileInfoType.lastName:
        return user.lastName;
    }
  }

  String labeltext() {
    switch (this) {
      case ProfileInfoType.firstName:
        return 'First name';
      case ProfileInfoType.lastName:
        return 'Last name';
      case ProfileInfoType.date:
        return 'Date of birth';
      case ProfileInfoType.email:
        return 'Email';
    }
  }

  Image image() {
    switch (this) {
      case ProfileInfoType.firstName:
        return Image.asset('assets/images/profile_default_image.png');
      case ProfileInfoType.lastName:
        return Image.asset('assets/images/profile_default_image.png');
      case ProfileInfoType.date:
        return Image.asset('assets/images/calendar.png');
      case ProfileInfoType.email:
        return Image.asset('assets/images/email.png');
    }
  }

  String error() {
    switch (this) {
      case ProfileInfoType.firstName:
        return 'firstName';
      case ProfileInfoType.lastName:
        return 'lastName';
      case ProfileInfoType.date:
        return 'birthDate';
      case ProfileInfoType.email:
        return 'email';
    }
  }

  TextInputType textInputText() {
    switch (this) {
      case ProfileInfoType.firstName:
        return TextInputType.name;
      case ProfileInfoType.lastName:
        return TextInputType.name;
      case ProfileInfoType.date:
        return TextInputType.datetime;
      case ProfileInfoType.email:
        return TextInputType.emailAddress;
    }
  }
}
