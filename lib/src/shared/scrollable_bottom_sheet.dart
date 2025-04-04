import 'package:flutter_sample_apps/src/constants.dart' as constants;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sample_apps/src/middlewares/connectivity/connectivity.dart';
import 'package:flutter_sample_apps/src/middlewares/extensions/string.dart';
import 'package:flutter_sample_apps/src/middlewares/notifiers/payment_methods.dart';
import 'package:flutter_sample_apps/src/models/order.dart';
import 'package:flutter_sample_apps/src/screens/map_view/comment_view/comment_view.dart';
import 'package:flutter_sample_apps/src/screens/map_view/enums/request_fields.dart';
import 'package:flutter_sample_apps/src/screens/map_view/place_search_view/place_search_view.dart';
import 'package:flutter_sample_apps/src/screens/map_view/select_address_map_view/bloc/main_bloc.dart';
import 'package:flutter_sample_apps/src/screens/map_view/shared/bottom_sheet_size.dart';
import 'package:flutter_sample_apps/src/screens/map_view/shared/rate_widget.dart';
import 'package:flutter_sample_apps/src/screens/map_view/shared/wait_message_widget.dart';
import 'package:flutter_sample_apps/src/screens/profile/payment/payment_methods_adding_screen.dart';
import 'package:flutter_sample_apps/src/shared/btm_sheet_type_extension.dart';
import 'package:flutter_sample_apps/src/shared/card_item.dart';
import 'package:flutter_sample_apps/src/shared/date_time_picker.dart';
import 'package:flutter_sample_apps/src/shared/heights_calculations.dart';
import 'package:flutter_sample_apps/src/shared/inkwell_widget.dart';
import 'package:flutter_sample_apps/src/shared/scrollable_bottom_sheet_bar.dart';
import 'package:flutter_sample_apps/src/shared/svg_icon.dart';
import 'package:flutter_sample_apps/src/shared/widgets_card.dart';
import 'package:flutter_sample_apps/src/style.dart';
import 'package:provider/provider.dart';

class ScrollableBottomSheet extends StatefulWidget {
  const ScrollableBottomSheet({
    required this.bottomSheetSize,
    required this.orderStatus,
    Key? key,
  }) : super(key: key);
  final BottomSheetSize bottomSheetSize;
  final OrderStatus orderStatus;

  @override
  _ScrollableBottomSheetState createState() => _ScrollableBottomSheetState();
}

class _ScrollableBottomSheetState extends State<ScrollableBottomSheet> {
  Map<RequestFields, bool> map = {};
  MainBloc get _mainBloc => BlocProvider.of(context);

  bool enable = true;
  Order get _order => _mainBloc.order;
  String fromStreet = '';
  bool _disableCurrentLocationBtn = false;
  bool _showLoading = false;

  final ValueNotifier<String> _selectedFromAddress = ValueNotifier('');
  final ValueNotifier<bool> _renderBottomSheetBar = ValueNotifier(true);
  double get _errorMessageTextHeight => "Location can't be null"
      .heightOfText(context, getStyle(fontSize: 12, color: Colors.red));
  double get _btnTextHeight =>
      'Request a driver'.heightOfText(context, getStyle(color: Colors.white));
  BottomSheetType get bottomSheetType =>
      widget.orderStatus.getBottomSheetType();

  OrderStatusType get orderStatusType =>
      widget.orderStatus.getOrderStatusType();

  @override
  void initState() {
    super.initState();
    checkOrderStatusAndSetValue();
  }

  @override
  void dispose() {
    super.dispose();
    _selectedFromAddress.dispose();
    _renderBottomSheetBar.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final listViewController = ScrollController();
    return BlocListener<MainBloc, MainState>(
        listener: _listener, child: a(listViewController));
  }

  Widget a(ScrollController listViewController) {
    if (widget.orderStatus == OrderStatus.rate) {
      return RateWidget(
        showLoading: _showLoading,
      );
    } else if (bottomSheetType == BottomSheetType.unconfirmed) {
      return _renderWaitingCard();
    } else {
      return DraggableScrollableSheet(
          initialChildSize: widget.bottomSheetSize.initial,
          maxChildSize: widget.bottomSheetSize.max,
          minChildSize: widget.bottomSheetSize.min,
          builder: (context, scrollController) =>
              _draggableScrollableSheetContent(scrollController));
    }
  }

  Future<void> _listener(context, state) async {
    if (state is NotExistingPaymentMethodsState) {
      final notifier =
          Provider.of<PaymentMethodsNotifier>(context, listen: false);
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ChangeNotifierProvider.value(
                  value: notifier, child: const PaymentMethodsAddingScreen())));
      setState(() {
        _showLoading = false;
      });
    }

    if (state is ExistingPaymentMethodsState) {
      _mainBloc.add(ValidateRequestEvent());
      _showLoading = true;
    }
    if (state is GetCurrentLocationTakenState) {
      _disableCurrentLocationBtn = false;
      _selectedFromAddress.value = state.currentLocationStreet;
    }
    if (state is CheckedRequestState ||
        state is GetStreetState ||
        state is SelectedFromStreetState ||
        state is SelectedToStreetState) {
      _selectedFromAddress.value = _mainBloc.order.from;
      checkValidationResult();
    }

    if (state is CreatingRequestState) {
      enable = false;
      _showLoading = true;
    }

    if (state is CancelingRequestState ||
        state is LoadingDriverState ||
        state is CheckingPaymentMethodsState ||
        state is RatedState) {
      setState(() {
        _showLoading = true;
      });
    }

    if (state is RatingNotValidState) {
      setState(() {
        _showLoading = false;
      });
    }
  }

  Widget _draggableScrollableSheetContent(ScrollController scrollController) {
    List<Widget> _children() {
      if (bottomSheetType == BottomSheetType.rate) {
        return [
          RateWidget(
            showLoading: _showLoading,
          )
        ];
      }
      return _renderScrollableSheetContent(scrollController);
    }

    return Stack(children: _children());
  }

  List<Widget> _renderScrollableSheetContent(
      ScrollController scrollController) {
    return [_renderScrollableContent(scrollController), _renderRequestButton()];
  }

  Widget _renderWaitingCard() {
    return WaitingMessageWidget(
        showLoading: _showLoading,
        getCurrentLocation: () => checkAndGetCurrentLocation());
  }

  Widget _renderScrollableContent(ScrollController scrollController) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: HeightsCalculations.bottomSheetBarHeight(context),
          child: ValueListenableBuilder<bool>(
              valueListenable: _renderBottomSheetBar,
              builder: (context, isRender, child) {
                return ScrollableBottomSheetBar(
                    fabButtonOnTap: () =>
                        checkAndGetCurrentLocation(haveStatus: true));
              }),
        ),
        Expanded(
          child: ListView(
            controller: scrollController,
            physics: const ClampingScrollPhysics(),
            children: [
              _renderRequestData(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _renderRequestButton() {
    return Positioned.fill(
        bottom: 10 * constants.rh(context),
        child: Align(
            alignment: Alignment.bottomCenter,
            child: widget.orderStatus.getButton(context, _mainBloc,
                enable: enable, showLoading: _showLoading)));
  }

  void checkAndGetCurrentLocation({bool haveStatus = false}) {
    return Connection.checker(context,
        onDone: () => _getCurrentLocation(false, haveStatus));
  }

  Widget _renderRequestData() {
    return Container(
      height: HeightsCalculations.scrollableBottomSheetContainerHeight(
        context: context,
        amount: _mainBloc.order.amount,
        bottomSheetType: bottomSheetType,
        orderStatusType: orderStatusType,
        btnTextHeight: _btnTextHeight,
        errorTextHeight: _errorMessageTextHeight,
      ),
      decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10), topRight: Radius.circular(10))),
      child: Column(
        children: [
          _renderOrderStatus(),
          WidgetsCard(
            [
              _renderDriverFnameLname(),
              _renderDriverContact(),
              _renderLocationData(),
              _renderPaymentData(),
            ],
          ),
          _renderRequestDetailsCard()
        ],
      ),
    );
  }

  Widget _renderOrderStatus() {
    return Visibility(
        visible: bottomSheetType == BottomSheetType.withDriverAndStatus,
        child: Container(
          padding: EdgeInsets.all(20 * constants.rw(context)),
          width: double.infinity,
          margin: EdgeInsets.all(10 * constants.rw(context)),
          color: Colors.white,
          child: Text(
            orderStatusType.getString(),
            style: getStyle(color: azureRadianceColor),
            textAlign: TextAlign.center,
          ),
        ));
  }

  Widget _renderDriverFnameLname() {
    return Visibility(
      visible: bottomSheetType != BottomSheetType.none,
      child: CardItem(
        orderStatus: widget.orderStatus,
        order: _mainBloc.order,
        cardTitle: CardTitle.driver,
        withDivider: false,
      ),
    );
  }

  Widget _renderDriverContact() {
    return Visibility(
      visible: bottomSheetType != BottomSheetType.none,
      child: InkWellCard(
        onTap: _driverCall,
        child: CardItem(
          orderStatus: widget.orderStatus,
          order: _mainBloc.order,
          cardTitle: CardTitle.contactDriver,
          withDivider: false,
        ),
      ),
    );
  }

  Widget _renderLocationData() {
    return Row(
      children: [
        SizedBox(
          height: 120 * constants.rw(context),
          width: 20 * constants.rw(context),
          child: const SvgIcon(IconName.destination),
        ),
        Expanded(
            child: Column(children: [
          ValueListenableBuilder<String>(
              valueListenable: _selectedFromAddress,
              builder: (context, position, child) {
                return CardItem(
                  orderStatus: widget.orderStatus,
                  order: _mainBloc.order,
                  isValid: map[RequestFields.from] ?? true,
                  cardTitle: CardTitle.from,
                  onTap: () => _navigateToPlaceSearchViewScreen(),
                );
              }),
          CardItem(
            orderStatus: widget.orderStatus,
            order: _mainBloc.order,
            isValid: map[RequestFields.destination] ?? true,
            cardTitle: CardTitle.destination,
            onTap: () => _navigateToPlaceSearchViewScreen(),
            withDivider: _mainBloc.order.amount != 0,
          ),
        ])),
      ],
    );
  }

  Widget _renderPaymentData() {
    return Visibility(
      visible: _mainBloc.order.amount != 0,
      child: CardItem(
        orderStatus: widget.orderStatus,
        order: _mainBloc.order,
        cardTitle: CardTitle.payment,
        withDivider: false,
      ),
    );
  }

  Widget _renderRequestDetailsCard() {
    return WidgetsCard([
      DateTimePicker(
        disable: _isRequestEditable(),
      ),
      InkWellCard(
        onTap: () => Connection.checker(context,
            onDone: () =>
                _isRequestEditable() ? () {} : _navigateToCommentScreen()),
        child: CardItem(
          orderStatus: widget.orderStatus,
          order: _mainBloc.order,
          cardTitle: CardTitle.comment,
        ),
      ),
    ]);
  }

  /// Get user current location
  Future<void> _getCurrentLocation(
      bool getLocationFromShared, bool haveStatus) async {
    if (!_disableCurrentLocationBtn) {
      _mainBloc
        ..showCurrentLoctaion = true
        ..add(GetCurrentLocationEvent(
            getLocationFromShared: getLocationFromShared,
            haveStatus: haveStatus))
        ..showCurrentLoctaion = true;
      _disableCurrentLocationBtn = true;
    }
  }

  void checkOrderStatusAndSetValue() {
    if (_isRequestEditable()) {
      if (_renderBottomSheetBar.value == true) {
        _renderBottomSheetBar.value = false;
      }
    } else {
      if (_renderBottomSheetBar.value == false) {
        _renderBottomSheetBar.value = true;
      }
    }
  }

  /// Check if from or destination field is empty
  void checkValidationResult() {
    setState(() {
      map[RequestFields.from] =
          !_mainBloc.invalidItems.containsKey(RequestFields.from);

      map[RequestFields.destination] =
          !_mainBloc.invalidItems.containsKey(RequestFields.destination);
    });
  }

  /// Check request data not editable
  bool _isRequestEditable() {
    return widget.orderStatus != OrderStatus.none &&
        widget.orderStatus != OrderStatus.canceled &&
        widget.orderStatus != OrderStatus.fromFinished;
  }

  /// Navigate to comment screen
  void _navigateToCommentScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => BlocProvider.value(
                value: _mainBloc,
                child: const CommentView(),
              )),
    );
  }

  /// Navigate destination or from location select screen
  void _navigateToPlaceSearchViewScreen() {
    if (!_isRequestEditable()) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) {
          return BlocProvider.value(
            value: BlocProvider.of<MainBloc>(context),
            child: const PlaceSearchView(),
          );
        }),
      ).then((value) {
        if (value == null) {
          return;
        }

        if (!value) {
          Future.delayed(const Duration(milliseconds: 500),
              () => Connection.showEntry(context));
        }
      });
    }
  }

  /// This method is for calling to driver
  void _driverCall() {
    final _driver = _order.driver;
    if (_driver != null) {
      final _phoneNumber = _driver.phone;
      constants.launchURL('tel://$_phoneNumber');
    }
  }
}
