import 'package:flutter_sample_apps/constants.dart' as constants;
import 'package:flutter_sample_apps/middlewares/extension/string.dart';
import 'package:flutter_sample_apps/shared/connectivity/connection.dart';
import 'package:flutter_sample_apps/style.dart';
import 'package:flutter/material.dart';

class NextButton extends StatelessWidget {
  const NextButton({
    required this.onPress,
    required this.text,
    required this.textColor,
    this.padding = EdgeInsets.zero,
    this.margin = 30,
    this.absorbing = false,
    this.borderColor = Colors.transparent,
    this.color = azureRadianceColor,
    this.progressIndicatorColor = whiteColor,
    this.isActive = true,
    this.width = double.infinity,
    this.showLoading = false,
    this.checkInternet = true,
  });

  final Color color;
  final Color textColor;
  final Function() onPress;
  final String text;
  final EdgeInsets padding;
  final double margin;
  final bool absorbing;
  final Color borderColor;
  final bool isActive;
  final bool checkInternet;
  final double width;
  final bool showLoading;
  final Color progressIndicatorColor;

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: padding,
        child: Container(
            width: width,
            height: _getButtonHeight(context),
            margin: EdgeInsets.symmetric(
                horizontal: margin * constants.rw(context),),
            child: AbsorbPointer(
              absorbing: absorbing,
              child: InkWell(
                  onTap: () => checkInternet
                      ? _onPressCheckInternet(context)
                      : onPress(),
                  child: Container(
                    decoration: BoxDecoration(
                        border: Border.all(
                            color: isActive ? borderColor : doveGrayColor,),
                        color: isActive ? color : whiteColor,
                        borderRadius:
                            BorderRadius.circular(5 * constants.rh(context)),),
                    child: showLoading
                        ? Center(
                            child: SizedBox(
                            width: _getButtonHeight(context) / 2,
                            height: _getButtonHeight(context) / 2,
                            child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation(
                                    progressIndicatorColor,),),
                          ),)
                        : Center(
                            child: Text(
                              text,
                              textAlign: TextAlign.center,
                              style: getStyle(
                                  color: isActive ? textColor : blackColor,),
                            ),
                          ),
                  ),),
            ),),);
  }

  /// This function check internet connection when press the NextButton
  void _onPressCheckInternet(BuildContext context) =>
      Connection.checker(context, onDone: () => onPress());

  /// This function get NextButton height
  double _getButtonHeight(BuildContext context) =>
      15 * constants.rh(context) * 2 + text.heightOfText(context, getStyle());
}
