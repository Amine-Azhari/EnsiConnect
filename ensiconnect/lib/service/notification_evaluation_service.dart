import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ensiconnect/service/user_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationEvaluationService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> submitEvaluation({
    required String sessionId,
    required String tutorId,
    required int note,
    required String commentaire,
  }) async {
    final user = await UserServices().getCurrentUser();
    final userId = user?.id ?? 'anonyme';

    final existingEvaluation = await _db
        .collection('Evaluation')
        .where('SessionID', isEqualTo: sessionId)
        .where('tutorId', isEqualTo: tutorId)
        .where('userId', isEqualTo: userId)
        .limit(1)
        .get();

    final payload = <String, dynamic>{
      'SessionID': sessionId,
      'tutorId': tutorId,
      'userId': userId,
      'Note': note,
      'Commentaire': commentaire.trim(),
      'DateDEnvoi': FieldValue.serverTimestamp(),
    };

    if (existingEvaluation.docs.isNotEmpty) {
      await existingEvaluation.docs.first.reference.set(
        payload,
        SetOptions(merge: true),
      );
    } else {
      await _db.collection('Evaluation').add(payload);
    }

    await UserServices().updateAverageNote(tutorId);
  }

  Future<List<Map<String, dynamic>>?> getNotificationsCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('user_email');

    if (email == null) {
      return null;
    }

    final studentResult = await _db
        .collection('Etudiant')
        .where('eMail', isEqualTo: email)
        .limit(1)
        .get();

    if (studentResult.docs.isEmpty) {
      return null;
    }

    final studentId = studentResult.docs.first.id;
    final notificationsResult = await _db
        .collection('Notification')
        .where('userId', isEqualTo: studentId)
        .get();

    final notifications = notificationsResult.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return data;
    }).toList();

    notifications.sort((a, b) {
      final aTime = a['createdAt'];
      final bTime = b['createdAt'];
      final aMillis = aTime is Timestamp ? aTime.millisecondsSinceEpoch : 0;
      final bMillis = bTime is Timestamp ? bTime.millisecondsSinceEpoch : 0;
      return bMillis.compareTo(aMillis);
    });

    return notifications;
  }

  Stream<List<Map<String, dynamic>>> watchMyNotifications(String studentId) {
    return _db
        .collection('Notification')
        .where('userId', isEqualTo: studentId)
        .snapshots()
        .map((snapshot) {
      final notifications = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();

      notifications.sort((a, b) {
        final aTime = a['createdAt'];
        final bTime = b['createdAt'];
        final aMillis = aTime is Timestamp ? aTime.millisecondsSinceEpoch : 0;
        final bMillis = bTime is Timestamp ? bTime.millisecondsSinceEpoch : 0;
        return bMillis.compareTo(aMillis);
      });

      return notifications;
    });
  }

  Future<void> deleteNotification(String notificationId) async {
    await _db.collection('Notification').doc(notificationId).delete();
  }
}
