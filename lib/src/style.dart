import 'package:flutter/material.dart';

const String fontNameDefault = 'Poppins';
const String dateFormatDefault = 'MM/dd/yyyy';

const cadetBlueColor = Color.fromRGBO(169, 180, 193, 1.0);
const azureRadianceColor = Color.fromRGBO(3, 126, 242, 1.0);
const whiteColor = Color.fromRGBO(255, 255, 255, 1.0);
const catskillWhiteColor = Color.fromRGBO(237, 241, 247, 1.0);
const codGrayColor = Color.fromRGBO(21, 21, 21, 1.0);
const spunPearlColor = Color.fromRGBO(177, 177, 190, 1.0);
const blackHazeColor = Color.fromRGBO(247, 248, 248, 1.0);
const doveGrayColor = Color.fromRGBO(107, 107, 107, 1.0);
const dodgerBlueColor = Color.fromRGBO(51, 102, 255, 1.0);
const blackColor = Color.fromRGBO(0, 0, 0, 1.0);
const athensGrayColor = Color.fromRGBO(248, 248, 249, 1.0);
const redColor = Color.fromRGBO(255, 16, 16, 1.0);
const blackColor42 = Color.fromRGBO(0, 0, 0, 0.42);
const greyColor = Color.fromRGBO(224, 224, 224, 1.0);

TextStyle getStyle 
    ({FontWeight? weight, double? fontSize, Color? color, double? height}) {
  return TextStyle(
      fontFamily: fontNameDefault,
      fontWeight: weight,
      fontSize: fontSize,
      height: height,
      color: color);
}

const TextStyle requestTextFieldsStyle = TextStyle(
    fontSize: 15,
    color: codGrayColor,
    fontWeight: FontWeight.w500,
    fontFamily: fontNameDefault);
const TextStyle labelTextStyle =
    TextStyle(fontSize: 13, color: cadetBlueColor, fontFamily: fontNameDefault);

const TextStyle appBarNavBtnStyle = TextStyle(
    fontWeight: FontWeight.w600,
    color: azureRadianceColor,
    fontSize: 16,
    fontFamily: fontNameDefault);

const TextStyle appBarTitleStyle = TextStyle(
    fontSize: 22, fontWeight: FontWeight.w500, fontFamily: fontNameDefault);

const TextStyle regularBlueTextStyle12 = TextStyle(
    color: cadetBlueColor,
    fontFamily: fontNameDefault,
    fontSize: 12,
    fontWeight: FontWeight.w400);

const TextStyle underlineBlueTextStyle12 = TextStyle(
    color: cadetBlueColor,
    fontFamily: fontNameDefault,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    decoration: TextDecoration.underline);

const TextStyle requestWaitingStateTextStyle = TextStyle(
  fontSize: 23,
  color: codGrayColor,
  fontWeight: FontWeight.w500,
  fontFamily: fontNameDefault,
);

const TextStyle requestWaitingStateSubtextStyle = TextStyle(
    fontSize: 23,
    color: azureRadianceColor,
    fontWeight: FontWeight.w500,
    fontFamily: fontNameDefault);
const TextStyle boldTextStyle = TextStyle(
    fontSize: 16,
    color: codGrayColor,
    fontWeight: FontWeight.w700,
    fontFamily: fontNameDefault);

const TextStyle rateStateTextStyle = TextStyle(
    fontSize: 16,
    color: codGrayColor,
    fontWeight: FontWeight.w500,
    fontFamily: fontNameDefault,
    fontStyle: FontStyle.normal);
const TextStyle viewTripBtnTextStyle = TextStyle(
    fontWeight: FontWeight.w500,
    color: azureRadianceColor,
    fontSize: 12,
    fontFamily: fontNameDefault);

const TextStyle notificationDialogTextStyle = TextStyle(
  fontSize: 16,
  color: codGrayColor,
  fontWeight: FontWeight.w700,
  fontFamily: fontNameDefault,
);
