import 'package:flutter_sample_apps/constants.dart' as constants;
import 'package:flutter_sample_apps/screens/login_signup/login_signup_screen.dart';
import 'package:flutter_sample_apps/screens/login_signup/phone_number/phone_number_screen.dart';
import 'package:flutter_sample_apps/screens/profile/about_app/about_app_page.dart';
import 'package:flutter_sample_apps/screens/profile/profile_drawer/profile_drawer_bloc/profile_informaiton_event.dart';
import 'package:flutter_sample_apps/screens/profile/profile_drawer/profile_drawer_bloc/profile_information_bloc.dart';
import 'package:flutter_sample_apps/screens/profile/profile_drawer/profile_drawer_bloc/profile_information_state.dart';
import 'package:flutter_sample_apps/screens/profile/settings/settings_bloc/settings_bloc.dart';
import 'package:flutter_sample_apps/screens/profile/settings/settings_bloc/settings_event.dart';
import 'package:flutter_sample_apps/screens/profile/settings/settings_bloc/settings_state.dart';
import 'package:flutter_sample_apps/screens/profile/shared/expansion_item.dart';
import 'package:flutter_sample_apps/screens/profile/shared/expansion_widget.dart';
import 'package:flutter_sample_apps/shared/alert_widget.dart';
import 'package:flutter_sample_apps/shared/app_bar_widget.dart';
import 'package:flutter_sample_apps/shared/connectivity/connection.dart';
import 'package:flutter_sample_apps/shared/loading_widget.dart';
import 'package:flutter_sample_apps/shared/next_button.dart';
import 'package:flutter_sample_apps/style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late SettingsBloc _settingsBloc;
  late ProfileInformationBloc _profileInformationBloc;

  List<ExpansionItem> settingItems = [
    ExpansionItem(expansionType: ExpansionType.changePhoneNumber),
    ExpansionItem(expansionType: ExpansionType.language),
    ExpansionItem(expansionType: ExpansionType.aboutApp),
    ExpansionItem(expansionType: ExpansionType.logOut),
  ];

  @override
  void initState() {
    super.initState();
    _profileInformationBloc = BlocProvider.of<ProfileInformationBloc>(context);
  }

  @override
  void dispose() {
    _settingsBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SettingsBloc>(
      create: (context) {
        return _settingsBloc = SettingsBloc();
      },
      child: MultiBlocListener(
        listeners: [
          BlocListener<SettingsBloc, SettingsState>(
            listener: _settingsBlocListener,
          ),
          BlocListener<ProfileInformationBloc, ProfileInformationState>(
            listener: _profileInformationblocListener,
          ),
        ],
        child: BlocBuilder<SettingsBloc, SettingsState>(
          builder: (context, state) {
            return LoadingWidget(
                isLoading: state is SettingsLoadingState, child: _render(),);
          },
        ),
      ),
    );
  }

  Widget _render() {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Stack(children: [
          Container(color: blackHazeColor),
          Column(
            children: [
              _renderAppBar(),
              _renderSettingItems(),
            ],
          ),
        ],),
      ),
    );
  }

  Widget _renderSettingItems() {
    return Flexible(
      child: Padding(
        padding: EdgeInsets.only(
          top: 10 * constants.rh(context),
        ),
        child: ListView.builder(
          shrinkWrap: true,
          physics: const BouncingScrollPhysics(),
          itemCount: settingItems.length,
          itemBuilder: _itemBuilder,
        ),
      ),
    );
  }

  Widget _itemBuilder(BuildContext context, int index) {
    final expansionItem = settingItems[index];

    return ExpansionWidget(
        item: expansionItem,
        onExpansionChanged: (isExpanded) {
          _onExpansionChanged(expansionItem, isExpanded);
        },);
  }

  Widget _renderAppBar() {
    return ClipRRect(
      borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(10 * constants.rw(context)),
          bottomRight: Radius.circular(10 * constants.rw(context)),),
      child: AppBarWidget(
        backgroundColor: Colors.white,
        titleText: 'Settings',
        titleStyle: getStyle(weight: FontWeight.w500, fontSize: 20),
        prefixWidget: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: const Icon(Icons.arrow_back_sharp),
        ),
      ),
    );
  }

  //This method opens bottom sheet, where you can change the app's language
  void _languageBottomSheet() {
    Widget _renderLanguageBottomSheetTitle() {
      return Container(
        margin: EdgeInsets.only(
          bottom: 30 * constants.rh(context),
        ),
        width: MediaQuery.of(context).size.width,
        color: Colors.white,
        padding: EdgeInsets.symmetric(vertical: 20 * constants.rh(context)),
        child: Text(
          'Change language',
          textAlign: TextAlign.center,
          style: getStyle(fontSize: 18, weight: FontWeight.w500),
        ),
      );
    }

    Widget _renderSelectLanguageTile({String language = 'English'}) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10 * constants.rw(context)),
        child: Container(
          color: Colors.white,
          margin: EdgeInsets.all(10 * constants.rw(context)),
          child: ListTile(
            contentPadding: EdgeInsets.only(
                left: 30 * constants.rw(context),
                right: 20 * constants.rw(context),),
            trailing: const Icon(Icons.check_circle, color: dodgerBlueColor),
            title: Text(language, style: getStyle()),
            onTap: () {},
          ),
        ),
      );
    }

    Widget _renderSaveButton() {
      return NextButton(
        onPress: () => Navigator.pop(context),
        text: 'Save',
        textColor: Colors.white,
        padding: EdgeInsets.symmetric(vertical: 30 * constants.rh(context)),
      );
    }

    showModalBottomSheet(
        backgroundColor: blackHazeColor,
        context: context,
        isScrollControlled: true,
        builder: (context) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _renderLanguageBottomSheetTitle(),
              _renderSelectLanguageTile(),
              _renderSaveButton(),
            ],
          );
        },);
  }

  void _onExpansionChanged(ExpansionItem expansionItem, bool isExpanded) {
    switch (expansionItem.expansionType) {
      case ExpansionType.changePhoneNumber:
        Connection.checker(context,
            onDone: () => _settingsBloc.add(const ChangePhoneNumberEvent()),);
        break;
      case ExpansionType.language:
        _settingsBloc.add(const ChangeLanguageEvent());
        break;
      case ExpansionType.aboutApp:
        Connection.checker(context,
            onDone: () => _settingsBloc.add(const AboutApplicationEvent()),);
        break;
      case ExpansionType.logOut:
        AlertWidget.showConfirmAlertDialog(context,
            title: 'Are you sure you want to log out?',
            accept: 'Log out',
            onAcceptAction: () =>
                _profileInformationBloc.add(const DriverLogOutEvent()),);
        break;
      case ExpansionType.email:
        break;
      case ExpansionType.question:
        break;
    }
  }

  void _settingsBlocListener(BuildContext context, state) {
    if (state is AboutAppLoadErrorState) {
      AlertWidget().showMessage(context, state.errorMessage);
    }

    if (state is ChangeLanguageState) {
      _languageBottomSheet();
    }

    if (state is AboutAppTextLoadedState) {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                AboutAppPage(aboutAppText: state.aboutAppText),),
      );
    }
    if (state is ChangePhoneNumberState) {
      Navigator.of(context).push(
        MaterialPageRoute<ProfileInformationBloc>(
          builder: (_) => BlocProvider.value(
            value: BlocProvider.of<ProfileInformationBloc>(context),
            child: const PhoneNumberScreen(
              loginType: LoginType.changeNumber,
            ),
          ),
        ),
      );
    }
  }

  void _profileInformationblocListener(BuildContext context, state) {
    if (state is DriverLoggedOutState) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (BuildContext context) => const LogInSignUpScreen(
            fromMap: true,
          ),
        ),
        (Route route) => false,
      );
    }
  }
}
