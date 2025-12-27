import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sokett/viewModel/view_model.dart';
import '../model/message_model.dart';
import '../data/pick.dart';
import '../data/socket.dart';
import '../widget/textWidget.dart';
import '../widget/imageWidget.dart';
import '../widget/docWidget.dart';

class ChatScreen extends StatefulWidget {
  final String contName;
  final String name;
  const ChatScreen({super.key, required this.contName, required this.name});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late final ChatViewModel vm;
  final messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    vm = ChatViewModel(AppSocket())..init();
  }

  @override
  void dispose() {
    vm.dispose();
    messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage(
    String text, {
    MessageType type = MessageType.text,
    String? name,
  }) {
    final msg = MessageModel(
      message: text,
      name: name ?? widget.name,
      isSender: true,
      type: type,
      dateTime: DateTime.now(),
    );
    vm.sendMessage(msg);
    messageController.clear();
    vm.sendTyping(false);
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
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
                title: 'Image',
                onTap: () async {
                  var fileUrl = await pickAndUploadFile(FileType.image);
                  if (fileUrl != null) {
                    _sendMessage(fileUrl['url'], type: MessageType.image);
                  }
                  Navigator.pop(c);
                  FocusScope.of(c).unfocus();
                },
              ),
              AttachmentIconButtom(
                iconData: 'images/file.png',
                title: 'Document',
                onTap: () async {
                  var fileUrl = await pickAndUploadFile(FileType.custom);
                  if (fileUrl['url'] != null) {
                    _sendMessage(
                      fileUrl['url'],
                      type: MessageType.doc,
                      name: fileUrl['name'],
                    );
                  }
                  Navigator.pop(c);
                  FocusScope.of(c).unfocus();
                },
              ),
              AttachmentIconButtom(
                iconData: 'images/video.png',
                title: 'Video',
                onTap: () async {
                  var fileUrl = await pickAndUploadFile(FileType.video);
                  if (fileUrl['url'] != null) {
                    _sendMessage(
                      fileUrl['url'],
                      type: MessageType.video,
                      name: fileUrl['name'],
                    );
                  }
                  Navigator.pop(c);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget getMessageWidget({
    required MessageModel m,
    required String formattedTime,
  }) {
    switch (m.type) {
      case MessageType.text:
        return TextMessage(messageModel: m, formattedTime: formattedTime);
      case MessageType.image:
        return ImageMessageWidget(
          messageModel: m,
          formattedTime: formattedTime,
        );
      case MessageType.doc:
        return DocumentWidget(formattTime: formattedTime, messageModel: m);
      case MessageType.video:
        return const SizedBox();
    }
  }

  @override
  Widget build(BuildContext context) {
    final keyboardV = MediaQuery.of(context).viewInsets.bottom;
    if (keyboardV > 0) _scrollToBottom();

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
                  stream: vm.messagesStream,
                  builder: (_, snapshot) {
                    final messages = snapshot.data ?? [];
                    return ListView.builder(
                      padding: const EdgeInsets.only(top: 60),
                      physics: const ClampingScrollPhysics(),
                      controller: _scrollController,
                      itemCount: messages.length,
                      itemBuilder: (_, i) {
                        final msg = messages[i];
                        final formattedTime = DateFormat(
                          'HH:mm',
                        ).format(msg.dateTime);
                        return getMessageWidget(
                          m: msg,
                          formattedTime: formattedTime,
                        );
                      },
                    );
                  },
                ),
              ),
              Container(
                height: 60,
                width: double.infinity,
                color: Colors.white,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text(widget.contName),
                    ValueListenableBuilder<StatusType>(
                      valueListenable: vm.status,
                      builder: (_, status, __) {
                        switch (status) {
                          case StatusType.typing:
                            return const Text('...typing');
                          case StatusType.offline:
                            return const Text('offline');
                          case StatusType.online:
                            return const Text('online');
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomSheet: TextField(
          controller: messageController,
          onChanged: (v) => vm.sendTyping(v.isNotEmpty),
          textInputAction: TextInputAction.send,
          style: const TextStyle(fontSize: 20),
          decoration: InputDecoration(
            border: InputBorder.none,
            fillColor: Colors.white,
            filled: true,
            prefixIcon: IconButton(
              icon: const Icon(Icons.archive_rounded),
              onPressed: () {
                FocusScope.of(context).unfocus();
                showFileBottomSheet(context);
              },
            ),
            suffixIcon: Padding(
              padding: const EdgeInsets.all(8),
              child: IconButton(
                icon: const Icon(Icons.send_rounded),
                onPressed: () => _sendMessage(messageController.text),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AttachmentIconButtom extends StatelessWidget {
  final String title;
  final String iconData;
  final VoidCallback? onTap;

  const AttachmentIconButtom({
    super.key,
    required this.title,
    required this.iconData,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: IconButton(
        onPressed: onTap,
        icon: Column(children: [Image.asset(iconData, scale: 3), Text(title)]),
      ),
    );
  }
}
