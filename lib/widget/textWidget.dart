import 'package:flutter/material.dart';
import 'package:sokett/model/message_model.dart';

class TextMessage extends StatelessWidget {
  const TextMessage({required this.messageModel, required this.formattedTime});

  final MessageModel messageModel;
  final formattedTime;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsGeometry.all(8),
      child: Align(
        alignment: messageModel.isSender
            ? Alignment.centerRight
            : Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: messageModel.isSender
                ? Color.fromRGBO(219, 204, 172, 1)
                : Colors.white,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!messageModel.isSender) ...[
                Text(
                  messageModel.name,
                  style: const TextStyle(
                    color: Color.fromARGB(255, 0, 0, 0),
                    fontSize: 20,
                  ),
                ),
              ],
              Text(
                messageModel.message,
                style: const TextStyle(color: Colors.black, fontSize: 22),
              ),
              Text(
                formattedTime,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color.fromARGB(255, 0, 0, 0),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
