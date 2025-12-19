import 'dart:developer';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:sokett/pick.dart';
import 'package:sokett/socket.dart';
import 'package:sokett/widget/docWidget.dart';
import 'package:sokett/widget/imageWidget.dart';
import 'package:sokett/widget/textWidget.dart';
import '../model/message_model.dart';

final socket = AppSocket();

class ChatScreen extends StatefulWidget {
  final String contName;
  final String name;
  ChatScreen({super.key, required this.contName, required this.name});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final messagecontroller = TextEditingController();

  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    messagecontroller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

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

        body: ClipRect(
          clipBehavior: Clip.hardEdge,
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.asset('images/bg.png', fit: BoxFit.fill),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 75),
                child: StreamBuilder<List<MessageModel>>(
                  stream: socket.streamController.stream,
                  builder: (c, s) {
                    var message = s.data ?? [];
                    log(s.data.toString());
                    messageAnim();
                    return ListView.builder(
                      physics: const ClampingScrollPhysics(),
                      controller: _scrollController,
                      itemCount: message.length,
                      itemBuilder: (c, i) {
                        final createdAt = DateTime.parse(
                          message[i].dateTime.toString(),
                        );
                        final formattedTime = DateFormat(
                          'HH:mm',
                        ).format(createdAt);

                        return getMessageWidget(
                          m: message[i],
                          formattedTime: formattedTime,
                        );
                      },
                    );
                  },
                ),
              ),
              Container(
                height: 60,
                width: 550,
                color: Colors.white,
                child: ValueListenableBuilder<StatusType>(
                  valueListenable: socket.status,

                  builder: (_, status, _) => Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text(widget.contName),
                      status == StatusType.online
                          ? Text('online')
                          : status == StatusType.offline
                          ? Text('offline')
                          : Text('...typing'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        bottomSheet: TextField(
          onChanged: (value) {
            socket.sendTyping(value.isNotEmpty);
          },
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
                    send(message: messagecontroller.text, name: widget.name);
                    messagecontroller.clear();
                    messageAnim();
                    socket.sendTyping(false);
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
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeIn,
          );
        }
      });
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
                    send(message: fileUrl['url'], t: MessageType.image);
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
                iconData: 'images/video.png',
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
