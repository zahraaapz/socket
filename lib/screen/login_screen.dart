import 'package:flutter/material.dart';
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
              onPressed: () {
                String name = controller.text.trim();

                if (name.isNotEmpty) {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (c) => ChatScreen(name: name)),
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
