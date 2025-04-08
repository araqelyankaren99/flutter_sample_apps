import 'package:flutter_sample_apps/constants.dart' as constants;
import 'package:flutter_sample_apps/style.dart';
import 'package:flutter/material.dart';

class WidgetsCard extends StatefulWidget {
  const WidgetsCard(this.widgets);
  final List<Widget> widgets;
  @override
  _WidgetsCardState createState() => _WidgetsCardState();
}

class _WidgetsCardState extends State<WidgetsCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.fromLTRB(
          10 * constants.rw(context),
          10 * constants.rw(context),
          10 * constants.rw(context),
          10 * constants.rw(context),),
      color: whiteColor,
      elevation: 0,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
            20 * constants.rw(context),
            10 * constants.rw(context),
            10 * constants.rw(context),
            10 * constants.rw(context),),
        child: Column(
          children: widget.widgets,
        ),
      ),
    );
  }
}
