import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class UserServices {
  UserServices({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _etudiants =>
      _db.collection('Etudiant');

  //  CURRENT USER
  Future<User?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('user_email');

    if (email == null) return null;

    final result = await _etudiants
        .where('eMail', isEqualTo: email)
        .limit(1)
        .get();

    if (result.docs.isEmpty) return null;

    return _mapUser(result.docs.first);
  }


  Future<void> setAverageNote({
  required String userId,
  required double note,
}) async {
  await _etudiants.doc(userId).set({
    'averageNote': note,
    'updatedAt': FieldValue.serverTimestamp(),
  }, SetOptions(merge: true));
}

  //  GET USER BY ID
  Future<User?> getUserById(String userId) async {
    final doc = await _etudiants.doc(userId).get();

    if (!doc.exists) return null;

    return _mapUser(doc);
  }

  //  MAP FIRESTORE → USER
  User _mapUser(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};

    return User(
      id: doc.id,
      firstName: data['Prenom'] ?? '',
      lastName: data['Nom'] ?? '',
      email: data['eMail'] ?? '',
      promotion: data['Promotion'] ?? '1A',
      filiere: data['Filiere'] ?? 'Informatique',
      role: data['Role'] ?? 'Étudiant',
      description: data['description'] ?? '',

      //  SAFE CAST SKILLS
      skills: List<String>.from(data['skills'] ?? []),

      //  SAFE CAST SESSIONS
      sessions: (data['sessions'] is num)
          ? (data['sessions'] as num).toInt()
          : 0,

      //  SAFE CAST AVERAGE NOTE (FIX IMPORTANT)
      averageNote: (data['averageNote'] is num)
          ? (data['averageNote'] as num).toDouble()
          : 0.0,
    );
  }

  //  MATIERES / SKILLS OPTIONS
  Future<List<Map<String, dynamic>>> getAllSkillsOptions() async {
    final snapshot = await _db.collection('Matiere').get();

    return snapshot.docs.map((doc) {
      final data = doc.data();

      return {
        'id': doc.id,
        'name': (data['Nom'] ?? data['name'] ?? '').toString(),
      };
    }).toList();
  }

  //  UPDATE USER PROFILE
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