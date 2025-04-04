import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sample_apps/src/screens/map_view/select_address_map_view/bloc/main_bloc.dart';
import 'package:flutter_sample_apps/src/shared/alert_widget.dart';
import 'package:flutter_sample_apps/src/shared/next_button.dart';
import 'package:flutter_sample_apps/src/shared/scrollable_bottom_sheet_bar.dart';
import 'package:flutter_sample_apps/src/style.dart';
import 'package:progress_indicators/progress_indicators.dart';

class WaitingMessageWidget extends StatefulWidget {
  const WaitingMessageWidget(
      {required this.showLoading, required this.getCurrentLocation});

  final bool showLoading;
  final VoidCallback getCurrentLocation;

  @override
  _WaitingMessageWidgetState createState() => _WaitingMessageWidgetState();
}

class _WaitingMessageWidgetState extends State<WaitingMessageWidget> {
  bool get _showLoading => widget.showLoading;
  MainBloc get _mainBloc => BlocProvider.of<MainBloc>(context);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MainBloc, MainState>(builder: (context, state) {
      return Align(
          alignment: Alignment.bottomCenter,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            ScrollableBottomSheetBar(
                hideTriangle: true,
                fabButtonOnTap: () => widget.getCurrentLocation()),
            Container(
              height: MediaQuery.of(context).size.height / 3,
              color: whiteColor,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _renderMessageText(),
                  _renderWaitingMessageText(),
                  _renderCancelButton(state)
                ],
              ),
            )
          ]));
    });
  }

  Widget _renderMessageText() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 50),
      child: Column(
        children: const [
          Text('The driver will be', style: requestWaitingStateTextStyle),
          Text('taking your order', style: requestWaitingStateTextStyle),
          Text('soon.', style: requestWaitingStateTextStyle),
        ],
      ),
    );
  }

  Widget _renderWaitingMessageText() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('Please wait', style: requestWaitingStateSubtextStyle),
        JumpingText('...', style: requestWaitingStateSubtextStyle)
      ],
    );
  }

  Widget _renderCancelButton(MainState state) {
    return NextButton(
        absorbing: state is CancelingRequestState,
        showLoading: _showLoading,
        onPress: _onPressNextButton,
        text: 'Cancel',
        textColor: whiteColor);
  }

  /// This function call when press the NextButton
  void _onPressNextButton() {
    AlertWidget.showConfirmAlertDialog(context,
        title: 'Are you sure you want to cancel your order?',
        accept: 'Yes',
        cancel: 'No ', onAcceptAction: () {
      _mainBloc.add(CancelOrderEvent(order: _mainBloc.order));
      Navigator.pop(context);
    });
  }
}
