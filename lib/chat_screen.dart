import 'dart:io';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';
import 'package:sokett/pick.dart';
import 'package:sokett/socket.dart';
import 'message_model.dart';

final socket = AppSocket();

class ChatScreen extends StatelessWidget {
  final String name;
  ChatScreen({super.key, required this.name});
  final messagecontroller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(title: const Text('چت')),
        body: Stack(
          children: [
            Positioned.fill(
              child: Image.asset('images/bg.png', fit: BoxFit.fill),
            ),
            StreamBuilder<List<MessageModel>>(
              stream: socket.streamController.stream,
              builder: (c, s) {
                var message = s.data ?? [];
                return ListView.builder(
                  controller: _scrollController,
                  itemCount: message.length,
                  itemBuilder: (c, i) {
                    final formattedTime = DateFormat(
                      'HH:mm',
                    ).format(message[i].dateTime);

                    return getMessageWidget(
                      m: message[i],
                      formattedTime: formattedTime,
                    );
                  },
                );
              },
            ),
          ],
        ),
        bottomNavigationBar: TextField(
          style: const TextStyle(fontSize: 20),
          controller: messagecontroller,
          textInputAction: TextInputAction.send,
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: '',
            fillColor: Colors.white,
            filled: true,
            prefixIcon: IconButton(
              onPressed: () => showFileBottomSheet(context),
              icon: const Icon(Icons.archive_rounded),
            ),
            suffixIcon: Padding(
              padding: const EdgeInsets.all(8),
              child: IconButton(
                onPressed: () {
                  if (messagecontroller.text.isNotEmpty) {
                    send(message: messagecontroller.text, name: name);
                    messagecontroller.clear();
                    messageAnim();
                  }
                },
                icon: const Icon(Icons.send_rounded),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<Null> messageAnim() {
    return Future.delayed(const Duration(milliseconds: 100), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    });
  }

  void showFileBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (c) {
        return SizedBox(
          height: MediaQuery.sizeOf(context).height / 7,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              AttachmentIconButtom(
                iconData: Icons.image,
                onTap: () async {
                  var fileUrl = await pickAndUploadFile(FileType.image);
                  if (fileUrl != null) {
                    send(message: fileUrl['url'], t: MessageType.image);
                    messageAnim();
                  }
                  Navigator.pop(c);
                  FocusScope.of(c).unfocus();
                },
                title: 'Image',
              ),
              AttachmentIconButtom(
                iconData: Icons.insert_chart,
                onTap: () async {
                  var fileUrl = await pickAndUploadFile(FileType.custom);
                  if (fileUrl['url'] != null) {
                    send(
                      message: fileUrl['url'],
                      t: MessageType.doc,
                      name: fileUrl['name'],
                    );
                    messageAnim();
                  }

                  Navigator.pop(c);
                  FocusScope.of(c).unfocus();
                },
                title: 'Document',
              ),
              AttachmentIconButtom(
                iconData: Icons.video_camera_front,
                onTap: () async {
                  var fileUrl = await pickAndUploadFile(FileType.video);
                  if (fileUrl['url'] != null) {
                    send(
                      message: fileUrl['url'],
                      t: MessageType.video,
                      name: fileUrl['name'],
                    );
                    messageAnim();
                  }
                  Navigator.pop(c);
                },
                title: 'Video',
              ),
            ],
          ),
        );
      },
    );
  }
}

void send({
  String? message,
  String name = '',
  MessageType t = MessageType.text,
}) {
  socket.sendMessage(
    MessageModel(
      name: name,
      isSender: true,
      message: message!,
      type: t,
      dateTime: DateTime.now(),
    ),
  );
}

class _TextMessage extends StatelessWidget {
  const _TextMessage({required this.messageModel, required this.formattedTime});

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
            color: messageModel.isSender ? Colors.cyanAccent : Colors.white,
          ),
          child: Column(
            children: [
              if (!messageModel.isSender) ...[
                Text(
                  messageModel.name,
                  style: const TextStyle(
                    color: Color.fromARGB(255, 17, 129, 180),
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
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

getMessageWidget({required MessageModel m, required formattedTime}) {
  switch (m.type) {
    case MessageType.text:
      return _TextMessage(messageModel: m, formattedTime: formattedTime);
    case MessageType.video:
      return const SizedBox();
    case MessageType.doc:
      return DocumentWidget(formattTime: formattedTime, messageModel: m);
    case MessageType.image:
      return _ImageMessageWidget(messageModel: m, formattedTime: formattedTime);
  }
}

class _ImageMessageWidget extends StatelessWidget {
  final MessageModel messageModel;
  const _ImageMessageWidget({
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
          height: MediaQuery.sizeOf(context).height * 0.5,
          width: MediaQuery.sizeOf(context).width * 0.6,
          decoration: BoxDecoration(
            image: DecorationImage(
              fit: BoxFit.cover,
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
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AttachmentIconButtom extends StatelessWidget {
  const AttachmentIconButtom({
    super.key,
    required this.iconData,
    required this.onTap,
    required this.title,
  });

  final String title;
  final Function()? onTap;
  final IconData iconData;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsGeometry.all(8),
      child: IconButton(
        onPressed: onTap,
        icon: Column(children: [Icon(iconData), Text(title)]),
      ),
    );
  }
}

class DocumentWidget extends StatelessWidget {
  final formattTime;
  final messageModel;
  const DocumentWidget({
    super.key,
    required this.formattTime,
    required this.messageModel,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(
        messageModel.isSender ? 60 : 8,
        8,
        messageModel.isSender ? 8 : 58,

        8,
      ),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 150, 219, 71),
        borderRadius: BorderRadius.circular(20),
      ),
      child: ListTile(
        selectedColor: Colors.white,
        subtitle: Text(formattTime),
        leading: Icon(Icons.insert_drive_file),
        title: Text(messageModel.name),
        onTap: () async {
          try {
            final dir = Directory.systemTemp.path;
            final filePath = "$dir/${messageModel.name}";

            final response = await http.get(Uri.parse(messageModel.message));

            final file = File(filePath);
            await file.writeAsBytes(response.bodyBytes);

            await OpenFilex.open(filePath);
          } catch (e) {
            print("❌ خطا در دانلود/باز کردن فایل: $e");
          }
        },
      ),
    );
  }
}
