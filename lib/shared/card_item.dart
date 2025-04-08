import 'package:flutter_sample_apps/constants.dart' as constants;
import 'package:flutter_sample_apps/middlewares/extension/string.dart';
import 'package:flutter_sample_apps/shared/heights_calculations.dart';
import 'package:flutter_sample_apps/style.dart';
import 'package:flutter/material.dart';

class CardItem extends StatefulWidget {
  const CardItem({
    required this.title,
    required this.content,
    this.suffixWidgets,
    this.prefixWidgets,
    this.withDivider,
    this.isValid,
  });

  final String title;
  final Widget? content;
  final bool? withDivider;
  final bool? isValid;
  final List<Widget>? suffixWidgets;
  final Widget? prefixWidgets;

  @override
  _CardItemState createState() => _CardItemState();
}

class _CardItemState extends State<CardItem> {
  double get errorMessageTextHeight => "Location can't be null"
      .heightOfText(context, getStyle(fontSize: 12, color: Colors.red));

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _height(),
      child: Row(
        children: [
          _prefixItem(),
          _renderField(),
          _renderSuffixWidgets(),
        ],
      ),
    );
  }

  Widget _prefixItem() {
    return Container(
      margin: EdgeInsets.only(right: 16 * constants.rw(context)),
      child: widget.prefixWidgets,
    );
  }

  Widget _renderField() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.title, style: labelTextStyle),
          Expanded(
            child: Container(child: widget.content ?? Container()),
          ),
          _renderDivider(),
          Visibility(
            visible: widget.isValid != null,
            child: _renderError(),
          ),
        ],
      ),
    );
  }

  Widget _renderError() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3.0),
      child: Text("Location can't be empty",
          style: getStyle(
              fontSize: 12,
              color: widget.isValid == false ? Colors.red : Colors.white,),),
    );
  }

  Widget _renderDivider() {
    Color? _color() {
      if (widget.isValid != false || widget.withDivider == true) {
        return blackHazeColor;
      }

      if (widget.isValid == false) {
        return Colors.red;
      }

      return Colors.transparent;
    }

    return Divider(
      color: _color(),
      thickness: 1,
    );
  }

  Widget _renderSuffixWidgets() {
    if (widget.suffixWidgets != null) {
      return Row(
        children: widget.suffixWidgets ?? [],
      );
    }
    return Container();
  }

  double _height() {
    return 80 * constants.rw(context) -
        ((widget.isValid != null)
            ? 0
            : HeightsCalculations.errorMessageSpace(
                context: context, errorTextHeight: errorMessageTextHeight,));
  }
}
