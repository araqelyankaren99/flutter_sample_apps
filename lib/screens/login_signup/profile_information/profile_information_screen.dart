import 'package:flutter_sample_apps/constants.dart' as constants;
import 'package:flutter_sample_apps/middlewares/extension/profile_info_extension.dart';
import 'package:flutter_sample_apps/middlewares/extension/string.dart';
import 'package:flutter_sample_apps/models/driver.dart';
import 'package:flutter_sample_apps/screens/login_signup/profile_information/driver_license_photo_screen.dart';
import 'package:flutter_sample_apps/screens/login_signup/profile_information/driver_license_photos_bloc/driver_license_photos_bloc.dart';
import 'package:flutter_sample_apps/screens/login_signup/profile_information/driver_license_photos_bloc/driver_license_photos_event.dart';
import 'package:flutter_sample_apps/screens/login_signup/profile_information/driver_license_photos_bloc/driver_license_photos_state.dart';
import 'package:flutter_sample_apps/screens/login_signup/profile_information/edit_bloc/edit_driver_bloc.dart';
import 'package:flutter_sample_apps/screens/login_signup/profile_information/edit_bloc/edit_driver_event.dart';
import 'package:flutter_sample_apps/screens/login_signup/profile_information/edit_bloc/edit_driver_state.dart';
import 'package:flutter_sample_apps/screens/login_signup/profile_information/screen_bloc_type.dart';
import 'package:flutter_sample_apps/screens/login_signup/profile_information/sign_up_bloc/sign_up_bloc.dart';
import 'package:flutter_sample_apps/screens/login_signup/profile_information/sign_up_bloc/sign_up_event.dart';
import 'package:flutter_sample_apps/screens/login_signup/profile_information/sign_up_bloc/sign_up_state.dart';
import 'package:flutter_sample_apps/screens/login_signup/profile_information/user_info_bloc/user_info_bloc.dart';
import 'package:flutter_sample_apps/screens/login_signup/profile_information/user_info_bloc/user_info_event.dart';
import 'package:flutter_sample_apps/screens/login_signup/profile_information/user_info_bloc/user_info_state.dart';
import 'package:flutter_sample_apps/screens/login_signup/shared/profile_information/bottom_sheet_widget.dart';
import 'package:flutter_sample_apps/screens/login_signup/shared/profile_information/loading_indicator.dart';
import 'package:flutter_sample_apps/screens/login_signup/shared/profile_information/photo_information.dart';
import 'package:flutter_sample_apps/screens/login_signup/shared/profile_information/profile_activation_btm_sheet.dart';
import 'package:flutter_sample_apps/screens/login_signup/shared/profile_information/txt_field_wih_icon.dart';
import 'package:flutter_sample_apps/screens/profile/live_orders/live_orders_screen.dart';
import 'package:flutter_sample_apps/shared/alert_widget.dart';
import 'package:flutter_sample_apps/shared/next_button.dart';
import 'package:flutter_sample_apps/style.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class ProfileInformationScreen extends StatefulWidget {
  const ProfileInformationScreen({required this.screenBlocType, this.driver});
  final ScreenBlocType screenBlocType;

  final Driver? driver;
  @override
  _ProfileInformationScreenState createState() =>
      _ProfileInformationScreenState();
}

class _ProfileInformationScreenState extends State<ProfileInformationScreen>
    with WidgetsBindingObserver {
  double get _screenHeight => MediaQuery.of(context).size.height;
  double get _buttonHeight => 30 * constants.rh(context);
  double get _textHeight => 'Next'.heightOfText(context, getStyle());
  double get _datePickerHeight => _screenHeight * 1 / 3 + _buttonHeight;
  double get _keyboardHeight => MediaQuery.of(context).viewInsets.bottom;
  double get _safeAreaHeight =>
      _buttonHeight + _textHeight + 15 * constants.rh(context);
  bool get screenBlocTypeIsSignUpBloc =>
      widget.screenBlocType == ScreenBlocType.signUpBloc;
  bool _isEditable = false;
  bool _isEnable = true;
  bool _isEditableFromDraw = true;
  late UserInfoBloc _userInfoBloc;
  final _editBloc = EditDriverBloc();
  Driver _driver = Driver();
  SignUpBloc? _signUpBloc;
  final _driverLicensePhotoBloc = DriverLicensePhotoBloc();
  bool _isDownloaded = false;
  final _birthDateEditingController = TextEditingController();
  final _cityEditingController = TextEditingController();
  final _documentsPhotoController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _percent = ValueNotifier(0.0);

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  @override
  void dispose() {
    _userInfoBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<UserInfoBloc>(
            create: (context) =>
                _userInfoBloc = UserInfoBloc()..add(LoadCitiesEvent()),),
        BlocProvider.value(value: _driverLicensePhotoBloc),
        BlocProvider.value(value: _editBloc)
      ],
      child: MultiBlocListener(
        listeners: _listeners(),
        child: _render(),
      ),
    );
  }

  Widget _render() {
    return WillPopScope(
      onWillPop: () async => true,
      child: BlocBuilder<UserInfoBloc, UserInfoState>(
        builder: (context, state) {
          return GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: Scaffold(
              resizeToAvoidBottomInset: false,
              body: SafeArea(
                top: false,
                child: _renderFieldOnScreen(state: state),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _renderFieldOnScreen({required UserInfoState state}) {
    return Stack(
      children: [
        _renderFields(state: state),
        _renderAppBarWidget(),
        _renderNextButton(
          state: state,
          text: 'Send',
          onPress: () {
            if (_isEditableFromDraw && _isActive(state)) {
              if (state is DriverValidState) {
                _nextButtonOnPressOnValidState();
              }
            }
            if (state is DriverInvalidState) {
              _nextButtonOnPressedOnInvalidState();
            }
          },
        ),
      ],
    );
  }

  void _nextButtonOnPressOnValidState() {
    final bloc = _signUpBloc;
    if (_isEditable) {
      _editBloc.add(EditDriver(driver: _driver));
      return;
    } else if (bloc != null) {
      bloc.add(CreateDriverEvent(driver: _driver));
      return;
    }
  }

  void _nextButtonOnPressedOnInvalidState() {
    final currentState = _formKey.currentState;
    if (currentState != null) {
      currentState.validate();
    }
  }

  Widget _renderAppBarWidget() {
    if (widget.screenBlocType == ScreenBlocType.profileInformationBloc) {
      return PhotoInformation(
        driver: _driver,
        screenBlocType: ScreenBlocType.profileInformationBloc,
      );
    } else if (screenBlocTypeIsSignUpBloc) {
      return PhotoInformation(
        screenBlocType: ScreenBlocType.signUpBloc,
        driver: _driver,
      );
    }
    return Container();
  }

  Widget _renderFields({required UserInfoState state}) {
    double _bottomMargin() {
      if (_keyboardHeight == 0) {
        return _safeAreaHeight;
      }
      return _keyboardHeight;
    }

    return Container(
        margin: EdgeInsets.only(
            top: _screenHeight * 1 / 3, bottom: _bottomMargin(),),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Column(
              children: [
                _renderTextField(
                    state: state,
                    profileInfoType: ProfileInfoType.firstName,
                    enabled: _isEditableFromDraw,),
                _renderTextField(
                    state: state,
                    profileInfoType: ProfileInfoType.lastName,
                    enabled: _isEditableFromDraw,),
                _renderDatePicker(state: state),
                _renderCitiesField(state: state),
                _renderDriverLicenseField(state: state),
                _renderTextField(
                    state: state,
                    profileInfoType: ProfileInfoType.email,
                    padding: EdgeInsets.symmetric(
                        vertical: 10 * constants.rh(context),),
                    enabled: _isEditableFromDraw,),
              ],
            ),
          ),
        ),);
  }

  Widget _renderDatePicker({required UserInfoState state}) {
    return GestureDetector(
      onTap: () {
        if (_isEditableFromDraw) {
          _userInfoBloc.add(const AddBirthDateEvent());
          final currentState = _formKey.currentState;
          if (currentState != null && state is DriverInvalidState) {
            currentState.reset();
          }
        }
      },
      child: AbsorbPointer(
        child: TxtFieldWithIcon(
          controller: _birthDateEditingController,
          prefixWidgets: ProfileInfoType.date.image(),
          label: ProfileInfoType.date.labeltext(),
          enabled: false,
          validator: (_) =>
              state is DriverInvalidState ? state.error['birthDate'] : null,
          padding: EdgeInsets.only(
            top: 10 * constants.rh(context),
          ),
        ),
      ),
    );
  }

  Widget _renderDriverLicenseField({required UserInfoState state}) {
    return GestureDetector(
      onTap: () {
        final currentState = _formKey.currentState;
        if (currentState != null && state is DriverInvalidState) {
          currentState.reset();
        }
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MultiBlocProvider(
                providers: [
                  BlocProvider.value(
                    value: _driverLicensePhotoBloc,
                  ),
                  BlocProvider.value(value: _userInfoBloc)
                ],
                child: DriverLicensePhotosScreen(
                  driver: _driver,
                  controller: _documentsPhotoController,
                  isDownLoaded: _isDownloaded,
                  isEnable: _isEditableFromDraw,
                ),
              ),
            ),);
      },
      child: AbsorbPointer(
        absorbing: _isEnable,
        child: TxtFieldWithIcon(
          controller: _documentsPhotoController,
          validator: (_) =>
              state is DriverInvalidState ? state.error['driverLicense'] : null,
          prefixWidgets: ProfileInfoType.driverLicense.image(),
          label: ProfileInfoType.driverLicense.labeltext(),
          enabled: false,
          padding: EdgeInsets.only(
            top: 10 * constants.rh(context),
          ),
        ),
      ),
    );
  }

  Widget _renderCitiesField({required UserInfoState state}) {
    return GestureDetector(
      onTap: () {
        if (_isEditableFromDraw) {
          _userInfoBloc.add(LoadUserCityEvent());
          final currentState = _formKey.currentState;
          if (currentState != null && state is DriverInvalidState) {
            currentState.reset();
          }
        }
      },
      child: AbsorbPointer(
        child: TxtFieldWithIcon(
          controller: _cityEditingController,
          validator: (_) =>
              state is DriverInvalidState ? state.error['city'] : null,
          prefixWidgets: ProfileInfoType.city.image(),
          label: ProfileInfoType.city.labeltext(),
          enabled: false,
          padding: EdgeInsets.only(
            top: 10 * constants.rh(context),
          ),
        ),
      ),
    );
  }

  Widget _renderTextField(
      {required UserInfoState state,
      required ProfileInfoType profileInfoType,
      bool enabled = true,
      EdgeInsets? padding,}) {
    return TxtFieldWithIcon(
      enabled: enabled,
      initialValue: profileInfoType.getInitialValue(_driver),
      prefixWidgets: profileInfoType.image(),
      inputFormatter: profileInfoType.formatter(),
      label: profileInfoType.labeltext(),
      txtType: profileInfoType.textInputText(),
      onTap: () {
        final currentState = _formKey.currentState;
        if (currentState != null && state is DriverInvalidState) {
          currentState.reset();
        }
      },
      onEditingComplete: () => _onComplete(profileInfoType: profileInfoType),
      action: _inputAction(profileInfoType: profileInfoType),
      onChange: _onChange(profileInfoType: profileInfoType),
      validator: (val) => state is DriverInvalidState
          ? state.error[profileInfoType.error()]
          : null,
      padding: padding ??
          EdgeInsets.only(
            top: 10 * constants.rh(context),
          ),
    );
  }

  Widget _renderNextButton({
    required String text,
    required Function() onPress,
    required UserInfoState state,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 15 * constants.rh(context)),
      alignment: Alignment.bottomCenter,
      child: NextButton(
        isActive: _isActive(state),
        onPress: onPress,
        text: text,
        textColor: whiteColor,
      ),
    );
  }

  Future<void> _selectDate() async {
    final dateNow = DateTime.now();
    await showModalBottomSheet<DateTime>(
      isDismissible: false,
      context: context,
      builder: (context) {
        var tempPickedDate = _driver.birthDate ?? dateNow;
        return SizedBox(
          height: _datePickerHeight,
          child: Column(
            children: <Widget>[
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date,
                  initialDateTime: _driver.birthDate ?? dateNow,
                  maximumDate: dateNow,
                  minimumDate: DateTime(dateNow.year - 101),
                  onDateTimeChanged: (DateTime dateTime) {
                    tempPickedDate = dateTime;
                  },
                ),
              ),
              SafeArea(
                child: _renderNextButton(
                  state: AddingBirthDateState(),
                  text: 'OK',
                  onPress: () {
                    _userInfoBloc
                        .add(ChooseBirthDateEvent(birthDate: tempPickedDate));
                    FocusScope.of(context).unfocus();

                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  bool _isActive(UserInfoState state) {
    return (state is AddingBirthDateState || state is DriverValidState) &&
        _isEditableFromDraw &&
        _isEnable;
  }

  void _signUpBlocListener(BuildContext context, state) {
    if (state is DriverCreateErrorState) {
      Navigator.pop(context);
      AlertWidget().showMessage(context, state.message);
    }
    if (state is SignUpLoadingState) {
      _showDialog();
    }
    if (state is DriverCreatedState) {
      if (state.firstTimeCreated) {
        Navigator.pop(context);
      }
      if (_isEditable) {
        _userInfoBloc.add(DriverValidationEvent(driver: _driver));
      } else {
        _signUpBloc?.add(ListenDriverActivationEvent());
        _showIsActiveBottomSheet();
      }
    }
    if (state is DriverIsActivateState) {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => const LiveOrdersScreen(order: null),),
      );
    }
    if (state is DriverIsEditableState) {
      _isEditable = true;
      Navigator.pop(context);
      _userInfoBloc.add(DriverValidationEvent(driver: _driver));
    }
    if (state is LoadingIndicatorState) {
      _percent.value = state.percent;
    }
  }

  void _showCities(BuildContext context, {required List list}) {
    showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (context) {
          return BlocProvider.value(
            value: _userInfoBloc,
            child: BottomSheetWidget(
              list: list,
              selectedItem: _cityEditingController.text,
            ),
          );
        },).whenComplete(() => FocusScope.of(context).unfocus());
  }

  void _showIsActiveBottomSheet() {
    showModalBottomSheet(
      isDismissible: false,
      enableDrag: false,
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return SizedBox(
            height: _datePickerHeight,
            child: BlocProvider.value(
                value: _userInfoBloc, child: ProfileActivationBtmSheet(),),);
      },
    );
  }

  void _driverPhotoBlocListener(context, state) {
    if (state is PhotoIsDownLoading) {
      _documentsPhotoController.text = 'Downloading...';
      _isEnable = false;
    }
    if (state is PhotoIsDownLoadedState) {
      _documentsPhotoController.text = 'Your documents is added';
      _driver.drivingLicensePhotos = {};
      _driver.drivingLicensePhotos
          ?.addAll(_driverLicensePhotoBloc.licensePhoto);

      _isEnable = true;
      _userInfoBloc.add(DriverValidationEvent(driver: _driver));
    }
  }

  void _userInfoBlocListener(BuildContext context, state) {
    if (state is AddingBirthDateState) {
      _selectDate();
    }

    if (state is AddedBirthDateState) {
      _birthDateEditingController.text =
          DateFormat('MM/dd/yyyy').format(state.birthDate);
      _driver.birthDate = state.birthDate;
      _userInfoBloc.add(DriverValidationEvent(driver: _driver));
    }
    if (state is AddingUserCityState) {
      _userInfoBloc.add(DriverValidationEvent(driver: _driver));
      _showCities(context, list: state.cities);
    }
    if (state is CityIsChoosedState) {
      _cityEditingController.text = state.city;
      _driver.city = state.city;
      _userInfoBloc.add(DriverValidationEvent(driver: _driver));
    }
  }

  void _editDriverListener(BuildContext context, state) {
    if (state is DriverEditErrorState) {
      Navigator.pop(context);
      AlertWidget().showMessage(context, state.message);
    }
    if (state is DriverIsEditedState) {
      Navigator.of(context).pop();
      final bloc = _signUpBloc;
      if (bloc != null) {
        _showIsActiveBottomSheet();
        bloc.add(ListenDriverActivationEvent());
      }
    }
    if (state is EditDriverLoadingState) {
      _showDialog();
    }
    if (state is EditLoadingIndicator) {
      if (_percent.value >= 100) {
        _percent.value = 0;
      }
      _percent.value = state.precent;
    }
    if (state is IsEditableState) {
      _isEditableFromDraw = state.isProve;
      _isEditable = true;
    }
  }

  /// Show upload dialog
  void _showDialog() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Dialog(
            backgroundColor: Colors.transparent,
            insetPadding:
                EdgeInsets.symmetric(horizontal: 15 * constants.rw(context)),
            child: Stack(
              children: <Widget>[
                Container(
                    width: double.infinity,
                    height: _screenHeight / 4,
                    decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius.circular(15 * constants.rh(context)),
                        color: whiteColor,),
                    child: LoadingIndicator(
                      notifier: _percent,
                    ),),
              ],
            ),),);
  }

  void _initialize() {
    final widgetDriver = widget.driver;
    if (widgetDriver != null) {
      _isEnable = false;
      _isEditable = widgetDriver.isProved ?? false;
      _driver = widgetDriver;
      final date = _driver.birthDate;
      if (date != null) {
        _birthDateEditingController.text =
            DateFormat('MM/dd/yyyy').format(date).toString();
      }

      _cityEditingController.text = _driver.city ?? '';
    }
    if (screenBlocTypeIsSignUpBloc) {
      _signUpBloc = BlocProvider.of<SignUpBloc>(context);
      if (widgetDriver != null) {
        _signUpBloc?.add(DriverIsAlreadyCreatedEvent(driver: _driver));
      }
    }
    final attachment = _driver.attachment;
    if (attachment != null) {
      final downloadLinks = attachment.downloadLink;
      if (downloadLinks != null) {
        _driverLicensePhotoBloc.add(DownLoadImagesFromUrlsEvent(
            links: downloadLinks.where((element) {
          final key = element.keys.first;
          return key.contains('Front') || key.contains('Back');
        }).toList(),),);
        _isDownloaded = true;
      }
    }
    if (widget.screenBlocType == ScreenBlocType.profileInformationBloc) {
      _isEditableFromDraw = false;
      _editBloc.add(CheckIsProve());
    }
  }

  List<BlocListener> _listeners() {
    return [
      BlocListener<UserInfoBloc, UserInfoState>(
        listener: _userInfoBlocListener,
      ),
      BlocListener<DriverLicensePhotoBloc, DriverLicensePhotoState>(
        listener: _driverPhotoBlocListener,
      ),
      BlocListener<EditDriverBloc, EditDriverState>(
        listener: _editDriverListener,
      ),
      if (screenBlocTypeIsSignUpBloc)
        BlocListener<SignUpBloc, SignUpState>(
          listener: _signUpBlocListener,
        ),
    ];
  }
}

extension _ProfileInfoStateAddition on _ProfileInformationScreenState {
  Function(String)? _onChange({required ProfileInfoType profileInfoType}) {
    switch (profileInfoType) {
      case ProfileInfoType.firstName:
        return (val) {
          _driver.firstName = val;
          _userInfoBloc.add(DriverValidationEvent(driver: _driver));
        };
      case ProfileInfoType.lastName:
        return (val) {
          _driver.lastName = val;
          _userInfoBloc.add(DriverValidationEvent(driver: _driver));
        };
      case ProfileInfoType.email:
        return (val) {
          _driver.email = val;
          _userInfoBloc.add(DriverValidationEvent(driver: _driver));
        };
      case ProfileInfoType.date:
        break;
      case ProfileInfoType.city:
        break;
      case ProfileInfoType.driverLicense:
        break;
    }
    return null;
  }

  TextInputAction? _inputAction({required ProfileInfoType profileInfoType}) {
    switch (profileInfoType) {
      case ProfileInfoType.firstName:
        if ((_driver.lastName ?? '').isEmpty ||
            _birthDateEditingController.text.isEmpty) {
          return TextInputAction.next;
        }
        return TextInputAction.done;
      case ProfileInfoType.lastName:
        if (_birthDateEditingController.text.isEmpty ||
            (_driver.firstName ?? '').isEmpty) {
          return TextInputAction.next;
        }
        return TextInputAction.done;

      case ProfileInfoType.date:
        break;
      case ProfileInfoType.email:
        return TextInputAction.done;
      case ProfileInfoType.city:
        break;
      case ProfileInfoType.driverLicense:
        break;
    }
    return null;
  }

  void _onComplete({required ProfileInfoType profileInfoType}) {
    switch (profileInfoType) {
      case ProfileInfoType.firstName:
        if ((_driver.lastName ?? '').isEmpty) {
          FocusScope.of(context).nextFocus();
          break;
        }
        FocusScope.of(context).unfocus();
        break;
      case ProfileInfoType.lastName:
        if (_birthDateEditingController.text.isEmpty) {
          _userInfoBloc.add(const AddBirthDateEvent());
        }

        FocusScope.of(context).unfocus();
        break;
      case ProfileInfoType.date:
        break;
      case ProfileInfoType.email:
        FocusScope.of(context).unfocus();
        break;
      case ProfileInfoType.city:
        break;
      case ProfileInfoType.driverLicense:
        break;
    }
  }
}
