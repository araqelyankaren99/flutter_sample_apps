import 'package:flutter_sample_apps/src/constants.dart' as constants;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sample_apps/src/middlewares/connectivity/connectivity.dart';
import 'package:flutter_sample_apps/src/middlewares/extensions/string.dart';
import 'package:flutter_sample_apps/src/models/order.dart';
import 'package:flutter_sample_apps/src/screens/profile/order/order_card_widget_bloc.dart/order_card_bloc.dart';
import 'package:flutter_sample_apps/src/screens/profile/order/order_card_widget_bloc.dart/order_card_event.dart';
import 'package:flutter_sample_apps/src/screens/profile/order/order_card_widget_bloc.dart/order_card_state.dart';
import 'package:flutter_sample_apps/src/screens/profile/order/order_info_dialog.dart';
import 'package:flutter_sample_apps/src/screens/profile/shared/user_action_result.dart';
import 'package:flutter_sample_apps/src/style.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart' as intl;
import 'package:marquee/marquee.dart';

class OrderCardWidget extends StatefulWidget {
  const OrderCardWidget({
    required this.orderInfos,
    required this.order,
    this.hasDivider = false,
    this.showViewAndInvoiceSuffix = false,
    this.margin = const EdgeInsets.all(5),
    this.padding = const EdgeInsets.all(10),
  });
  final EdgeInsets margin;
  final EdgeInsets padding;
  final bool showViewAndInvoiceSuffix;
  final bool hasDivider;
  final Order order;
  final List<OrderInfo> orderInfos;

  @override
  _OrderCardWidgetState createState() => _OrderCardWidgetState();
}

class _OrderCardWidgetState extends State<OrderCardWidget> {
  late OrderInfo orderInfo = widget.orderInfos[0];
  late bool showDivider = widget.hasDivider;
  late OrderCardBloc _orderCardWidgetBloc;
  bool loading = false;
  @override
  Widget build(BuildContext context) {
    return _render();
  }

  Widget _render() {
    return InkWell(
      onTap: _orderCardOnTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10 * constants.rw(context)),
          color: Colors.white,
        ),
        margin: widget.margin,
        padding: widget.padding,
        child: ListView.builder(
            physics: const ClampingScrollPhysics(),
            shrinkWrap: true,
            itemCount: widget.orderInfos.length,
            itemBuilder: (context, index) {
              if (index == widget.orderInfos.length - 1 &&
                  orderInfo != OrderInfo.road) {
                showDivider = false;
              }

              orderInfo = widget.orderInfos[index];
              return BlocProvider<OrderCardBloc>(
                  create: (context) {
                    return _orderCardWidgetBloc = OrderCardBloc();
                  },
                  child: BlocListener<OrderCardBloc, OrderCardState>(
                      listener: _listener,
                      child: WillPopScope(
                          onWillPop: () async => true,
                          child: _renderContent())));
            }),
      ),
    );
  }

  Widget _renderContent() {
    return Row(
      children: [
        _renderPrefixWidget(),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _renderOrderMainInformation(),
              ),
              if (widget.showViewAndInvoiceSuffix) _viewAndInvoiceButtons(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _renderPrefixWidget() {
    return Padding(
      padding: EdgeInsets.all(15 * constants.rw(context)),
      child: orderInfo.getImage(),
    );
  }

  Widget _renderDivider({Color color = Colors.grey, double height = 10}) {
    return Divider(
      color: color,
      height: height,
      thickness: 0.09,
    );
  }

  Widget _viewAndInvoiceButtons() {
    return Column(
      children: [
        _viewButton(),
        BlocBuilder<OrderCardBloc, OrderCardState>(
          builder: (context, state) {
            return _invoiceButton(state);
          },
        ),
      ],
    );
  }

  Widget _viewButton() {
    return Padding(
      padding: EdgeInsets.fromLTRB(10 * constants.rw(context), 0,
          10 * constants.rw(context), 15 * constants.rh(context)),
      child: const Text(
        'View',
        style: TextStyle(color: azureRadianceColor, fontSize: 12),
      ),
    );
  }

  Widget _invoiceButton(OrderCardState state) {
    return InkWell(
      onTap: () => Connection.checker(context,
          onDone: () =>
              state is! OrderCardLoadingState ? _onTapInvoice() : null),
      child: Padding(
        padding: EdgeInsets.fromLTRB(10 * constants.rw(context),
            15 * constants.rh(context), 10 * constants.rw(context), 0),
        child: state is! OrderCardLoadingState
            ? SvgPicture.asset(
                'assets/images/invoice_icon.svg',
                semanticsLabel: 'PDF',
                height: 20,
              )
            : const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(azureRadianceColor),
                  strokeWidth: 2,
                ),
              ),
      ),
    );
  }

  Widget _renderOrderMainInformation() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        _renderText(
          orderInfo.getName(),
          color: cadetBlueColor,
          fontSize: 10,
        ),
        _renderText(
          orderInfo.getValue(widget.order),
          color: Colors.black,
          fontSize: 13,
        ),
        if (showDivider) _renderDivider() else Container(),
        _renderRoadDestination(),
      ],
    );
  }

  Widget _renderRoadDestination() {
    if (orderInfo == OrderInfo.road) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!showDivider) _renderDivider(height: 20.0, color: Colors.white),
          _renderText(
            'Destination',
            color: cadetBlueColor,
            fontSize: 10,
          ),
          _renderText(widget.order.destination,
              color: Colors.black, fontSize: 13),
        ],
      );
    }
    return Container();
  }

  Widget _renderText(String text,
      {Color? color, double? fontSize, EdgeInsets margin = EdgeInsets.zero}) {
    return Container(
      height: text.heightOfText(context, getStyle(fontSize: fontSize)),
      margin: margin,
      child: hasTextOverflow(text, const TextStyle(),
              maxWidth: MediaQuery.of(context).size.width -
                  110 * constants.rw(context))
          ? _renderOverflowedText(
              text: text,
              textStyle: getStyle(
                color: color,
                fontSize: fontSize,
                weight: FontWeight.w500,
              ))
          : _renderTextWithoutOverflow(
              text: text,
              textStyle: getStyle(
                color: color,
                fontSize: fontSize,
                weight: FontWeight.w500,
              )),
    );
  }

  Widget _renderOverflowedText(
      {required String text, required TextStyle textStyle}) {
    return Marquee(
      pauseAfterRound: const Duration(seconds: 1),
      textScaleFactor: 1,
      crossAxisAlignment: CrossAxisAlignment.start,
      blankSpace: 60,
      text: text,
      startAfter: const Duration(seconds: 1),
      style: textStyle,
    );
  }

  Widget _renderTextWithoutOverflow(
      {required String text, required TextStyle textStyle}) {
    return Text(
      text,
      style: textStyle,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  void _listener(BuildContext context, OrderCardState state) {
    if (state is InvoicePdfLoadError) {
      UserActionResultDialog(context: context).show(
          dismissOnTap: true,
          editNotificationText: 'Error loading invoice pdf');
    }
  }

  /// If OrderCardWidget has 'view'(showViewAndInvoiceSuffix is set true) then this method opens dialog with full order information, otherwise does nothing
  void _orderCardOnTap() {
    if (widget.showViewAndInvoiceSuffix) {
      return ShowOrderDialog(
          context: context,
          order: widget.order,
          buttonText: 'OK',
          callback: () => Navigator.pop(context)).showOrderFullInformation();
    }
  }

  /// This method downloads pdf file from server and opens it in native app
  Future<void> _onTapInvoice() async {
    String? invoiceUrl;
    final invoice = widget.order.invoice;
    if (invoice != null) {
      invoiceUrl = invoice.pdf;
    }
    _orderCardWidgetBloc.add(InvoicePdfEvent(invoiceUrl: invoiceUrl));
  }

  bool hasTextOverflow(String text, TextStyle style,
      {double minWidth = 0,
      double maxWidth = double.infinity,
      int maxLines = 1}) {
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: maxLines,
      textDirection: TextDirection.ltr,
    )..layout(minWidth: minWidth, maxWidth: maxWidth);
    return textPainter.didExceedMaxLines;
  }
}

extension OrderCardTypeExtension on OrderInfo {
  String getValue(Order order) {
    switch (this) {
      case OrderInfo.orderDate:
        return intl.DateFormat('dd/MM/yyyy').format(order.dueDate);
      case OrderInfo.driver:
        final driver = order.driver;
        return driver != null ? driver.firstName : '';
      case OrderInfo.orderTime:
        return intl.DateFormat('kk:mm').format(order.dueDate);
      case OrderInfo.payment:
        return '\$${order.amount}';
      case OrderInfo.road:
        return order.from;
    }
  }

  Widget getImage() {
    switch (this) {
      case OrderInfo.road:
        return SvgPicture.asset(
          'assets/images/destination.svg',
          semanticsLabel: 'Destination',
          width: 15,
        );
      case OrderInfo.orderDate:
        return SvgPicture.asset(
          'assets/images/calendar.svg',
          semanticsLabel: 'Calendar',
          width: 15,
        );
      case OrderInfo.orderTime:
        return SvgPicture.asset(
          'assets/images/clock.svg',
          semanticsLabel: 'Clock',
          width: 15,
        );
      case OrderInfo.driver:
        return SvgPicture.asset(
          'assets/images/driver.svg',
          semanticsLabel: 'Driver',
          width: 15,
        );
      case OrderInfo.payment:
        return SvgPicture.asset(
          'assets/images/payment.svg',
          semanticsLabel: 'Payment',
          width: 15,
        );
    }
  }

  String getName() {
    switch (this) {
      case OrderInfo.orderDate:
        return 'Date';
      case OrderInfo.driver:
        return 'Driver';
      case OrderInfo.orderTime:
        return 'Time';
      case OrderInfo.payment:
        return 'Payment';
      case OrderInfo.road:
        return 'From';
    }
  }
}

enum OrderInfo {
  road,
  orderDate,
  orderTime,
  driver,
  payment,
}
