import 'package:flutter/material.dart';
import 'package:socket/chat_screen.dart';

class LoginScreen extends StatelessWidget{

final controller=TextEditingController();

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return SafeArea(child: Scaffold(
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: 25),
        children: [

          Image.asset('images/logo.png'),
          TextField(
            controller:controller ,
          decoration: InputDecoration(hintText: 'kk'),),
          SizedBox(height: 20,),
          ElevatedButton(onPressed: (){

String name=controller.text.trim();

if (name.isNotEmpty) {
  Navigator.of(context).push(MaterialPageRoute(builder:(c)=>ChatScreen() ));
}




          }, child:Text(' ورود  به چت'))
        ],
        
      ),
    ));
  }
  
}