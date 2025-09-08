enum MessageType { text, doc, image, video }

class MessageModel {
  final String name;
  final String message;
  final MessageType type;
  final bool isSender;
  final DateTime dateTime;

  MessageModel({
    required this.dateTime,
    required this.name,
    required this.isSender,
    required this.message,
    required this.type,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      dateTime: DateTime.parse(json['dateTime']),
      name: json['name'],
      isSender: false,
      message: json['message'],
      type: MessageType.values[json['type']],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'dateTime': dateTime.toIso8601String(),
      'isSender': isSender,
      'message': message,
      'type': type.index,
    };
  }
}
