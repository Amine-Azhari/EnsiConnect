import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ensiconnect/service/user_service.dart';
// import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationEvaluationService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> submitEvaluation({
    // required String sessionId,
    required String tutorId,
    required int note,
    required String commentaire,
  }) async {

    final user = await UserServices().getCurrentUser();
    // Need Update
    final String userId = user?.id ?? 'anonyme';


    await _db.collection('Evaluation').add({
      // 'SessionID': sessionId,
      'tutorId': tutorId,
      'EleveId': userId,
      'Note': note,
      'Commentaire': commentaire,
      'DateDEnvoi': FieldValue.serverTimestamp(),
    });

    //Met à jour la moyenne du tuteur
    await UserServices().updateAverageNote(tutorId);
  }

  Future<List<Map<String, dynamic>>?> getNotificationsCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('user_email');


    if (email == null) return null;

    final studentResult = await _db
      .collection('Etudiant') 
      .where('eMail', isEqualTo: email)
      .limit(1)
      .get();

    if (studentResult.docs.isEmpty) return null;

    final String studentId = studentResult.docs.first.id;

    final notificationsResult = await _db
        .collection('Notification')
        .where('receiverId', isEqualTo: studentId)
        .get();

    return notificationsResult.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return data;
    }).toList();

  }

  Stream<List<Map<String, dynamic>>> watchMyNotifications(String studentId) {
  return _db
    .collection('Notification')
    .where('receiverId', isEqualTo: studentId)
    // .orderBy('createdAt', descending: true) // Les plus récentes en premier
    .snapshots()
    .map((snapshot) => snapshot.docs.map((doc) {
          final data = doc.data();
          data['id'] = doc.id;
          return data;
        }).toList());
  }

  Future<void> deleteNotification(String notificationId) async {
    await _db.collection('Notification').doc(notificationId).delete();
  }
}