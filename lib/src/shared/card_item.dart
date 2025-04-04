import 'package:flutter_sample_apps/src/constants.dart' as constants;

import 'package:flutter_sample_apps/src/middlewares/extensions/string.dart';
import 'package:flutter_sample_apps/src/models/order.dart';
import 'package:flutter_sample_apps/src/shared/button_to_map_view.dart';
import 'package:flutter_sample_apps/src/shared/card_item_extension.dart';
import 'package:flutter_sample_apps/src/shared/heights_calculations.dart';

import 'package:flutter_sample_apps/src/style.dart';
import 'package:flutter/material.dart';

class CardItem extends StatefulWidget {
  const CardItem({
    required this.cardTitle,
    required this.order,
    this.orderStatus = OrderStatus.none,
    this.withDivider,
    this.isValid,
    this.onTap,
  });

  final CardTitle cardTitle;
  final Order order;
  final bool? withDivider;
  final bool? isValid;
  final OrderStatus orderStatus;

  final GestureTapCallback? onTap;
  @override
  _CardItemState createState() => _CardItemState();
}

class _CardItemState extends State<CardItem> {
  double get errorMessageTextHeight => "Location can't be null"
      .heightOfText(context, getStyle(fontSize: 12, color: Colors.red));

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 90 * constants.rw(context) -
          ((widget.isValid != null)
              ? 0
              : HeightsCalculations.errorMessageSpace(
                  context: context, errorTextHeight: errorMessageTextHeight)),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: widget.onTap,
              highlightColor: Colors.transparent,
              splashColor: Colors.transparent,
              child: Row(
                children: [
                  Container(
                    margin: EdgeInsets.only(right: 16 * constants.rw(context)),
                    child: widget.cardTitle.getPrefixWidget(),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(widget.cardTitle.getTitle(),
                                  style: labelTextStyle),
                              if (widget.cardTitle == CardTitle.payment)
                                Padding(
                                    padding: const EdgeInsets.only(right: 8.0),
                                    child: Text(CardTitle.baseFare.getTitle(),
                                        style: labelTextStyle))
                              else
                                Container()
                            ]),
                        Expanded(
                          child: Container(
                              child: widget.cardTitle.getContent(
                            context,
                            widget.order,
                          )),
                        ),
                        _renderDivider(),
                        Visibility(
                          visible: widget.isValid != null,
                          child: _renderError(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          _renderSuffixWidgets()
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
              color: widget.isValid == false ? Colors.red : Colors.white)),
    );
  }

  Widget _renderDivider() {
    if (widget.isValid != false || widget.withDivider == true) {
      return const Divider(
        color: blackHazeColor,
        thickness: 1,
      );
    }
    if (widget.isValid == false) {
      return const Divider(
        color: Colors.red,
        thickness: 1,
      );
    }
    return const Divider(
      color: Colors.transparent,
      thickness: 1,
    );
  }

  Widget _renderSuffixWidgets() {
    if (widget.cardTitle == CardTitle.from ||
        widget.cardTitle == CardTitle.destination) {
      final isDestination = widget.cardTitle == CardTitle.destination;
      final suffixWidgets = _renderSuffixIcons(isDestination, _isReadOnly());
      return Row(
        children: [suffixWidgets],
      );
    }
    return Container();
  }

  Widget _renderSuffixIcons(bool isDestination, bool readOnly) {
    return readOnly
        ? Container()
        : ButtonToMapVIew(order: widget.order, isDestination: isDestination);
  }

  bool _isReadOnly() {
    return widget.orderStatus != OrderStatus.none &&
        widget.orderStatus != OrderStatus.canceled &&
        widget.orderStatus != OrderStatus.fromFinished;
  }
}

enum CardTitle {
  from,
  destination,
  dateTime,
  comment,
  driver,
  contactDriver,
  payment,
  baseFare
}
