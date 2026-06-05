import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/session.dart';

class SessionService {
  SessionService({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _sessions =>
      _db.collection('Session');

  Future<DocumentReference<Map<String, dynamic>>> createHelpRequestSession(
    Session session,
  ) {
    return _sessions.add(session.toMap());
  }

  Stream<List<Session>> watchHelpRequestSessions() {
    return _sessions
        .where('Type', isEqualTo: 'demande_aide')
        .snapshots()
        .map((snapshot) {
      final sessions = snapshot.docs
          .map((doc) => Session.fromMap(doc.data(), doc.id))
          .toList();

      sessions.sort((a, b) => b.date.compareTo(a.date));
      return sessions;
    });
  }

  Future<void> deleteSession(String sessionId) {
    return _sessions.doc(sessionId).delete();
  }
}
