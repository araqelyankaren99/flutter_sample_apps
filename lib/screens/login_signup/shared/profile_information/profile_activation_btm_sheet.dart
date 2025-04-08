import 'package:flutter_sample_apps/constants.dart' as constants;
import 'package:flutter_sample_apps/screens/login_signup/profile_information/user_info_bloc/user_info_bloc.dart';
import 'package:flutter_sample_apps/screens/login_signup/profile_information/user_info_bloc/user_info_event.dart';
import 'package:flutter_sample_apps/screens/login_signup/profile_information/user_info_bloc/user_info_state.dart';
import 'package:flutter_sample_apps/style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfileActivationBtmSheet extends StatefulWidget {
  @override
  _ProfileActivationBtmSheetState createState() =>
      _ProfileActivationBtmSheetState();
}

class _ProfileActivationBtmSheetState extends State<ProfileActivationBtmSheet> {
  UserInfoBloc get _userInfoBloc => BlocProvider.of<UserInfoBloc>(context);
  String? get _adminPhoneNumber => _userInfoBloc.adminPhoneNumber;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<UserInfoBloc>(
      create: (context) {
        _userInfoBloc.add(GetAdminPhoneNumberEvent());
        return _userInfoBloc;
      },
      child: BlocBuilder<UserInfoBloc, UserInfoState>(
        builder: (context, state) {
          return Container(
              margin: EdgeInsets.all(10 * constants.rw(context)),
              child: Column(
                children: [
                  Flexible(flex: 4, child: _renderTexts()),
                  const Divider(),
                  Flexible(flex: 2, child: _renderPhoneNumber())
                ],
              ),);
        },
      ),
    );
  }

  Widget _renderTexts() {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10 * constants.rh(context)),
          color: whiteColor,),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(
            'Your account is still inactive',
            style: getStyle(
              color: redColor,
              weight: FontWeight.w500,
              height: 3,
              fontSize: 24 * constants.rh(context),
            ),
            softWrap: true,
          )
        ],),
        Padding(
            padding: EdgeInsets.only(top: 10 * constants.rh(context)),
            child: Text(
              'Please call to office',
              softWrap: true,
              style: getStyle(
                  color: codGrayColor, weight: FontWeight.w500, fontSize: 18,),
            ),)
      ],),
    );
  }

  Widget _renderPhoneNumber() {
    return SafeArea(
        child: GestureDetector(
            onTap: () => _call(_adminPhoneNumber ?? ''),
            child: Container(
                decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.circular(10 * constants.rh(context)),
                    color: whiteColor,),
                child: Container(
                  alignment: Alignment.centerLeft,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                        'Call',
                        style: getStyle(
                            color: azureRadianceColor,
                            weight: FontWeight.w500,
                            fontSize: 25,),
                      ),
                      Text(
                        _adminPhoneNumber ?? '',
                        style: getStyle(
                            color: azureRadianceColor,
                            weight: FontWeight.w500,
                            fontSize: 25,),
                      )
                    ],
                  ),
                ),),),);
  }

  /// This method is for calling to office
  void _call(String url) {
    constants.launchURL('tel://$url');
  }
}
