import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/session.dart';
import '../models/user.dart';
import 'user_service.dart';

class JoinedSessionDetails {
  JoinedSessionDetails({
    required this.joinId,
    required this.joinDate,
    required this.joinMessage,
    required this.session,
    required this.subjectName,
    required this.roomName,
    required this.organizerName,
  });

  final String joinId;
  final String joinDate;
  final String joinMessage;
  final Session session;
  final String subjectName;
  final String roomName;
  final String organizerName;

  DateTime? get sessionDateTime {
    if (session.date.isEmpty) {
      return null;
    }

    try {
      final baseDate = DateTime.parse(session.date);
      final parts = session.heureDebut.split(':');
      final hour = parts.isNotEmpty ? int.tryParse(parts[0]) ?? 0 : 0;
      final minute = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
      return DateTime(
          baseDate.year, baseDate.month, baseDate.day, hour, minute);
    } catch (_) {
      return null;
    }
  }
}

class JoinedSessionService {
  JoinedSessionService({
    FirebaseFirestore? firestore,
    UserServices? userServices,
  })  : _db = firestore ?? FirebaseFirestore.instance,
        _userServices = userServices ?? UserServices(firestore: firestore);

  final FirebaseFirestore _db;
  final UserServices _userServices;

  CollectionReference<Map<String, dynamic>> get _joins =>
      _db.collection('RejoindreSession');

  Future<List<JoinedSessionDetails>> getJoinedSessionsForCurrentUser() async {
    final User? currentUser = await _userServices.getCurrentUser();
    if (currentUser == null) {
      return const [];
    }

    final joinSnapshot =
        await _joins.where('EtudiantId', isEqualTo: currentUser.id).get();

    if (joinSnapshot.docs.isEmpty) {
      return const [];
    }

    final sessionIds = <String>{};
    for (final doc in joinSnapshot.docs) {
      final sessionId = doc.data()['SessionId'] as String? ?? '';
      if (sessionId.isNotEmpty) {
        sessionIds.add(sessionId);
      }
    }

    if (sessionIds.isEmpty) {
      return const [];
    }

    final sessionsById = await _fetchSessionsById(sessionIds);
    final matiereIds = sessionsById.values
        .map((session) => session.matiereId)
        .where((id) => id.isNotEmpty)
        .toSet();
    final salleIds = sessionsById.values
        .map((session) => session.salleId)
        .where((id) => id.isNotEmpty)
        .toSet();
    final organisateurIds = sessionsById.values
        .map((session) => session.organisateurId)
        .where((id) => id.isNotEmpty)
        .toSet();

    final matieres = await _fetchNameMap('Matiere', matiereIds);
    final salles = await _fetchNameMap('Salle', salleIds);
    final organisateurs = await _fetchStudentNameMap(organisateurIds);

    final joinedSessions = <JoinedSessionDetails>[];
    for (final doc in joinSnapshot.docs) {
      final data = doc.data();
      final sessionId = data['SessionId'] as String? ?? '';
      final session = sessionsById[sessionId];
      if (session == null) {
        continue;
      }

      joinedSessions.add(
        JoinedSessionDetails(
          joinId: doc.id,
          joinDate: data['Date'] as String? ?? '',
          joinMessage: data['Contenu'] as String? ?? '',
          session: session,
          subjectName: matieres[session.matiereId] ?? 'Matiere inconnue',
          roomName: salles[session.salleId] ?? 'Salle inconnue',
          organizerName:
              organisateurs[session.organisateurId] ?? 'Organisateur inconnu',
        ),
      );
    }

    joinedSessions.sort((a, b) {
      final aDate = a.sessionDateTime;
      final bDate = b.sessionDateTime;
      if (aDate == null && bDate == null) {
        return 0;
      }
      if (aDate == null) {
        return 1;
      }
      if (bDate == null) {
        return -1;
      }
      return aDate.compareTo(bDate);
    });

    return joinedSessions;
  }

  Future<Map<String, Session>> _fetchSessionsById(Set<String> ids) async {
    final Map<String, Session> sessions = {};
    for (final chunk in _chunkIds(ids.toList())) {
      final snapshot = await _db
          .collection('Session')
          .where(FieldPath.documentId, whereIn: chunk)
          .get();

      for (final doc in snapshot.docs) {
        sessions[doc.id] = Session.fromMap(doc.data(), doc.id);
      }
    }
    return sessions;
  }

  Future<Map<String, String>> _fetchNameMap(
    String collection,
    Set<String> ids,
  ) async {
    final Map<String, String> names = {};
    if (ids.isEmpty) {
      return names;
    }

    for (final chunk in _chunkIds(ids.toList())) {
      final snapshot = await _db
          .collection(collection)
          .where(FieldPath.documentId, whereIn: chunk)
          .get();

      for (final doc in snapshot.docs) {
        names[doc.id] = doc.data()['Nom'] as String? ?? 'Inconnu';
      }
    }
    return names;
  }

  Future<Map<String, String>> _fetchStudentNameMap(Set<String> ids) async {
    final Map<String, String> names = {};
    if (ids.isEmpty) {
      return names;
    }

    for (final chunk in _chunkIds(ids.toList())) {
      final snapshot = await _db
          .collection('Etudiant')
          .where(FieldPath.documentId, whereIn: chunk)
          .get();

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final firstName = data['Prenom'] as String? ?? '';
        final lastName = data['Nom'] as String? ?? '';
        final fullName = '$firstName $lastName'.trim();
        names[doc.id] = fullName.isEmpty ? 'Utilisateur inconnu' : fullName;
      }
    }
    return names;
  }

  List<List<String>> _chunkIds(List<String> ids) {
    const int maxWhereIn = 10;
    final chunks = <List<String>>[];
    for (var i = 0; i < ids.length; i += maxWhereIn) {
      final end = (i + maxWhereIn < ids.length) ? i + maxWhereIn : ids.length;
      chunks.add(ids.sublist(i, end));
    }
    return chunks;
  }
}
