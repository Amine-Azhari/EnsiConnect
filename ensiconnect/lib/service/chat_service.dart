import 'package:cloud_firestore/cloud_firestore.dart';

class ChatService {
  ChatService({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

    final FirebaseFirestore _db;

    // Trouver les conversations d'un utilisateur
    Stream<QuerySnapshot> getConversations(String userId) {
      return _db
          .collection('conversations')
          .where('participants', arrayContains: userId)
          .orderBy('lastMessageAt', descending: true)
          .snapshots();
    }

    Stream<QuerySnapshot> getMessages(String conversationId) {
      return _db
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .orderBy('createdAt', descending: false)
        .snapshots();
    }

    Future<void> sendMessage({
      required String conversationId,
      required String senderId,
      required String content,
    }) async {
      final messageRef = _db
          .collection('conversations')
          .doc(conversationId)
          .collection('messages');

      await messageRef.add({
        'senderId': senderId,
        'content': content,
        'createdAt': FieldValue.serverTimestamp(),
      });
  }
}