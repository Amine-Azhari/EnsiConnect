import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseDataService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> initialiserDonneesDeTest() async {

    // On vérifie s'il y a déjà des étudiants
    final snap = await _db.collection('Etudiant').limit(1).get();
    
    // Si la collection n'est pas vide, on arrête tout
    if (snap.docs.isNotEmpty) {
      print("⚠️ Données déjà présentes, pas besoin d'insérer.");
      return; 
    }
    
    try {
      // Insertion des Étudiants
      // On stocke les références pour récupérer les IDs générés par Firebase
      DocumentReference refAlice = await _db.collection('Etudiant').add({
        'Nom': 'Dupont', 'Prenom': 'Alice', 'eMail': 'alice.dupont@uha.fr', 'Password': 'hash_password_123'
      });
      DocumentReference refLucas = await _db.collection('Etudiant').add({
        'Nom': 'Martin', 'Prenom': 'Lucas', 'eMail': 'lucas.martin@uha.fr', 'Password': 'hash_password_456'
      });
      DocumentReference refSarah = await _db.collection('Etudiant').add({
        'Nom': 'El Fassi', 'Prenom': 'Sarah', 'eMail': 'sarah.elfassi@uha.fr', 'Password': 'hash_password_789'
      });

      // Insertion des Matières
      DocumentReference refMaths = await _db.collection('Matiere').add({'Nom': 'Algèbre Linéaire'});
      DocumentReference refInfo = await _db.collection('Matiere').add({'Nom': 'Programmation Orientée Objet'});
      DocumentReference refPhysique = await _db.collection('Matiere').add({'Nom': 'Thermodynamique'});

      // Insertion des Salles
      DocumentReference refSalleA = await _db.collection('Salle').add({'Nom': 'Salle TD 101'});
      await _db.collection('Salle').add({'Nom': 'Bibliothèque (Box 3)'});
      await _db.collection('Salle').add({'Nom': 'En ligne (Discord)'});

      // Insertion de la Session
      DocumentReference refSessionMaths = await _db.collection('Session').add({
        'MatiereID': refMaths.id,
        'SalleID': refSalleA.id,
        'OrganisateurID': refLucas.id,
        'Date': '2026-06-10',
        'Heure_Debut': '14:00',
        'Heure_Fin': '16:00'
      });

      // Inscriptions (RejoindreSession)
      await _db.collection('RejoindreSession').add({
        'EtudiantID': refAlice.id, 'SessionID': refSessionMaths.id, 'Date': '2026-06-05', 'Contenu': 'Super !'
      });

      // Évaluation
      await _db.collection('Evaluation').add({
        'EvaluateurID': refAlice.id, 'EvalueID': refLucas.id, 'SessionID': refSessionMaths.id, 'Note': 5
      });

      // Messagerie
      await _db.collection('Messagerie').add({
        'ExpediteurID': refLucas.id, 'DestinataireID': refSarah.id, 'SessionID': null, 
        'Date': '2026-06-06 18:30', 'Contenu': 'Salut Sarah, on peut se voir demain !'
      });

      print('Données de test Firebase insérées avec succès !');
    } catch (e) {
      print('Erreur lors de l\'insertion Firebase : $e');
    }
  }
}