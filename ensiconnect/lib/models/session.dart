class Session {
  final String? id;
  final String type;
  final String date;
  final String heureDebut;
  final String heureFin;
  final String matiereId;
  final String organisateurId;
  final String salleId;
  final String organisateurPrenom;
  final String organisateurNom;
  final String sujet;
  final String description;
  final List<String> participantsIds;

  Session({
    this.id,
    this.type = 'session',
    required this.date,
    required this.heureDebut,
    required this.heureFin,
    required this.matiereId,
    required this.organisateurId,
    required this.salleId,
    this.participantsIds = const [],
    this.organisateurPrenom = '',
    this.organisateurNom = '',
    this.sujet = '',
    this.description = '',
  });

  String get organisateurFullName =>
      '$organisateurPrenom $organisateurNom'.trim();

  // Crée un objet Session à partir d'un document Firebase (Map)
  factory Session.fromMap(Map<String, dynamic> map, [String? documentId]) {
  return Session(
    id: documentId,
    type: map['Type'] ?? 'session',
    date: map['Date'] ?? '',
    heureDebut: map['Heure_Debut'] ?? '',
    heureFin: map['Heure_Fin'] ?? '',
    matiereId: map['MatiereID'] ?? '',
    organisateurId: map['OrganisateurID'] ?? '',
    salleId: map['SalleID'] ?? '',
    organisateurPrenom: map['OrganisateurPrenom'] ?? '',
    organisateurNom: map['OrganisateurNom'] ?? '',
    sujet: map['Sujet'] ?? '',
    description: map['Description'] ?? '',
    participantsIds: List<String>.from(map['Participants'] ?? []),
  );
}

  // Convertit l'objet Session en Map pour l'insérer dans Firebase
  Map<String, dynamic> toMap() {
    return {
      'Type': type,
      'Date': date,
      'Heure_Debut': heureDebut,
      'Heure_Fin': heureFin,
      'MatiereID': matiereId,
      'OrganisateurID': organisateurId,
      'SalleID': salleId,
      'OrganisateurPrenom': organisateurPrenom,
      'OrganisateurNom': organisateurNom,
      'Sujet': sujet,
      'Description': description,
      'Participants': participantsIds,
    };
  }
}
