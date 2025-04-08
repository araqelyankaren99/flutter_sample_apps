import 'package:flutter_sample_apps/models/car.dart';

class User {
  User(
      {this.phone,
      this.id,
      this.firstName,
      this.lastName,
      this.birthDate,
      this.email,
      this.country,
      this.city,
      this.car,
      this.plateNumber,});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
        id: json['id'] is String ? json['id'] as String : null,
        firstName: json['firstName'] is String ? json['firstName'] as String : null,
        lastName: json['lastName'] is String ? json['lastName'] as String : null,
        birthDate: json['birthDate'] is String ? json['birthDate'] as String : null,
        email: json['email'] is String ? json['email'] as String : null,
        country: json['country'] is String ? json['country'] as String : null,
        city: json['city'] is String ? json['city'] as String : null,
        phone: json['phone'] is String ? json['phone'] as String : null,
        plateNumber: json['userCar']['licensePlateNumber'] as String?,
        car: json['userCar']?['car'] != null
            ? Car.fromJson(json['userCar']['car'] as Map<String,dynamic>)
            : null,);
  }

  String? id;
  String? firstName;
  String? lastName;
  String? birthDate;
  String? email;
  String? country;
  String? city;
  String? phone;
  Car? car;
  String? plateNumber;

  @override
  String toString() {
    return '''
firstName: "${firstName ?? ''}",
lastName: "${lastName ?? ''}",
birthDate: "${birthDate ?? ''}",
email: "${email ?? ''}",
country: "${country ?? ''}",
city: "${city ?? ''}",
phone: "$phone"
''';
  }

  Map<String, String> toJson() {
    return {
      'firstName': firstName ?? '',
      'lastName': lastName ?? '',
      'birthDate': birthDate ?? '',
      'email': email ?? '',
      'country': country ?? '',
      'city': city ?? '',
      'phone': phone ?? ''
    };
  }
}
