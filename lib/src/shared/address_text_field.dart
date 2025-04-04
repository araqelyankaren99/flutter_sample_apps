import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_sample_apps/src/middlewares/connectivity/connectivity.dart';
import 'package:flutter_sample_apps/src/style.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AddressTextField extends StatefulWidget {
  const AddressTextField(
      {Key? key, required this.labelText,
      required this.onChanged,
      this.controller,
      this.focusNode}) : super(key: key);
  final String labelText;
  final Function onChanged;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  @override
  _AddressTextFieldState createState() => _AddressTextFieldState();
}

class _AddressTextFieldState extends State<AddressTextField> {
  ConnectivityResult _connectionStatus = ConnectivityResult.none;
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    initialize();
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () => Connection.checker(context,
            onDone: () => widget.focusNode?.requestFocus()),
        child: Row(children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.labelText, style: labelTextStyle),
                Container(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: TextField(
                      enabled: _connectionStatus != ConnectivityResult.none,
                      textInputAction: TextInputAction.next,
                      focusNode: widget.focusNode,
                      onChanged: (text) => widget.onChanged(text),
                      controller: widget.controller,
                      scrollPhysics: const ClampingScrollPhysics(),
                      style: requestTextFieldsStyle,
                      minLines: 1,
                      maxLines: 3,
                      decoration: InputDecoration(
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 5.0),
                        isCollapsed: true,
                        isDense: true,
                        suffixIcon: IconButton(
                          alignment: Alignment.centerRight,
                          padding: EdgeInsets.zero,
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          onPressed: () => widget.controller?.clear(),
                          icon: SvgPicture.asset(
                            'assets/images/clean.svg',
                            width: 20,
                          ),
                        ),
                        enabledBorder: const UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: cadetBlueColor, width: 0.5),
                        ),
                        focusedBorder: const UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: cadetBlueColor, width: 0.5),
                        ),
                      ),
                    ))
              ],
            ),
          ),
        ]));
  }

  /// This function check connection status.
  Future<void> initConnectivity() async {
    var result = [ConnectivityResult.wifi];
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      debugPrint(e.toString());
      return;
    }
    return _updateConnectionStatus(result);
  }

  /// This function updated connection status
  Future<void> _updateConnectionStatus(List<ConnectivityResult> result) async =>
      setState(() => _connectionStatus = result.first);

  /// This fuction initialized connectivity
  void initialize() {
    initConnectivity();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }
}
