import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

class NavigatorObserverImpl extends NavigatorObserver {
  final Logger _logger;

  NavigatorObserverImpl(String name) : _logger = Logger(name);

  @override
  void didChangeTop(Route topRoute, Route? previousTopRoute) {
    _logger.info(
      'didChangeTop: ${topRoute.settings.name} ${previousTopRoute?.settings.name}',
    );
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    _logger.info(
      'didPop: ${route.settings.name} ${previousRoute?.settings.name}',
    );
  }

  @override
  void didPush(Route route, Route? previousRoute) {
    _logger.info(
      'didPush: ${route.settings.name} ${previousRoute?.settings.name}',
    );
  }

  @override
  void didRemove(Route route, Route? previousRoute) {
    _logger.info(
      'didRemove: ${route.settings.name} ${previousRoute?.settings.name}',
    );
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    _logger.info(
      'didReplace: ${newRoute?.settings.name} ${oldRoute?.settings.name}',
    );
  }

  @override
  void didStartUserGesture(Route route, Route? previousRoute) {
    _logger.info(
      'didStartUserGesture: ${route.settings.name} ${previousRoute?.settings.name}',
    );
  }

  @override
  void didStopUserGesture() {
    _logger.info('didStopUserGesture');
  }
}