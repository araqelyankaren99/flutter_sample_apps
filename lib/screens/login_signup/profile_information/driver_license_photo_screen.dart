import 'dart:io';
import 'package:flutter_sample_apps/constants.dart' as constants;
import 'package:flutter_sample_apps/models/driver.dart';
import 'package:flutter_sample_apps/models/image_item.dart';
import 'package:flutter_sample_apps/screens/login_signup/profile_information/driver_license_photos_bloc/driver_license_photos_bloc.dart';
import 'package:flutter_sample_apps/screens/login_signup/profile_information/driver_license_photos_bloc/driver_license_photos_event.dart';
import 'package:flutter_sample_apps/screens/login_signup/profile_information/driver_license_photos_bloc/driver_license_photos_state.dart';
import 'package:flutter_sample_apps/screens/login_signup/profile_information/user_info_bloc/user_info_bloc.dart';
import 'package:flutter_sample_apps/screens/login_signup/profile_information/user_info_bloc/user_info_event.dart';
import 'package:flutter_sample_apps/screens/login_signup/shared/profile_information/photo_card.dart';
import 'package:flutter_sample_apps/shared/app_bar_widget.dart';
import 'package:flutter_sample_apps/shared/next_button.dart';
import 'package:flutter_sample_apps/style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DriverLicensePhotosScreen extends StatefulWidget {
  const DriverLicensePhotosScreen(
      {required this.driver,
      required this.controller,
      required this.isEnable,
      this.isDownLoaded = false,});
  final Driver driver;
  final TextEditingController controller;
  final bool isDownLoaded;
  final bool isEnable;
  @override
  State<StatefulWidget> createState() => _DriverLicensePhotosScreenState();
}

class _DriverLicensePhotosScreenState extends State<DriverLicensePhotosScreen> {
  Driver get _driver => widget.driver;
  DriverLicensePhotoBloc get _driverLicensePhotoBloc =>
      BlocProvider.of<DriverLicensePhotoBloc>(context);
  UserInfoBloc get _userInfoBloc => BlocProvider.of<UserInfoBloc>(context);
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<DriverLicensePhotoBloc>.value(
        value: _driverLicensePhotoBloc,
        child: BlocBuilder<DriverLicensePhotoBloc, DriverLicensePhotoState>(
            builder: (context, state) {
          return _render();
        },),);
  }

  Widget _render() {
    return WillPopScope(
      onWillPop: () async => true,
      child: Scaffold(
        body: SafeArea(
          top: false,
          child: _renderFieldOnScreen(),
        ),
      ),
    );
  }

  Widget _renderFieldOnScreen() {
    return Stack(
      children: [
        _renderAppBarWidget(),
        _renderPhotoLists(),
        _renderSaveButton(),
      ],
    );
  }

  Widget _renderAppBarWidget() {
    return SafeArea(
      child: AppBarWidget(
        titleText: 'Upload Image',
        titleStyle: getStyle(
            color: codGrayColor, fontSize: 20, weight: FontWeight.w500,),
        prefixWidget: _renderBackIcon(),
      ),
    );
  }

  Widget _renderBackIcon() {
    return InkWell(
      onTap: _onTapBackIcon,
      child: const Icon(
        Icons.arrow_back,
        color: azureRadianceColor,
      ),
    );
  }

  Widget _renderPhotoLists() {
    return Container(
        margin: EdgeInsets.symmetric(horizontal: 25 * constants.rw(context)),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          _renderPhotoFields(text: 'Driving License'),
        ],),);
  }

  Widget _renderPhotoFields(
      {required String text, EdgeInsets padding = EdgeInsets.zero,}) {
    const frontType = PhotoType.driverLicenseFront;
    const backType = PhotoType.driverLicenseBack;
    return Container(
        margin: padding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _renderText(text),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                PhotoCard(
                    photoType: frontType,
                    photo: _getPhoto(photoType: frontType),
                    onTapDelete: () => _onTapDelete(frontType),
                    onTapAddPhoto: () => _onTapAddPhoto(frontType),),
                PhotoCard(
                    photoType: backType,
                    photo: _getPhoto(photoType: backType),
                    onTapDelete: () => _onTapDelete(backType),
                    onTapAddPhoto: () => _onTapAddPhoto(backType),),
              ],
            ),
          ],
        ),);
  }

  Widget _renderSaveButton() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: NextButton(
        absorbing: !_isActiveSaveButton(),
        isActive: _isActiveSaveButton(),
        text: 'Save',
        textColor: whiteColor,
        onPress: _onTapSaveButton,
      ),
    );
  }

  Widget _renderText(String text) {
    return Padding(
        padding: EdgeInsets.only(bottom: 15 * constants.rh(context)),
        child: Row(
          children: [
            Text(
              text,
              style: getStyle(
                  color: blackColor, weight: FontWeight.w500, fontSize: 18,),
            )
          ],
        ),);
  }

  /// Return file if list is not empty else null
  File? _getPhoto({required PhotoType photoType}) {
    final photos = _driverLicensePhotoBloc.licensePhoto;
    return photos[photoType.typeName()];
  }

  bool _isActiveSaveButton() {
    return _driverLicensePhotoBloc.licensePhoto.length == 2 && widget.isEnable;
  }

  void _onTapBackIcon() {
    _driverLicensePhotoBloc.add(UnsaveDriverLicenseChangesEvent(
        driverLicensePhotos: _driver.drivingLicensePhotos ?? {},),);

    Navigator.pop(context);
  }

  void _onTapSaveButton() {
    _driver.drivingLicensePhotos = {};
    _driver.drivingLicensePhotos?.addAll(_driverLicensePhotoBloc.licensePhoto);

    _userInfoBloc.add(DriverValidationEvent(driver: _driver));
    if (_driver.drivingLicensePhotos?.length == 2) {
      widget.controller.text = 'Your documents is added';
    } else {
      widget.controller.clear();
    }
    Navigator.pop(context);
  }

  void _onTapDelete(PhotoType photoType) {
    if (widget.isEnable) {
      _driverLicensePhotoBloc
          .add(DeleteLicensePhotoEvent(photoType: photoType));
    }
  }

  void _onTapAddPhoto(PhotoType photoType) {
    _driverLicensePhotoBloc.add(OpenCameraEvent(photoType: photoType));
  }
}
