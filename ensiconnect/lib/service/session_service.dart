import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/session.dart';

class SessionService {
  SessionService({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _sessions =>
      _db.collection('Session');
  CollectionReference<Map<String, dynamic>> get _notifications =>
      _db.collection('Notification');
  CollectionReference<Map<String, dynamic>> get _registrations =>
      _db.collection('RejoindreSession');

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

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final rawDate = data['Date'] as String?;
        if (rawDate == null || rawDate.isEmpty) {
          continue;
        }

        try {
          final parsedDate = DateTime.parse(rawDate);
          final sessionDate =
              DateTime(parsedDate.year, parsedDate.month, parsedDate.day);

          var isExpired = false;
          if (sessionDate.isBefore(today)) {
            isExpired = true;
          } else if (sessionDate.isAtSameMomentAs(today)) {
            final heureFin = data['Heure_Fin'] as String?;
            if (heureFin != null && heureFin.isNotEmpty) {
              final parts = heureFin.split(':');
              if (parts.length >= 2) {
                final hour = int.tryParse(parts[0]) ?? 23;
                final minute = int.tryParse(parts[1]) ?? 59;
                final endTime = DateTime(
                  sessionDate.year,
                  sessionDate.month,
                  sessionDate.day,
                  hour,
                  minute,
                );
                if (endTime.isBefore(now)) {
                  isExpired = true;
                }
              }
            }
          }

          if (!isExpired) {
            continue;
          }

          final tutorId =
              (data['OrganisateurId'] ?? data['OrganisateurID'] ?? '')
                  .toString()
                  .trim();
          if (tutorId.isEmpty) {
            continue;
          }

          final sessionId = doc.id;
          final sessionName =
              ((data['Titre'] ?? data['Sujet'] ?? 'Session') as String).trim();
          final participantIds = await _resolveParticipantIds(
            sessionId: sessionId,
            tutorId: tutorId,
            sessionData: data,
          );
          final registrations = await _loadRegistrations(sessionId);

          final batch = _db.batch();

          batch.set(_notifications.doc(), {
            'userId': tutorId,
            'tutorId': tutorId,
            'sessionId': sessionId,
            'title': 'Session terminee !',
            'message':
                'Votre session de "$sessionName" est finie. Vos eleves ont ete invites a vous laisser une note.',
            'type': 'info',
            'isRead': false,
            'createdAt': FieldValue.serverTimestamp(),
          });

          for (final participantId in participantIds) {
            batch.set(_notifications.doc(), {
              'userId': participantId,
              'tutorId': tutorId,
              'sessionId': sessionId,
              'title': 'Evaluez votre tuteur',
              'message':
                  'La session de "$sessionName" est finie. Prenez un moment pour evaluer votre tuteur.',
              'type': 'evaluation',
              'isRead': false,
              'createdAt': FieldValue.serverTimestamp(),
            });
          }

          for (final registration in registrations) {
            batch.delete(registration.reference);
          }

          batch.delete(doc.reference);
          await batch.commit();
        } catch (_) {
          // Une session mal formée ne doit pas bloquer le nettoyage global.
        }
      }
    } catch (_) {
      // Le nettoyage ne doit pas casser l'application.
    }
  }

  Future<Set<String>> _resolveParticipantIds({
    required String sessionId,
    required String tutorId,
    required Map<String, dynamic> sessionData,
  }) async {
    final participantIds = <String>{};

    void addCandidate(dynamic value) {
      final candidate = value.toString().trim();
      if (candidate.isNotEmpty && candidate != tutorId) {
        participantIds.add(candidate);
      }
    }

    for (final key in const ['participants', 'Participants']) {
      final raw = sessionData[key];
      if (raw is List) {
        for (final participant in raw) {
          addCandidate(participant);
        }
      }
    }

    final registrations = await _loadRegistrations(sessionId);

    for (final registration in registrations) {
      addCandidate(
        registration.data()['EtudiantId'] ?? registration.data()['EtudiantID'],
      );
    }

    return participantIds;
  }

  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> _loadRegistrations(
    String sessionId,
  ) async {
    final lowerCaseSnapshot =
        await _registrations.where('SessionId', isEqualTo: sessionId).get();
    final upperCaseSnapshot =
        await _registrations.where('SessionID', isEqualTo: sessionId).get();

    final registrationsById = <String, QueryDocumentSnapshot<Map<String, dynamic>>>{};
    for (final doc in lowerCaseSnapshot.docs) {
      registrationsById[doc.id] = doc;
    }
    for (final doc in upperCaseSnapshot.docs) {
      registrationsById[doc.id] = doc;
    }

    return registrationsById.values.toList();
  }
}
