
import 'package:flutter_sample_apps/src/models/order.dart';

class Driver {
  Driver(
      {required this.id,
      required this.phone,
      required this.firstName,
      required this.lastName,
      required this.birthDate,
      required this.city,
      this.rating,
      this.email,
      this.order});

  factory Driver.fromMap(Map<String, dynamic> map) {
    return Driver(
      id: map['id'] ?? '',
      phone: map['phone'] ?? '',
      rating: map['rating']?.toDouble() ?? 0.0,
      firstName: map['firstName'],
      lastName: map['lastName'],
      birthDate: DateTime.parse(map['birthDate']),
      city: map['city'],
      email: map['email'] ?? '',
    );
  }

  String id;
  String phone;
  double? rating;
  String firstName;
  String lastName;
  DateTime birthDate;
  String city;
  String? email;
  Order? order;
  void resetDriverData() {
    id = '';
    phone = '';
    firstName = '';
    lastName = '';
    birthDate = DateTime.now();
    city = '';
    rating = null;
    email = null;
    order = null;
  }

  @override
  String toString() {
    return '{driver: id: $id,phone: $phone, rating: $rating,firstname: $firstName,lastname: $lastName,birthDate: $birthDate,city: $city,email: $email}';
  }
}
