import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'chat_screen.dart';

class LoginScreen extends StatelessWidget {
  final controller = TextEditingController();

  LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          children: [
            Image.asset('images/logo.png', scale: 0.5),
            TextField(
              style: const TextStyle(fontSize: 22),
              controller: controller,
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintStyle: TextStyle(fontSize: 22),
                hintText: 'نام خود را وارد کنید',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(Colors.cyan),
              ),
              onPressed: () async {
                String name = controller.text.trim();
                final userId = await login(name);
                log(userId.toString());
                if (userId != null) {
                  if (!context.mounted) return;

                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (c) => ChatScreen(name: name, userId: userId),
                    ),
                  );
                }
              },
              child: const Text(' ورود  به چت', style: TextStyle(fontSize: 22)),
            ),
          ],
        ),
      ),
    );
  }
}

Future login(String name) async {
  final client = Supabase.instance.client;
  final exitUser = await client
      .from('users')
      .select('id')
      .eq('user_name', name)
      .maybeSingle();

  if (exitUser != null) {
    return exitUser['id'] as int;
  } else {
    final newuser = await client
        .from('users')
        .insert({'user_name': name})
        .select()
        .single();
    return newuser['id'] as int;
  }
}
