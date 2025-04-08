import 'package:flutter_sample_apps/constants.dart' as constants;
import 'package:flutter_sample_apps/shared/app_bar_widget.dart';
import 'package:flutter_sample_apps/shared/text_area.dart';
import 'package:flutter_sample_apps/style.dart';
import 'package:flutter/material.dart';

class CommentView extends StatelessWidget {
  const CommentView({required this.comment});

  final String comment;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: blackHazeColor,
        body: SafeArea(
          child: Column(children: [
            _renderAppBar(context),
            Expanded(child: _renderTextArea())
          ],),
        ),);
  }

  Widget _renderAppBar(BuildContext context) {
    return AppBarWidget(
      titleText: 'Comment',
      titleStyle: appBarTitleStyle,
      prefixWidget: Padding(
        padding: EdgeInsets.symmetric(
            vertical: 17 * constants.rh(context),
            horizontal: 17 * constants.rw(context),),
        child: InkWell(
            onTap: () => Navigator.pop(context),
            child: const Text('Cancel', style: appBarNavBtnStyle),),
      ),
    );
  }

  Widget _renderTextArea() {
    return TextArea(
      controller: TextEditingController(text: comment),
    );
  }
}
