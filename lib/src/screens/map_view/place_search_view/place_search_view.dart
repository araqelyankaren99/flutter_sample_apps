import 'package:flutter_google_places_sdk/flutter_google_places_sdk.dart';
import 'package:flutter_sample_apps/src/constants.dart' as constants;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sample_apps/src/middlewares/connectivity/connectivity.dart';
import 'package:flutter_sample_apps/src/models/order.dart';
import 'package:flutter_sample_apps/src/screens/map_view/select_address_map_view/bloc/main_bloc.dart';
import 'package:flutter_sample_apps/src/shared/address_text_field.dart';
import 'package:flutter_sample_apps/src/shared/app_bar_widget.dart';
import 'package:flutter_sample_apps/src/style.dart';
import 'package:flutter_svg/svg.dart';

class PlaceSearchView extends StatefulWidget {
  const PlaceSearchView({Key? key}) : super(key: key);

  @override
  State<PlaceSearchView> createState() => _PlaceSearchViewState();
}

class _PlaceSearchViewState extends State<PlaceSearchView> {
  MainBloc get _mainBloc => BlocProvider.of<MainBloc>(context);
  Order get _request => _mainBloc.order;
  List places = [];
  bool destinationTextFieldChanged = false;
  AutocompletePrediction? _selectedFromPlace;
  AutocompletePrediction? _selectedToPlace;
  final FocusNode _focusFrom = FocusNode();
  final FocusNode _focusDestination = FocusNode();
  late FlutterGooglePlacesSdk _googlePlace;
  final TextEditingController _fromController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  @override
  void initState() {
    super.initState();
    _googlePlace = FlutterGooglePlacesSdk(constants.apiKey);
    _configListeners();
  }

  @override
  void dispose() {
    _fromController.dispose();
    _destinationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: blackHazeColor,
      body: BlocListener<MainBloc, MainState>(
          listener: _listener, child: _renderScreen()),
    );
  }

  Future<void> _listener(context, state) async {
    if (state is AutoCompleteSearchState) {
      setState(() {
        places = state.predictions ?? [];
      });
    }
  }

  Widget _renderScreen() {
    return SafeArea(
        child: Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(children: [
        _renderAppBar(),
        Container(
          margin: EdgeInsets.only(
              bottom: 40 * constants.rh(context),
              top: 20 * constants.rh(context)),
          child: Column(
            children: [
              _renderForm(),
            ],
          ),
        ),
        Expanded(
            child: Padding(
          padding:
              EdgeInsets.symmetric(horizontal: 20.0 * constants.rw(context)),
          child: ListView.separated(
              physics: const ClampingScrollPhysics(),
              padding: EdgeInsets.only(
                left: 15 * constants.rw(context),
              ),
              itemCount: places.length,
              itemBuilder: (BuildContext context, int index) {
                return _renderTextItem(
                  places[index],
                );
              },
              separatorBuilder: (BuildContext context, int index) => SizedBox(
                    height: 15 * constants.rh(context),
                  )),
        ))
      ]),
    ));
  }

  Widget _renderAppBar() {
    return AppBarWidget(
        titleText: 'Destination',
        titleStyle: appBarTitleStyle,
        prefixWidget: Padding(
          padding: EdgeInsets.fromLTRB(
              1 * constants.rw(context),
              17 * constants.rh(context),
              17 * constants.rw(context),
              17 * constants.rh(context)),
          child: InkWell(
              onTap: () => _onCancel(),
              child: const Text('Cancel', style: appBarNavBtnStyle)),
        ),
        suffixWidget: Padding(
          padding: EdgeInsets.fromLTRB(
              17 * constants.rw(context),
              17 * constants.rh(context),
              1 * constants.rw(context),
              17 * constants.rh(context)),
          child: InkWell(
              onTap: () => _onDone(),
              child: const Text('Done', style: appBarNavBtnStyle)),
        ));
  }

  Widget _renderForm() {
    return Card(
      elevation: 0,
      child: Container(
        padding: EdgeInsets.symmetric(
            horizontal: 20 * constants.rw(context),
            vertical: 20 * constants.rh(context)),
        child: Row(
          children: [
            Padding(
              padding: EdgeInsets.only(right: 10.0 * constants.rw(context)),
              child: SvgPicture.asset(
                'assets/images/destination.svg',
              ),
            ),
            Expanded(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    AddressTextField(
                      focusNode: _focusFrom,
                      controller: _fromController,
                      labelText: 'From',
                      onChanged: _onChangedFrom,
                    ),
                    AddressTextField(
                      focusNode: _focusDestination,
                      controller: _destinationController,
                      onChanged: _onChangedDestination,
                      labelText: 'Destination',
                    )
                  ],),
            )
          ],
        ),
      ),
    );
  }

  Widget _renderTextItem(AutocompletePrediction place) {
    return GestureDetector(
      onTap: () {
        if (destinationTextFieldChanged) {
          _destinationController.text = place.fullText ?? '';

          final val = TextSelection.collapsed(
              offset: _destinationController.text.length);
          _destinationController.selection = val;
          _selectedToPlace = place;
        } else {
          _fromController.text = place.fullText ?? '';

          final val =
              TextSelection.collapsed(offset: _fromController.text.length);
          _fromController.selection = val;

          _selectedFromPlace = place;
        }
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 15 * constants.rh(context)),
        child: Row(children: [
          Padding(
            padding: EdgeInsets.only(right: 10.0 * constants.rw(context)),
            child: SvgPicture.asset('assets/images/pin.svg'),
          ),
          Expanded(
              child:
                  Text(place.fullText ?? '', style: requestTextFieldsStyle))
        ]),
      ),
    );
  }

  /// Back to MapView screen
  void _onCancel() {
    Navigator.pop(context, true);
  }

  /// Back to MapView screen and set selected place
  void _onDone() {
    if (_selectedToPlace != null) {
      _mainBloc.add(SelectToStreetEvent(
          toStreet: _selectedToPlace ?? AutocompletePrediction(distanceMeters:0, placeId: '', primaryText: '', secondaryText: '', fullText: '' )));
    } else if (_destinationController.text.isEmpty) {
      _mainBloc.add(const ChangeOrderDestinationEvent(isFrom: false));
    }
    if (_selectedFromPlace != null) {
      _mainBloc.add(SelectFromStreetEvent(
          fromStreet: _selectedFromPlace ?? AutocompletePrediction(distanceMeters:0, placeId: '', primaryText: '', secondaryText: '', fullText: '' )));
    } else if (_fromController.text.isEmpty) {
      _mainBloc.add(const ChangeOrderDestinationEvent(isFrom: true));
    }
    Connection().check().then((value) => Navigator.pop(context, value));
  }

  /// Listen change of focus
  void _configListeners() {
    _focusFrom.addListener(_onFocusChangeFrom);
    _focusDestination.addListener(_onFocusChangeDestination);
    _fromController.text = _request.from;
    _destinationController.text = _request.destination;
  }

  /// Check current focused textfield for set correct address
  void _onFocusChangeFrom() {
    if (_focusFrom.hasFocus) {
      destinationTextFieldChanged = false;
      _mainBloc.add(AutoCompleteSearchEvent(
          googlePlace: _googlePlace, placeName: _fromController.text));
    }
  }

  /// Check current focused textfield for set correct address
  void _onFocusChangeDestination() {
    if (_focusDestination.hasFocus) {
      destinationTextFieldChanged = true;
      _mainBloc.add(AutoCompleteSearchEvent(
          googlePlace: _googlePlace, placeName: _destinationController.text));
    }
  }

  /// Search address by inputted string
  void _onChangedFrom(String placeName) {
    _onFocusChangeFrom();
    _search(placeName);
  }

  /// Search address by inputted string
  void _onChangedDestination(String placeName) {
    _onFocusChangeDestination();
    _search(placeName);
  }

  /// Add event
  void _search(String placeName) {
    _mainBloc.add(AutoCompleteSearchEvent(
        googlePlace: _googlePlace, placeName: placeName));
  }
}
