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
        appBar: AppBar(title: Text('jk')),
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
                        return Container(
                          child: Text(message[i].message),
                        );
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
              suffixIcon: Padding(
                padding: EdgeInsets.all(8),
                child: IconButton(
                    onPressed: () {
                      if (messagecontroller.text.isNotEmpty) {
                        send(messagecontroller.text);
                        messagecontroller.clear();
                      }
                    }, icon: Icon(Icons.send_rounded)),
              )),
        ),
      ),
    );
  }
}
