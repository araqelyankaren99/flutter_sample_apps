import 'package:flutter_sample_apps/constants.dart' as constants;
import 'package:flutter_sample_apps/style.dart';
import 'package:flutter/material.dart';

class NoOrderMessage extends StatelessWidget {
  const NoOrderMessage({required this.opacity});
  final double opacity;
  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: opacity,
      duration: const Duration(milliseconds: 500),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 50 * constants.rh(context)),
        child: Column(
          children: [
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: 40 * constants.rw(context),),
                child: Image.asset(
                  'assets/images/no_orders.gif',
                  fit: BoxFit.contain,
                ),
              ),
            ),
            _renderNoOrderText(
              'Swipe down to refresh',
            ),
          ],
        ),
      ),
    );
  }

  Widget _renderNoOrderText(String text) {
    return Text(
      text,
      style: getStyle(fontSize: 20, weight: FontWeight.bold),
      textAlign: TextAlign.center,
    );
  }
}
