import 'dart:io';

Future<void> main(List<String> args) async {
  final port = args.isNotEmpty ? int.parse(args.first) : 8080;
  final clients = <WebSocket>{};
  var nextId = 1;

  final server = await HttpServer.bind(InternetAddress.anyIPv4, port);
  print('WebSocket server listening on ws://0.0.0.0:$port');
  for (final interface in await NetworkInterface.list(type: InternetAddressType.IPv4)) {
    for (final address in interface.addresses) {
      print('  ${interface.name}: ws://${address.address}:$port');
    }
  }

  await for (final request in server) {
    if (!WebSocketTransformer.isUpgradeRequest(request)) {
      request.response
        ..statusCode = HttpStatus.badRequest
        ..write('WebSocket connections only')
        ..close();
      continue;
    }

    final socket = await WebSocketTransformer.upgrade(request);
    final id = nextId++;
    final remote = request.connectionInfo?.remoteAddress.address;
    clients.add(socket);
    print('[client $id] connected from $remote (${clients.length} online)');

    socket.listen(
          (message) {
        print('[client $id] -> $message');
        for (final client in clients) {
          if (client != socket) {
            client.add(message);
          }
        }
      },
      onError: (Object error) => print('[client $id] error: $error'),
      onDone: () {
        clients.remove(socket);
        print('[client $id] disconnected (${clients.length} online)');
      },
    );
  }
}
