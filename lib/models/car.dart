class Car {
  Car({
    this.id,
    this.createdYear,
    this.make,
    this.model,
    this.transmissionType,
    this.horsepower,
    this.imgUrl,
    this.plateNumber,
  });

  factory Car.fromJson(Map<String, dynamic> json) {
    return Car(
        createdYear: json['createdYear'] as String,
        make: json['make'] as String,
        model: json['model'] as String,
        transmissionType: json['transmissionType'] as String,
        horsepower: json['horsepower'] as String,
        imgUrl: json['img_url'] as String,);
  }
  String? id;
  String? createdYear;
  String? make;
  String? model;
  String? transmissionType;
  String? horsepower;
  String? imgUrl;
  String? plateNumber;

  Map<String, dynamic> toJson() {
    return {
      'createdYear': createdYear ?? '',
      'make': make ?? '',
      'model': model ?? '',
      'transmissionType': transmissionType ?? '',
      ' horsepower': horsepower ?? '',
      'img_url': imgUrl ?? ''
    };
  }
}
