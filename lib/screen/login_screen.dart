import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'contacts_screen.dart';

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
                final list = await getContact();
                if (name.isNotEmpty) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (c) => ContactsScreen(cont: list, name: name),
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

Future<List> getContact() async {
  final res = await http.get(Uri.parse('http://10.0.2.2:3900/users'));
  final List users = jsonDecode(res.body);
  log(users.toString());
  return users;
}
