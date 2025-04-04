import 'package:flutter_sample_apps/src/constants.dart' as constants;
import 'package:flutter/material.dart';

class AppBarWidget extends StatelessWidget {
  const AppBarWidget(
      {this.titleText = '',
      this.suffixWidget,
      this.titleStyle,
      this.prefixWidget,
      this.backgroundColor,
      this.decoration});

  final Widget? suffixWidget;
  final Widget? prefixWidget;
  final String titleText;
  final TextStyle? titleStyle;
  final Color? backgroundColor;
  final BoxDecoration? decoration;

  @override
  Widget build(BuildContext context) {
    Widget _renderPrefix() {
      return Positioned(
          left: 20 * constants.rw(context),
          child: Container(
              alignment: Alignment.center, child: Center(child: prefixWidget)));
    }

    Widget _renderSuffix() {
      return Positioned(
          right: 20 * constants.rw(context),
          child: Container(
              alignment: Alignment.center,
              child: Center(
                child: suffixWidget ??
                    const Icon(
                      Icons.ac_unit_outlined,
                      color: Colors.transparent,
                    ),
              )));
    }

    Widget _renderTitle() {
      return Padding(
          padding: EdgeInsets.symmetric(vertical: 15 * constants.rh(context)),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(
              titleText,
              style: titleStyle,
            )
          ]));
    }

    return Container(
      color: backgroundColor,
      decoration: decoration,
      child: Stack(
        alignment: Alignment.center,
        children: [
          _renderPrefix(),
          _renderTitle(),
          _renderSuffix(),
        ],
      ),
    );
  }
}
