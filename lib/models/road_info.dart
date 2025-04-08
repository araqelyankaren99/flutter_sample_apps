import 'package:flutter_sample_apps/models/direction.dart';

class RoadInfo {
  RoadInfo({
    required this.miles,
    required this.amount,
    required this.direction,
  });

  double miles;
  double amount;
  Direction direction;
}
