import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

import '../../Models/message.dart';

class ChatService extends ChangeNotifier {
  //get instance of firestore & auth
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;


  //get all user stream
  Stream<List<Map<String, dynamic>>> getUsersStream(){
    return _firestore.collection('users').snapshots().map((event) {
      return event.docs.map((doc) {
        return doc.data();
      }).toList();
    });
  }
  //get all user stream except blocked user
  Stream<List<Map<String, dynamic>>> getUsersStreamExcludingBlocked() {
    final currentUser = _auth.currentUser;

    return _firestore
        .collection('users')
        .doc(currentUser!.uid)
        .collection('blockedUsers')
        .snapshots()
        .asyncMap((snapshot) async {
      // get list of blocked user ids
      final blockedUserIds = snapshot.docs.map((doc) => doc.id).toList();

      // get all users
      final usersSnapshot = await _firestore.collection('users').get();

      // filter out blocked users and current user
      return usersSnapshot.docs
          .where((doc) =>
      doc.data()['email'] != currentUser.email &&
          !blockedUserIds.contains(doc.id))
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    });
  }


  //send messages
  Future<void> sendMessage(String receiverID, message) async {
    //get current user info
    final String CurrentUserID = _auth.currentUser!.uid;
    final String CurrentUserEmail = _auth.currentUser!.email!;
    final Timestamp timestamp = Timestamp.now();

    //create a new message
    Message newMessage = Message(
      senderId: CurrentUserID,
      senderEmail: CurrentUserEmail,
      receiverId: receiverID,
      message: message,
      timestamp: timestamp,
    );

    //construct chat room ID for two users (stored to ensure uniqueness)
    List<String> ids = [CurrentUserID, receiverID];
    ids.sort();//sort the ids (this ensure the chatRoomID is the same for any two people)
    String chatRoomID = ids.join('_');

    //add new message to database
    await _firestore.collection('chatRooms').doc(chatRoomID).collection('messages').add(newMessage.toMap());
  }

  //get messages
  Stream<QuerySnapshot> getMessages(String userID, otherUserID) {
    List<String> ids = [userID, otherUserID];
    ids.sort();
    String chatRoomID = ids.join('_');
    return _firestore
        .collection('chatRooms')
        .doc(chatRoomID)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  //report user

  Future<void> reportUser(String messageID, userID) async {
    final currentUser = _auth.currentUser;
    final report = {
      'reportedBy': currentUser!.uid,
      'messageID': messageID,
      'messageOwnerID': userID,
      'timestamp': FieldValue.serverTimestamp(),
    };
    await _firestore.collection('reports').add(report);
  }

  //block user
  Future<void> blockUser(String userID) async {
    final currentUser = _auth.currentUser;
    await _firestore
        .collection('users')
        .doc(currentUser!.uid)
        .collection('blockedUsers')
        .doc(userID)
        .set({'blocked': true});
    notifyListeners();
  }

  //unblock user
  Future<void> unblockUser(String blockedUserID) async {
    final currentUser = _auth.currentUser;
    await _firestore
        .collection('users')
        .doc(currentUser!.uid)
        .collection('blockedUsers')
        .doc(blockedUserID)
        .delete();
  }

  //get blocked user stream
  Stream<List<Map<String, dynamic>>> getBlockedUsersStream(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('blockedUsers')
        .snapshots()
        .asyncMap((snapshot) async {
          //get list of blocked user ids
      final blockedUserIds = snapshot.docs.map((doc) => doc.id).toList();

      final userDocs = await Future.wait(
        blockedUserIds.map((id) => _firestore.collection('users').doc(id).get()),
      );

      //return list of blocked users
      return userDocs
          .where((doc) => doc.exists)
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    });
  }

}
