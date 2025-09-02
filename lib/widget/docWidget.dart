import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:open_filex/open_filex.dart';

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
        color: const Color.fromARGB(255, 218, 217, 162),
        borderRadius: BorderRadius.circular(20),
      ),
      child: ListTile(
        selectedColor: Colors.white,
        subtitle: Text(formattTime),
        leading: Image.asset('images/file.png', scale: 2),
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
