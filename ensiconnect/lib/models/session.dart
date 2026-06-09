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

  DateTime? get startDateTime {
    if (date.isEmpty) {
      return null;
    }

    try {
      final baseDate = DateTime.parse(date);
      final parts = heureDebut.split(':');
      final hour = parts.isNotEmpty ? int.tryParse(parts[0]) ?? 0 : 0;
      final minute = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
      return DateTime(
        baseDate.year,
        baseDate.month,
        baseDate.day,
        hour,
        minute,
      );
    } catch (_) {
      return null;
    }
  }

  static int compareByStartTime(Session a, Session b) {
    final aStart = a.startDateTime;
    final bStart = b.startDateTime;

    if (aStart == null && bStart == null) {
      return 0;
    }
    if (aStart == null) {
      return 1;
    }
    if (bStart == null) {
      return -1;
    }

    return aStart.compareTo(bStart);
  }

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
      sujet: map['Titre'] ?? map['Sujet'] ?? '',
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
      'Titre': sujet,
      'Sujet': sujet,
      'Description': description,
      'Participants': participantsIds,
    };
  }
}
