import 'package:flutter_sample_apps/src/models/user.dart';
import 'package:flutter_sample_apps/src/screens/profile/profile_drawer/profile_drawer_bloc/profile_informaiton_event.dart';
import 'package:flutter_sample_apps/src/screens/profile/profile_drawer/profile_drawer_bloc/profile_information_bloc.dart';
import 'package:flutter_sample_apps/src/screens/profile/profile_drawer/profile_drawer_bloc/profile_information_state.dart';
import 'package:flutter_sample_apps/src/screens/profile/profile_information/profile_information.dart';
import 'package:flutter_sample_apps/src/screens/profile/shared/user_action_result.dart';
import 'package:flutter_sample_apps/src/shared/alert_widget.dart';
import 'package:flutter_sample_apps/src/shared/app_bar_widget.dart';
import 'package:flutter_sample_apps/src/style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfileInformationScreen extends ProfileInformationClass {
  const ProfileInformationScreen({required this.user})
      : super(nextButtonText: 'Save', loggedInUser: user);
  final User user;

  @override
  _ProfileInformationScreenState createState() =>
      _ProfileInformationScreenState();
}

class _ProfileInformationScreenState
    extends ProfileInformationClassState<ProfileInformationScreen> {
  late ProfileInformationBloc _profileInformationBloc;

  @override
  void initState() {
    super.initState();
    _configBloc();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileInformationBloc, ProfileInformationState>(
      listener: _profileInformationBlocListener,
      child: BlocBuilder<ProfileInformationBloc, ProfileInformationState>(
        builder: (context, state) {
          return Scaffold(
            resizeToAvoidBottomInset: false,
            body: IgnorePointer(
              ignoring: state is LoadingState || state is UserEditSuccessState,
              child: super.build(context),
            ),
          );
        },
      ),
    );
  }

  void _profileInformationBlocListener(context, state) {
    print(state);
    if (state is! LoadingState && state is! UserEditSuccessState) {
      super.addUserInfoInitialEvent();
    }
    if (state is UserEditSuccessState) {
      AlertWidget(closeAction: () {
        Navigator.pop(context);
      }).acceptAction(context, 'User is updated');

      widget.user.copy(user: state.editedUser);
    }
    if (state is UserEditErrorState) {
      UserActionResultDialog(context: context)
          .show(dismissOnTap: true, editNotificationText: state.errorMessage);
    }
  }

  @override
  void nextButtonOnPress() {
    super.addUserInfoLoadingEvent();
    _profileInformationBloc
        .add(UserEditEvent(user: super.user, userBeforeEditing: widget.user));
  }

  @override
  Widget renderAppBarWidget() {
    return SafeArea(
      child: AppBarWidget(
        prefixWidget: _renderArrowBackButton(),
        titleText: 'Profile',
        titleStyle: getStyle(weight: FontWeight.w500, fontSize: 22),
      ),
    );
  }

  Widget _renderArrowBackButton() {
    return InkWell(
      onTap: () => Navigator.pop(context),
      child: const Icon(
        Icons.arrow_back_sharp,
        color: azureRadianceColor,
      ),
    );
  }

  /// This method initializes bloc
  void _configBloc() {
    _profileInformationBloc = BlocProvider.of<ProfileInformationBloc>(context);
  }
}
