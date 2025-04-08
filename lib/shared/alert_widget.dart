import 'dart:async';

import 'package:flutter_sample_apps/constants.dart' as constants;
import 'package:flutter_sample_apps/screens/login_signup/shared/login_signup_button.dart';
import 'package:flutter_sample_apps/shared/next_button.dart';
import 'package:flutter_sample_apps/style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class AlertWidget {
  AlertWidget({this.closeAction});
  Function? closeAction;

  void acceptAction(BuildContext context, String text) {
    const type = AlertWidgetType.check;
    _showDialog(context, text, type);
  }

  void cancelAction(BuildContext context, String text) {
    const type = AlertWidgetType.cancel;
    _showDialog(context, text, type);
  }

  void showMessage(BuildContext context, String message,
      {VoidCallback? closeAction,}) {
    _showMessageDialog(context, message, closeAction);
  }

  void showOrderClosed(BuildContext context) {
    _showOrderClosedDialog(context);
  }

  void _showDialog(
    BuildContext context,
    String text,
    AlertWidgetType type,
  ) {
    Future.delayed(const Duration(seconds: 1), () {
      final popUntilFunction = closeAction;
      Navigator.pop(context);
      if (popUntilFunction != null) {
        popUntilFunction();
      }
    });
    showDialog(
      barrierDismissible: false,
      context: context,
      barrierColor: Colors.transparent,
      useRootNavigator: false,
      builder: (BuildContext buildContext) {
        return _renderDialog(buildContext, text, type);
      },
    );
  }

  /// This function create confirm alert
  static void showConfirmAlertDialog(BuildContext context,
      {required String title,
      required String accept,
      required VoidCallback onAcceptAction,
      String cancel = 'Cancel',}) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return AlertDialog(
          title: Column(
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
              ),
              Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Row(children: [
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: LoginAndSignUpButton(
                            color: catskillWhiteColor,
                            text: cancel,
                            onPress: () => Navigator.pop(context),),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: LoginAndSignUpButton(
                          color: azureRadianceColor,
                          text: accept,
                          textColor: whiteColor,
                          onPress: onAcceptAction,
                        ),
                      ),
                    )
                  ],),)
            ],
          ),
        );
      },
    );
  }

  Future<void> _showMessageDialog(
      BuildContext context, String message, VoidCallback? closeAction,) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: SingleChildScrollView(
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: getStyle(fontSize: 20),
            ),
          ),
          actions: <Widget>[
            NextButton(
                onPress: () => closeAction != null
                    ? closeAction()
                    : Navigator.of(context).pop(),
                text: 'OK',
                textColor: whiteColor,)
          ],
        );
      },
    );
  }

  Future<void> _showOrderClosedDialog(BuildContext context) async {
    final Widget svg = SvgPicture.asset('assets/images/sad.svg');
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                svg,
                Padding(
                  padding: EdgeInsets.only(top: 10.0 * constants.rh(context)),
                  child: Text(
                    'This order has\nbeen canceled',
                    style: getStyle(weight: FontWeight.w600, fontSize: 20),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Dialog _renderDialog(
      BuildContext context, String text, AlertWidgetType type,) {
    return Dialog(
        elevation: 0,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
                Radius.circular(20.0 * constants.rw(context)),),),
        insetPadding: EdgeInsets.symmetric(
            horizontal: 40 * constants.rw(context),
            vertical: 40 * constants.rh(context),),
        backgroundColor: blackHazeColor,
        child: _renderDialogContent(context, text, type),);
  }

  Widget _renderDialogContent(
      BuildContext context, String text, AlertWidgetType type,) {
    Widget _renderIcon() {
      return Container(
          padding: EdgeInsets.all(20 * constants.rw(context)),
          decoration: BoxDecoration(
            color: type._getColor(),
            shape: BoxShape.circle,
          ),
          child: _renderSvg(
            context,
            type._getIcon(),
          ),);
    }

    Widget _renderText() {
      if (text.isNotEmpty) {
        return Container(
            padding: EdgeInsets.fromLTRB(20 * constants.rw(context),
                30 * constants.rh(context), 20 * constants.rw(context), 0,),
            child: Text(
              text,
              style: notificationDialogTextStyle,
              textAlign: TextAlign.center,
            ),);
      } else {
        return Container();
      }
    }

    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.all(30 * constants.rw(context)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [_renderIcon(), _renderText()],
        ),
      ),
    );
  }

  Widget _renderSvg(BuildContext context, String svgImagePath) {
    return SvgPicture.asset(
      svgImagePath,
      height: 40 * constants.rw(context),
      width: 40 * constants.rw(context),
    );
  }
}

enum AlertWidgetType { check, cancel }

extension _TypeExtension on AlertWidgetType {
  String _getIcon() {
    switch (this) {
      case AlertWidgetType.check:
        return 'assets/images/check.svg';
      case AlertWidgetType.cancel:
        return 'assets/images/cancel.svg';
    }
  }

  Color _getColor() {
    switch (this) {
      case AlertWidgetType.check:
        return azureRadianceColor;
      case AlertWidgetType.cancel:
        return Colors.red;
    }
  }
}
