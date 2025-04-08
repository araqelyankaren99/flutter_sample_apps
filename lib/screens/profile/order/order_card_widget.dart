import 'package:flutter_sample_apps/constants.dart' as constants;
import 'package:flutter_sample_apps/middlewares/extension/string.dart';
import 'package:flutter_sample_apps/models/order.dart';
import 'package:flutter_sample_apps/screens/profile/order/appearing_btm_sheet_extension.dart';
import 'package:flutter_sample_apps/screens/profile/order/order_info_dialog.dart';
import 'package:flutter_sample_apps/screens/profile/shared/confirm_btn.dart';
import 'package:flutter_sample_apps/shared/car_info.dart';
import 'package:flutter_sample_apps/shared/comment_view.dart';
import 'package:flutter_sample_apps/style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart' as intl;
import 'package:marquee/marquee.dart';

class OrderCardWidget extends StatefulWidget {
  const OrderCardWidget({
    required this.orderInfos,
    required this.order,
    this.hasDivider = false,
    this.showViewAndAmountAndKmText = false,
    this.margin = const EdgeInsets.all(5),
    this.padding = const EdgeInsets.all(10),
    this.userOrderStatusType = UserOrderStatusType.none,
    this.onConfirmTap,
    this.isActive = true,
    this.onViewTripTap,
    this.confirmButtonLoading = false,
  });

  final EdgeInsets margin;
  final EdgeInsets padding;
  final bool showViewAndAmountAndKmText;
  final bool hasDivider;
  final Order order;
  final UserOrderStatusType userOrderStatusType;
  final GestureTapCallback? onConfirmTap;
  final GestureTapCallback? onViewTripTap;
  final bool confirmButtonLoading;
  final bool isActive;
  final List<OrderInfo> orderInfos;

  @override
  _OrderCardWidgetState createState() => _OrderCardWidgetState();
}

class _OrderCardWidgetState extends State<OrderCardWidget> {
  late OrderInfo orderInfo = widget.orderInfos[0];

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
        child: Stack(
          children: [
            ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: widget.orderInfos.length,
              itemBuilder: (context, index) {
                orderInfo = widget.orderInfos[index];
                if (orderInfo == OrderInfo.comment ||
                    orderInfo == OrderInfo.car) {
                  return _moreInfoWidget(orderInfo);
                }
                return _renderContent();
              },
            ),
            if (widget.userOrderStatusType == UserOrderStatusType.unconfirmed)
              Align(
                alignment: Alignment.topRight,
                child: Text(
                  '${OrderInfo.orderDate.getValue(widget.order)} ${OrderInfo.orderTime.getValue(widget.order)}',
                  style: getStyle(color: azureRadianceColor, fontSize: 12),
                  textAlign: TextAlign.right,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _renderContent() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _renderPrefixWidget(),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _renderOrderMainInformation(),
              ),
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

  Widget _moreInfoWidget(OrderInfo orderInfo) {
    return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _navigateToMoreInfoPage(orderInfo),
        child: _renderContent(),);
  }

  Widget _renderDivider({Color color = Colors.grey, double height = 10}) {
    return Divider(
      color: color,
      height: height,
      thickness: 0.09,
    );
  }

  Widget _renderOrderStatusIcon() {
    return Container(
      child: widget.order.state?.statusIcon() ?? const Icon(Icons.circle),
    );
  }

  Widget _renderOrderMainInformation() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _renderText(
              orderInfo.getName(),
              color: cadetBlueColor,
              fontSize: 10,
            ),
            if (widget.showViewAndAmountAndKmText) _renderOrderStatusIcon()
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _renderText(
              orderInfo.getValue(widget.order),
              color: Colors.black,
              fontSize: 13,
            ),
            if (widget.userOrderStatusType == UserOrderStatusType.unconfirmed &&
                orderInfo == OrderInfo.payment)
              _renderConfirmAndViewTripButtons(),
          ],
        ),
        if (widget.hasDivider) _renderDivider(),
        _renderRoadDestination(),
        if (widget.showViewAndAmountAndKmText)
          _renderRoadAmountAndKmAndViewButton(),
      ],
    );
  }

  Widget _renderConfirmAndViewTripButtons() {
    return Row(
      children: [
        _renderViewTripButton(),
        _renderConfirmButton(),
      ],
    );
  }

  Widget _renderViewTripButton() {
    return InkWell(
      onTap: widget.onViewTripTap,
      child: Container(
        margin: EdgeInsets.only(right: 10 * constants.rw(context)),
        child: Text('View trip',
            style: getStyle(fontSize: 12, color: azureRadianceColor),),
      ),
    );
  }

  Widget _renderConfirmButton() {
    return Container(
        padding: EdgeInsets.symmetric(
          horizontal: 15 * constants.rw(context),
          vertical: 5 * constants.rh(context),
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(
            10 * constants.rw(context),
          ),
          color: azureRadianceColor,
        ),
        child: ConfirmButton(
          isActive: widget.isActive,
          confirmButtonLoading: widget.confirmButtonLoading,
          onConfirmTap: widget.onConfirmTap,
        ),);
  }

  Widget _renderRoadAmountAndKmAndViewButton() {
    return Padding(
      padding: EdgeInsets.only(top: 10 * constants.rh(context)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              _renderRoadAmountOrKmText(
                padding: EdgeInsets.only(right: 5 * constants.rw(context)),
                text: '\$' + '${widget.order.amount}',
              ),
              _renderDotIcon(),
              _renderRoadAmountOrKmText(
                padding: EdgeInsets.only(
                  left: 5 * constants.rw(context),
                ),
                text: '${widget.order.km.toStringAsFixed(2)} km',
              ),
            ],
          ),
          _renderViewText(),
        ],
      ),
    );
  }

  Widget _renderViewText() {
    return Text(
      'View',
      style: getStyle(
        color: azureRadianceColor,
        weight: FontWeight.w500,
      ),
    );
  }

  Widget _renderRoadAmountOrKmText(
      {required String text, EdgeInsets padding = EdgeInsets.zero,}) {
    return Padding(
      padding: padding,
      child: Text(
        text,
        style: getStyle(
          color: azureRadianceColor,
          weight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _renderDotIcon() {
    return const Icon(
      Icons.brightness_1,
      size: 5,
      color: Colors.grey,
    );
  }

  Widget _renderRoadDestination() {
    if (orderInfo == OrderInfo.road) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!widget.hasDivider)
            _renderDivider(height: 20.0, color: Colors.white),
          _renderText(
            'Destination',
            color: cadetBlueColor,
            fontSize: 10,
          ),
          _renderText(widget.order.destination,
              color: Colors.black, fontSize: 13,),
          if (widget.hasDivider) _renderDivider() else Container(),
        ],
      );
    }
    return Container();
  }

  Widget _renderText(String text,
      {Color? color, double? fontSize, EdgeInsets margin = EdgeInsets.zero,}) {
    return Container(
      height: text.heightOfText(context, getStyle(fontSize: fontSize)),
      margin: margin,
      child: hasTextOverflow(
              text,
              getStyle(
                fontSize: fontSize,
                weight: FontWeight.w500,
              ),
              maxWidth: MediaQuery.of(context).size.width -
                  160 * constants.rw(context),)
          ? SizedBox(
              width: MediaQuery.of(context).size.width -
                  130 * constants.rw(context),
              child: _renderOverflowedText(
                text: text,
                textStyle: getStyle(
                  color: color,
                  fontSize: fontSize,
                  weight: FontWeight.w500,
                ),
              ),
            )
          : _renderTextWithoutOverflow(
              text: text,
              textStyle: getStyle(
                color: color,
                fontSize: fontSize,
                weight: FontWeight.w500,
              ),
            ),
    );
  }

  Widget _renderOverflowedText(
      {required String text, required TextStyle textStyle,}) {
    return Marquee(
      text: text,
      style: textStyle,
      crossAxisAlignment: CrossAxisAlignment.start,
      blankSpace: 20.0,
      pauseAfterRound: const Duration(seconds: 1),
      accelerationDuration: const Duration(seconds: 1),
      accelerationCurve: Curves.linear,
      decelerationDuration: const Duration(milliseconds: 500),
      decelerationCurve: Curves.easeOut,
    );
  }

  Widget _renderTextWithoutOverflow(
      {required String text, required TextStyle textStyle,}) {
    return Text(
      text,
      style: textStyle,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  /// If OrderCardWidget has 'view'(showViewAndAmountAndKmText is set true) then this method opens dialog with full order information, otherwise does nothing
  void _orderCardOnTap() {
    if (widget.showViewAndAmountAndKmText) {
      return ShowOrderDialog(
          context: context,
          order: widget.order,
          buttonText: 'OK',
          callback: () => Navigator.pop(context),).showOrderFullInformation();
    }
  }

  void _navigateToMoreInfoPage(OrderInfo orderInfo) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => orderInfo == OrderInfo.comment
              ? CommentView(comment: widget.order.comment ?? '')
              : CarInformationScreen(order: widget.order),),
    );
  }

  bool hasTextOverflow(String text, TextStyle style,
      {double minWidth = 0,
      double maxWidth = double.infinity,
      int maxLines = 1,}) {
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
        return intl.DateFormat('MM/dd/yyyy').format(order.dueDate);
      case OrderInfo.driver:
        final driver = order.driver;
        return driver != null ? driver.firstName! : '';
      case OrderInfo.orderTime:
        return intl.DateFormat('kk:mm').format(order.dueDate);

      case OrderInfo.payment:
        return '\$${order.amount}';
      case OrderInfo.road:
        return order.from;
      case OrderInfo.car:
        final car = order.user?.car;
        return '${car?.make} ${car?.model}';
      case OrderInfo.comment:
        if (order.comment != null) {
          if (order.comment!.length > 20) {
            return '${order.comment!.substring(0, 15)}...';
          }
          return order.comment!;
        }
        return '';
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
      case OrderInfo.comment:
        return SvgPicture.asset(
          'assets/images/comment.svg',
          semanticsLabel: 'Comment',
          width: 15,
        );
      case OrderInfo.car:
        return Transform.scale(
            scale: 1.3,
            child: SvgPicture.asset(
              'assets/images/car.svg',
              semanticsLabel: 'Car Information',
              width: 15,
            ),);
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
      case OrderInfo.comment:
        return 'Comment';
      case OrderInfo.car:
        return 'Car';
    }
  }
}

enum OrderInfo {
  road,
  orderDate,
  orderTime,
  driver,
  payment,
  comment,
  car,
}
