import 'package:flutter_sample_apps/src/constants.dart' as constants;
import 'package:flutter/material.dart';
import 'package:flutter_sample_apps/src/shared/app_bar_widget.dart';
import 'package:flutter_sample_apps/src/style.dart';

class AboutAppPage extends StatelessWidget {
  const AboutAppPage({required this.aboutAppText});
  final String aboutAppText;
  @override
  Widget build(BuildContext context) {
    Widget _renderAppBar() {
      return ClipRRect(
        borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(10 * constants.rw(context)),
            bottomRight: Radius.circular(10 * constants.rw(context))),
        child: AppBarWidget(
          backgroundColor: Colors.white,
          titleText: 'About',
          titleStyle: getStyle(weight: FontWeight.w500, fontSize: 20),
          prefixWidget: InkWell(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back_sharp),
          ),
        ),
      );
    }

    Widget _renderText() {
      return Flexible(
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
          ),
          margin: EdgeInsets.symmetric(
            horizontal: 10 * constants.rw(context),
            vertical: 10 * constants.rh(context),
          ),
          padding: EdgeInsets.fromLTRB(
              20 * constants.rw(context),
              20 * constants.rh(context),
              20 * constants.rw(context),
              40 * constants.rh(context)),
          child: SingleChildScrollView(
            child: Text(
              aboutAppText,
              style: getStyle(
                color: Colors.grey,
                fontSize: 12,
                weight: FontWeight.w500,
              ),
            ),
          ),
        ),
      );
    }

    Widget _render() {
      return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          bottom: false,
          child: Stack(
            children: [
              Container(color: blackHazeColor),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _renderAppBar(),
                  _renderText(),
                ],
              ),
            ],
          ),
        ),
      );
    }

    return _render();
  }
}
