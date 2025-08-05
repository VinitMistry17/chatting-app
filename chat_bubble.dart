import 'package:flutter/material.dart';
import 'package:my_chatting_app/Services/chat/chat_service.dart';
import 'package:provider/provider.dart';

import '../themes/theme_provider.dart';

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isCurrentUser;
  final String messageId;
  final String userId;

  const ChatBubble({
    super.key,
    required this.message,
    required this.isCurrentUser,
    required this.messageId,
    required this.userId,
  });

  //show options
  void _showOptions(BuildContext context, String messageId, String userId) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return SafeArea(
              child: Wrap(
                children: [
                  //report message button
                  ListTile(
                    leading: const Icon(Icons.report),
                    title: const Text("Report Message"),
                    onTap: () {
                      Navigator.pop(context);
                      _reportMessage(context, messageId, userId);
                    },
                  ),
                  //block user button
                  ListTile(
                    leading: const Icon(Icons.block),
                    title: const Text("Block User"),
                    onTap: () {
                      Navigator.pop(context);
                      _blockUser(context, userId);
                    },
                  ),

                  //cancel button
                  ListTile(
                    leading: const Icon(Icons.cancel),
                    title: const Text("cancel"),
                    onTap: () => Navigator.pop(context),
                  ),
                ],
              )
          );
        }
    );
  }

  //report message
  void _reportMessage(BuildContext context, String messageId, String userId){
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Report Message"),
          content: const Text("Are you sure you want to report this message?"),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
            ),

            //report button
            TextButton(
              onPressed: () {
                ChatService().reportUser(messageId, userId);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Message reported"),
                  ),
                );
              },
              child: const Text("Report"),
            ),
          ],
        )
    );
  }

  //block user
  void _blockUser(BuildContext context, String userId){
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Block User"),
          content: const Text("Are you sure you want to block this user?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),

            //block button
            TextButton(
              onPressed: () {
                ChatService().blockUser(userId);
                //dismiss dialog
                Navigator.pop(context);
                //dismiss page
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("User Blocked!"),
                  ),
                );
              },
              child: const Text("Block"),
            ),
          ],
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    //light vs dark mode for correct bubble color
    bool isDarkMode = Provider.of<ThemeProvider>(context, listen: false).isDarkMode;
    return GestureDetector(
      onLongPress: () {
        if(!isCurrentUser){
          _showOptions(context,messageId, userId);
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: isCurrentUser
              ?(isDarkMode ? Colors.green.shade600 : Colors.grey.shade500) :
          (isDarkMode ? Colors.grey.shade900 : Colors.grey.shade200),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.symmetric(vertical: 2.5, horizontal: 25),
        child: Text(
            message,
          style: TextStyle(color: isCurrentUser ? Colors.white : (isDarkMode? Colors.white : Colors.black)),
        ),
      ),
    );
  }
}
