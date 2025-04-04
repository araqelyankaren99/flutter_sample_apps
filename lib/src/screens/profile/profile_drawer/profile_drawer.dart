import 'package:flutter_sample_apps/src/constants.dart' as constants;
import 'package:flutter_sample_apps/src/middlewares/connectivity/connectivity.dart';
import 'package:flutter_sample_apps/src/middlewares/notifiers/payment_methods.dart';
import 'package:flutter_sample_apps/src/screens/profile/help/help_page.dart';
import 'package:flutter_sample_apps/src/screens/profile/history/history_page.dart';
import 'package:flutter_sample_apps/src/screens/profile/payment/payment_methods_adding_screen.dart';
import 'package:flutter_sample_apps/src/screens/profile/payment/payment_methods_screen.dart';
import 'package:flutter_sample_apps/src/screens/profile/profile_drawer/profile_drawer_bloc/profile_informaiton_event.dart';
import 'package:flutter_sample_apps/src/screens/profile/profile_drawer/profile_drawer_bloc/profile_information_bloc.dart';
import 'package:flutter_sample_apps/src/screens/profile/profile_drawer/profile_drawer_bloc/profile_information_state.dart';
import 'package:flutter_sample_apps/src/screens/profile/profile_information/profile_information_screen.dart';
import 'package:flutter_sample_apps/src/screens/profile/profile_personal_info.dart';
import 'package:flutter_sample_apps/src/screens/profile/settings/settings_screen.dart';
import 'package:flutter_sample_apps/src/shared/alert_widget.dart';
import 'package:flutter_sample_apps/src/shared/payment_methods_builder.dart';
import 'package:flutter_sample_apps/src/style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

class ProfileDrawer extends StatefulWidget {
  const ProfileDrawer({required this.callBackFunction});
  final Function callBackFunction;
  @override
  _ProfileDrawerState createState() => _ProfileDrawerState();
}

class _ProfileDrawerState extends State<ProfileDrawer>
    with AutomaticKeepAliveClientMixin {
  double get _screenWidth => MediaQuery.of(context).size.width;
  late ProfileInformationBloc _profileInformationBloc;
  String get firstname => _profileInformationBloc.user.firstName ?? '';
  String get lastname => _profileInformationBloc.user.lastName ?? '';

  String get phone => _profileInformationBloc.user.phone ?? '';

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocProvider<ProfileInformationBloc>(
        create: (context) {
          return _profileInformationBloc = ProfileInformationBloc()
            ..add(CheckPaymentMethodEvent())
            ..add(const GetProfileInformationEvent());
        },
        child: BlocListener<ProfileInformationBloc, ProfileInformationState>(
            listener: _listener,
            child: BlocBuilder<ProfileInformationBloc, ProfileInformationState>(
              builder: (context, state) {
                return _render();
              },
            )));
  }

  void _listener(context, state) {
    if (state is PaymentMethodsFailedState) {
      AlertWidget().showMessage(context, state.errorMessage);
    }
    if (state is ExistingPaymentMethodsState) {
      Provider.of<PaymentMethodsNotifier>(context, listen: false)
          .hasPaymentMethods = true;
    }
  }

  Widget _render() {
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
                child: _renderDrawerBody(),
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

  Widget _renderDrawerBody() {
    return SingleChildScrollView(
        child: Column(
      children: [
        Column(
          children: [
            ProfilePersonalInfo(
              firstname: firstname,
              lastname: lastname,
            ),
            _renderDivider(),
            _renderProfileColumn(),
          ],
        ),
      ],
    ));
  }

  Widget _renderProfileColumn() {
    return Column(
      children: [
        _renderProfileRow(ProfileRowType.payment),
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
          _onTap(profileRowType);
        },
        child: _renderProfileRowHeader(profileRowType._title()),
      ),
    );
  }

  Widget _renderProfileRowHeader(String header) {
    return Container(
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.fromLTRB(50 * constants.rw(context),
          20 * constants.rh(context), 0, 20 * constants.rh(context)),
      child: Text(
        header,
        style: getStyle(color: Colors.white, fontSize: 16),
      ),
    );
  }

  Widget _renderDivider() {
    return const Divider(color: Colors.grey, thickness: 1);
  }

  /// This method opens page or url
  void _onTap(ProfileRowType profileRowType) {
    switch (profileRowType) {
      case ProfileRowType.payment:
        final notifier =
            Provider.of<PaymentMethodsNotifier>(context, listen: false);
        Connection.checker(
          context,
          onDone: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => BlocProvider.value(
                      value: _profileInformationBloc,
                      child: ChangeNotifierProvider.value(
                          value: notifier,
                          child: PaymentMethodBuilder(
                              child: notifier.hasPaymentMethods
                                  ? PaymentMethodsScreen()
                                  : const PaymentMethodsAddingScreen()))))),
        );

        break;

      case ProfileRowType.profile:
        if (_profileInformationBloc.user.id != null) {
          _navigateToWithProfileInformationBloc(profileRowType,
              page:
                  ProfileInformationScreen(user: _profileInformationBloc.user));
        }
        break;

      case ProfileRowType.history:
        Connection.checker(context,
            onDone: () => profileRowType._navigateTo(
                context: context, page: HistoryPage()));
        break;

      case ProfileRowType.settings:
        Connection.checker(context,
            onDone: () => _navigateToSettingsPage(profileRowType));

        break;

      case ProfileRowType.help:
        Connection.checker(context,
            onDone: () =>
                profileRowType._navigateTo(context: context, page: HelpPage()));
        break;

      case ProfileRowType.privacyPolice:
        Connection.checker(context,
            onDone: () => constants.launchURL(constants.driveHopPrivacyPolicy));
        break;

      case ProfileRowType.termOfUse:
        Connection.checker(context,
            onDone: () => constants.launchURL('constants.driveHopTermsOfUse'));
        break;

      default:
        break;
    }
  }

  void _navigateToWithProfileInformationBloc(ProfileRowType profileRowType,
      {required Widget page}) {
    if (_profileInformationBloc.user.id != null) {
      Navigator.of(context).push(
        MaterialPageRoute<ProfileInformationBloc>(
          builder: (_) => BlocProvider.value(
            value: _profileInformationBloc,
            child: page,
          ),
        ),
      );
    }
  }

  ///This method navigate to settings page
  void _navigateToSettingsPage(ProfileRowType profileRowType) {
    if (_profileInformationBloc.user.id != null) {
      _navigateToWithProfileInformationBloc(
        profileRowType,
        page: SettingsScreen(),
      );
    }
  }

  @override
  bool get wantKeepAlive => true;
}

enum ProfileRowType {
  payment,
  profile,
  history,
  settings,
  help,
  privacyPolice,
  termOfUse,
}

extension ProfileRowTypeExtension on ProfileRowType {
  /// This method returns string title based on ProfileRowType
  String _title() {
    switch (this) {
      case ProfileRowType.payment:
        return 'Payment';

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

  void _navigateTo({required BuildContext context, required Widget page}) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  EdgeInsets _getPadding(BuildContext context) {
    switch (this) {
      case ProfileRowType.payment:
        return EdgeInsets.only(top: 30 * constants.rh(context));
      default:
        return EdgeInsets.zero;
    }
  }
}
