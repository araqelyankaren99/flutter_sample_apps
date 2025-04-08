import 'package:flutter_sample_apps/models/driver.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum ProfileInfoType { firstName, lastName, date, email, city, driverLicense }

extension ProfileInfoTypeAddition on ProfileInfoType {
  String? getInitialValue(Driver driver) {
    switch (this) {
      case ProfileInfoType.date:
        return driver.birthDate.toString();
      case ProfileInfoType.email:
        return driver.email;
      case ProfileInfoType.firstName:
        return driver.firstName;
      case ProfileInfoType.lastName:
        return driver.lastName;
      case ProfileInfoType.city:
        break;
      case ProfileInfoType.driverLicense:
        break;
    }
    return null;
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
      case ProfileInfoType.city:
        return 'City';
      case ProfileInfoType.driverLicense:
        return 'Driver License';
    }
  }

  List<TextInputFormatter>? formatter() {
    final filtringFormatter = [
      FilteringTextInputFormatter.allow(RegExp('[a-zA-Z0-9]'))
    ];
    switch (this) {
      case ProfileInfoType.firstName:
        return filtringFormatter;
      case ProfileInfoType.lastName:
        return filtringFormatter;
      case ProfileInfoType.date:
        break;
      case ProfileInfoType.email:
        break;
      case ProfileInfoType.city:
        break;
      case ProfileInfoType.driverLicense:
        break;
    }
    return null;
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
      case ProfileInfoType.city:
        return Image.asset('assets/images/city.png');
      case ProfileInfoType.driverLicense:
        return Image.asset('assets/images/orders.png');
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
      case ProfileInfoType.city:
        return 'city';
      case ProfileInfoType.driverLicense:
        return 'driverLicense';
    }
  }

  TextInputType? textInputText() {
    switch (this) {
      case ProfileInfoType.firstName:
        return TextInputType.name;
      case ProfileInfoType.lastName:
        return TextInputType.name;
      case ProfileInfoType.date:
        return TextInputType.datetime;
      case ProfileInfoType.email:
        return TextInputType.emailAddress;
      case ProfileInfoType.city:
        break;
      case ProfileInfoType.driverLicense:
        break;
    }
    return null;
  }
}
