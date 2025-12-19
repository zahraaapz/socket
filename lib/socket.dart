import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:socket_io_client/socket_io_client.dart' as socket_io;
import 'model/message_model.dart';

enum StatusType { online, offline, typing }

class AppSocket {
  socket_io.Socket? socket;
  ValueNotifier<StatusType> status = ValueNotifier(StatusType.online);

  final List<MessageModel> _message = [];
  StreamController<List<MessageModel>> streamController =
      StreamController.broadcast();

  Future<void> init() async {
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
          .build(),
    );

    socket!.connect();
    socket!.onConnect((v) {
      log('connect');
      status.value = StatusType.online;
    });

    socket!.on('chat', (data) {
      log(data.toString());
      var message = MessageModel.fromJson(data);
      _message.add(message);
      streamController.add(_message);
    });
    socket!.on('disconnect', (data) {
      log(data.toString());
      status.value = data == false ? StatusType.offline : StatusType.online;
    });
    socket!.on('typing', (data) {
      log('TYPING EVENT RECEIVED: $data');

      data
          ? status.value = StatusType.typing
          : status.value = StatusType.online;
    });
  }

  void sendMessage(MessageModel message) {
    _message.add(message);
    streamController.add(_message);
    socket?.emit('chat', message.toJson());
  }

  void sendTyping(bool isTyping) {
    socket!.emit('typing', isTyping);
  }

  void dispose() {
    socket!.close();
  }
}
