import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ensiconnect/service/user_service.dart';
import 'package:flutter/material.dart';
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
      'tutorID': tutorId,
      'EleveID': userId,
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

    debugPrint("🔍 [DEBUG BDD] Email récupéré localement : '$email'");

    if (email == null) {
      debugPrint("[DEBUG BDD] Échec : 'user_email' est null dans SharedPreferences.");
      return null;
    }

    try {
      final studentResult = await _db
        .collection('Etudiant') 
        .where('eMail', isEqualTo: email)
        .limit(1)
        .get();

      debugPrint("[DEBUG BDD] Nombre d'étudiants trouvés : ${studentResult.docs.length}");

      if (studentResult.docs.isEmpty) {
        debugPrint("[DEBUG BDD] Aucun document dans la collection 'etudiants' avec eMail = '$email'");
        return null;
      }

      final String studentId = studentResult.docs.first.id;
      debugPrint("[DEBUG BDD] ID Étudiant trouvé : $studentId");

      final notificationsResult = await _db
          .collection('Notification')
          .where('receiverId', isEqualTo: studentId)
          .get();

      debugPrint("[DEBUG BDD] Notifications récupérées : ${notificationsResult.docs.length}");

      return notificationsResult.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();

    } catch (e) {
      debugPrint("[DEBUG BDD] Erreur fatale Firestore : $e");
      return null;
    }
  }

  // Sans recharger
  // Stream<List<Map<String, dynamic>>> watchMyNotifications(String studentId) {
  // return _db
  //   .collection('Notification')
  //   .where('receiverId', isEqualTo: studentId)
  //   .orderBy('createdAt', descending: true) // Les plus récentes en premier
  //   .snapshots()
  //   .map((snapshot) => snapshot.docs.map((doc) {
  //         final data = doc.data();
  //         data['id'] = doc.id;
  //         return data;
  //       }).toList());
  // }
}