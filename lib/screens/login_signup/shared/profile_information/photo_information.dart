import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_sample_apps/constants.dart' as constants;
import 'package:flutter_sample_apps/models/driver.dart';
import 'package:flutter_sample_apps/screens/login_signup/profile_information/screen_bloc_type.dart';
import 'package:flutter_sample_apps/screens/login_signup/profile_information/sign_up_bloc/sign_up_bloc.dart';
import 'package:flutter_sample_apps/screens/login_signup/profile_information/user_info_bloc/user_info_bloc.dart';
import 'package:flutter_sample_apps/screens/login_signup/profile_information/user_info_bloc/user_info_event.dart';
import 'package:flutter_sample_apps/screens/login_signup/profile_information/user_info_bloc/user_info_state.dart';
import 'package:flutter_sample_apps/screens/profile/profile_drawer/profile_drawer_bloc/profile_information_bloc.dart';
import 'package:flutter_sample_apps/shared/app_bar_widget.dart';
import 'package:flutter_sample_apps/style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PhotoInformation extends StatefulWidget {
  const PhotoInformation({
    required this.screenBlocType,
    required this.driver,
  });
  final ScreenBlocType screenBlocType;
  final Driver driver;

  @override
  _PhotoInformationState createState() => _PhotoInformationState();
}

class _PhotoInformationState extends State<PhotoInformation> {
  File _image = File('');
  late UserInfoBloc _userInfoBloc;

  SignUpBloc? signUpBloc;
  ProfileInformationBloc? profileInformationBloc;
  @override
  void initState() {
    super.initState();
    _initialize();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<UserInfoBloc>.value(
      value: _userInfoBloc,
      child: BlocListener<UserInfoBloc, UserInfoState>(
        listener: _listener,
        child: BlocBuilder<UserInfoBloc, UserInfoState>(
          builder: (context, state) {
            return _render(state: state);
          },
        ),
      ),
    );
  }

  Widget _render({required UserInfoState state}) {
    return Container(
      height: MediaQuery.of(context).size.height * 1 / 3,
      alignment: Alignment.topCenter,
      decoration: BoxDecoration(
          color: blackColor,
          borderRadius: BorderRadius.only(
              bottomRight: Radius.circular(20 * constants.rw(context)),
              bottomLeft: Radius.circular(20 * constants.rw(context)),),),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: _renderAppBar(),
          ),
          Column(
            children: [
              _renderProfilePhoto(),
              _renderTextButton(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _renderAppBar() {
    return SafeArea(
      child: AppBarWidget(
        prefixWidget:
            widget.screenBlocType == ScreenBlocType.profileInformationBloc
                ? _renderCancelButton()
                : null,
        titleText: 'Profile Information',
        titleStyle: getStyle(
          color: whiteColor,
          fontSize: 20,
          weight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _renderProfilePhoto() {
    return GestureDetector(
      onTap: _onAddPhoto,
      child: Container(
        decoration:
            const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(70.0 * constants.rw(context)),
          child: _image.path != ''
              ? Image.file(
                  _image,
                  height: 110 * constants.rw(context),
                  width: 110 * constants.rw(context),
                  fit: BoxFit.cover,
                )
              : Image.asset(
                  'assets/images/profile_default_image.png',
                  height: 110 * constants.rw(context),
                  width: 110 * constants.rw(context),
                ),
        ),
      ),
    );
  }

  Widget _renderTextButton() {
    Color _color() {
      if (widget.screenBlocType == ScreenBlocType.profileInformationBloc) {
        return spunPearlColor;
      }
      if (_image.path != '') {
        return spunPearlColor;
      }
      if (widget.driver.profileImageBytes != null) {
        return spunPearlColor;
      }

      return redColor;
    }

    return TextButton(
      onPressed: _onAddPhoto,
      child: Text(
        widget.screenBlocType == ScreenBlocType.signUpBloc
            ? 'Add photo'
            : 'Profile photo',
        style: getStyle(color: _color(), fontSize: 12, weight: FontWeight.w500),
      ),
    );
  }

  Widget _renderCancelButton() {
    return InkWell(
      onTap: () => Navigator.pop(context),
      child: const Icon(
        Icons.arrow_back_ios_rounded,
        color: Colors.white,
      ),
    );
  }

  void _onAddPhoto() {
    FocusScope.of(context).unfocus();
    _userInfoBloc
      ..add(DriverValidationEvent(driver: widget.driver))
      ..add(AddPhotoEvent());
  }

  void _listener(BuildContext context, state) {
    if (state is AddingPhotoState) {
      _showPicker(context);
    }

    if (state is UnselectedImageState) {
      Navigator.of(context).pop();
    }

    if (state is AddedPhotoState) {
      _image = state.image;
      widget.driver.profileImage = _image;
      _userInfoBloc.add(DriverValidationEvent(driver: widget.driver));
      if (!state.isDownLoaded) {
        Navigator.of(context).pop();
      }
    }
  }

  Future<void> _showPicker(BuildContext context) async {
    showModalBottomSheet(
            context: context,
            builder: (BuildContext bc) {
              return SafeArea(
                child: SizedBox(
                  child: Wrap(
                    children: <Widget>[
                      _listTitle('Photo Library',
                          direction: PhotoDirection.gallery,
                          leading: const Icon(Icons.photo_library),),
                      _listTitle('Camera',
                          direction: PhotoDirection.camera,
                          leading: const Icon(Icons.photo_camera),),
                    ],
                  ),
                ),
              );
            },)
        .whenComplete(() =>
            _userInfoBloc.add(DriverValidationEvent(driver: widget.driver)),);
  }

  Future<void> _initialize() async {
    _userInfoBloc = BlocProvider.of<UserInfoBloc>(context);
    if (widget.screenBlocType == ScreenBlocType.signUpBloc) {
      signUpBloc = BlocProvider.of<SignUpBloc>(context);
    }
    final bytes = widget.driver.profileImageBytes;
    if (bytes != null) {
      _userInfoBloc.add(DownLoadImage(bytes: bytes));
    }
  }

  File createFileFromBytes(Uint8List bytes) => File.fromRawPath(bytes);

  Widget _listTitle(String text,
      {required PhotoDirection direction, required Icon leading,}) {
    return ListTile(
        leading: leading,
        title: Text(text),
        onTap: () {
          _userInfoBloc.add(ChoosePhotoEvent(direction: direction));
        },);
  }
}

enum PhotoDirection { gallery, camera }
