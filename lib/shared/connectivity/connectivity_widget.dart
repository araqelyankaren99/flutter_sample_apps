import 'package:flutter_sample_apps/middlewares/extension/string.dart';
import 'package:flutter_sample_apps/style.dart';
import 'package:flutter/material.dart';

class ConnectivityWidget extends StatefulWidget {
  @override
  _ConnectivityWidgetState createState() => _ConnectivityWidgetState();
}

class _ConnectivityWidgetState extends State<ConnectivityWidget> {
  static const _errorMessage = 'Internet connection not available!';

  double get _errorMessageTextHeight =>
      _errorMessage.heightOfText(context, getStyle(fontSize: 15));

  @override
  Widget build(BuildContext context) {
    return Material(
        color: Colors.transparent,
        child: SafeArea(
            child: Container(
          alignment: Alignment.center,
          height: _errorMessageTextHeight + 20,
          width: MediaQuery.of(context).size.width,
          color: redColor,
          child: _renderText(_errorMessage),
        ),),);
  }

  Widget _renderText(String message) {
    return Text(
      message,
      textAlign: TextAlign.center,
      style: getStyle(
        color: whiteColor,
        weight: FontWeight.w500,
        fontSize: 14,
      ),
    );
  }
}
