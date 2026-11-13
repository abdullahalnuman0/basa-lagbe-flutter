import 'dart:async';

import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../config.dart';

const _nul = '\u0000';

class StompClient {
  StompClient({String baseUrl = AppConfig.baseUrl}) : wsUrl = toWsUrl(baseUrl);

  final String wsUrl;

  static String toWsUrl(String baseUrl) {
    final url = baseUrl.replaceFirst('https://', 'wss://').replaceFirst('http://', 'ws://');
    final idx = url.indexOf('/api/');
    return '${idx == -1 ? url : url.substring(0, idx)}/ws';
  }

  Stream<String> subscribe(String topic) {
    WebSocketChannel? socket;
    StreamSubscription<dynamic>? sub;
    late final StreamController<String> controller;

    controller = StreamController<String>(
      onListen: () {
        var subscribed = false;
        try {
          // the realtime socket only pings; a quiet connection must not be torn down
          socket = IOWebSocketChannel.connect(
            Uri.parse(wsUrl),
            pingInterval: const Duration(seconds: 20),
          );
        } catch (_) {
          controller.close();
          return;
        }
        socket!.sink.add('CONNECT\naccept-version:1.2\nheart-beat:0,0\n\n$_nul');
        sub = socket!.stream.listen(
          (frame) {
            if (frame is! String) return;
            final command = frame.split('\n').first.trim();
            if (command == 'CONNECTED' && !subscribed) {
              subscribed = true;
              socket!.sink.add('SUBSCRIBE\nid:sub-0\ndestination:$topic\n\n$_nul');
            } else if (command == 'MESSAGE') {
              final body = parseBody(frame);
              if (body.isNotEmpty && !controller.isClosed) controller.add(body);
            } else if (command == 'ERROR') {
              controller.close();
            }
          },
          onError: (_) => controller.close(),
          onDone: () => controller.close(),
          cancelOnError: true,
        );
      },
      onCancel: () async {
        await sub?.cancel();
        await socket?.sink.close(1000);
      },
    );
    return controller.stream;
  }

  /// Body is everything after the blank line, minus the NUL terminator.
  static String parseBody(String frame) {
    final idx = frame.indexOf('\n\n');
    if (idx == -1) return '';
    var body = frame.substring(idx + 2);
    if (body.endsWith(_nul)) body = body.substring(0, body.length - 1);
    return body.trim();
  }
}
