import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';

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

    // Trouver les messages dans une conversation
    Stream<QuerySnapshot> getMessages(String conversationId) {
      return _db
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .orderBy('createdAt', descending: false)
        .snapshots();
    }

    // Envoyer un message
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

      await _db.collection('conversations').doc(conversationId).update({
      'lastMessage': content,
      'lastMessageAt': FieldValue.serverTimestamp(),
    });
  }

  // Créer une conversation
  Future<String> createConversation({
    required List<String> participants,
    String? name,
  }) async {
    final doc = await _db.collection('conversations').add({
      'participants': participants,
      'name': name,
      'lastMessage': '',
      'lastMessageAt': FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
    });

    return doc.id;
  }

  // Vérifier si une conversation existe. Si non, la créer 
  Future<String> getOrCreateConversation({
    required List<String> participants,
    String? name,
  }) async {
    final query = await _db
        .collection('conversations')
        .where('participants', arrayContainsAny: participants)
        .get();

    for (final doc in query.docs) {
      final data = doc.data();

      final existingParticipants = List<String>.from(data['participants']);
      final existingName = data['name'];

      final sameParticipants =
        Set.from(existingParticipants).containsAll(participants) &&
        Set.from(participants).containsAll(existingParticipants);

      final sameName = existingName == name;

      if (sameParticipants && sameName) {
        return doc.id;
      }
    }

    return createConversation(
      participants: participants, 
      name: name
    );
  }


  Future<void> addUserIntoConversation({
    required String userId,
    required String conversationId
  }) async {
    final query = await _db
        .collection('conversations')
        .doc(conversationId)
        .update({
          'participants': FieldValue.arrayUnion([userId]),
        });  
  }

    Future<void> deleteUserFromConversation({
    required String userId,
    required String conversationId
  }) async {
    final query = await _db
        .collection('conversations')
        .doc(conversationId)
        .update({
          'participants': FieldValue.arrayRemove([userId]),
        });
  }

  // A demander d'implémenter dans user_service
  CollectionReference<Map<String, dynamic>> get _etudiants =>
      _db.collection('Etudiant');

  Future<User?> getUserById(String userId) async {
    final doc = await _etudiants.doc(userId).get();

    if (!doc.exists) return null;

    final data = doc.data()!;

    return User(
      id: doc.id,
      firstName: data['Prenom'] ?? '',
      lastName: data['Nom'] ?? '',
      email: data['eMail'] ?? '',
      promotion: data['Promotion'] ?? '1A',
      filiere: data['Filiere'] ?? 'Informatique',
      role: data['Role'] ?? 'Étudiant',
      description: data['description'] ?? '',
      skills: List<String>.from(data['skills'] ?? []),
      sessions: (data['sessions'] ?? 0),
      averageNote: (data['averageNote'] ?? 0.0),
    );
  }
}