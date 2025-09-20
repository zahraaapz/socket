import 'package:flutter/material.dart';
import 'package:sokett/screen/chat_screen.dart';

class ContactsScreen extends StatelessWidget {
  ContactsScreen({super.key, required this.cont, required this.name});
  List cont = [];
  final name;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            SizedBox(
              height: 550,
              child: ListView.builder(
                itemCount: cont.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: InkWell(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (c) => ChatScreen(
                              contName: cont[index]['name'],
                              name: name,
                            ),
                          ),
                        );
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(radius: 40),
                              SizedBox(width: 20),
                              Text(cont[index]['name']),
                            ],
                          ),

                          Text(cont[index]['time']),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Align(
              alignment: AlignmentGeometry.bottomRight,
              child: Container(
                margin: EdgeInsets.all(8),
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(40),
                ),
                child: IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.add, size: 30, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
