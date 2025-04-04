import 'package:flutter_sample_apps/src/constants.dart' as constants;
import 'package:flutter_sample_apps/src/models/faq.dart';
import 'package:flutter_sample_apps/src/screens/profile/shared/expansion_item.dart';
import 'package:flutter_sample_apps/src/style.dart';
import 'package:flutter/material.dart';

class ExpansionWidget extends StatefulWidget {
  const ExpansionWidget({required this.item, this.onExpansionChanged});

  final ExpansionItem item;
  final Function(bool)? onExpansionChanged;

  @override
  _ExpansionWidgetState createState() => _ExpansionWidgetState();
}

class _ExpansionWidgetState extends State<ExpansionWidget> {
  ExpansionItem get _expansionItem => widget.item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          10 * constants.rw(context),
          _expansionItem.expansionType == ExpansionType.email
              ? 60 * constants.rh(context)
              : 10 * constants.rh(context),
          10 * constants.rw(context),
          10 * constants.rh(context)),
      child: _renderExpansionTile(),
    );
  }

  Widget _renderExpansionTile() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10.0 * constants.rw(context)),
      child: ExpansionTile(
        childrenPadding:
            (_expansionItem.expansionType == ExpansionType.question)
                ? EdgeInsets.all(10 * constants.rw(context))
                : EdgeInsets.zero,
        collapsedBackgroundColor: Colors.white,
        backgroundColor: Colors.white,
        onExpansionChanged: (isExpanded) {
          if (widget.onExpansionChanged != null) {
            widget.onExpansionChanged?.call(isExpanded);
          }
        },
        trailing: _renderTrailing(),
        tilePadding: EdgeInsets.only(
            left: 30 * constants.rw(context),
            right: 20 * constants.rw(context)),
        title: _renderTitle(),
        children: (_expansionItem.expansionType == ExpansionType.question)
            ? [_renderExpansionTileChild()]
            : [],
      ),
    );
  }

  Widget _renderTitle() {
    return Text(
      _expansionItem.expansionType._title(_expansionItem.faq),
      style: getStyle(
        color: _expansionItem.expansionType._textColor(),
        fontSize: 14,
        weight: FontWeight.w500,
      ),
    );
  }

  Widget _renderExpansionTileChild() {
    return ListTile(
      title: _renderChildTitle(),
    );
  }

  Widget _renderChildTitle() {
    return Text(
      _expansionItem.expansionType._body(_expansionItem.faq) ?? '',
      style: getStyle(
        color: Colors.grey,
        weight: FontWeight.w500,
        fontSize: 12,
      ),
    );
  }

  Widget _renderTrailing() {
    return RotatedBox(
      quarterTurns: (_expansionItem.expansionType == ExpansionType.question &&
              _expansionItem.isClicked)
          ? 45
          : 0,
      child: Icon(
        Icons.arrow_forward_ios_sharp,
        color: _expansionItem.expansionType == ExpansionType.logOut
            ? Colors.transparent
            : Colors.grey,
        size: 20,
      ),
    );
  }

  /// This method changes isExpanded state
  void onExpansionChange({required bool isExpanded}) {
    setState(() {
      _expansionItem.isClicked = isExpanded;
    });
  }
}

extension _ExpansionTypeAddition on ExpansionType {
  Color _textColor() {
    switch (this) {
      case ExpansionType.logOut:
        return Colors.red;
      default:
        return codGrayColor;
    }
  }

  String _title(FAQ? faq) {
    switch (this) {
      case ExpansionType.changePhoneNumber:
        return 'Change phone number';
      case ExpansionType.aboutApp:
        return 'About application';
      case ExpansionType.email:
        return 'support@drivehop.com';
      case ExpansionType.question:
        return faq != null ? faq.question : '';
      case ExpansionType.language:
        return 'Language';
      case ExpansionType.logOut:
        return 'Log out';
    }
  }

  String? _body(FAQ? faq) {
    switch (this) {
      case ExpansionType.question:
        return faq != null ? faq.answer : '';
      default:
        return null;
    }
  }
}
