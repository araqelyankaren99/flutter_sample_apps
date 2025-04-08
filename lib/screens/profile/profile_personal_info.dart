import 'dart:typed_data';

import 'package:flutter_sample_apps/constants.dart' as constants;
import 'package:flutter_sample_apps/models/driver.dart';
import 'package:flutter_sample_apps/style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class ProfilePersonalInfo extends StatelessWidget {
  const ProfilePersonalInfo({
    required this.driver,
    required this.loading,
  });

  final Driver? driver;
  final bool loading;

  String get firstname => driver?.firstName ?? '';
  String get lastname => driver?.lastName ?? '';
  double get rating => driver?.rating ?? 0.0;
  Uint8List? get imageBytes => driver?.profileImageBytes;

  @override
  Widget build(BuildContext context) {
    Widget _renderRaiting() {
      return Container(
        padding: EdgeInsets.only(top: 10 * constants.rh(context)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            SvgPicture.asset(
              'assets/images/star.svg',
              semanticsLabel: 'Rating',
              height: 20,
              color: azureRadianceColor,
            ),
            Container(
              margin: EdgeInsets.only(left: 10 * constants.rw(context)),
              child: Text(
                rating.toStringAsFixed(2),
                style: getStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      );
    }

    Widget _renderText(String text, {EdgeInsets padding = EdgeInsets.zero}) {
      return Padding(
        padding: padding,
        child: Text(
          text,
          style: getStyle(color: Colors.white, fontSize: 16),
        ),
      );
    }

    Widget _renderFirstnameAndLastname() {
      return Row(
        children: [
          _renderText(
            firstname,
            padding: EdgeInsets.only(
              right: 10 * constants.rw(context),
            ),
          ),
          _renderText(
            lastname,
            padding: EdgeInsets.only(
              right: 20 * constants.rw(context),
            ),
          ),
        ],
      );
    }

    Widget _renderDefaultProfilePicture() {
      return Image.asset(
        'assets/images/profile_default_image.png',
        height: 80 * constants.rw(context),
        width: 80 * constants.rw(context),
      );
    }

    Widget _renderProfilePictureFromServer() {
      final image = imageBytes;
      if (image != null) {
        return Image.memory(
          image,
          fit: BoxFit.cover,
          height: 80 * constants.rw(context),
          width: 80 * constants.rw(context),
        );
      }
      return _renderDefaultProfilePicture();
    }

    Widget _loadingProfileImage() {
      return SizedBox(
        height: 80 * constants.rw(context),
        width: 80 * constants.rw(context),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    Widget _renderProfilePictureContainer() {
      return Container(
        decoration:
            const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
        margin: EdgeInsets.only(
            left: 20 * constants.rw(context),
            right: 20 * constants.rw(context),),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(50.0 * constants.rw(context)),
          child: loading
              ? _loadingProfileImage()
              : imageBytes == null
                  ? _renderDefaultProfilePicture()
                  : _renderProfilePictureFromServer(),
        ),
      );
    }

    return SafeArea(
      child: Container(
        margin: EdgeInsets.only(
          top: 50 * constants.rh(context),
          bottom: 10 * constants.rh(context),
        ),
        child: Row(
          children: [
            _renderProfilePictureContainer(),
            Flexible(
              child: FittedBox(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _renderFirstnameAndLastname(),
                    _renderRaiting(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
