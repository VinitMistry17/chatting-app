import 'package:flutter/material.dart';
import 'package:my_chatting_app/Services/auth/auth_service.dart';

import '../Services/chat/chat_service.dart';
import '../components/user_tile.dart';

class BlockedUsersPage extends StatelessWidget {
  BlockedUsersPage({super.key});

  //chat & auth services
  final ChatService _chatService = ChatService();
  final AuthServices _authService = AuthServices();

  //show conform unblock box
  void _showUnblockBox(BuildContext context, String userId){
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Unblock User"),
          content: Text("Are you sure you want to unblock this user?"),
          actions: [
            //cancel button
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),

            //unblock button
            TextButton(
              onPressed: () {
                _chatService.unblockUser(userId);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("User unblocked"),
                  )
                );
              },
              child: Text("Unblock"),
            )
          ]
        )
    );
  }


  @override
  Widget build(BuildContext context) {
    //get current user id
    String userId = _authService.getCurrentUser()!.uid;

    //UI
    return Scaffold(
      appBar: AppBar(
        title: Text("Blocked Users"),
        actions: [],
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _chatService.getBlockedUsersStream(userId),
        builder: (context, snapshot) {
          //errors..
          if(snapshot.hasError){
            return const Center(
              child: Text("Something went wrong"),
            );
          }

          //loading..
          if(snapshot.connectionState == ConnectionState.waiting){
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          //data
          final blockedUsers = snapshot.data ?? [];

          //no users
          if(blockedUsers.isEmpty){
            return const Center(
              child: Text("No blocked users"),
            );
          }

          //load complete
          return ListView.builder(
            itemCount: blockedUsers.length,
            itemBuilder: (context, index){
              final blockedUser = blockedUsers[index];
              return UserTile(
                text: blockedUser["email"],
                onTap: () => _showUnblockBox(context, blockedUser["uid"]),
              );
            }
          );
        }

      )
    );
  }
}
