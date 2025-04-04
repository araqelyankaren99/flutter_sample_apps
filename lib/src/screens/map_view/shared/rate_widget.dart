import 'package:flutter_sample_apps/src/constants.dart' as constants;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_sample_apps/src/models/order.dart';
import 'package:flutter_sample_apps/src/screens/map_view/select_address_map_view/bloc/main_bloc.dart';
import 'package:flutter_sample_apps/src/shared/next_button.dart';
import 'package:flutter_sample_apps/src/style.dart';

class RateWidget extends StatefulWidget {
  const RateWidget({required this.showLoading});

  final bool showLoading;

  @override
  _RateWidgetState createState() => _RateWidgetState();
}

class _RateWidgetState extends State<RateWidget> {
  final TextEditingController _controller = TextEditingController();
  double get _keyboardHeight => MediaQuery.of(context).viewInsets.bottom;
  double _rating = 0.0;
  bool get _showLoading => widget.showLoading;
  bool _isVisibleRateWidget = true;
  OrderStatus get orderStatus => _mainBloc.orderStatus;
  MainBloc get _mainBloc => BlocProvider.of<MainBloc>(context);

  @override
  Widget build(BuildContext context) {
    return BlocListener<MainBloc, MainState>(
      listener: _listener,
      child: Visibility(
        visible: _isVisibleRateWidget,
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            color: _isVisibleRateWidget ? whiteColor : Colors.transparent,
            margin: EdgeInsets.only(bottom: _keyboardHeight),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _renderRateCard(),
                _renderStarRating(),
                _renderViewTrip(),
                _renderCommentCard(),
                _renderRatingComment(),
                _renderSubmitButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _listener(context, state) async {
    if (state is ViewTripCloseState) {
      setState(() {
        _isVisibleRateWidget = !_isVisibleRateWidget;
      });
    }
  }

  Widget _renderRateCard() {
    return Stack(
      children: [
        Padding(
          padding: EdgeInsets.only(left: 20 * constants.rw(context)),
          child: _renderCloseIcon(),
        ),
        Column(
          children: [
            const Center(
              child: Padding(
                  padding: EdgeInsets.only(),
                  child: Text(
                    'Rate',
                    style: rateStateTextStyle,
                  )),
            ),
            Padding(
              padding: EdgeInsets.only(
                  top: 10 * constants.rh(context),
                  bottom: 10 * constants.rh(context)),
              child:
                  const Text('Thanks for use drivehop', style: boldTextStyle),
            ),
            Padding(
                padding: EdgeInsets.only(bottom: 10 * constants.rh(context)),
                child: const Text('Rate your Driver', style: labelTextStyle)),
          ],
        ),
      ],
    );
  }

  Widget _renderStarRating() {
    return RatingBar.builder(
      allowHalfRating: true,
      itemPadding:
          EdgeInsets.symmetric(horizontal: 4.0 * constants.rw(context)),
      itemBuilder: (context, _) => const Icon(
        Icons.star,
        color: azureRadianceColor,
      ),
      onRatingUpdate: (rating) {
        setState(() {
          _rating = rating;
        });
      },
    );
  }

  Widget _renderViewTrip() {
    return Padding(
        padding: EdgeInsets.only(
            top: 10 * constants.rh(context),
            bottom: 10 * constants.rh(context)),
        child: InkWell(
          onTap: () {
            setState(() {
              _isVisibleRateWidget = !_isVisibleRateWidget;
            });
            _mainBloc.add(ViewTripEvent());
          },
          child: const Text(
            'View trip',
            style: viewTripBtnTextStyle,
          ),
        ));
  }

  Widget _renderCommentCard() {
    return Padding(
        padding: EdgeInsets.only(
          left: 8 * constants.rw(context),
          bottom: 5 * constants.rh(context),
        ),
        child: const Text(
          'What can we improve?',
          style: boldTextStyle,
        ));
  }

  Widget _renderRatingComment() {
    return Container(
      padding: EdgeInsets.only(
          left: 15 * constants.rw(context),
          right: 15 * constants.rw(context),
          top: 10 * constants.rh(context),
          bottom: 15 * constants.rh(context)),
      child: TextField(
        controller: _controller,
        maxLines: 2,
        cursorColor: azureRadianceColor,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.all(8 * constants.rw(context)),
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          hintText: 'Tell us on how can we improved...',
          hintStyle: getStyle(fontSize: 14),
          filled: true,
          fillColor: greyColor,
        ),
      ),
    );
  }

  Widget _renderSubmitButton() {
    return Padding(
      padding: EdgeInsets.only(bottom: 20 * constants.rh(context)),
      child: NextButton(
          showLoading: _showLoading,
          isActive: _isActiveSubmitButton(),
          onPress: () {
            if (_isActiveSubmitButton()) {
              _mainBloc.add(RateDriverEvent(
                  rating: _rating, comment: _controller.text.trim()));
            }
          },
          text: 'Submit',
          textColor: whiteColor),
    );
  }

  Widget _renderCloseIcon() {
    return InkWell(
      onTap: () {
        _mainBloc.add(RateDriverCloseEvent());
      },
      child: const Icon(
        Icons.close,
        color: azureRadianceColor,
      ),
    );
  }

  bool _isActiveSubmitButton() => _rating != 0.0;
}
