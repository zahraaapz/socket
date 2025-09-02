import 'package:flutter/material.dart';
import 'package:sokett/message_model.dart';

class ImageMessageWidget extends StatelessWidget {
  final MessageModel messageModel;
  const ImageMessageWidget({
    required this.messageModel,
    required this.formattedTime,
  });
  final formattedTime;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Align(
        alignment: messageModel.isSender
            ? Alignment.centerRight
            : Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.all(8.0),
          height: MediaQuery.sizeOf(context).height * 0.4,
          width: MediaQuery.sizeOf(context).width * 0.6,
          decoration: BoxDecoration(
            image: DecorationImage(
              fit: BoxFit.fill,
              image: Image.network(messageModel.message).image,
            ),
            borderRadius: BorderRadius.circular(8),
            color: Colors.white,
          ),
          child: Align(
            alignment: AlignmentGeometry.bottomLeft,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                formattedTime,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color.fromARGB(255, 0, 0, 0),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
