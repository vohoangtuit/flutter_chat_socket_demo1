import 'dart:convert';

import 'package:chat_socket/models/ChatModel.dart';
import 'package:chat_socket/models/Message.dart';
import 'package:chat_socket/models/User.dart';
import 'package:flutter/material.dart';
import 'package:flutter_socket_io/flutter_socket_io.dart';
import 'package:scoped_model/scoped_model.dart';

class ChatPage extends StatefulWidget {
  final User friend;
  ChatPage(this.friend);
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController textEditingController = TextEditingController();

  bool typing =false;
  SocketIO socketIO;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.friend.name),
      ),
      // body: ListView(
      //   children: <Widget>[
      //     buildChatList(),
      //     buildChatArea(),
      //   ],
      // ),
      body: Stack(
        children: [
          Column(
            children: [
              buildChatList(),
             buildTyping(),
              buildChatArea(),
            ],
          )
        ],
      ),
    );
  }
  @override
  void initState() {
    super.initState();

  }

  Widget buildSingleMessage(Message message) {
    return Container(
      alignment: message.senderID == widget.friend.chatID
          ? Alignment.centerLeft
          : Alignment.centerRight,
      padding: EdgeInsets.all(10.0),
      margin: EdgeInsets.all(10.0),
      child: Text(message.text),
    );
  }

  Widget buildChatList() {
    return Flexible(
      child: ScopedModelDescendant<ChatModel>(
        builder: (context, child, model) {
          List<Message> messages =
          model.getMessagesForChatID(widget.friend.chatID);

          return Container(
            height: MediaQuery.of(context).size.height * 0.75,
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (BuildContext context, int index) {
                return buildSingleMessage(messages[index]);
              },
            ),
          );
        },
      ),
    );
  }
  Widget buildTyping(){
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left:7.0,top: 5.0,right: 0.0,bottom: 2.0),
          child: Text(
            typing?'typing...':'',style: TextStyle(color: Colors.lightBlue, fontSize: 11),
          ),
        ),
      ],
    );
  }
  Widget buildChatArea() {
    return ScopedModelDescendant<ChatModel>(
      builder: (context, child, model) {
        textEditingController.addListener(() {
          if(textEditingController.text.isNotEmpty){
            model.handleTyping(true,model.currentUser);
          }else{
            //  print("stop typing");
            model.handleTyping(false,model.currentUser);
          }
        });
        return Container(
          color: Colors.black12,
          child: Padding(
            padding: const EdgeInsets.only(left: 8.0,top: 0.0,right: 0.0,bottom: 0.0),
            child: Row(
              children: <Widget>[
                Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: TextField(
                    controller: textEditingController,
                  ),
                ),
                SizedBox(width: 10.0),
                FloatingActionButton(
                  onPressed: () {
                    model.sendMessage(
                        textEditingController.text, widget.friend.chatID);
                    textEditingController.text = '';
                  },
                  elevation: 0,
                  child: Icon(Icons.send),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}