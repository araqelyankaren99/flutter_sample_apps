import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class LoaderWidget extends StatelessWidget {
  const LoaderWidget({
    super.key,
    required this.primaryColor,
    required this.secondaryColor,
  });

  final Color primaryColor;
  final Color secondaryColor;

  @override
  Widget build(BuildContext context) {
    return Lottie.asset(
          width: 150,
          height: 150,
          'assets/loader.json',
          delegates: LottieDelegates(
            values: [
              ValueDelegate.color(
                ['loader-color-primary', '**'],
                value: primaryColor,
              ),
              ValueDelegate.color(
                ['loader-color-secondary', '**'],
                value: secondaryColor,
              ),
            ],
          ),
    );
  }
}
