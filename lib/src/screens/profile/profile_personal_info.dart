import 'package:flutter_sample_apps/src/constants.dart' as constants;
import 'package:flutter_sample_apps/src/style.dart';
import 'package:flutter/material.dart';

class ProfilePersonalInfo extends StatelessWidget {
  const ProfilePersonalInfo({required this.firstname, required this.lastname});

  final String firstname;
  final String lastname;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        margin: EdgeInsets.only(
          top: 70 * constants.rh(context),
          bottom: 10 * constants.rh(context),
        ),
        child: FittedBox(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _renderText(
                firstname,
                padding: EdgeInsets.only(
                  left: 20 * constants.rw(context),
                  right: 10 * constants.rw(context),
                ),
              ),
              _renderText(
                lastname,
                padding: EdgeInsets.only(
                  right: 10 * constants.rw(context),
                  left: 20 * constants.rw(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _renderText(String text, {EdgeInsets padding = EdgeInsets.zero}) {
    return Padding(
      padding: padding,
      child: Text(
        text,
        style: getStyle(color: Colors.white, fontSize: 16),
      ),
    );
  }
}
