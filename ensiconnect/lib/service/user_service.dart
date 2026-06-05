import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class UserServices {
  UserServices({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _etudiants =>
      _db.collection('Etudiant');

<<<<<<< HEAD
  // Recupere l'utilisateur actuellement connecte depuis Firestore.
=======
        // Recupere l'utilisateur actuellement connecte depuis Firestore.
>>>>>>> c7e3314 (split user and auth)
  Future<User?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('user_email');
    if (email == null) return null;

    final result = await _etudiants
        .where('eMail', isEqualTo: email)
        .limit(1)
        .get();

    if (result.docs.isEmpty) return null;

    final doc = result.docs.first;
    final data = doc.data();

    return User(
      id: doc.id,
      firstName: data['Prenom'] ?? '',
      lastName: data['Nom'] ?? '',
      email: data['eMail'] ?? '',
      promotion: data['Promotion'] ?? '1A',
      filiere: data['Filiere'] ?? 'Informatique',
      role: data['Role'] ?? 'Étudiant',
      profilePictureUrl: data['ProfilePictureUrl'],
      description: data['description'] ?? '',
      skills: List<String>.from(data['skills'] ?? []),
      sessions: (data['sessions'] ?? 0),
      averageNote: (data['averageNote'] ?? 0.0),
    );
  }

  // Mise à jour du profil utilisateur
  Future<void> updateUserProfile({
    required String userId,
    required String description,
    required List<String> skills,
    required String filiere,
    required String promotion,
  }) async {
    await _etudiants.doc(userId).set({
      'description': description,
      'skills': skills,
      'Filiere': filiere,
      'Promotion': promotion,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
