import 'package:flutter_sample_apps/src/constants.dart' as constants;
import 'package:flutter_sample_apps/src/middlewares/extensions/datetime.dart';
import 'package:flutter_sample_apps/src/screens/map_view/select_address_map_view/bloc/main_bloc.dart';
import 'package:flutter_sample_apps/src/shared/card_item.dart';
import 'package:flutter_sample_apps/src/shared/inkwell_widget.dart';
import 'package:flutter_sample_apps/src/shared/next_button.dart';
import 'package:flutter_sample_apps/src/style.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DateTimePicker extends StatefulWidget {
  const DateTimePicker({this.disable = false});
  final bool disable;
  @override
  _DateTimePickerState createState() => _DateTimePickerState();
}

class _DateTimePickerState extends State<DateTimePicker> {
  MainBloc get _mainBloc => BlocProvider.of<MainBloc>(context);
  DateTime _selectedDateTime = DateTime.now().get20MinutesLaterRounded();
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MainBloc, MainState>(builder: (context, state) {
      return _renderPicker(context);
    });
  }

  Widget _renderPicker(BuildContext context) {
    return InkWellCard(
        onTap: () => widget.disable == true
            ? null
            : _showPicker(
                context: context,
                child: Material(child: _renderCupertinoDatePicker())),
        child: CardItem(
          order: _mainBloc.order,
          cardTitle: CardTitle.dateTime,
        ));
  }

  Widget _renderCupertinoDatePicker() {
    return SizedBox(
      height: MediaQuery.of(context).size.height / 3 +
          50 +
          15 * constants.rh(context),
      child: Column(
        children: [
          _BottomPicker(
            datePicker: CupertinoDatePicker(
                use24hFormat: true,
                minuteInterval: 10,
                initialDateTime: _initDateTime(),
                backgroundColor: whiteColor,
                minimumDate:
                    _minDateTime().subtract(const Duration(minutes: 5)),
                onDateTimeChanged: (date) {
                  _selectedDateTime = date;
                }),
          ),
          _renderNextButton('OK', () {
            _mainBloc.add(SelectDueDateEvent(dueDate: _selectedDateTime));
            Navigator.pop(context);
          }),
        ],
      ),
    );
  }

  Widget _renderNextButton(
    String text,
    Function() onPress,
  ) {
    return Container(
        margin: EdgeInsets.only(bottom: 15 * constants.rh(context)),
        child: NextButton(
          onPress: onPress,
          text: text,
          textColor: whiteColor,
        ));
  }

  DateTime _minDateTime() {
    return DateTime.now().get20MinutesLaterRounded();
  }

  DateTime _initDateTime() {
    if (_selectedDateTime.difference(_minDateTime()).inMinutes > 0) {
      return _selectedDateTime;
    } else {
      _mainBloc.add(SelectDueDateEvent(dueDate: _minDateTime()));
      return _minDateTime();
    }
  }

  void _showPicker({
    required BuildContext context,
    required Widget child,
  }) {
    final themeData = CupertinoTheme.of(context);
    final dialogBody = CupertinoTheme(
      data: themeData,
      child: child,
    );

    showCupertinoModalPopup<void>(
      barrierColor: codGrayColor.withOpacity(0.2),
      context: context,
      builder: (context) => dialogBody,
    );
  }
}

class _BottomPicker extends StatefulWidget {
  const _BottomPicker({
    required this.datePicker,
  });
  final Widget datePicker;

  @override
  __BottomPickerState createState() => __BottomPickerState();
}

class __BottomPickerState extends State<_BottomPicker> {
  double get _screenHeight => MediaQuery.of(context).size.height;
  double get _bottomPadding => MediaQuery.of(context).viewInsets.bottom;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: _screenHeight / 3 - 15 * constants.rh(context),
      margin: EdgeInsets.only(
        bottom: _bottomPadding,
      ),
      color: CupertinoColors.systemBackground.resolveFrom(context),
      child: DefaultTextStyle(
        style: getStyle(
          color: CupertinoColors.label.resolveFrom(context),
          fontSize: 25,
        ),
        child: InkWell(
          onTap: () {},
          child: SafeArea(
            top: false,
            child: widget.datePicker,
          ),
        ),
      ),
    );
  }
}
