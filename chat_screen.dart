import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:my_chatting_app/components/my_textfield.dart';

import '../Services/auth/auth_service.dart';
import '../Services/chat/chat_service.dart';
import '../components/chat_bubble.dart';

class ChatPage extends StatefulWidget {
  final String receiverEmail;
  final String receiverID;

  ChatPage({
    super.key,
    required this.receiverEmail,
    required this.receiverID,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  //text controller
  final TextEditingController _messageController = TextEditingController();

  //chat & auth services
  final ChatService _chatService = ChatService();
  final AuthServices _authServices = AuthServices();

  //for textfield focus
  FocusNode myFocusNode = FocusNode();

  @override
  void initState(){
    super.initState();

    //add listener to focus node
    myFocusNode.addListener(() {
      if(myFocusNode.hasFocus){
        //cause the delay so that the keyboard has time to show up
        //then the amount of remaining space will be calculated
        //and the listview will scroll down
        Future.delayed(const Duration(microseconds: 500),
                () => scrollDown(),
        );
      }
    });

    //wait a bit for listview to be built, then scroll to bottom
    Future.delayed(const Duration(microseconds: 500),
            () => scrollDown(),
    );
  }

  @override
  void dispose(){
    myFocusNode.dispose();
    _messageController.dispose();
    super.dispose();
  }

  //scroll controller
  final ScrollController _scrollController = ScrollController();
  void scrollDown() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(seconds: 1),
      curve: Curves.fastOutSlowIn,
    );
  }

  //send message
  void sendMessage() async{
    //if there is something inside the textfield
    if(_messageController.text.isNotEmpty) {
      //send message
      await _chatService.sendMessage(widget.receiverID, _messageController.text);
      //clear textfield
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.receiverEmail),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.grey,
        elevation: 0,
      ),
      body: Column(
        children: [
          //display all messages
          Expanded(
              child: _buildMessageList(),
          ),

          //user input
          _buildUserInput(),
        ]
          //messages
      ),
    );
  }

  //build message lis
  Widget _buildMessageList() {
    String senderID = _authServices.getCurrentUser()!.uid;
    return StreamBuilder(
      stream: _chatService.getMessages(senderID, widget.receiverID),
        builder: (context, snapshot) {
          //error
          if (snapshot.hasError) {
            return Text("Error");
          }
          //loading
          if (snapshot.connectionState == ConnectionState.waiting){
            return const Text("Loading");
          }

          //return listview
          return ListView(
            controller: _scrollController,
            reverse: true,
            children: snapshot.data!.docs.map((doc) => _buildMessageItem(doc)).toList(),
          );
        }
        //loading
    );
  }

  //build message item
  Widget _buildMessageItem(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    //is current user
    bool isCurrentUser = data['senderId'] == _authServices.getCurrentUser()!.uid;

    //align message to the right side if sender is current user , otherwise left side
    var alignment = isCurrentUser ? Alignment.centerRight : Alignment.centerLeft;
    return Container(
      alignment: alignment,
        child: Column(
          crossAxisAlignment:

          isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,

          children: [
            ChatBubble(
              message: data['message'],
              isCurrentUser: isCurrentUser,
              messageId: doc.id,
              userId: data['senderId'],
            ),
          ],
        )
    );
  }

  //build message input
  Widget _buildUserInput() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 50.0),
      child: Row(
        children: [
          //textfiel should takeup most of the space
          Expanded(
              child: MyTextfield(
                  hintText: "Type a message...",
                  controller: _messageController,
                  obscureText: false,
                  focusNode: myFocusNode,
              ),
          ),

          //send button
          Container(
            decoration: const BoxDecoration(
                color: Colors.green,
              shape: BoxShape.circle,
            ),
            margin: const EdgeInsets.only(right: 25),
            child: IconButton(
              onPressed: sendMessage,
              icon: Icon(
                  Icons.send,
                color: Colors.white,
              ),
            ),
          ),
        ]
      ),
    );
  }
}
