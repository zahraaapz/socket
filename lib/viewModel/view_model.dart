import 'dart:async';
import '../data/socket.dart';
import '../../model/message_model.dart';
import 'package:flutter/foundation.dart';

enum StatusType { online, offline, typing }

class ChatViewModel {
  final AppSocket _socket;

  ChatViewModel(this._socket);

  final StreamController<List<MessageModel>> _messageController =
      StreamController.broadcast();
  Stream<List<MessageModel>> get messagesStream => _messageController.stream;

  final ValueNotifier<StatusType> status = ValueNotifier(StatusType.offline);

  final List<MessageModel> _messages = [];

  void init() {
    _socket.init(
      onConnect: () => status.value = StatusType.online,
      onDisconnect: () => status.value = StatusType.offline,
      onConnectError: (_) => status.value = StatusType.offline,
      onMessage: (data) {
        final msg = MessageModel.fromJson(Map<String, dynamic>.from(data));
        _messages.add(msg);
        _messageController.add(List.unmodifiable(_messages));
      },
      onTyping: (isTyping) {
        status.value = isTyping ? StatusType.typing : StatusType.online;
      },
    );
  }

  void sendMessage(MessageModel message) {
    _messages.add(message);
    _messageController.add(List.unmodifiable(_messages));
    _socket.sendMessage(message.toJson());
  }

  void sendTyping(bool typing) {
    _socket.sendTyping(typing);
  }

  void dispose() {
    _socket.dispose();
    _messageController.close();
    status.dispose();
  }
}
