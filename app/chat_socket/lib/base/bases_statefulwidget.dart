import 'dart:convert';

import 'package:chat_socket/models/ChatModel.dart';
import 'package:chat_socket/models/Message.dart';
import 'package:chat_socket/models/User.dart';
import 'package:chat_socket/utils/Constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_socket_io/flutter_socket_io.dart';
import 'package:flutter_socket_io/socket_io_manager.dart';

abstract class BaseStatefulState<T extends StatefulWidget> extends State<T> {
 static BaseStatefulState baseStatefulState;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
 SocketIO socketIO;
 List<Message> messages = List<Message>();
  bool onStart =false;
 User currentUser;
  @override
  Widget build(BuildContext context) {

    return Stack(
      key: _scaffoldKey,
      children: <Widget>[

      ],
    );
  }

  @override
  void initState() {
    super.initState();
    print("onStart "+onStart.toString());
    currentUser=ChatModel().users[0];// user 1
    currentUser=ChatModel().users[1];// user 2
    messages =ChatModel().messages;
  }
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    print("onStart 1 "+onStart.toString());
    if(!onStart){
      baseStatefulState=this;
  //    productViewModel = new ProductViewModel(baseStatefulState);
    //  userViewModel = new UserViewModel(baseStatefulState);

      onStart =true;
    }
  }
  void initSocketIO(){
    socketIO = SocketIOManager().createSocketIO(
        Constants().SOCKET_URL, '/',
        query: 'chatID=${currentUser.chatID}');
    socketIO.init();

    socketIO.subscribe('receive_message', (jsonData) {// todo: receive message form server socket
      Map<String, dynamic> data = json.decode(jsonData);
      print("receive_message ----- "+data['content']);
      messages.add(Message(
          data['content'], data['senderChatID'], data['receiverChatID']));
      //notifyListeners();
    });

    socketIO.subscribe('typing', (jsonData) {// todo: receive message form server socket
      Map<String, dynamic> data = json.decode(jsonData);
      print("typing ----- "+data.toString());
     // typing(true);

    });
    socketIO.subscribe('stop_typing', (jsonData) {// todo: receive message form server socket
      Map<String, dynamic> data = json.decode(jsonData);
      print("stop_typing ----- "+data.toString());
    //  typing(false);
    });

    socketIO.connect();
  }
  addFunction(Function function){
    Future.delayed(Duration.zero, () async {
      function();
    });
  }
  @override
  void dispose() {
  //  progressBar.hide();
    super.dispose();
  }
  void showLoading() {
   // progressBar.show(context);
  }

  void hideLoading() {
   // progressBar.hide();
  }

  void baseMethod() {
    // Parent method
  }


}
