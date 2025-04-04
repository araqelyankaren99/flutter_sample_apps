import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class TriangleIconWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: SvgPicture.asset(
        'assets/images/triangle.svg',
        alignment: Alignment.bottomCenter,
        fit: BoxFit.cover,
      ),
    );
  }
}
