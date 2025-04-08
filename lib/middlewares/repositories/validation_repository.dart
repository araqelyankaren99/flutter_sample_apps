import 'package:flutter_sample_apps/models/driver.dart';
import 'package:email_validator/email_validator.dart';

class ValidationRepository {
  bool isFilled(String? field) {
    if (field == null) {
      return false;
    }
    return field.isNotEmpty;
  }

  bool isFilledBirthDate(DateTime? birhdate) {
    if (birhdate == null) {
      return false;
    }
    return birhdate.toString().isNotEmpty;
  }

  bool isEmail(String? email) {
    if (email == null || email.isEmpty) {
      return true;
    }
    return EmailValidator.validate(email);
  }

  /// Checks length >= 8 of phone number
  bool isValidPhoneNumber(String val) {
    return val.length >= 8;
  }

  /// Checks if pinCode is completed or not
  bool isPinCodeValid(String pinCode) {
    return pinCode.length == 6;
  }

  /// Check is all documents uploaded
  bool isDocumnetsIsUploaded(Driver driver) {
    final drivingLicensePhotos = driver.drivingLicensePhotos;
    if (drivingLicensePhotos != null) {
      if (drivingLicensePhotos.length == 2) {
        return true;
      }
    }
    return false;
  }
}
