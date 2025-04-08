import 'package:flutter/material.dart';

class LoadingWidget extends StatefulWidget {
  const LoadingWidget(
      {required this.child,
      required this.isLoading,
      this.backgroundColor = Colors.white,});

  final bool isLoading;
  final Widget child;
  final Color backgroundColor;

  @override
  State<StatefulWidget> createState() => _LoadingWidgetState();
}

class _LoadingWidgetState extends State<LoadingWidget> {
  @override
  Widget build(BuildContext context) {
    return _circularProgressIndicator();
  }

  Widget _circularProgressIndicator() {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: widget.isLoading
            ? Colors.white.withOpacity(0.6)
            : widget.backgroundColor,
        body: IgnorePointer(
            ignoring: widget.isLoading,
            child: Stack(children: [
              widget.child,
              Visibility(
                  visible: widget.isLoading,
                  child: Container(
                      alignment: Alignment.center,
                      color: Colors.white.withOpacity(0.6),
                      child: const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(Colors.black),
                        strokeWidth: 2,
                      ),),),
            ],),),);
  }
}
