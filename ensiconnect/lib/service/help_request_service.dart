import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/help_request.dart';

class HelpRequestService {
  HelpRequestService({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _requests =>
      _db.collection('DemandeAide');

  Future<DocumentReference<Map<String, dynamic>>> createRequest(
    HelpRequest request,
  ) {
    return _requests.add(request.toMap());
  }

  Stream<List<HelpRequest>> watchRequests(String? currentUserId) {
    return _requests.snapshots().map((snapshot) {
      final requests = snapshot.docs
          .map(
            (doc) => HelpRequest.fromMap(
              doc.data(),
              id: doc.id,
              isMe: doc.data()['OrganisateurId'] == currentUserId,
            ),
          )
          .toList();

      requests.sort((a, b) {
        final aDate = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bDate = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return bDate.compareTo(aDate);
      });

      return requests;
    });
  }

  Future<void> deleteRequest(String requestId) {
    return _requests.doc(requestId).delete();
  }
}
