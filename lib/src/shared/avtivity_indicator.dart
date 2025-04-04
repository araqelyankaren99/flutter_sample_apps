import 'package:flutter_sample_apps/src/constants.dart' as constants;
import 'package:flutter_sample_apps/src/style.dart';
import 'package:flutter/cupertino.dart';

class ActivityIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
        child: Container(
      height: MediaQuery.of(context).size.height,
      width: double.infinity,
      color: whiteColor.withOpacity(0.8),
      child: CupertinoActivityIndicator(
        radius: 20 * constants.rw(context),
      ),
    ));
  }
}
