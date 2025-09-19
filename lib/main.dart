import 'package:flutter/material.dart';
import 'package:sokett/secret.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screen/chat_screen.dart';
import 'screen/login_screen.dart';

void main() async {
  //socket.init();
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(anonKey: pkey, url: url);
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
