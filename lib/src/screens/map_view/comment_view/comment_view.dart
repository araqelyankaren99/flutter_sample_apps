import 'package:flutter_sample_apps/src/constants.dart' as constants;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sample_apps/src/screens/map_view/select_address_map_view/bloc/main_bloc.dart';
import 'package:flutter_sample_apps/src/shared/app_bar_widget.dart';
import 'package:flutter_sample_apps/src/shared/text_area.dart';
import 'package:flutter_sample_apps/src/style.dart';

class CommentView extends StatefulWidget {
  const CommentView();
  @override
  _CommentState createState() => _CommentState();
}

class _CommentState extends State<CommentView> {
  MainBloc get _mainBloc => BlocProvider.of<MainBloc>(context);

  final TextEditingController _controller = TextEditingController();
  @override
  void initState() {
    super.initState();
    _controller.text = _mainBloc.order.comment ?? '';
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _render();
  }

  Widget _render() {
    return Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: blackHazeColor,
        body: SafeArea(
          child: Column(
              children: [_renderAppBar(), Expanded(child: _renderTextArea())]),
        ));
  }

  Widget _renderAppBar() {
    return AppBarWidget(
        titleText: 'Comment',
        titleStyle: appBarTitleStyle,
        prefixWidget: Padding(
          padding: EdgeInsets.symmetric(
              vertical: 17 * constants.rh(context),
              horizontal: 17 * constants.rw(context)),
          child: InkWell(
              onTap: () => _onCancel(),
              child: const Text('Cancel', style: appBarNavBtnStyle)),
        ),
        suffixWidget: Padding(
          padding: EdgeInsets.symmetric(
              vertical: 17 * constants.rh(context),
              horizontal: 17 * constants.rw(context)),
          child: InkWell(
              onTap: () => _onDone(),
              child: const Text(
                'Done',
                style: appBarNavBtnStyle,
              )),
        ));
  }

  Widget _renderTextArea() {
    return TextArea(
      controller: _controller,
      hintText: 'Write your comment',
      hintStyle: const TextStyle(fontSize: 15, fontFamily: fontNameDefault),
    );
  }

  /// Set to valueNotifier inputted text and back MapView screen
  void _onDone() {
    _mainBloc.add(AddCommentEvent(comment: _controller.text.trim()));

    Navigator.pop(context);
  }

  /// Back MapView screen
  void _onCancel() {
    Navigator.pop(context);
  }
}
