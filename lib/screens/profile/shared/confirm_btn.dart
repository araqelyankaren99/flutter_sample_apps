import 'package:flutter_sample_apps/middlewares/extension/string.dart';
import 'package:flutter_sample_apps/style.dart';
import 'package:flutter/material.dart';

class ConfirmButton extends StatelessWidget {
  const ConfirmButton(
      {this.onConfirmTap,
      this.confirmButtonLoading = false,
      this.isActive = true,});
  final GestureTapCallback? onConfirmTap;
  final bool confirmButtonLoading;
  final bool isActive;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isActive ? onConfirmTap : null,
      child: confirmButtonLoading
          ? Stack(
              alignment: Alignment.center,
              children: [
                Text(
                  'Confirm',
                  style: getStyle(color: azureRadianceColor),
                ),
                Positioned(
                  child: Container(
                    alignment: Alignment.center,
                    height: 'Confirm'.heightOfText(context, getStyle()),
                    width: 'Confirm'.heightOfText(context, getStyle()),
                    child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(whiteColor),),
                  ),
                ),
              ],
            )
          : Text(
              'Confirm',
              style: getStyle(color: Colors.white),
            ),
    );
  }
}
