import 'package:cloud_firestore/cloud_firestore.dart';
import 'user_service.dart';
import 'chat_service.dart';

class PostSessionService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> creerSession({
    required String titre,
    required String? matiere,
    required String description,
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

    final allParticipants = <String>{
      user?.id ?? 'inconnu',
      ...participants,
    }.toList();

    // 4. Insère la session
    final sessionRef = await _db.collection('Session').add({
      'Sujet': titre,
      'MatiereId': matiereId,
      'MatiereID': matiereId,
      'SalleId': salleId,
      'SalleID': salleId,
      'OrganisateurId': user?.id ?? 'inconnu',
      'OrganisateurID': user?.id ?? 'inconnu',
      'OrganisateurNom': user != null ? '${user.firstName} ${user.lastName}' : 'Inconnu',
      'Date': dateStr,
      'Heure_Debut': heureDebut,
      'Heure_Fin': heureFin,
      'NbPlaces': nbPlaces,
      'Tags': tags,
      'Description': description,
      'Public': true,
      'participants': participants,
    });

    // await _db.collection('Chats').add({
    //   'sessionId': sessionRef.id,
    //   'name': titre,
    //   'participants': allParticipants,
    //   'createdAt': FieldValue.serverTimestamp(),
    // });

    await _db.collection('RejoindreSession').add({
      'SessionId': sessionRef.id,
      'SessionID': sessionRef.id,
      'EtudiantId': user?.id,
      'EtudiantID': user?.id,
    });

    //Ajout des participants à la base de donnée

    for (final participantId in participants ) {
      await _db.collection('RejoindreSession').add({
        'SessionId': sessionRef.id,
        'SessionID': sessionRef.id,
        'EtudiantId': participantId,
        'EtudiantID': participantId,
      });
    }

    // 5. Crée le salon de discussion associé
    final chatService = ChatService();
    final conversationId = await chatService.createConversation(
      participants: [user?.id ?? 'inconnu', ...participants],
      name: titre,
    );

    await sessionRef.update({
      'ConversationId': conversationId,
    });
  }
}

