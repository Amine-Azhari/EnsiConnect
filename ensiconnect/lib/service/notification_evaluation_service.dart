import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ensiconnect/service/user_service.dart';

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
  }
}