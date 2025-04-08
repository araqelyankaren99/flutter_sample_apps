import 'package:flutter_sample_apps/constants.dart' as constants;
import 'package:flutter_sample_apps/middlewares/extension/string.dart';
import 'package:flutter_sample_apps/screens/order_view/scrollable_bottom_sheet/scroll_height_calculation.dart';
import 'package:flutter_sample_apps/style.dart';
import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';

class OrderInfoCell extends StatefulWidget {
  const OrderInfoCell(
      {this.labelTitle = '', this.orderInfo = '', this.text = '', this.onTap,});
  final String labelTitle;
  final String orderInfo;
  final String text;
  final GestureTapCallback? onTap;

  @override
  _OrderInfoCellState createState() => _OrderInfoCellState();
}

class _OrderInfoCellState extends State<OrderInfoCell> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: Colors.transparent,
      focusColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: widget.onTap,
      child: Padding(
          padding: EdgeInsets.fromLTRB(
              8.0 * constants.rw(context),
              8.0 * constants.rw(context),
              15.0 * constants.rw(context),
              8.0 * constants.rw(context),),
          child: SizedBox(
            height: widget.labelTitle.heightOfText(context, labelTextStyle) +
                widget.orderInfo.heightOfText(context, requestTextFieldsStyle),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children:
                  widget.text.isEmpty ? _getLabeledText() : _getSimpleText(),
            ),
          ),),
    );
  }

  List<Widget> _getLabeledText() {
    return [_getLabel(), _getOrderData(), _getDivider()];
  }

  List<Widget> _getSimpleText() {
    return [
      Text(
        widget.text,
        style: getStyle(color: azureRadianceColor),
      )
    ];
  }

  Widget _getDivider() {
    return Container(
        color: blackHazeColor,
        child: const Divider(
          height: 1,
        ),);
  }

  Widget _getOrderData() {
    return Expanded(
        child: (widget.orderInfo.isNotEmpty)
            ? ScrollHeightCalculation.hasTextOverflow(
                    context, widget.orderInfo, requestTextFieldsStyle,
                    maxLines: 1,
                    maxWidth: ScrollHeightCalculation.maxWidth(context),)
                ? _renderComplexMarquee(widget.orderInfo)
                : Text(
                    widget.orderInfo,
                    maxLines: 1,
                    style: requestTextFieldsStyle,
                  )
            : Container(),);
  }

  Widget _getLabel() {
    return widget.labelTitle.isNotEmpty
        ? Text(
            widget.labelTitle,
            style: labelTextStyle,
          )
        : Container();
  }

  Widget _renderComplexMarquee(String street) {
    return Marquee(
      text: street,
      style: requestTextFieldsStyle,
      crossAxisAlignment: CrossAxisAlignment.start,
      blankSpace: 20.0,
      pauseAfterRound: const Duration(seconds: 1),
      accelerationDuration: const Duration(seconds: 1),
      accelerationCurve: Curves.linear,
      decelerationDuration: const Duration(milliseconds: 500),
      decelerationCurve: Curves.easeOut,
    );
  }
}
