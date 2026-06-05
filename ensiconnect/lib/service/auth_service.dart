import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import './user_service.dart';

class AuthServices {
  AuthServices({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _etudiants =>
      _db.collection('Etudiant');

  // Sauvegarde l'email dans la session locale.
  Future<void> _saveSession(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_email', email);
  }

  // Deconnecte l'utilisateur en supprimant la session.
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_email');
  }

  // Cherche un etudiant avec le couple email / mot de passe saisi.
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();

    // On normalise l'email pour eviter les erreurs de majuscules ou espaces.
    final result = await _etudiants
        .where('eMail', isEqualTo: normalizedEmail)
        .where('Password', isEqualTo: password)
        .limit(1)
        .get();

    if (result.docs.isNotEmpty) {
      await _saveSession(normalizedEmail);
      return true;
    }
    return false;
  }

  // Cree un nouveau document Etudiant apres avoir verifie que l'email est libre.
  Future<void> register({
    required String nom,
    required String prenom,
    required String email,
    required String password,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();

    // Firestore ne doit pas contenir deux comptes avec la meme adresse.
    final existingAccount = await _etudiants
        .where('eMail', isEqualTo: normalizedEmail)
        .limit(1)
        .get();

    if (existingAccount.docs.isNotEmpty) {
      throw Exception('Un compte existe déja avec cette adresse mail.');
    }

    // Les noms de champs suivent ceux deja utilises dans data_insert.dart.
    await _etudiants.add({
      'Nom': nom.trim(),
      'Prenom': prenom.trim(),
      'eMail': normalizedEmail,
      'Password': password,
    });
    
    // Sauvegarde la session apres une inscription reussie.
    await _saveSession(normalizedEmail);
  }
}