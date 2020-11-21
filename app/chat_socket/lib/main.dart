import 'package:chat_socket/screens/AllChatsPage.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import 'models/ChatModel.dart';

void main() {
  runApp(MyApp());
}
// todo tutorial : https://school.geekwall.in/p/-mR8NDvPU/realtime-chat-app-one-to-one-using-flutter-socket-io-node-js
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScopedModel(
      model: ChatModel(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: AllChatsPage(),
      ),
    );
  }
}

