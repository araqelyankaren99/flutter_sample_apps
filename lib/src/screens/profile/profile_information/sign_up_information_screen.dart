import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sample_apps/main.dart';
import 'package:flutter_sample_apps/src/home_screen_initialization.dart';
import 'package:flutter_sample_apps/src/screens/login_signup/profile_information/sign_up_bloc/sign_up_bloc.dart';
import 'package:flutter_sample_apps/src/screens/login_signup/profile_information/sign_up_bloc/sign_up_event.dart';
import 'package:flutter_sample_apps/src/screens/login_signup/profile_information/sign_up_bloc/sign_up_state.dart';
import 'package:flutter_sample_apps/src/screens/map_view/map_view.dart';
import 'package:flutter_sample_apps/src/screens/profile/profile_information/profile_information.dart';

class ProfileInformationSignUp extends ProfileInformationClass {
  const ProfileInformationSignUp({super.key}) : super(nextButtonText: 'Save');

  @override
  _ProfileInformationSignUpState createState() =>
      _ProfileInformationSignUpState();
}

class _ProfileInformationSignUpState
    extends ProfileInformationClassState<ProfileInformationSignUp> {
  late SignUpBloc _signUpBloc;

  @override
  void initState() {
    super.initState();
    _configBloc();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SignUpBloc, SignUpState>(
      listener: _signUpBlocListener,
      child: BlocBuilder<SignUpBloc, SignUpState>(
        builder: (context, state) {
          return Scaffold(
            resizeToAvoidBottomInset: false,
            body: IgnorePointer(
              ignoring:
                  state is SignUpLoadingState || state is UserCreatedState,
              child: super.build(context),
            ),
          );
        },
      ),
    );
  }

  void _signUpBlocListener(context, state) {
    print(state);
    if (state is! SignUpLoadingState && state is! UserCreatedState) {
      super.addUserInfoInitialEvent();
    }
    if (state is UserCreatedState) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  MapView(order: HomeScreenType.mapView.getOrder())));
    }
    if (state is UserCreateErrorState) {
      //
      // UserActionResultDialog(context: context)
      //     .show(dismissOnTap: true, editNotificationText: state.errorMessage);
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  MapView(order: HomeScreenType.mapView.getOrder())));

    }
  }

  @override
  void nextButtonOnPress() {
    super.addUserInfoLoadingEvent();
    _signUpBloc.add(CreateUserEvent(user: super.user));
  }

  /// This method initializes bloc
  void _configBloc() {
    _signUpBloc = BlocProvider.of<SignUpBloc>(context);
  }
}
