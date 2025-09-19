import 'dart:developer';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:sokett/pick.dart';
import 'package:sokett/socket.dart';
import 'package:sokett/widget/docWidget.dart';
import 'package:sokett/widget/imageWidget.dart';
import 'package:sokett/widget/textWidget.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/message_model.dart';

final socket = AppSocket();

class ChatScreen extends StatelessWidget {
  final String name;
  final int userId;
  ChatScreen({super.key, required this.name, required this.userId});
  final messagecontroller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final keyboardV = MediaQuery.of(context).viewInsets.bottom;
    if (keyboardV > 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(microseconds: 200),
          curve: Curves.easeInOut,
        );
      });
    }
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(title: const Text('چت')),
        body: Stack(
          children: [
            Positioned.fill(
              child: Image.asset('images/bg.png', fit: BoxFit.fill),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 75),
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: client
                    .from('messages')
                    .stream(primaryKey: ['id'])
                    .order('created_at'),
                builder: (c, s) {
                  var message = s.data ?? [];
                  log(s.data.toString());
                  return ListView.builder(
                    reverse: true,
                    physics: const BouncingScrollPhysics(),
                    controller: _scrollController,
                    itemCount: message.length,
                    itemBuilder: (c, i) {
                      final createdAt = DateTime.parse(
                        message[i]['created_at'],
                      );
                      final formattedTime = DateFormat(
                        'HH:mm',
                      ).format(createdAt);

                      final msg = MessageModel(
                        name: message[i]['sender_id'].toString(),
                        isSender: message[i]['sender_id'] == userId,
                        message: message[i]['mess_txt'],
                        type: MessageType.text,
                        dateTime: createdAt,
                      );
                      return getMessageWidget(
                        m: msg,
                        formattedTime: formattedTime,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
        bottomSheet: TextField(
          style: const TextStyle(fontSize: 20),
          controller: messagecontroller,
          textInputAction: TextInputAction.send,
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: '',
            fillColor: Colors.white,
            filled: true,
            prefixIcon: IconButton(
              onPressed: () {
                FocusScope.of(context).unfocus();
                showFileBottomSheet(context);
              },
              icon: const Icon(Icons.archive_rounded),
            ),
            suffixIcon: Padding(
              padding: const EdgeInsets.all(8),
              child: IconButton(
                onPressed: () {
                  if (messagecontroller.text.isNotEmpty) {
                    sendMessage(3, userId, messagecontroller.text);

                    //send(message: messagecontroller.text, name: name);
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
                iconData: 'images/image.png',
                onTap: () async {
                  var fileUrl = await pickAndUploadFile(FileType.image);
                  if (fileUrl != null) {
                    // send(message: fileUrl['url'], t: MessageType.image);
                    messageAnim();
                  }
                  Navigator.pop(c);
                  FocusScope.of(c).unfocus();
                },
                title: 'Image',
              ),
              AttachmentIconButtom(
                iconData: 'images/file.png',
                onTap: () async {
                  var fileUrl = await pickAndUploadFile(FileType.custom);
                  if (fileUrl['url'] != null) {
                    // send(
                    //   message: fileUrl['url'],
                    //   t: MessageType.doc,
                    //   name: fileUrl['name'],
                    // );
                    messageAnim();
                  }

                  Navigator.pop(c);
                  FocusScope.of(c).unfocus();
                },
                title: 'Document',
              ),
              AttachmentIconButtom(
                iconData: 'images/video.png',
                onTap: () async {
                  var fileUrl = await pickAndUploadFile(FileType.video);
                  if (fileUrl['url'] != null) {
                    // send(
                    //   message: fileUrl['url'],
                    //   t: MessageType.video,
                    //   name: fileUrl['name'],
                    // );
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

getMessageWidget({required MessageModel m, required formattedTime}) {
  switch (m.type) {
    case MessageType.text:
      return TextMessage(messageModel: m, formattedTime: formattedTime);
    case MessageType.video:
      return const SizedBox();
    case MessageType.doc:
      return DocumentWidget(formattTime: formattedTime, messageModel: m);
    case MessageType.image:
      return ImageMessageWidget(messageModel: m, formattedTime: formattedTime);
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
  final String iconData;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsGeometry.all(8),
      child: IconButton(
        onPressed: onTap,
        icon: Column(children: [Image.asset(iconData, scale: 3), Text(title)]),
      ),
    );
  }
}

final client = Supabase.instance.client;

Future sendMessage(int recId, int userId, String txt) async {
  await client
      .from('messages')
      .insert({'sender_id': userId, 'rec_id': recId, 'mess_txt': txt})
      .select()
      .single();
}
