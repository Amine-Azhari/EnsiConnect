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

      sessions.sort(Session.compareByStartTime);
      return sessions;
    });
  }

  Future<void> deleteSession(String sessionId) {
    return _sessions.doc(sessionId).delete();
  }

  Future<void> cleanupOldSessions() async {
    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      final snapshot = await _sessions.get();

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final rawDate = data['Date'] as String?;
        if (rawDate != null && rawDate.isNotEmpty) {
          try {
            final parsedDate = DateTime.parse(rawDate);
            final sessionDate =
                DateTime(parsedDate.year, parsedDate.month, parsedDate.day);

            bool isExpired = false;

            if (sessionDate.isBefore(today)) {
              isExpired = true;
            } else if (sessionDate.isAtSameMomentAs(today)) {
              final heureFin = data['Heure_Fin'] as String?;
              if (heureFin != null && heureFin.isNotEmpty) {
                final parts = heureFin.split(':');
                if (parts.length >= 2) {
                  final hour = int.tryParse(parts[0]) ?? 23;
                  final minute = int.tryParse(parts[1]) ?? 59;
                  final endTime = DateTime(sessionDate.year, sessionDate.month,
                      sessionDate.day, hour, minute);
                  if (endTime.isBefore(now)) {
                    isExpired = true;
                  }
                }
              }
            }

            if (isExpired) {
              final tutorId = data['OrganisateurID'] as String?;
              final participantsRaw = data['participants'] as List<dynamic>?;

              List<dynamic> participants = [];
              if (participantsRaw is List) participants = participantsRaw;

              final sessionName = data['Titre'] as String? ?? 'Session';
              final sessionId = doc.id;

              WriteBatch batch = _db.batch();

              if (tutorId != null && tutorId.isNotEmpty) {            
                DocumentReference notifRef = _db.collection('Notification').doc();
                batch.set(notifRef, {
                  'userId': tutorId,
                  'tutorId': tutorId,
                  'sessionId': sessionId,
                  'title': 'Session terminée !',
                  'message': 'Votre session de "$sessionName" est finie. Vos élèves ont été invités à vous laisser une note.',
                  'type': 'info',
                  'isRead': false,
                  'createdAt': FieldValue.serverTimestamp(),
                }); 
              }

                for (var participant in participants) {
                  final participantId = participant.toString().trim();
                  if (participantId.isEmpty || participantId == tutorId) continue;

                  DocumentReference notifRef = _db.collection('Notification').doc();
                  batch.set(notifRef, {
                    'userId': participantId,
                    'tutorId': tutorId,
                    'sessionId': sessionId,
                    'title': 'Évaluez votre tuteur',
                    'message': 'La session de "$sessionName" est finie. Prenez un moment pour évaluer votre tuteur.',
                    'type': 'evaluation',
                    'isRead': false,
                    'createdAt': FieldValue.serverTimestamp(),
                  });
                }

                // await doc.reference.delete();

                batch.delete(doc.reference);

                await batch.commit();
            }
          } catch (e) {
            // Ignorer les erreurs de parsing pour ne pas bloquer la boucle
          }
        }
      }
    } catch (e) {
      // Gérer l'erreur silencieusement
    }
  }
}
