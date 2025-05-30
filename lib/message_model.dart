enum MessageType { text, doc, image, video }

class MessageModel {
  final String name;
  final String message;
  final MessageType type;
  final bool isSender;

  MessageModel(
      {required this.name,
      required this.isSender,
      required this.message,
      required this.type});

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
        name: json['name'],
        isSender: false,
        message: json['message'],
        type: json['type']);
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'isSender': isSender,
      'message': message,
      'type': type
    };
  }
}
