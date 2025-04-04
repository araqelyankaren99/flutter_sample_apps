import 'package:flutter_sample_apps/src/constants.dart' as constants;
import 'package:easy_mask/easy_mask.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sample_apps/src/middlewares/extensions/string.dart';
import 'package:flutter_sample_apps/src/screens/login_signup/login_signup_screen.dart';
import 'package:flutter_sample_apps/src/screens/login_signup/phone_number/phone_number_bloc/phone_number_bloc.dart';
import 'package:flutter_sample_apps/src/screens/login_signup/phone_number/phone_number_bloc/phone_number_event.dart';
import 'package:flutter_sample_apps/src/screens/login_signup/phone_number/phone_number_bloc/phone_number_state.dart';
import 'package:flutter_sample_apps/src/screens/login_signup/profile_information/sign_up_bloc/sign_up_bloc.dart';
import 'package:flutter_sample_apps/src/screens/login_signup/shared/center_text_widget.dart';
import 'package:flutter_sample_apps/src/screens/login_signup/shared/create_text_widget.dart';
import 'package:flutter_sample_apps/src/screens/login_signup/shared/phone_number/phone_number_field.dart';
import 'package:flutter_sample_apps/src/screens/login_signup/shared/phone_number/security_text_widget.dart';
import 'package:flutter_sample_apps/src/screens/login_signup/shared/phone_number/verification_text_widget.dart';
import 'package:flutter_sample_apps/src/screens/login_signup/verification/phone_verify_screen.dart';
import 'package:flutter_sample_apps/src/screens/profile/profile_drawer/profile_drawer_bloc/profile_information_bloc.dart';
import 'package:flutter_sample_apps/src/shared/app_bar_widget.dart';
import 'package:flutter_sample_apps/src/shared/next_button.dart';
import 'package:flutter_sample_apps/src/style.dart';

class PhoneNumberScreen extends StatefulWidget {
  const PhoneNumberScreen({Key? key, required this.loginType}) : super(key: key);

  final LoginType loginType;

  @override
  State<PhoneNumberScreen> createState() => _PhoneNumberScreenState();
}

class _PhoneNumberScreenState extends State<PhoneNumberScreen> {
  LoginType get loginType => widget.loginType;

  final  _textEditingController = TextEditingController();
  final maskFormatter = TextInputMask(mask: '(999)999-9999');

  late PhoneNumberBloc _phoneNumberBloc;
  SignUpBloc? _signUpBloc;
  ProfileInformationBloc? _profileInformationBloc;
  String _phoneNumber = '';

  @override
  void initState() {
    super.initState();
    _initialize();
  }

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
    return BlocProvider<PhoneNumberBloc>(
      create: (context) {
        return _phoneNumberBloc = PhoneNumberBloc();
      },
      child: BlocListener<PhoneNumberBloc, PhoneNumberState>(
        listener: _phoneNumberBlocListener,
        child: _renderScreen(),
      ),
    );
  }

  Widget _renderScreen() {
    return BlocBuilder<PhoneNumberBloc, PhoneNumberState>(
      builder: (context, state) {
        return Scaffold(
          resizeToAvoidBottomInset: false,
          body: Column(
            children: [
              Flexible(
                child: _renderFieldOnScreen(state),
              ),
              SizedBox(
                height: MediaQuery.of(context).viewInsets.bottom,
                width: double.infinity,
              )
            ],
          ),
        );
      },
    );
  }

  Widget _renderFieldOnScreen(PhoneNumberState state) {
    return SafeArea(
      child: ListView(
        children: [
          _renderAppBar(),
          Flexible(
            flex: 2,
            child: _renderTexts(),
          ),
          Flexible(
            child: _renderPhoneField(state),
          ),
          Flexible(
            flex: 3,
            child: _renderNextButton(state),
          ),
          _renderSecurityText(),
        ],
      ),
    );
  }

  Widget _renderAppBar() {
    return AppBarWidget(
      titleText: loginType._appBarTitle(),
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
      children: [
        _renderTitle(),
        _renderSubTitle(),
        _renderVerificationText(),
      ],
    );
  }

  Widget _renderTitle() {
    return loginType._renderTitle(context);
  }

  Widget _renderSubTitle() {
    return Padding(
        padding: EdgeInsets.only(top: 40 * constants.rh(context)),
        child: CenterText(text: loginType._subTitle()));
  }

  Widget _renderVerificationText() {
    return VerificationTextWidget(
        padding: EdgeInsets.only(top: 15 * constants.rh(context)),
        text: loginType._verificationText());
  }

  Widget _renderPhoneField(PhoneNumberState state) {
    return PhoneNumberField(
      enabled: !_showLoading(state),
      controller: _textEditingController,
      inputFormatter: maskFormatter,
      onChange: _onChange,
      onClear: _onClear,
    );
  }

  /// This method calls when tap in clear icon
  void _onClear() {
    _phoneNumber = '';
    _textEditingController.clear();
    _phoneNumberBloc.add(PhoneNumberCheckEvent(phoneNumber: _phoneNumber));
  }

  /// This function initializes and checks phone number's validation
  void _onChange(String val) {
    _phoneNumber = val;
    _phoneNumberBloc.add(PhoneNumberCheckEvent(phoneNumber: _phoneNumber));
  }

  Widget _renderNextButton(PhoneNumberState state) {
    return NextButton(
      absorbing: _absorbing(state),
      showLoading: _showLoading(state),
      isActive: _isActive(state),
      onPress: () => _onTap(state),
      text: 'Next',
      textColor: whiteColor,
    );
  }

  /// This method calls when can't tap in next button
  bool _absorbing(PhoneNumberState state) =>
      state is PhoneNumberLoadingState || _phoneNumber.isEmpty;

  Widget _renderSecurityText() {
    return loginType._renderSecurityText(context);
  }

  /// This method change button color
  bool _isActive(PhoneNumberState state) =>
      _phoneNumber.isNotEmpty && state is! PhoneNumberInvalidState;

  /// This method calls when tap in next button
  void _onTap(PhoneNumberState state) {
    if (!_phoneNumber.startsWith('+')) {
      _phoneNumber = '+1$_phoneNumber';
    }
    if (_isActive(state)) {
      _phoneNumberBloc.add(
        PhoneNumberVerifyEvent(
          phoneNumber: _phoneNumber,
          changingPhoneNumber: loginType == LoginType.changeNumber,
          oldPhoneNumber: _profileInformationBloc?.user.phone,
        ),
      );
    }
  }

  /// This function call when we pass to next page
  bool _showLoading(PhoneNumberState state) => state is PhoneNumberLoadingState;

  /// This method initializes bloc
  void _initialize() {
    _configBloc();
    SystemChannels.textInput.invokeMethod('TextInput.show');
  }

  void _phoneNumberBlocListener(context, state) {
    if (state is PhoneVerifySuccessedState) {
      final signUpBloc = _signUpBloc;
      final profileInformationBloc = _profileInformationBloc;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MultiBlocProvider(
            providers: [
              BlocProvider.value(value: _phoneNumberBloc),
              if ((loginType == LoginType.login ||
                      loginType == LoginType.signUp) &&
                  signUpBloc != null)
                BlocProvider.value(value: signUpBloc)
              else if (loginType == LoginType.changeNumber &&
                  profileInformationBloc != null)
                BlocProvider.value(value: profileInformationBloc)
            ],
            child: PhoneVerifyScreen(
              loginType: loginType,
              phoneNumber: _phoneNumber.phoneNumberWithoutScope(),
            ),
          ),
        ),
      );
    }
    if (state is PhoneNumberVerifyErrorState) {
      _showPhoneNumberErrorDialog(errorNotificationText: state.errorMessage);
    }
  }

  /// This method opens dialog, when user's phone number has error
  void _showPhoneNumberErrorDialog({required String errorNotificationText}) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return AlertDialog(
          title: Column(
            children: [
              Text(
                errorNotificationText,
                textAlign: TextAlign.center,
              ),
              NextButton(
                  padding: const EdgeInsets.only(top: 10),
                  onPress: () => Navigator.pop(context),
                  text: 'OK',
                  textColor: Colors.white),
            ],
          ),
        );
      },
    );
  }
}

extension _LoginTypeAddition on LoginType {
  String _appBarTitle() {
    switch (this) {
      case LoginType.login:
        return 'Log In';
      case LoginType.signUp:
        return 'Create an Account';
      case LoginType.changeNumber:
        return 'Change phone number';
    }
  }

  String _subTitle() {
    switch (this) {
      case LoginType.login:
        return 'Welcome back!';
      case LoginType.signUp:
        return 'Enter your phone number';
      case LoginType.changeNumber:
        return 'Enter your new phone number';
    }
  }

  String _verificationText() {
    switch (this) {
      case LoginType.login:
        return 'Login to your account';
      default:
        return 'We’ll send a verification code to your phone via text message';
    }
  }

  Widget _renderTitle(BuildContext context) {
    switch (this) {
      case LoginType.login:
        return Container();
      case LoginType.signUp:
        return Padding(
            padding: EdgeInsets.only(top: 30 * constants.rh(context)),
            child: CreateTextWidget());
      case LoginType.changeNumber:
        return Container();
    }
  }

  Widget _renderSecurityText(BuildContext context) {
    switch (this) {
      case LoginType.login:
        return Container();
      case LoginType.signUp:
        return SafeArea(
            child: SecurityTextWidget(
                padding: EdgeInsets.only(top: 30 * constants.rh(context))));
      case LoginType.changeNumber:
        return Container();
    }
  }
}
