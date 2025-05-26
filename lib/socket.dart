import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:socket/message_model.dart';
import 'package:socket_io_client/socket_io_client.dart' as socket_io;

class AppSocket {
  socket_io.Socket? socket;

  final List<MessageModel> _message = [];
  StreamController<List<MessageModel>> streamController =
      StreamController.broadcast();

  void init() {
    String server = '';

    if (Platform.isAndroid) {
      server = 'ws://10.0.2.2:3900';
    } else if (Platform.isIOS) {
      server = 'ws://127.0.0.1:3900';
    }

    socket = socket_io.io(
        server,
        socket_io.OptionBuilder()
            .setTransports(['websocket'])
            .enableReconnection()
            .enableForceNew()
            .enableForceNewConnection()
            .build());

    socket!.connect();
    socket!.onConnect((v) {
      log('connect');
    });
    socket!.on('chat', (data) {
      log(data.toString());
      var message = MessageModel.fromJson(data);
      _message.add(message);
      streamController.add(_message);
    });
  }

  void sendMessage(MessageModel message) {
    _message.add(message);
    streamController.add(_message);
    socket!.emit('chat', message.toJson());
  }
}
