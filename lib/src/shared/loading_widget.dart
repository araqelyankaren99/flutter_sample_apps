import 'package:flutter/material.dart';

class LoadingWidget extends StatelessWidget {
  const LoadingWidget(
      {required this.child,
      required this.isLoading,
      this.backgroundColor = Colors.white,});

  final bool isLoading;
  final Widget child;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor:
          isLoading ? Colors.white.withOpacity(0.6) : backgroundColor,
      body: IgnorePointer(
        ignoring: isLoading,
        child: Stack(
          children: [
            child,
            if (isLoading) const _LoaderWidget() else const SizedBox.shrink()
          ],
        ),
      ),
    );
  }
}

class _LoaderWidget extends StatelessWidget {
  const _LoaderWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.white.withOpacity(0.6),
      child: const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
          strokeWidth: 2,
        ),
      ),
    );
  }
}
