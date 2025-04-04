import 'package:email_validator/email_validator.dart';

class ValidationRepository {
  bool isFilled(String? field) {
    if (field == null) {
      return false;
    }
    return field.isNotEmpty;
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
}
