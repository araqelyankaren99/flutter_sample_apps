import 'package:flutter_sample_apps/constants.dart' as constants;
import 'package:flutter_sample_apps/style.dart';
import 'package:flutter/widgets.dart';

class CopyrightText extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.only(bottom: 10 * constants.rh(context)),
        alignment: Alignment.bottomCenter,
        child: Text('2021.DRIVEHOPAPP',
            style: getStyle(
                color: cadetBlueColor, fontSize: 14, weight: FontWeight.w400,),),);
  }
}
