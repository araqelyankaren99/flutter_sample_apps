import 'package:flutter_sample_apps/src/constants.dart' as constants;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sample_apps/src/screens/login_signup/car_information/shared/app_info.dart';
import 'package:flutter_sample_apps/src/screens/profile/help/help_page_bloc/help_page_bloc.dart';
import 'package:flutter_sample_apps/src/screens/profile/help/help_page_bloc/help_page_event.dart';
import 'package:flutter_sample_apps/src/screens/profile/help/help_page_bloc/help_page_state.dart';
import 'package:flutter_sample_apps/src/screens/profile/profile_drawer/profile_drawer_bloc/profile_information_bloc.dart';
import 'package:flutter_sample_apps/src/screens/profile/shared/alert_dialog.dart';
import 'package:flutter_sample_apps/src/screens/profile/shared/expansion_item.dart';
import 'package:flutter_sample_apps/src/screens/profile/shared/expansion_widget.dart';
import 'package:flutter_sample_apps/src/shared/app_bar_widget.dart';
import 'package:flutter_sample_apps/src/shared/loading_widget.dart';
import 'package:flutter_sample_apps/src/style.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpPage extends StatefulWidget {
  @override
  _HelpPageState createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage> {
  List<ExpansionItem> helpItems = [];

  double get _screenHeight => MediaQuery.of(context).size.height;

  final ProfileInformationBloc _profileInformationBloc =
      ProfileInformationBloc();
  String get firstname => _profileInformationBloc.user.firstName ?? '';
  String get lastname => _profileInformationBloc.user.lastName ?? '';

  @override
  Widget build(BuildContext context) {
    return BlocProvider<HelpPageBloc>(
      create: (_) => HelpPageBloc()..add(const GetFAQsEvent()),
      child: BlocListener<HelpPageBloc, HelpPageState>(
        listener: listener,
        child: BlocBuilder<HelpPageBloc, HelpPageState>(
          builder: (context, state) {
            return LoadingWidget(
                isLoading: state is FAQsLoadingState, child: _render());
          },
        ),
      ),
    );
  }

  Widget _render() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(bottom: false, child: _renderHelpPageBody()),
    );
  }

  Widget _renderHelpPageBody() {
    return Stack(
      children: [
        _renderHintText(),
        Column(
          children: [
            _renderAppBar(),
            _renderHelpItems(),
          ],
        ),
        _renderContactInfo(),
      ],
    );
  }

  Widget _renderAppBar() {
    return ClipRRect(
      borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(10 * constants.rw(context)),
          bottomRight: Radius.circular(10 * constants.rw(context))),
      child: AppBarWidget(
        backgroundColor: Colors.white,
        titleText: 'Help',
        titleStyle: getStyle(weight: FontWeight.w500, fontSize: 20),
        prefixWidget: InkWell(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back),
        ),
      ),
    );
  }

  Widget _renderHelpItems() {
    return Flexible(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
            0, 10 * constants.rh(context), 0, 60 * constants.rh(context)),
        child: ListView.builder(
            shrinkWrap: true,
            physics: const BouncingScrollPhysics(),
            itemCount: helpItems.length,
            itemBuilder: _itemBuilder),
      ),
    );
  }

  Widget _itemBuilder(BuildContext context, int index) {
    final _expansionItem = helpItems[index];

    return ExpansionWidget(
        item: _expansionItem,
        onExpansionChanged: (isExpanded) {
          _onExpansionChanged(_expansionItem, isExpanded);
        });
  }

  Widget _renderContactInfo() {
    return Container(
      margin: EdgeInsets.only(bottom: 30 * constants.rh(context)),
      alignment: Alignment.bottomCenter,
      child: _renderContactInfoBody(),
    );
  }

  Widget _renderContactInfoBody() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _renderContactInfoText(),
        _renderContactInfoButton(),
      ],
    );
  }

  Widget _renderContactInfoText() {
    return Padding(
      padding: EdgeInsets.only(right: 10 * constants.rw(context)),
      child: Text(
        'Our contact:',
        textAlign: TextAlign.center,
        style: getStyle(
          fontSize: 12,
          color: spunPearlColor,
        ),
      ),
    );
  }

  Widget _renderContactInfoButton() {
    return InkWell(
      onTap: () {
        constants.launchURL(constants.driveHopPageUrl);
      },
      child: _renderContactInfoButtonText(),
    );
  }

  Widget _renderContactInfoButtonText() {
    return const Text(
      'support@drivehop.com',
      style: TextStyle(
        fontFamily: fontNameDefault,
        color: azureRadianceColor,
        fontSize: 12,
        decoration: TextDecoration.underline,
        decorationColor: Colors.grey,
      ),
    );
  }

  Widget _renderHintText() {
    return Container(
      color: blackHazeColor,
      alignment: Alignment.bottomCenter,
      padding: EdgeInsets.fromLTRB(
        30 * constants.rw(context),
        0,
        30 * constants.rw(context),
        _screenHeight * 1 / 5,
      ),
    );
  }

  /// This method will return on ExpansionItem tap
  void _onExpansionChanged(ExpansionItem expansionItem, bool isExpanded) {
    switch (expansionItem.expansionType) {
      case ExpansionType.question:
        setState(() {
          expansionItem.isClicked = isExpanded;
        });
        break;
      case ExpansionType.email:
        _openDefaultEmailApp();
        break;
      default:
        break;
    }
  }

  /// This method creates new mail default email app on phone
  Future<void> _openDefaultEmailApp() async {
    final info = await AppInfo.fetchData();
    final phoneInformation = info.phoneInformation;
    final version = info.version;
    final isNewVersion = info.isNewVersion;
    final _emailLaunchUri = Uri(
        scheme: 'mailto',
        path: constants.driveHopEmail,
        query:
            'body= $firstname $lastname ${isNewVersion ? 'and' : '\n \n'} Version:$version ${isNewVersion ? 'and' : '\n'} $phoneInformation');

    launch(_emailLaunchUri.toString()).catchError((e) {});
  }

  void listener(BuildContext context, HelpPageState state) {
    if (state is FAQsLoadedState) {
      helpItems = state.expansionItems;
    }
    if (state is FAQsLoadErrorState) {
      CustomAlertDialog.show(context);
    }
  }
}
