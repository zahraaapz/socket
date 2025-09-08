import 'package:flutter/material.dart';
import 'screen/chat_screen.dart';
import 'screen/login_screen.dart';

void main() {
  socket.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: LoginScreen());
  }
}
