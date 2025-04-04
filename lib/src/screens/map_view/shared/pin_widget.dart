import 'package:flutter_sample_apps/src/constants.dart' as constants;
import 'package:flutter/material.dart';
import 'package:flutter_sample_apps/src/shared/svg_icon.dart';

class PinWidget extends StatelessWidget {
  const PinWidget({required this.pinShowNotifier});

  final ValueNotifier<bool> pinShowNotifier;

  double get _pinIconSize => constants.pinIconSize;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final pinTop = screenHeight / 2 - (_pinIconSize / 2);
    final pinLeft = screenWidth / 2 - (_pinIconSize / 2);

    return ValueListenableBuilder<bool>(
      valueListenable: pinShowNotifier,
      builder: (context, renderPin, child) {

        return !renderPin
            ? Positioned(
                top: pinTop,
                left: pinLeft,
                child: SizedBox(
                  height: _pinIconSize,
                  width: _pinIconSize,
                  child: const SvgIcon(IconName.pin),
                ),
              )
            : const SizedBox.shrink();
      },
    );
  }
}
