import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class IconCell extends StatelessWidget {
  const IconCell({required this.iconName});
  final IconName iconName;

  @override
  Widget build(BuildContext context) {
    return TableCell(
        verticalAlignment: TableCellVerticalAlignment.middle,
        child: SvgPicture.asset(iconName._getSvgImagePath()),);
  }
}

enum IconName {
  search,
  pin,
  driver,
  phone,
  destination,
  payment,
  comment,
  calendar,
}

extension _IconNameAddition on IconName {
  String _getSvgImagePath() {
    switch (this) {
      case IconName.search:
        return 'assets/images/search.svg';
      case IconName.pin:
        return 'assets/images/pin.svg';
      case IconName.driver:
        return 'assets/images/driver.svg';
      case IconName.phone:
        return 'assets/images/phone.svg';
      case IconName.destination:
        return 'assets/images/destination.svg';
      case IconName.payment:
        return 'assets/images/payment.svg';
      case IconName.comment:
        return 'assets/images/comment.svg';
      case IconName.calendar:
        return 'assets/images/calendar.svg';
    }
  }
}
