import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ensiconnect/service/user_service.dart';


class PostSessionService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> creerSession({
    required String titre,
    required String? matiere,
    required DateTime date,
    required String heureDebut,
    required String lieu,
    required int nbPlaces,
    required List<String> tags,
    required List<String> participants,
    required String? heureFin,
  }) async {
    final user = await UserServices().getCurrentUser();

    // 1. Récupère ou crée la salle
    final salleSnap = await _db
        .collection('Salle')
        .where('Nom', isEqualTo: lieu)
        .limit(1)
        .get();
    String salleId;
    if (salleSnap.docs.isNotEmpty) {
      salleId = salleSnap.docs.first.id;
    } else {
      final ref = await _db.collection('Salle').add({'Nom': lieu});
      salleId = ref.id;
    }

    // 2. Récupère ou crée la matière
    final matiereName = matiere ?? titre;
    final matiereSnap = await _db
        .collection('Matiere')
        .where('Nom', isEqualTo: matiereName)
        .limit(1)
        .get();
    String matiereId;
    if (matiereSnap.docs.isNotEmpty) {
      matiereId = matiereSnap.docs.first.id;
    } else {
      final ref = await _db.collection('Matiere').add({'Nom': matiereName});
      matiereId = ref.id;
    }

    // 3. Formate la date
    final dateStr =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

    // 4. Insère la session
    await _db.collection('Session').add({
      'Titre': titre,
      'MatiereID': matiereId,
      'SalleID': salleId,
      'OrganisateurID': user?.id ?? 'inconnu',
      'Date': dateStr,
      'Heure_Debut': heureDebut,
      'Heure_Fin': heureFin,
      'NbPlaces': nbPlaces,
      'Tags': tags,
      'Public': true,
      'Participants': participants,
    });
  }
}