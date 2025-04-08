import 'package:flutter_sample_apps/constants.dart' as constants;
import 'package:flutter_sample_apps/screens/login_signup/shared/profile_information/search_widget.dart';
import 'package:flutter_sample_apps/shared/app_bar_widget.dart';
import 'package:flutter_sample_apps/style.dart';
import 'package:flutter/material.dart';

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
              titleText: 'Select your city',
              titleStyle: getStyle(
                  color: codGrayColor, fontSize: 20, weight: FontWeight.w500,),
              prefixWidget: InkWell(
                onTap: () => Navigator.pop(context),
                child: const Icon(
                  Icons.clear,
                  color: azureRadianceColor,
                ),
              ),),
          SearchWidget(
            controller: controller,
            onChanged: onChanged,
            onPressed: () {
              onPressed();
            },
          )
        ],),);
  }
}
