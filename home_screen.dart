import 'package:flutter/material.dart';
import 'package:my_chatting_app/components/my_drawer.dart';

import '../Services/auth/auth_service.dart';
import '../Services/chat/chat_service.dart';
import '../components/user_tile.dart';
import 'chat_screen.dart';


class HomePage extends StatelessWidget {
  HomePage({super.key});

  //chat & auth services
  final ChatService _chatService = ChatService();
  final AuthServices _authServices = AuthServices();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home"),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.grey,
        elevation: 0,
      ),
      drawer: const MyDrawer(),
      body: _buildUsersList(),
    );
  }

  //build a list of users except for the current logged in users
Widget _buildUsersList() {
    return StreamBuilder(
        stream: _chatService.getUsersStreamExcludingBlocked(),
        builder: (context, snapshot) {
          //error
          if (snapshot.hasError) {
            return Text("Error");
          }
          //loading
          if (snapshot.connectionState == ConnectionState.waiting){
            return const Text("Loading");
          }
            //loading

          //return list view
          return ListView(
              children: snapshot.data!.map<Widget>((userData) => _buildUsersListItem(userData, context)).toList(),
          );
        }
    );
  }

  //build individual list tile for user
  Widget _buildUsersListItem(Map<String, dynamic> userData, BuildContext context){
    //display all users except the current
    if(userData['email'] != _authServices.getCurrentUser()!.email){
      return UserTile(
        text: userData['email'],
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatPage(
                receiverEmail: userData['email'],
                receiverID: userData['uid'],
              ),
            ),
          );
        },
      );
    } else{
      return Container();
    }
  }
}
