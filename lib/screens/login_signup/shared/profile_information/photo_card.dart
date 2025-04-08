import 'dart:io';

import 'package:flutter_sample_apps/constants.dart' as constants;
import 'package:flutter_sample_apps/models/image_item.dart';
import 'package:flutter_sample_apps/screens/login_signup/shared/profile_information/delete_icon_widget.dart';
import 'package:flutter_sample_apps/style.dart';
import 'package:flutter/material.dart';

class PhotoCard extends StatelessWidget {
  const PhotoCard(
      {required this.photoType,
      this.photo,
      this.onTapDelete,
      this.onTapAddPhoto,});
  final PhotoType photoType;
  final File? photo;
  final VoidCallback? onTapDelete;
  final VoidCallback? onTapAddPhoto;
  @override
  Widget build(BuildContext context) {
    final width =
        (MediaQuery.of(context).size.width - 80 * constants.rw(context)) / 2;
    Widget _renderAddButton() {
      return Container(
          alignment: Alignment.center,
          child: ClipOval(
            child: Material(
              color: doveGrayColor.withOpacity(0.6),
              child: InkWell(
                onTap: onTapAddPhoto,
                child: SizedBox(
                  width: 80 * constants.rh(context),
                  height: 80 * constants.rh(context),
                  child: Icon(
                    Icons.add,
                    color: whiteColor,
                    size: 40 * constants.rh(context),
                  ),
                ),
              ),
            ),
          ),);
    }

    final _photo = photo;
    Widget _renderBody() {
      if (photo != null) {
        return Stack(
          children: <Widget>[
            ClipRRect(
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20), topRight: Radius.circular(20),),
              child: SizedBox(
                  width: width,
                  height: width,
                  child: Image.file(
                    _photo!,
                    fit: BoxFit.cover,
                  ),),
            ),
            DeleteIconWidget(onTapDelete: onTapDelete),
          ],
        );
      }
      return Column(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20),),
            child: Container(
                width: width,
                height: width,
                color: athensGrayColor,
                child: Stack(children: [_renderAddButton()]),),
          ),
        ],
      );
    }

    return Column(
      children: [
        _renderBody(),
        ClipRRect(
            borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),),
            child: Container(
                padding:
                    EdgeInsets.symmetric(vertical: 5 * constants.rh(context)),
                width: width,
                color: doveGrayColor.withOpacity(0.6),
                child: Text(photoType.uiName(),
                    textAlign: TextAlign.center,
                    style:
                        getStyle(color: whiteColor, weight: FontWeight.w600),),),)
      ],
    );
  }
}
