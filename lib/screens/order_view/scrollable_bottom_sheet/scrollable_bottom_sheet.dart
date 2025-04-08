import 'package:flutter_sample_apps/models/order.dart';
import 'package:flutter_sample_apps/screens/order_view/scrollable_bottom_sheet/scroll_height_calculation.dart';
import 'package:flutter_sample_apps/screens/order_view/scrollable_bottom_sheet/widgets/order_info_table.dart';
import 'package:flutter/material.dart';
import 'package:snapping_sheet/snapping_sheet.dart';

class ScrollableBottomSheet extends StatelessWidget {
  const ScrollableBottomSheet(this.order, {Key? key}) : super(key: key);
  final Order order;

  @override
  Widget build(BuildContext context) {
    final listViewController = ScrollController();
    return SnappingSheet(
      lockOverflowDrag: true,
      snappingPositions: [
        SnappingPosition.factor(
          positionFactor: ScrollHeightCalculation.minChildSize(context, order),
        ),
        SnappingPosition.factor(
          positionFactor: ScrollHeightCalculation.maxChildSize(context, order),
        ),
      ],
      sheetBelow: SnappingSheetContent(
        draggable: true,
        childScrollController: listViewController,
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          controller: listViewController,
          child: OrderInfoTable(order: order),
        ),
      ),
    );
  }
}
