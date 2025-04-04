import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sample_apps/src/home_screen_initialization.dart';
import 'package:flutter_sample_apps/src/screens/login_signup/login_signup_screen.dart';
import 'package:flutter_sample_apps/src/screens/login_signup/profile_information/sign_up_bloc/sign_up_bloc.dart';
import 'package:flutter_sample_apps/src/screens/login_signup/profile_information/sign_up_bloc/sign_up_event.dart';
import 'package:flutter_sample_apps/src/screens/map_view/map_view.dart';
import 'package:flutter_sample_apps/src/screens/profile/profile_information/sign_up_information_screen.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:provider/provider.dart';

//DriveHopClient
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initHiveForFlutter();
  WidgetsFlutterBinding.ensureInitialized();
  final homeScreenType = await initHomeScreen();
  Provider.debugCheckInvalidValueType = null;

  runApp(
    MyApp(
      homeScreenType: homeScreenType,
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key, required this.homeScreenType}) : super(key: key);

  final HomeScreenType homeScreenType;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        dividerColor: Colors.transparent,
      ),
      home: BlocProvider<SignUpBloc>(
        create: (context) {
          return SignUpBloc()..add(const CheckConnectivityEvent());
        },
        child: homeScreenType._getHomeScreen(),
      ),
    );
  }
}

enum HomeScreenType { logInSignup, profileInformation, mapView }

extension _HomeScreenTypeAddition on HomeScreenType {
  Widget _getHomeScreen() {
    switch (this) {
      case HomeScreenType.logInSignup:
        return const LogInSignUpScreen();
      case HomeScreenType.profileInformation:
        return const ProfileInformationSignUp();
      case HomeScreenType.mapView:
        return MapView(order: HomeScreenType.mapView.getOrder());
    }
  }
}


class A extends StatefulWidget {
  const A({super.key});

  @override
  State<A> createState() => _AState();
}

class _AState extends State<A> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
