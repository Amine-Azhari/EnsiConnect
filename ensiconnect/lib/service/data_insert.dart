import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseDataService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  final salles = [
    // Amphis
    {'Nom': 'Grand Amphi', 'Batiment': 'ENSISA Lumière'},
    {'Nom': 'Petit Amphi', 'Batiment': 'ENSISA Lumière'},
    {'Nom': 'Amphi 116', 'Batiment': 'ENSISA Werner'},
    {'Nom': 'Amphi RAS', 'Batiment': 'ENSISA Werner'},

    // Salles informatiques
    {'Nom': 'E37', 'Batiment': 'ENSISA Lumière'},
    {'Nom': 'E38', 'Batiment': 'ENSISA Lumière'},
    {'Nom': 'PC 1', 'Batiment': 'ENSISA Lumière'},
    {'Nom': 'PC 2', 'Batiment': 'ENSISA Lumière'},
    {'Nom': 'PC 3', 'Batiment': 'ENSISA Lumière'},
    {'Nom': 'PC 4', 'Batiment': 'ENSISA Lumière'},
    {'Nom': 'PC Master', 'Batiment': 'ENSISA Lumière'},

    // Salles de cours
    {'Nom': 'E20a', 'Batiment': 'ENSISA Lumière'},
    {'Nom': 'E20b', 'Batiment': 'ENSISA Lumière'},
    {'Nom': 'E21', 'Batiment': 'ENSISA Lumière'},
    {'Nom': 'E22', 'Batiment': 'ENSISA Lumière'},
    {'Nom': 'E23', 'Batiment': 'ENSISA Lumière'},
    {'Nom': 'E24', 'Batiment': 'ENSISA Lumière'},
    {'Nom': 'E25', 'Batiment': 'ENSISA Lumière'},
    {'Nom': 'E26', 'Batiment': 'ENSISA Lumière'},
    {'Nom': 'E27', 'Batiment': 'ENSISA Lumière'},
    {'Nom': 'E28', 'Batiment': 'ENSISA Lumière'},
    {'Nom': 'E30', 'Batiment': 'ENSISA Lumière'},
    {'Nom': 'E31', 'Batiment': 'ENSISA Lumière'},
    {'Nom': 'E32', 'Batiment': 'ENSISA Lumière'},
    {'Nom': 'E33', 'Batiment': 'ENSISA Lumière'},
    {'Nom': 'E34', 'Batiment': 'ENSISA Lumière'},
    {'Nom': 'E36', 'Batiment': 'ENSISA Lumière'},

    // Laboratoires et TP
    {'Nom': 'TP Auto 1', 'Batiment': 'ENSISA Lumière'},
    {'Nom': 'TP Auto 2', 'Batiment': 'ENSISA Lumière'},
    {'Nom': 'TP Auto 3', 'Batiment': 'ENSISA Lumière'},
    {'Nom': 'TP Électronique', 'Batiment': 'ENSISA Lumière'},
    {'Nom': 'TP Info Indus', 'Batiment': 'ENSISA Lumière'},
    {'Nom': 'TP Méca 1', 'Batiment': 'ENSISA Lumière'},
    {'Nom': 'TP Méca 2', 'Batiment': 'ENSISA Lumière'},
    {'Nom': 'TP Physique', 'Batiment': 'ENSISA Lumière'},
    {'Nom': 'TP SN', 'Batiment': 'ENSISA Lumière'},
    {'Nom': 'TP Réseaux', 'Batiment': 'ENSISA Lumière'},

    // Werner
    {'Nom': 'Salle 157', 'Batiment': 'ENSISA Werner'},
    {'Nom': 'Salle 158', 'Batiment': 'ENSISA Werner'},
    {'Nom': 'Salle 401', 'Batiment': 'ENSISA Werner'},
    {'Nom': 'Salle 402', 'Batiment': 'ENSISA Werner'},
    {'Nom': 'Salle 403', 'Batiment': 'ENSISA Werner'},

    // Ateliers et labos Werner
    {'Nom': 'Labo Chimie', 'Batiment': 'ENSISA Werner'},
    {'Nom': 'Labo Métrologie', 'Batiment': 'ENSISA Werner'},
    {'Nom': 'Salle Robot', 'Batiment': 'ENSISA Werner'},
    {'Nom': 'Salle Lectra', 'Batiment': 'ENSISA Werner'},
    {'Nom': 'TP 207', 'Batiment': 'ENSISA Werner'},
    {'Nom': 'TP 300', 'Batiment': 'ENSISA Werner'},
    {'Nom': 'TP 321', 'Batiment': 'ENSISA Werner'},
    {'Nom': 'TP 322', 'Batiment': 'ENSISA Werner'},
    {'Nom': 'TP 323', 'Batiment': 'ENSISA Werner'},
  ];

  Future<void> ajouterSallesManquantes() async {
    // try {
    //   for (final salle in salles) {
    //     final existing = await _db
    //         .collection('Salle')
    //         .where('Nom', isEqualTo: salle['Nom'])
    //         .where('Batiment', isEqualTo: salle['Batiment'])
    //         .limit(1)
    //         .get();

    //     if (existing.docs.isEmpty) {
    //       await _db.collection('Salle').add(salle);
    //     }
    //   }

    //   print('Salles manquantes insérées avec succès !');
    // } catch (e) {
    //   print('Erreur lors de l\'insertion des salles : $e');
    // }
  }

  Future<void> initialiserDonneesDeTest() async {
    // On vérifie s'il y a déjà des étudiants
    // final snap = await _db.collection('Etudiant').limit(1).get();
    
    // // Si la collection n'est pas vide, on arrête tout
    // if (snap.docs.isNotEmpty) {
    //   print("⚠️ Données déjà présentes, pas besoin d'insérer.");
    //   return; 
    // }
    
    // try {
    //   // Insertion des Étudiants
    //   // On stocke les références pour récupérer les IDs générés par Firebase
    //   DocumentReference refAlice = await _db.collection('Etudiant').add({
    //     'Nom': 'Dupont', 'Prenom': 'Alice', 'eMail': 'alice.dupont@uha.fr', 'Password': 'hash_password_123'
    //   });
    //   DocumentReference refLucas = await _db.collection('Etudiant').add({
    //     'Nom': 'Martin', 'Prenom': 'Lucas', 'eMail': 'lucas.martin@uha.fr', 'Password': 'hash_password_456'
    //   });
    //   DocumentReference refSarah = await _db.collection('Etudiant').add({
    //     'Nom': 'El Fassi', 'Prenom': 'Sarah', 'eMail': 'sarah.elfassi@uha.fr', 'Password': 'hash_password_789'
    //   });

    //   // Insertion des Matières
    //   DocumentReference refMaths = await _db.collection('Matiere').add({'Nom': 'Algèbre Linéaire'});
    //   DocumentReference refInfo = await _db.collection('Matiere').add({'Nom': 'Programmation Orientée Objet'});
    //   DocumentReference refPhysique = await _db.collection('Matiere').add({'Nom': 'Thermodynamique'});

    //   // Insertion des Salles
    //   DocumentReference refSalleA = await _db.collection('Salle').add({'Nom': 'Salle TD 101'});
    //   await _db.collection('Salle').add({'Nom': 'Bibliothèque (Box 3)'});
    //   await _db.collection('Salle').add({'Nom': 'En ligne (Discord)'});

    //   // Insertion de la Session
    //   DocumentReference refSessionMaths = await _db.collection('Session').add({
    //     'MatiereID': refMaths.id,
    //     'SalleID': refSalleA.id,
    //     'OrganisateurID': refLucas.id,
    //     'Date': '2026-06-10',
    //     'Heure_Debut': '14:00',
    //     'Heure_Fin': '16:00'
    //   });

    //   // Inscriptions (RejoindreSession)
    //   await _db.collection('RejoindreSession').add({
    //     'EtudiantID': refAlice.id, 'SessionID': refSessionMaths.id, 'Date': '2026-06-05', 'Contenu': 'Super !'
    //   });

    //   // Évaluation
    //   await _db.collection('Evaluation').add({
    //     'EvaluateurID': refAlice.id, 'EvalueID': refLucas.id, 'SessionID': refSessionMaths.id, 'Note': 5
    //   });

    //   // Messagerie
    //   await _db.collection('Messagerie').add({
    //     'ExpediteurID': refLucas.id, 'DestinataireID': refSarah.id, 'SessionID': null, 
    //     'Date': '2026-06-06 18:30', 'Contenu': 'Salut Sarah, on peut se voir demain !'
    //   });

    //   print('Données de test Firebase insérées avec succès !');
    // } catch (e) {
    //   print('Erreur lors de l\'insertion Firebase : $e');
    // }
  }
}
