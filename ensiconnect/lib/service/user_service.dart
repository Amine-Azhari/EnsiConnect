import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class UserServices {
  UserServices({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _etudiants =>
      _db.collection('Etudiant');

  // Recupere l'utilisateur actuellement connecte depuis Firestore.
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
      description: data['description'] ?? '',
      skills: List<String>.from(data['skills'] ?? []),
      sessions: data['sessions'] ?? 0,
      averageNote: (data['averageNote'] ?? 0.0).toDouble(),
    );
  }

  // Récupère un utilisateur à partir d'un userId Firestore
  Future<User?> getUserById(String userId) async {
    final result = await _etudiants
        .where('userId', isEqualTo: userId)
        .limit(1)
        .get();

    if (result.docs.isEmpty) {
      return null;
    }

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
      description: data['description'] ?? '',
      skills: List<String>.from(data['skills'] ?? []),
      sessions: data['sessions'] ?? 0,
      averageNote: (data['averageNote'] ?? 0.0).toDouble(),
    );
  }

  Future<List<Map<String, dynamic>>> getAllMatieres() async {
    final snapshot = await _db.collection('Matiere').get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return {
        'id': doc.id,
        'name': data['name'] ?? data['Nom'] ?? '',
      };
    }).toList();
  }

  Future<List<String>> getAllSkillsOptions() async {
    try {
      final doc = await _db.collection('Config').doc('skills').get();

      if (!doc.exists || doc.data() == null) return [];

      final data = doc.data();

      final list = data?['Matiere']; // 👈 ICI le vrai nom

      if (list is! List) return [];

      return List<String>.from(list);
    } catch (e) {
      print("ERROR getAllSkillsOptions: $e");
      return [];
    }
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