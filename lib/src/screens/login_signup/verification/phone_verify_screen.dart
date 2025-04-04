import 'dart:io';

import 'package:flutter_sample_apps/main.dart';
import 'package:flutter_sample_apps/src/constants.dart' as constants;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sample_apps/src/home_screen_initialization.dart';
import 'package:flutter_sample_apps/src/middlewares/extensions/string.dart';
import 'package:flutter_sample_apps/src/screens/login_signup/login_signup_screen.dart';
import 'package:flutter_sample_apps/src/screens/login_signup/phone_number/phone_number_bloc/phone_number_bloc.dart';
import 'package:flutter_sample_apps/src/screens/login_signup/phone_number/phone_number_bloc/phone_number_event.dart';
import 'package:flutter_sample_apps/src/screens/login_signup/phone_number/phone_number_bloc/phone_number_state.dart';
import 'package:flutter_sample_apps/src/screens/login_signup/profile_information/sign_up_bloc/sign_up_bloc.dart';
import 'package:flutter_sample_apps/src/screens/login_signup/shared/center_text_widget.dart';
import 'package:flutter_sample_apps/src/screens/login_signup/shared/phone_number/verification_text_widget.dart';
import 'package:flutter_sample_apps/src/screens/login_signup/shared/verification/pin_code_fields.dart';
import 'package:flutter_sample_apps/src/screens/map_view/map_view.dart';
import 'package:flutter_sample_apps/src/screens/map_view/shared/timer.dart';
import 'package:flutter_sample_apps/src/screens/profile/profile_drawer/profile_drawer_bloc/profile_informaiton_event.dart';
import 'package:flutter_sample_apps/src/screens/profile/profile_drawer/profile_drawer_bloc/profile_information_bloc.dart';
import 'package:flutter_sample_apps/src/screens/profile/profile_information/sign_up_information_screen.dart';
import 'package:flutter_sample_apps/src/shared/alert_widget.dart';
import 'package:flutter_sample_apps/src/shared/app_bar_widget.dart';
import 'package:flutter_sample_apps/src/shared/next_button.dart';
import 'package:flutter_sample_apps/src/style.dart';
import 'package:otp_autofill/otp_autofill.dart';

class PhoneVerifyScreen extends StatefulWidget {
  const PhoneVerifyScreen({Key? key, required this.loginType, required this.phoneNumber}) : super(key: key);

  final LoginType loginType;
  final String phoneNumber;

  @override
  _PhoneVerifyScreenState createState() => _PhoneVerifyScreenState();
}

class _PhoneVerifyScreenState extends State<PhoneVerifyScreen> {
  LoginType get loginType => widget.loginType;
  PhoneNumberBloc get _phoneNumberBloc =>
      BlocProvider.of<PhoneNumberBloc>(context);
  double get _screenHeight => MediaQuery.of(context).size.height;
  SignUpBloc? _signUpBloc;
  ProfileInformationBloc? _profileInformationBloc;

  String _pinCode = '';

  bool _showNextButton = false;
  bool _isOpenVerifyAlert = false;
  final FocusNode _focusNode = FocusNode();
  PinCodeState _pinCodeState = PinCodeState.initial;

  late dynamic _controller;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  @override
  void dispose() {
    _otpDispose();
    super.dispose();
  }

  /// This method initializes bloc
  void _configBloc() {
    if (loginType == LoginType.signUp || loginType == LoginType.login) {
      _signUpBloc = BlocProvider.of<SignUpBloc>(context);
    } else if (loginType == LoginType.changeNumber) {
      _profileInformationBloc =
          BlocProvider.of<ProfileInformationBloc>(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _render();
  }

  Widget _render() {
    return BlocListener<PhoneNumberBloc, PhoneNumberState>(
        listener: _listener, child: _renderBody());
  }

  Widget _renderBody() {
    return BlocBuilder<PhoneNumberBloc, PhoneNumberState>(
      bloc: _phoneNumberBloc,
      builder: (context, state) {
        return Scaffold(
          resizeToAvoidBottomInset: false,
          body: SafeArea(
            child: SingleChildScrollView(
              child: _renderFieldOnScreen(state),
            ),
          ),
        );
      },
    );
  }

  Widget _renderFieldOnScreen(PhoneNumberState state) {
    return SizedBox(
        height: _screenHeight,
        child: Stack(children: [
          Column(
            children: [
              Flexible(child: _renderAppBar()),
              Flexible(
                flex: 2,
                child: _renderTexts(),
              ),
              Flexible(
                  child: AbsorbPointer(
                      absorbing: _absorbing(state), child: _renderPinField())),
              _renderTimer(),
              Flexible(
                flex: 3,
                child: _renderNextButton(state),
              ),
            ],
          ),
        ]));
  }

  Widget _renderAppBar() {
    return AppBarWidget(
      titleText: 'Verify Code',
      titleStyle:
          getStyle(color: codGrayColor, fontSize: 20, weight: FontWeight.w500),
      prefixWidget: InkWell(
        onTap: () => Navigator.pop(context),
        child: const Icon(
          Icons.arrow_back,
          color: azureRadianceColor,
        ),
      ),
    );
  }

  Widget _renderTexts() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _renderSubTitle(),
        _renderVerificationText(),
      ],
    );
  }

  Widget _renderSubTitle() {
    return Padding(
        padding: EdgeInsets.only(top: 40 * constants.rh(context)),
        child: const CenterText(text: 'Enter Verify code'));
  }

  Widget _renderVerificationText() {
    return VerificationTextWidget(
        padding: EdgeInsets.only(top: 15 * constants.rh(context)),
        text:
            'Please check your messages for a six digit security code and enter it below.');
  }

  Widget _renderPinField() {
    return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _onClearPinCode,
        child: PinCodeFields(
            focusNode: _focusNode,
            color: _pinCodeState._getColor(),
            padding: EdgeInsets.only(top: 20 * constants.rh(context)),
            onChanged: (_) {},
            controller: _controller,
            onCompleted: _onPinCodeCompleted,),);
  }

  Widget _renderTimer() {
    return !_showNextButton
        ? Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Padding(
                padding: EdgeInsets.only(left: 20 * constants.rw(context)),
                child: const Text('Reseding in:')),
            Padding(
                padding: EdgeInsets.only(right: 20 * constants.rw(context)),
                child: TimerPage(
                    onTimerFinished: (value) => setState(() {
                          _showNextButton = value;
                        })))
          ])
        : Container();
  }

  Widget _renderNextButton(PhoneNumberState state) {
    return _showNextButton
        ? NextButton(
            absorbing: _absorbing(state),
            showLoading: _showLoading(state),
            padding: EdgeInsets.only(top: 30 * constants.rw(context)),
            onPress: _resendCode,
            text: 'GET NEW',
            textColor: whiteColor,
          )
        : Container();
  }

  /// This method calls when can't tap in next button
  bool _absorbing(PhoneNumberState state) {
    return state is PhoneNumberLoadingState ||
        state is PinCodeVerifySuccessedState;
  }

  /// This method calls when pin code is resend
  void _onClearPinCode() {
    _controller.clear();
    _pinCode = '';
  }

  /// Resends pin code when phone number is verified
  void _resendCode() {
    _phoneNumberBloc.add(ResendCodeEvent(phoneNumber: widget.phoneNumber));
  }

  bool _showLoading(PhoneNumberState state) =>
      state is PhoneNumberLoadingState || state is PinCodeVerifySuccessedState;

  ///This function call when the pinCode is full
  void _onPinCodeCompleted(String pinCode) {
    _isOpenVerifyAlert
        ? _onClearPinCode()
        : _phoneNumberBloc.add(VerifyCodeValidatedEvent(pinCode: pinCode));
  }

  void _otpInitialize() {
    if (_isAndroidPlatform()) {
      _controller = OTPTextEditController(
        codeLength: 6,
        onCodeReceive: _onCodeReceive,
      )..startListenUserConsent((code) => code?.smsCodeVerifyPinParser() ?? '');
    } else {
      _controller = TextEditingController();
    }
  }

  void _onCodeReceive(String code) {
    _phoneNumberBloc.add(SmsVerifyCodeEvent(pinCode: code));
  }

  Future<void> _otpDispose() async {
    if (_isAndroidPlatform()) {
      await _controller.stopListen();
    }
  }

  bool _isAndroidPlatform() => Platform.isAndroid;

  void _initialize() {
    _configBloc();
    _otpInitialize();
    SystemChannels.textInput.invokeMethod('TextInput.show');
  }
}

extension _PinCodeColorState on PinCodeState {
  Color _getColor() {
    switch (this) {
      case PinCodeState.initial:
        return blackColor;
      case PinCodeState.valid:
        return azureRadianceColor;
      case PinCodeState.invalid:
        return redColor;
    }
  }
}

extension _PhoneVerifyScreenListener on _PhoneVerifyScreenState {
  void _listener(context, state) {
    print('state is $state' );
    if (state is VerifyCodeValidatedState) {
      _showNextButton = true;
      _pinCode = state.pinCode;
      final _phoneNumber = widget.phoneNumber;
      _phoneNumberBloc.add(PinCodeCheckEvent(
          pinCode: _pinCode,
          phoneNumber: _phoneNumber,
          changingPhoneNumber: loginType == LoginType.changeNumber));
    }

    if (state is NotAuthenticatedUserState) {
      _pinCodeState = PinCodeState.invalid;
    }

    if (state is PhoneNumberLoadingState) {
      _isOpenVerifyAlert = true;
    }

    if (state is GetSmsVerifyCodeState) {
      _controller.text = state.pinCode;
    }

    if (state is PinCodeNotValidState) {
      _pinCodeState = PinCodeState.invalid;
      _onClearPinCode();
      _isOpenVerifyAlert = false;

      AlertWidget().showMessage(
          context, 'The code you entered is incorrect. Please try again',
          closeAction: () {
        _pinCodeState = PinCodeState.initial;
        Navigator.of(context).pop();
        final signUpBloc = _signUpBloc;
        if (signUpBloc != null) {
          Future.delayed(const Duration(seconds: 1), () {
            Navigator.push(context, MaterialPageRoute(builder: (_) {
              return BlocProvider.value(
                  value: signUpBloc, child: const ProfileInformationSignUp());
            }));
          });
        }
        // _focusNode.requestFocus();
      });
    }

    if (state is ResendCodeFailedState) {
      _onClearPinCode();
      AlertWidget(closeAction: () {
        _focusNode.requestFocus();
        _showNextButton = false;
        _isOpenVerifyAlert = false;
      }).cancelAction(
        context,
        'Send Failed',
      );
    }

    if (state is ResendCodeSuccessedState) {
      _onClearPinCode();
      AlertWidget(closeAction: () {
        _focusNode.requestFocus();
        _showNextButton = false;
        _isOpenVerifyAlert = false;
      }).acceptAction(context, 'Send');
    }

    if (state is PinCodeVerifySuccessedState) {
      _pinCodeState = PinCodeState.valid;
      if (widget.loginType == LoginType.changeNumber) {
        final profileinformationBloc = _profileInformationBloc;
        if (profileinformationBloc != null) {
          profileinformationBloc.add(UserPhoneNumberChangedEvent(
              changedPhoneNumber: widget.phoneNumber));
        }
        AlertWidget(closeAction: () {
          Navigator.pop(context);
          Navigator.pop(context);
        }).acceptAction(context, 'Phone number is updated');
      } else if (state.phone == null && _signUpBloc != null) {
        final signUpBloc = _signUpBloc;
        if (signUpBloc != null) {
          Future.delayed(const Duration(seconds: 1), () {
            Navigator.push(context, MaterialPageRoute(builder: (_) {
              return BlocProvider.value(
                  value: signUpBloc, child: const ProfileInformationSignUp());
            }));
          });
        }
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MapView(
              order: HomeScreenType.mapView.getOrder(),
            ),
          ),
        );
      }
    }
  }
}

enum PinCodeState { initial, valid, invalid }
