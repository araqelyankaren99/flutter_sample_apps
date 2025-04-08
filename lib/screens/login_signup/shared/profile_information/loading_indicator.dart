import 'package:flutter_sample_apps/constants.dart' as constants;
import 'package:flutter_sample_apps/style.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class LoadingIndicator extends StatefulWidget {
  const LoadingIndicator({required this.notifier});
  final ValueNotifier notifier;
  @override
  _LoadingindicatorState createState() => _LoadingindicatorState();
}

class _LoadingindicatorState extends State<LoadingIndicator> {
  ValueNotifier get _notifier => widget.notifier;
  double precent = 0;
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: _notifier,
        builder: (context, value, child) {
          precent = double.tryParse(value.toString()) ?? 0;
          if (precent >= 100) {
            precent = 0;
          }
          return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            LinearPercentIndicator(
              animateFromLastPercent: true,
              animation: true,
              padding:
                  EdgeInsets.symmetric(horizontal: 50 * constants.rw(context)),
              animationDuration: 1000,
              percent: precent / 100,
              lineHeight: 10,
              linearStrokeCap: LinearStrokeCap.roundAll,
              progressColor: cornflowerBlueColor,
              backgroundColor: geyserColor,
            ),
            Padding(
                padding: EdgeInsets.only(top: 20 * constants.rh(context)),
                child: Text('${precent.toInt()} %'),),
            const Text('Loading...')
          ],);
        },);
  }
}
