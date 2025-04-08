import 'package:flutter_sample_apps/constants.dart' as constants;
import 'package:flutter_sample_apps/screens/login_signup/phone_number/phone_number_screen.dart';
import 'package:flutter_sample_apps/screens/login_signup/profile_information/sign_up_bloc/sign_up_bloc.dart';
import 'package:flutter_sample_apps/screens/login_signup/shared/create_text_widget.dart';
import 'package:flutter_sample_apps/screens/login_signup/shared/login_signup_button.dart';
import 'package:flutter_sample_apps/style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LogInSignUpScreen extends StatefulWidget {
  const LogInSignUpScreen({this.fromMap = false});
  final bool fromMap;
  @override
  State<StatefulWidget> createState() => _LogInSignUpScreenState();
}

class _LogInSignUpScreenState extends State<LogInSignUpScreen> {
  double get _screenWidth => MediaQuery.of(context).size.width;
  late SignUpBloc _signUpBloc;

  @override
  void initState() {
    super.initState();
    if (!widget.fromMap) {
      _signUpBloc = BlocProvider.of<SignUpBloc>(context);
    } else {
      _signUpBloc = SignUpBloc();
    }
  }

  @override
  Widget build(BuildContext context) {
    return _render();
  }

  Widget _render() {
    return Scaffold(body: SafeArea(child: _renderFieldOnScreen()));
  }

  Widget _renderFieldOnScreen() {
    return Stack(
      children: [_renderBackground(), _renderBottomArea()],
    );
  }

  Widget _renderBackground() {
    return Center(
        child: Image.asset(
      'assets/images/welcome.png',
      fit: BoxFit.fill,
    ),);
  }

  Widget _renderButtons() {
    return Container(
        width: _screenWidth,
        padding: EdgeInsets.symmetric(horizontal: 30 * constants.rw(context)),
        child: Container(
            decoration: BoxDecoration(
                color: catskillWhiteColor,
                borderRadius: BorderRadius.circular(5 * constants.rh(context)),),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Expanded(
                  child: LoginAndSignUpButton(
                      color: azureRadianceColor,
                      text: 'Sign up',
                      textColor: whiteColor,
                      onPress: _onTap,),),
              Expanded(
                child: LoginAndSignUpButton(
                    color: catskillWhiteColor,
                    text: 'Log in',
                    onPress: () {
                      _onTap(loginType: LoginType.login);
                    },),
              )
            ],),),);
  }

  Widget _renderBottomArea() {
    return Positioned(
        bottom: 70 * constants.rh(context),
        child: Column(
          children: [
            _renderButtons(),
            Padding(
              padding: EdgeInsets.only(top: 15 * constants.rw(context)),
              child: CreateTextWidget(),
            )
          ],
        ),);
  }

// This method will call when tap on SignUp/LogIn button
  void _onTap({LoginType loginType = LoginType.signUp}) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => BlocProvider.value(
              value: _signUpBloc,
              child: PhoneNumberScreen(
                loginType: loginType,

              ),),),
    );
  }
}

enum LoginType { login, signUp, changeNumber }
