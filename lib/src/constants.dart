library constants;

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

const int relativeWidth = 414; // iPhone 11 Pro Max screen width
const int relativeHeight = 896; // iPhone 11 Pro Max screen height
const milesCoefficient = 0.621371;
const String driveHopEmail = 'drivehope@gmail.com';
const String graphQlLinkTest = 'http://54.177.67.167:3000/graphql';
const String graphQlLinkLive = 'http://55.53.242.195:3000/graphql';
const String subscriptionLiveEndpoint = 'ws://57.53.242.195:3000/graphql';
const String subscriptionTestEndpoint = 'ws://54.177.67.167:3000/graphql';
const String graphQlLink = 'https://drivehopserver.herokuapp.com/graphql';
const String driveHopPageUrl = 'https://support@drivehope.com';
const String driveHopPrivacyPolicy = 'http://drivehop.com/privacy-policy/';
const String driveHopTerm = 'http://drivehop.com/terms/';
const String apiKey = 'AIzaSyCeCQORHP-lAu1CEWsu59u64hr_ZMvRLmA';
const String directionsApiBaseUrl =
    'https://maps.googleapis.com/maps/api/directions/json?';
const int driverImagesCount = 3;
const double oneImagePercentage = 100 / driverImagesCount;
bool get isTestMode => _isTestMode;
const bool _isTestMode = false;
const pinIconSize = 40.0;
double rw(BuildContext context) {
  return rwWidth(MediaQuery.of(context).size.width);
}

double rwWidth(double width) {
  return width / relativeWidth;
}

double rh(BuildContext context) {
  return rhHeight(MediaQuery.of(context).size.height);
}

double rhHeight(double height) {
  return height / relativeHeight;
}

Future<void> launchURL(String url) async {
  if (await canLaunch(url)) {
    try {
      await launch(url);
    } catch (e) {
      //throw "Server cannot be found";
    }
  } else {
    throw 'Could not launch $url';
  }
}

const List transmissionTypes = [
  'Automatic',
  'Manual',
  'Continuously variable transmission',
  'Semi-automatic and dual-clutch'
];

String getGraphQlLink() {
  return _isTestMode ? graphQlLinkTest : graphQlLinkLive;
}

String getSubscriptionEndpoint() {
  return _isTestMode ? subscriptionTestEndpoint : subscriptionLiveEndpoint;
}
