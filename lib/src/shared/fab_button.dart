import 'package:flutter_sample_apps/src/constants.dart' as constants;
import 'package:flutter/material.dart';

import 'package:flutter_svg/svg.dart';

class FabButton extends StatefulWidget {
  const FabButton({this.onTap, this.buttonType = FabButtonType.menu});
  final GestureTapCallback? onTap;
  final FabButtonType buttonType;
  @override
  _FabButtonState createState() => _FabButtonState();
}

class _FabButtonState extends State<FabButton> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: widget.onTap,
        child: Container(
            margin: EdgeInsets.all(10 * constants.rw(context)),
            decoration: const BoxDecoration(
                boxShadow: [BoxShadow(color: Colors.black38, blurRadius: 10.0)],
                borderRadius: BorderRadius.all(Radius.circular(30))),
            child: widget.buttonType.getButtonSvg()));
  }
}

extension FabButtonTypeExtension on FabButtonType {
  SvgPicture getButtonSvg() {
    switch (this) {
      case FabButtonType.menu:
        return SvgPicture.asset(
          'assets/images/menu.svg',
          height: 40,
        );
      case FabButtonType.location:
        return SvgPicture.asset(
          'assets/images/map.svg',
        );
    }
  }
}

enum FabButtonType { menu, location }
