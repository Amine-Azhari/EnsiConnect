class Session {
  final String? id;
  final String date;
  final String heureDebut;
  final String heureFin;
  final String matiereId;
  final String organisateurId;
  final String salleId;

  Session({
    this.id,
    required this.date,
    required this.heureDebut,
    required this.heureFin,
    required this.matiereId,
    required this.organisateurId,
    required this.salleId,
  });

  // Crée un objet Session à partir d'un document Firebase (Map)
  factory Session.fromMap(Map<String, dynamic> map, [String? documentId]) {
    return Session(
      id: documentId,
      date: map['Date'] ?? '',
      heureDebut: map['Heure_Debut'] ?? '',
      heureFin: map['Heure_Fin'] ?? '',
      matiereId: map['MatiereID'] ?? '',
      organisateurId: map['OrganisateurID'] ?? '',
      salleId: map['SalleID'] ?? '',
    );
  }

  // Convertit l'objet Session en Map pour l'insérer dans Firebase
  Map<String, dynamic> toMap() {
    return {
      'Date': date,
      'Heure_Debut': heureDebut,
      'Heure_Fin': heureFin,
      'MatiereID': matiereId,
      'OrganisateurID': organisateurId,
      'SalleID': salleId,
    };
  }
}