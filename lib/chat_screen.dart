import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:socket/message_model.dart';
import 'package:socket/socket.dart';

String _name = '';
final _socket = AppSocket();

class ChatScreen extends StatelessWidget {
  ChatScreen({super.key});
  final messagecontroller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: const Text('jk')),
        body: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'images/bg.png',
                fit: BoxFit.fill,
              ),
            ),
            StreamBuilder<List<MessageModel>>(
                stream: _socket.streamController.stream,
                builder: (c, s) {
                  var message = s.data ?? [];
                  return ListView.builder(
                      itemCount: message.length,
                      itemBuilder: (c, i) {
                        return _TextMessage(messageModel: message[i]);
                      });
                }),
          ],
        ),
        bottomSheet: TextField(
          controller: messagecontroller,
          textInputAction: TextInputAction.send,
          decoration: InputDecoration(
              hintText: '',
              fillColor: Colors.white,
              filled: true,
              prefixIcon: IconButton(
                  onPressed: () => showFileBottomSheet(context),
                  icon: const Icon(Icons.archive_rounded)),
              suffixIcon: Padding(
                padding: const EdgeInsets.all(8),
                child: IconButton(
                    onPressed: () {
                      if (messagecontroller.text.isNotEmpty) {
                        send(messagecontroller.text);
                        messagecontroller.clear();
                      }
                    },
                    icon: const Icon(Icons.send_rounded)),
              )),
        ),
      ),
    );
  }

  void showFileBottomSheet(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (c) {
          return Container(
            height: 150,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
              AttachmentIconButtom(iconData: Icons.image, onTap: (){}, title: 'Image'),
              AttachmentIconButtom(iconData: Icons.document_scanner_rounded, onTap: (){}, title: 'Document'),
              AttachmentIconButtom(iconData: Icons.video_camera_front, onTap: (){}, title: 'Video'),
              ],
            ),
          );
        });
  }
}

void send(String message, [MessageType t = MessageType.text]) {
  _socket.sendMessage(
      MessageModel(name: _name, isSender: true, message: message, type: t));
}

class _TextMessage extends StatelessWidget {
  const _TextMessage({super.key, required this.messageModel});

  final MessageModel messageModel;
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
              color: messageModel.isSender ? Colors.lime[400] : Colors.white),
          child: Column(
            children: [
              if (!messageModel.isSender) ...[
                Text(
                  messageModel.name,
                  style: const TextStyle(color: Colors.black45),
                )
              ],
              Text(
                messageModel.message,
                style: const TextStyle(color: Colors.black),
              )
            ],
          ),
        ),
      ),
    );
  }
}


class AttachmentIconButtom extends StatelessWidget{


 AttachmentIconButtom( {super.key,  required this.iconData,required this.onTap,required this.title});
  
  String title;
  Function()? onTap;
  IconData iconData;
  @override
  Widget build(BuildContext context) {
  return   Padding(
                  padding: const EdgeInsetsGeometry.all(8),
                  child: IconButton(
                      onPressed: onTap,
                      icon: Column(
                        children: [
                          Icon(iconData),
                          Text(title)
                        ],
                      )),
                );
  }

}