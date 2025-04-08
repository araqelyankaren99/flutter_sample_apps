import 'package:flutter_sample_apps/constants.dart' as constants;
import 'package:flutter_sample_apps/models/driver.dart';
import 'package:flutter_sample_apps/screens/login_signup/profile_information/profile_information_screen.dart';
import 'package:flutter_sample_apps/screens/login_signup/profile_information/screen_bloc_type.dart';
import 'package:flutter_sample_apps/screens/profile/help/help_page.dart';
import 'package:flutter_sample_apps/screens/profile/history/history_page.dart';
import 'package:flutter_sample_apps/screens/profile/profile_drawer/profile_drawer_bloc/profile_informaiton_event.dart';
import 'package:flutter_sample_apps/screens/profile/profile_drawer/profile_drawer_bloc/profile_information_bloc.dart';
import 'package:flutter_sample_apps/screens/profile/profile_drawer/profile_drawer_bloc/profile_information_state.dart';
import 'package:flutter_sample_apps/screens/profile/profile_personal_info.dart';
import 'package:flutter_sample_apps/screens/profile/settings/settings_screen.dart';
import 'package:flutter_sample_apps/shared/alert_widget.dart';
import 'package:flutter_sample_apps/shared/connectivity/connection.dart';
import 'package:flutter_sample_apps/style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfileDrawer extends StatefulWidget {
  const ProfileDrawer(
      {required this.callBackFunction, this.fromOrdersScreen = false,});

  final Function callBackFunction;
  final bool fromOrdersScreen;
  @override
  _ProfileDrawerState createState() => _ProfileDrawerState();
}

class _ProfileDrawerState extends State<ProfileDrawer> {
  double get _screenWidth => MediaQuery.of(context).size.width;
  late ProfileInformationBloc _profileInformationBloc;
  Driver? get driver => _profileInformationBloc.driver;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ProfileInformationBloc>(
      create: (context) {
        if (widget.fromOrdersScreen) {
          _profileInformationBloc =
              BlocProvider.of<ProfileInformationBloc>(context);
        } else {
          _profileInformationBloc = ProfileInformationBloc();
        }
        _profileInformationBloc.add(const GetProfileInformationEvent());
        return _profileInformationBloc;
      },
      child: BlocListener<ProfileInformationBloc, ProfileInformationState>(
        listener: _listener,
        child: BlocBuilder<ProfileInformationBloc, ProfileInformationState>(
          builder: (context, state) {
            return _render(state);
          },
        ),
      ),
    );
  }

  void _listener(BuildContext context, state) {
    if (state is ProfileInformationLoadErrorState) {
      AlertWidget().showMessage(context, state.errorMessage);
    }
  }

  Widget _render(ProfileInformationState state) {
    return ClipRRect(
      borderRadius: BorderRadius.only(
        topRight: Radius.circular(
          10 * constants.rh(context),
        ),
        bottomRight: Radius.circular(
          10 * constants.rh(context),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: _screenWidth * 2 / 3,
            child: Drawer(
              child: Container(
                color: Colors.black,
                child: _renderDrawerBody(state),
              ),
            ),
          ),
          Expanded(
            child: InkWell(
              onTap: () => widget.callBackFunction(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _renderDrawerBody(ProfileInformationState state) {
    return Column(
      children: [
        ProfilePersonalInfo(loading: state is LoadingState, driver: driver),
        const Divider(color: Colors.grey, thickness: 1),
        _renderProfileColumn(),
      ],
    );
  }

  Widget _renderProfileColumn() {
    return Column(
      children: [
        _renderProfileRow(ProfileRowType.profile),
        _renderProfileRow(ProfileRowType.history),
        _renderProfileRow(ProfileRowType.settings),
        _renderProfileRow(ProfileRowType.help),
        _renderProfileRow(ProfileRowType.termOfUse),
        _renderProfileRow(ProfileRowType.privacyPolice),
      ],
    );
  }

  Widget _renderProfileRow(ProfileRowType profileRowType) {
    return Padding(
      padding: profileRowType._getPadding(context),
      child: InkWell(
        onTap: () {
          profileRowType._onTap(
              context: context,
              profileInformationBloc: _profileInformationBloc,);
        },
        child: _renderProfileRowHeader(profileRowType._title()),
      ),
    );
  }

  Widget _renderProfileRowHeader(String header) {
    return Container(
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.fromLTRB(50 * constants.rw(context),
          20 * constants.rh(context), 0, 20 * constants.rh(context),),
      child: Text(
        header,
        style: getStyle(color: Colors.white, fontSize: 16),
      ),
    );
  }
}

enum ProfileRowType {
  profile,
  history,
  settings,
  help,
  privacyPolice,
  termOfUse,
}

extension ProfileRowTypeExtension on ProfileRowType {
  //This method returns string title based on ProfileRowType
  String _title() {
    switch (this) {
      case ProfileRowType.profile:
        return 'Profile';

      case ProfileRowType.history:
        return 'History';

      case ProfileRowType.settings:
        return 'Settings';

      case ProfileRowType.help:
        return 'Help';

      case ProfileRowType.privacyPolice:
        return 'Privacy Police';

      case ProfileRowType.termOfUse:
        return 'Term Of Use';

      default:
        return '';
    }
  }

//This method opens page or url
  void _onTap(
      {required BuildContext context,
      required ProfileInformationBloc profileInformationBloc,}) {
    switch (this) {
      case ProfileRowType.profile:
        final driver = profileInformationBloc.driver;
        if (driver != null) {
          _navigateTo(
              context: context,
              page: ProfileInformationScreen(
                screenBlocType: ScreenBlocType.profileInformationBloc,
                driver: driver,
              ),);
        }

        break;

      case ProfileRowType.history:
        Connection.checker(context,
            onDone: () => _navigateTo(context: context, page: HistoryPage()),);

        break;

      case ProfileRowType.settings:
        _navigateToWithProfileInformationBloc(
            context: context,
            page: SettingsScreen(),
            profileInformationBloc: profileInformationBloc,);

        break;

      case ProfileRowType.help:
        Connection.checker(context,
            onDone: () => _navigateTo(context: context, page: HelpPage()),);

        break;

      case ProfileRowType.privacyPolice:
        Connection.checker(context,
            onDone: () => constants.launchURL(constants.driveHopPrivacyPolicy),);
        break;

      case ProfileRowType.termOfUse:
        Connection.checker(context,
            onDone: () => constants.launchURL(constants.driveHopTerm),);
        break;

      default:
        break;
    }
  }

  void _navigateToWithProfileInformationBloc(
      {required BuildContext context,
      required Widget page,
      required ProfileInformationBloc profileInformationBloc,}) {
    if (profileInformationBloc.driver != null) {
      Navigator.of(context).push(
        MaterialPageRoute<ProfileInformationBloc>(
          builder: (_) => BlocProvider.value(
            value: profileInformationBloc,
            child: page,
          ),
        ),
      );
    }
  }

  void _navigateTo({required BuildContext context, required Widget page}) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  EdgeInsets _getPadding(BuildContext context) {
    switch (this) {
      case ProfileRowType.profile:
        return EdgeInsets.only(top: 30 * constants.rh(context));
      default:
        return EdgeInsets.zero;
    }
  }
}
