import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_sample_apps/models/attachment.dart';
import 'package:flutter_sample_apps/models/order.dart';

class Driver {
  Driver(
      {this.id,
      this.phone,
      this.firstName,
      this.lastName,
      this.birthDate,
      this.city,
      this.rating,
      this.email,
      this.order,
      this.attachment,
      this.profileImage,
      this.drivingLicensePhotos,
      this.isProved,});

  factory Driver.fromMap(Map<String, dynamic> map) {
    return Driver(
      id: map['id'] is String ? map['id'] as String : '',
      phone: map['phone'] is String ? map['phone'] as String :'',
      rating: map['rating'] is double ? map['rating'] as double : 0.0,
      firstName: map['firstName'] is String ? map['firstName'] as String : null,
      lastName: map['lastName'] is String ? map['lastName'] as String : null,
      birthDate: map['birthDate'] is String ? DateTime.tryParse(map['birthDate'] as String) ?? DateTime.now() : DateTime.now(),
      city: map['city'] is String ? map['city'] as String : null,
      email: map['email'] is String ? map['email'] as String: '',
      isProved: map['isProved'] is bool ? map['isProved'] as bool : true,
      attachment: map['attachment'] != null
          ? Attachment.fromJson(map['attachment'] as List<dynamic>)
          : null,
    );
  }

  String? id;
  String? phone;
  double? rating;
  String? firstName;
  String? lastName;
  DateTime? birthDate;
  String? city;
  String? email;
  Order? order;
  File? profileImage;
  Map<String, File>? drivingLicensePhotos;
  Attachment? attachment;
  Uint8List? profileImageBytes;
  bool? isProved;
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
    return '''
firstName: "$firstName",
lastName: "$lastName",
birthDate: "$birthDate",
email: "${email ?? ''}",
city: "$city",
phone: "$phone"
''';
  }
}
