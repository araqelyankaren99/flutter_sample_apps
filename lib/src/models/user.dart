class User {
  User(
      {this.phone,
      this.id,
      this.firstName,
      this.lastName,
      this.birthDate,
      this.email,
      this.country,
      this.city});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      birthDate: json['birthDate'] ?? '',
      email: json['email'] ?? '',
      country: json['country'] ?? '',
      city: json['city'] ?? '',
      phone: json['phone'] ?? '',
    );
  }
  String? id;
  String? firstName;
  String? lastName;
  String? birthDate;
  String? email;
  String? country;
  String? city;
  String? phone;

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

  /// This method copies ONLY!!! firstName, lastName, birthDate and email
  void copy({required User user}) {
    firstName = user.firstName;
    lastName = user.lastName;
    birthDate = user.birthDate;
    email = user.email;
  }
}
