import 'package:flutter_sample_apps/src/constants.dart' as constants;
import 'package:flutter/material.dart';
import 'package:flutter_sample_apps/src/screens/login_signup/car_information/shared/search_widget.dart';
import 'package:flutter_sample_apps/src/shared/app_bar_widget.dart';
import 'package:flutter_sample_apps/src/style.dart';

class BtmSheetTitleWidget extends StatelessWidget {
  const BtmSheetTitleWidget({
    required this.controller,
    required this.onPressed,
    this.onChanged,
  });
  final TextEditingController controller;
  final Function(String)? onChanged;
  final Function onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.only(top: 20 * constants.rh(context)),
        child: Column(children: [
          AppBarWidget(
              titleText: 'Select Model',
              titleStyle: getStyle(
                  color: codGrayColor, fontSize: 20, weight: FontWeight.w500),
              prefixWidget: InkWell(
                onTap: () => Navigator.pop(context),
                child: const Icon(
                  Icons.clear,
                  color: azureRadianceColor,
                ),
              )),
          SearchWidget(
            controller: controller,
            onChanged: onChanged,
            onPressed: () {
              onPressed();
            },
          )
        ]));
  }
}
