import 'package:flutter_sample_apps/src/constants.dart' as constants;
import 'package:flutter_sample_apps/src/middlewares/connectivity/connectivity.dart';
import 'package:flutter_sample_apps/src/style.dart';
import 'package:flutter/material.dart';

class NextButton extends StatelessWidget {
  const NextButton(
      {required this.onPress,
      required this.text,
      required this.textColor,
      this.padding = EdgeInsets.zero,
      this.absorbing = false,
      this.borderColor = Colors.transparent,
      this.color = azureRadianceColor,
      this.isActive = true,
      this.checkInternet = true,
      this.showLoading = false});

  final Color color;
  final Color textColor;
  final Function() onPress;
  final String text;
  final EdgeInsets padding;
  final bool? absorbing;
  final Color borderColor;
  final bool isActive;
  final bool checkInternet;
  final bool showLoading;

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: padding,
        child: Container(
            width: double.infinity,
            height: 60 * constants.rh(context),
            margin:
                EdgeInsets.symmetric(horizontal: 30 * constants.rw(context)),
            child: AbsorbPointer(
              absorbing: absorbing ?? false,
              child: InkWell(
                onTap: () =>
                    checkInternet ? _onPressCheckInternet(context) : onPress(),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                      border: Border.all(
                          color: isActive ? borderColor : doveGrayColor),
                      color: isActive ? color : whiteColor,
                      borderRadius:
                          BorderRadius.circular(5 * constants.rh(context))),
                  child: showLoading
                      ? Padding(
                          padding: EdgeInsets.all(15 * constants.rh(context)),
                          child: Center(
                              child: SizedBox(
                            width: 30 * constants.rh(context),
                            child: const CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation(whiteColor)),
                          )))
                      :  Expanded(
                          child: Center(child: Text(
                            text,
                            textAlign: TextAlign.center,
                            style: getStyle(
                              color: isActive ? textColor : blackColor,
                            ),
                          ),
                        ),),
                ),
              ),
            )));
  }

  /// This function check internet connection when press the NextButton
  void _onPressCheckInternet(BuildContext context) =>
      Connection.checker(context, onDone: () => onPress());
}
