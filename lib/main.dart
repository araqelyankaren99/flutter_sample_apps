import 'dart:io';

import 'package:flutter_sample_apps/models/driver.dart';
import 'package:flutter_sample_apps/models/order.dart';
import 'package:flutter_sample_apps/screens/login_signup/login_signup_screen.dart';
import 'package:flutter_sample_apps/screens/login_signup/profile_information/profile_information_screen.dart';
import 'package:flutter_sample_apps/screens/login_signup/profile_information/screen_bloc_type.dart';
import 'package:flutter_sample_apps/screens/login_signup/profile_information/sign_up_bloc/sign_up_bloc.dart';
import 'package:flutter_sample_apps/screens/login_signup/profile_information/sign_up_bloc/sign_up_event.dart';
import 'package:flutter_sample_apps/screens/profile/live_orders/live_orders_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sample_apps/home_screen_initialization.dart' show initHomeScreen;
import 'package:graphql_flutter/graphql_flutter.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initHiveForFlutter();

  final homeScreenType = await initHomeScreen();
  HttpOverrides.global = MyHttpOverrides();


  runApp(MyApp(
    homeScreenType: homeScreenType,
  ),);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.homeScreenType});

  final Map<HomeScreenType, Object?> homeScreenType;

  @override
  Widget build(BuildContext context) {
    final hasDriver = homeScreenType.values.first == null;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        dividerColor: Colors.transparent,
      ),
      home: BlocProvider<SignUpBloc>(
        create: (context) {
          final signUpBloc = SignUpBloc();
          if (!hasDriver) {
            signUpBloc.add(ListenDriverActivationEvent());
          }
          return signUpBloc;
        },
        child: getScreen(),),);
  }

  Widget? getScreen() {
    if (homeScreenType.keys.first == HomeScreenType.liveOrders) {
      return homeScreenType.keys.first
          .getHomeScreen(null, homeScreenType.values.first as Order?);
    } else {
      return homeScreenType.keys.first
          .getHomeScreen(homeScreenType.values.first as Driver?, null);
    }
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)..maxConnectionsPerHost = 5;
  }
}

enum HomeScreenType { logInSignup, profileInformation, liveOrders }

extension HomeScreenTypeAddition on HomeScreenType {
  Widget getHomeScreen(Driver? driver, Order? order) {
    switch (this) {
      case HomeScreenType.logInSignup:
        return const LogInSignUpScreen();
      case HomeScreenType.profileInformation:
        return ProfileInformationScreen(
          screenBlocType: ScreenBlocType.signUpBloc,
          driver: driver,
        );
      case HomeScreenType.liveOrders:
        return LiveOrdersScreen(
          order: order,
        );
    }
  }
}
