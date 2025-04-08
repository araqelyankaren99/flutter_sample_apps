import 'package:flutter_sample_apps/constants.dart' as constants;
import 'package:flutter_sample_apps/models/order.dart';
import 'package:flutter_sample_apps/models/user.dart';
import 'package:flutter_sample_apps/screens/login_signup/shared/profile_information/txt_field_wih_icon.dart';
import 'package:flutter_sample_apps/shared/app_bar_widget.dart';
import 'package:flutter_sample_apps/style.dart';
import 'package:flutter/material.dart';

class CarInformationScreen extends StatefulWidget {
  const CarInformationScreen({required this.order});
  final Order order;

  @override
  _CarInformationScreenState createState() => _CarInformationScreenState();
}

class _CarInformationScreenState extends State<CarInformationScreen> {
  User? get _user => widget.order.user;

  @override
  Widget build(BuildContext context) {
    return _render();
  }

  Widget _render() {
    return _renderFieldOnScreen();
  }

  Widget _renderFieldOnScreen() {
    return GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Container(
            color: whiteColor,
            child: Scaffold(
                resizeToAvoidBottomInset: false,
                backgroundColor: blackHazeColor,
                body: Column(
                  children: [
                    Expanded(
                      child: _renderAppBar(),
                    ),
                    Flexible(
                      flex: 7,
                      child: _renderFields(),
                    ),
                  ],
                ),),),);
  }

  Widget _renderAppBar() {
    return Container(
        color: whiteColor,
        child: SafeArea(
            bottom: false,
            child: AppBarWidget(
              titleText: 'Car Information',
              prefixWidget: Padding(
                padding: EdgeInsets.symmetric(
                    vertical: constants.rh(context),
                    horizontal: constants.rw(context),),
                child: InkWell(
                    onTap: () => Navigator.pop(context),
                    child: const Text('Cancel', style: appBarNavBtnStyle),),
              ),
              titleStyle: getStyle(
                  color: codGrayColor, fontSize: 20, weight: FontWeight.w500,),
              decoration: BoxDecoration(
                  color: whiteColor,
                  borderRadius: BorderRadius.only(
                      bottomRight: Radius.circular(20 * constants.rw(context)),
                      bottomLeft: Radius.circular(20 * constants.rw(context)),),),
            ),),);
  }

  Widget _renderFields() {
    return Container(
        margin: EdgeInsets.symmetric(vertical: 10 * constants.rh(context)),
        decoration: BoxDecoration(
            color: whiteColor,
            borderRadius: BorderRadius.all(
              Radius.circular(20 * constants.rw(context)),
            ),),
        child: SafeArea(child: _renderTextFields()),);
  }

  Widget _renderTextFields() {
    return SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Column(
          children: [
            _renderTextField(carInfoType: CarInfoType.carMake),
            _renderTextField(carInfoType: CarInfoType.model),
            _renderTextField(carInfoType: CarInfoType.transmissionType),
            _renderTextField(carInfoType: CarInfoType.licensePlateNumber),
          ],
        ),);
  }

  Widget _renderTextField({
    required CarInfoType carInfoType,
  }) {
    return AbsorbPointer(
        child: TxtFieldWithIcon(
            initialValue: _infoText(carInfoType),
            prefixWidgets: carInfoType._image(),
            label: carInfoType._labeltext(),
            enabled: false,
            padding:
                EdgeInsets.symmetric(vertical: 5 * constants.rh(context)),),);
  }

  String? _infoText(CarInfoType carInfoType) {
    switch (carInfoType) {
      case CarInfoType.carMake:
        return _user?.car?.make;
      case CarInfoType.model:
        return _user?.car?.model;
      case CarInfoType.transmissionType:
        return _user?.car?.transmissionType;
      case CarInfoType.licensePlateNumber:
        return _user?.plateNumber;
    }
  }
}

enum CarInfoType {
  carMake,
  model,
  transmissionType,
  licensePlateNumber,
}

extension _CarnfoTypeAddition on CarInfoType {
  String _labeltext() {
    switch (this) {
      case CarInfoType.carMake:
        return 'Car Make';
      case CarInfoType.model:
        return 'Model';
      case CarInfoType.transmissionType:
        return 'Transmission Type';
      case CarInfoType.licensePlateNumber:
        return 'License Plate Number';
    }
  }

  Image _image() {
    switch (this) {
      case CarInfoType.carMake:
        return Image.asset('assets/images/car.png');
      case CarInfoType.model:
        return Image.asset('assets/images/cube.png');
      case CarInfoType.transmissionType:
        return Image.asset('assets/images/transmission.png');
      case CarInfoType.licensePlateNumber:
        return Image.asset('assets/images/calendar.png');
    }
  }
}

enum BottomSheetInfoType { carMake, carModel, transmissionType }
