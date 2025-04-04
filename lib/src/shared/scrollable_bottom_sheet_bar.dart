import 'package:flutter_sample_apps/src/shared/fab_button.dart';
import 'package:flutter_sample_apps/src/shared/triangle_icon_widget.dart';
import 'package:flutter/material.dart';

class ScrollableBottomSheetBar extends StatefulWidget {
  const ScrollableBottomSheetBar(
      {this.fabButtonOnTap, this.hideTriangle = false});
  final GestureTapCallback? fabButtonOnTap;
  final bool hideTriangle;

  @override
  _ScrollableBottomSheetBarState createState() =>
      _ScrollableBottomSheetBarState();
}

class _ScrollableBottomSheetBarState extends State<ScrollableBottomSheetBar> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Align(
          alignment: Alignment.bottomRight,
          child: FabButton(
            onTap: widget.fabButtonOnTap,
            buttonType: FabButtonType.location,
          ),
        ),
        _renderScrollBtn()
      ],
    );
  }

  Widget _renderScrollBtn() {
    return widget.hideTriangle == false
        ? Align(
            alignment: Alignment.bottomCenter,
            child: TriangleIconWidget(),
          )
        : const SizedBox.shrink();
  }
}
