import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/message_model.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Send message
  Future<void> sendMessage(String receiverId, String content, String type) async {
    final String currentUserId = _auth.currentUser!.uid;
    final String messageId = _firestore.collection('messages').doc().id;
    final String timestamp = DateTime.now().toString();

    MessageModel message = MessageModel(
      messageId: messageId,
      senderId: currentUserId,
      receiverId: receiverId,
      content: content,
      type: type,
      timestamp: timestamp,
    );

    // Create chat room ID from user IDs (sorted to ensure consistency)
    List<String> ids = [currentUserId, receiverId];
    ids.sort(); // Sort the ids to ensure the chatroom id is always the same for any pair
    String chatroomId = ids.join('_');

    // Add message to firestore
    await _firestore
        .collection('chatrooms')
        .doc(chatroomId)
        .collection('messages')
        .doc(messageId)
        .set(message.toMap());

    // Update last message in chatroom
    await _firestore.collection('chatrooms').doc(chatroomId).set({
      'lastMessage': content,
      'lastMessageTime': timestamp,
      'participants': ids,
    }, SetOptions(merge: true));
  }

  // Get messages stream
  Stream<QuerySnapshot> getMessages(String userId, String otherUserId) {
    // Create chat room ID from user IDs (sorted to ensure consistency)
    List<String> ids = [userId, otherUserId];
    ids.sort();
    String chatroomId = ids.join('_');

    return _firestore
        .collection('chatrooms')
        .doc(chatroomId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // Get chat rooms for current user
  Stream<QuerySnapshot> getChatrooms() {
    String userId = _auth.currentUser!.uid;

    return _firestore
        .collection('chatrooms')
        .where('participants', arrayContains: userId)
        .orderBy('lastMessageTime', descending: true)
        .snapshots();
  }

  // Mark message as read
  Future<void> markMessageAsRead(String chatroomId, String messageId) async {
    await _firestore
        .collection('chatrooms')
        .doc(chatroomId)
        .collection('messages')
        .doc(messageId)
        .update({'isRead': true});
  }
}