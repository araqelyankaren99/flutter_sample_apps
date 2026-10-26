import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/status.dart' as ws_status;
import 'package:web_socket_channel/web_socket_channel.dart';

enum SocketStatus { disconnected, connecting, connected, error }

typedef SocketMessageListener = void Function(dynamic message);

const String socketUrl = String.fromEnvironment(
  'SOCKET_URL',
  defaultValue: 'ws://192.168.1.3:8080',
);

class SocketService {
  SocketService._();

  static final SocketService instance = SocketService._();

  WebSocketChannel? _channel;
  StreamSubscription? _subscription;
  final List<SocketMessageListener> _listeners = [];

  SocketStatus _status = SocketStatus.disconnected;

  SocketStatus get status => _status;

  bool get isConnected => _status == SocketStatus.connected;

  void _setStatus(SocketStatus newStatus) {
    if (_status == newStatus) {
      return;
    }
    debugPrint('Socket status changed: ${_status.name} -> ${newStatus.name}');
    _status = newStatus;
  }

  Future<void> connect({String url = socketUrl}) async {
    if (_status == SocketStatus.connecting || isConnected) {
      return;
    }

    _setStatus(SocketStatus.connecting);
    try {
      final channel = WebSocketChannel.connect(Uri.parse(url));
      await channel.ready;
      _channel = channel;
      _setStatus(SocketStatus.connected);

      _subscription = channel.stream.listen(
            (message) {
          debugPrint('Socket received: $message');
          for (final listener in List.of(_listeners)) {
            listener(message);
          }
        },
        onError: (Object error) {
          debugPrint('Socket error: $error');
          _setStatus(SocketStatus.error);
        },
        onDone: () {
          debugPrint('Socket closed: code=${channel.closeCode}, reason=${channel.closeReason}');
          _channel = null;
          _subscription = null;
          if (_status != SocketStatus.error) {
            _setStatus(SocketStatus.disconnected);
          }
        },
      );
    } on Object catch (e) {
      debugPrint('Socket connect failed: $e');
      _channel = null;
      _setStatus(SocketStatus.error);
    }
  }

  bool send(dynamic message) {
    final channel = _channel;
    if (channel == null || !isConnected) {
      debugPrint('Socket send skipped, status: ${_status.name}');
      return false;
    }
    channel.sink.add(message);
    debugPrint('Socket sent: $message');
    return true;
  }

  void addListener(SocketMessageListener listener) => _listeners.add(listener);

  void removeListener(SocketMessageListener listener) => _listeners.remove(listener);

  Future<void> disconnect() async {
    await _subscription?.cancel();
    _subscription = null;
    await _channel?.sink.close(ws_status.normalClosure);
    _channel = null;
    _setStatus(SocketStatus.disconnected);
  }
}