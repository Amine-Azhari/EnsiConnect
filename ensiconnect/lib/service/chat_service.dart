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

}