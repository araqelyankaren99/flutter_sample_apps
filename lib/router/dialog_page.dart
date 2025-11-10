import 'package:flutter/material.dart';
class DialogPage extends Page {
  final Widget child;

  const DialogPage({
    super.key,
    super.name,
    super.arguments,
    super.restorationId,
    super.canPop,
    super.onPopInvoked,
    required this.child,
  });

  @override
  Route createRoute(BuildContext context) => DialogRoute(
    context: context,
    settings: this,
    builder: (context) => child,
  );
}