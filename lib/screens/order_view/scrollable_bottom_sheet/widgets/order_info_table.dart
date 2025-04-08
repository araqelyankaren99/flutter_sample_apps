import 'package:flutter_sample_apps/constants.dart' as constants;
import 'package:flutter_sample_apps/models/order.dart';
import 'package:flutter_sample_apps/screens/order_view/scrollable_bottom_sheet/scroll_height_calculation.dart';
import 'package:flutter_sample_apps/screens/order_view/scrollable_bottom_sheet/widgets/icon_cell.dart';
import 'package:flutter_sample_apps/screens/order_view/scrollable_bottom_sheet/widgets/order_info_cell.dart';
import 'package:flutter_sample_apps/style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sms/flutter_sms.dart';

class OrderInfoTable extends StatelessWidget {
  const OrderInfoTable({required this.order});
  final Order order;

  /// This method is for calling to client
  void _userCall() {
    final user = order.user;
    if (user != null) {
      final phoneNumber = user.phone;
      if (phoneNumber != null) {
        if (phoneNumber.isNotEmpty) {
          constants.launchURL('tel://$phoneNumber');
        }
      }
    }
  }

  /// This method is for send message to client
  void _userMessage() {
    final user = order.user;
    if (user != null) {
      final phoneNumber = user.phone;
      if (phoneNumber != null) {
        if (phoneNumber.isNotEmpty) {
          _sendSMS('', [phoneNumber]);
        }
      }
    }
  }

  Future<void> _sendSMS(String message, List<String> recipents) async {
    await sendSMS(message: message, recipients: recipents)
        .catchError((onError) {
      debugPrint(onError.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
        ),
        margin: EdgeInsets.all(5.0 * constants.rh(context)),
        child: Table(
          columnWidths: {
            0: FixedColumnWidth(50.0 * constants.rw(context)),
            1: const FlexColumnWidth(7),
          },
          defaultColumnWidth: const FixedColumnWidth(120.0),
          children: [
            TableRow(children: [
              const IconCell(
                iconName: IconName.destination,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  OrderInfoCell(
                    labelTitle: 'From',
                    orderInfo: order.from,
                  ),
                  OrderInfoCell(
                    labelTitle: 'Destination',
                    orderInfo: order.destination,
                  )
                ],
              ),
            ],),
          ],
        ),
      ),
      Container(
        height: ScrollHeightCalculation.tableMinHeight1(context, order),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
        ),
        margin: EdgeInsets.all(5.0 * constants.rh(context)),
        child: Table(
          columnWidths: {
            0: FixedColumnWidth(50.0 * constants.rw(context)),
            1: const FlexColumnWidth(7),
          },
          defaultColumnWidth: const FixedColumnWidth(120.0),
          children: [
            TableRow(children: [
              const IconCell(
                iconName: IconName.payment,
              ),
              OrderInfoCell(
                labelTitle: 'Payment',
                orderInfo: '\$${order.amount}',
              )
            ],),
            TableRow(
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: blackHazeColor),
                  ),
                ),
                children: [
                  const IconCell(
                    iconName: IconName.phone,
                  ),
                  OrderInfoCell(
                    onTap: _userCall,
                    text: 'Call',
                  )
                ],),
            TableRow(children: [
              const IconCell(iconName: IconName.calendar),
              OrderInfoCell(
                onTap: _userMessage,
                text: 'Message',
              )
            ],),
          ],
        ),
      )
    ],);
  }
}
