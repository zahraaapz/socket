import 'dart:developer';
import 'dart:io';
import 'dart:ui';
import 'package:socket_io_client/socket_io_client.dart' as io;

class AppSocket {
  io.Socket? _socket;

  void init({
    required VoidCallback onConnect,
    required VoidCallback onDisconnect,
    required Function(dynamic error) onConnectError,
    required Function(dynamic data) onMessage,
    required Function(bool isTyping) onTyping,
  }) {
    final server = Platform.isAndroid
        ? 'http://10.0.2.2:3900'
        : 'http://127.0.0.1:3900';

    _socket = io.io(
      server,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .enableReconnection()
          .setReconnectionAttempts(5)
          .setReconnectionDelay(3000)
          .build(),
    );

    _socket!.connect();

    _socket!.onConnect((_) {
      log('socket connected');
      onConnect();
    });

    _socket!.onDisconnect((_) {
      log('socket disconnected');
      onDisconnect();
    });

    _socket!.onConnectError((error) {
      log('connect error: $error');
      onConnectError(error);
    });

    _socket!.on('chat', onMessage);

    _socket!.on('typing', (data) => onTyping(data == true));
  }

  void sendMessage(Map<String, dynamic> data) {
    _socket?.emit('chat', data);
  }

  void sendTyping(bool typing) {
    _socket?.emit('typing', typing);
  }

  void dispose() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
  }
}
