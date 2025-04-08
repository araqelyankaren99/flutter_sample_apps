import 'package:flutter_sample_apps/constants.dart' as constants;
import 'package:flutter_sample_apps/style.dart';
import 'package:flutter/material.dart';

class DeleteIconWidget extends StatelessWidget {
  const DeleteIconWidget({this.onTapDelete});

  final VoidCallback? onTapDelete;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: -2,
      right: -2,
      child: Container(
        decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: [
          BoxShadow(
              blurRadius: 15,
              color: whiteColor.withOpacity(0.8),
              spreadRadius: 2,)
        ],),
        child: InkWell(
          onTap: onTapDelete,
          child: Icon(
            Icons.cancel,
            size: 30 * constants.rw(context),
            color: doveGrayColor,
          ),
        ),
      ),
    );
  }
}
