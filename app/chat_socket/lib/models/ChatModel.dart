import 'dart:convert';

import 'package:chat_socket/utils/Constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_socket_io/flutter_socket_io.dart';
import 'package:flutter_socket_io/socket_io_manager.dart';
import 'package:scoped_model/scoped_model.dart';

import 'Message.dart';
import 'User.dart';

class ChatModel extends Model {
  List<User> users = [
    User('Vo Hoang Duy', '111'),
    User('Hoang Tu Vo', '222'),
    User('Nguyen Van A', '333'),
    User('Phan Van B', '444'),
    User('Huynh Thi Kieu Van', '555'),
  ];

  User currentUser;
  List<User> friendList = List<User>();
  List<Message> messages = List<Message>();
  SocketIO socketIO;
  bool typing;
  // ChatModel( {ValueChanged typing}){
  //   this.typing =typing;
  // }
  void init() {
    currentUser=users[0];// user 1
    //currentUser=users[1]; //user 2
    friendList = users.where((user) => user.chatID != currentUser.chatID).toList();

    socketIO = SocketIOManager().createSocketIO(
        Constants().SOCKET_URL, '/',
        query: 'chatID=${currentUser.chatID}');
    socketIO.init();

    socketIO.subscribe('receive_message', (jsonData) {// todo: receive message form server socket
      Map<String, dynamic> data = json.decode(jsonData);
      print("receive_message ----- "+data['content']);
      messages.add(Message(
          data['content'], data['senderChatID'], data['receiverChatID']));
      notifyListeners();
    });

    socketIO.subscribe('typing', (jsonData) {// todo: receive message form server socket
      Map<String, dynamic> data = json.decode(jsonData);
      print("typing ----- "+data.toString());
      typing =true;
      notifyListeners();

    });
    socketIO.subscribe('stop_typing', (jsonData) {// todo: receive message form server socket
      Map<String, dynamic> data = json.decode(jsonData);
      print("stop_typing ----- "+data.toString());
      typing =false;
      notifyListeners();
    });

    socketIO.connect();
  }
  void handleTyping(bool typing,User user,User friend){
    if(typing){// todo send message to server socket
      socketIO.sendMessage(
        'typing',
        json.encode({
          'senderChatID': user.chatID,
          'receiverChatID': friend.chatID,
        }),
      );
    }else{
      socketIO.sendMessage(
        'stop_typing',
        json.encode({
          'senderChatID': user.chatID,
          'receiverChatID': friend.chatID,
        }),
      );
    }
  }


  void sendMessage(String text, String receiverChatID) {
    // if(socketIO==null){
    //   print("sendMessage socketIO==null ");
    //   return;
    // }
    messages.add(Message(text, currentUser.chatID, receiverChatID));
    socketIO.sendMessage(// todo send message to server socket
      'send_message',
      json.encode({
        'receiverChatID': receiverChatID,
        'senderChatID': currentUser.chatID,
        'content': text,
      }),
    );
    notifyListeners();
  }

  List<Message> getMessagesForChatID(String chatID) {
    return messages
        .where((msg) => msg.senderID == chatID || msg.receiverID == chatID)
        .toList();
  }
}