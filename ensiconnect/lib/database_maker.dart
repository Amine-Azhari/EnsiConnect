import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  // Récupérer ou initialiser la base de données
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('ensiconnect.db'); // Nom du fichier SQLite
    return _database!;
  }

  // Ouvrir le fichier sur le téléphone
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB, // Appel de la fonction pour créer les tables
    );
  }
  
  // Code SQL pour créer tes tables
  Future _createDB(Database db, int version) async {
    // Table des Etudiants
    await db.execute('''
      CREATE TABLE Etudiant (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        Nom TEXT,
        Prenom TEXT,
        eMail TEXT,
        Password TEXT
      )
    ''');

    // Table des matières
    await db.execute('''
      CREATE TABLE Matiere (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      Nom TEXT
      )
    ''');

    // Table des Salles
    await db.execute('''
      CREATE TABLE Salle (
        id INTEGER PRIMARY KEY,
        Nom TEXT not null
      )
    ''');

    // Table des Matières associé aux étudiants
    await db.execute('''
      CREATE TABLE EtudiantMatiere (
      EtudiantID INTEGER NOT NULL,
      MatiereID INTEGER NOT NULL,
      PRIMARY KEY (EtudiantID, MatiereID),
      FOREIGN KEY (EtudiantID) REFERENCES Etudiant(id) ON DELETE CASCADE,
      FOREIGN KEY (MatiereID) REFERENCES Matiere(id) ON DELETE CASCADE
      )
    ''');

    // Table des évaluations
    await db.execute('''
      CREATE TABLE Evaluation (
      EvaluateurID integer not null,
      EvalueID integer not null,
      SessionID integer not null,
      Note integer NOT NULL,
      PRIMARY KEY (SessionID, EvaluateurID, EvalueID),
      FOREIGN KEY (EvaluateurID) REFERENCES Etudiant(id) ON DELETE CASCADE,
      FOREIGN KEY (EvalueID) REFERENCES Etudiant(id) ON DELETE CASCADE,
      FOREIGN KEY (SessionID) REFERENCES Session(id) ON DELETE CASCADE
      )
    ''');

    // Table des sessions
    await db.execute('''
      CREATE TABLE Session (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      MatiereID integer not null,
      SalleID integer not null,
      OrganisateurID integer not null,
      Date Text not null,
      Heure_Debut Text not null,
      Heure_Fin Text not null,
      foreign key (MatiereID) references Matiere(id) on delete cascade,
      foreign key (SalleID) references Salle(id) on delete cascade,
      foreign key (OrganisateurID) references Etudiant(id) on delete cascade
      )
    ''');

    // Table des salons textuels
    await db.execute('''
      CREATE TABLE Messagerie (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        ExpediteurID integer,
        DestinataireID integer,
        SessionID integer,
        Date TEXT,
        Contenu TEXT,
        foreign key (ExpediteurID) references Etudiant(id) on delete cascade,
        foreign key (DestinataireID) references Etudiant(id) on delete cascade,
        foreign key (SessionID) references Session(id) on delete cascade
      )
    ''');

    // Table pour demander une session
    await db.execute('''
      CREATE TABLE DemandeSession (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        EtudiantID integer,
        MatiereID integer,
        Titre TEXT not null,
        Description TEXT,
        foreign key (EtudiantID) references Etudiant(id) on delete cascade,
        foreign key (MatiereID) references Matiere(id) on delete cascade
      )
    ''');

    // Table Rejoindre une session
    await db.execute('''
      CREATE TABLE RejoindreSession (
        EtudiantID integer not null,
        SessionID integer not null,
        Date TEXT,
        Contenu Text,
        primary key (EtudiantID, SessionID),
        foreign key (EtudiantID) references Etudiant(id) on delete cascade,
        foreign key (SessionID) references Session(id) on delete cascade
      )
    ''');

    await insererDonneesDeTest(db);
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}

/// Fonction pour insérer des données de test dans toutes les tables
Future<void> insererDonneesDeTest(Database db) async {
  // --------------------------------------------------------
  // 1. TABLES INDÉPENDANTES (Aucune clé étrangère)
  // --------------------------------------------------------

  // Insertion des Étudiants
  int etudiant1 = await db.insert('Etudiant', {
    'Nom': 'Dupont',
    'Prenom': 'Alice',
    'eMail': 'alice.dupont@uha.fr',
    'Password': 'hash_password_123'
  });

  int etudiant2 = await db.insert('Etudiant', {
    'Nom': 'Martin',
    'Prenom': 'Lucas',
    'eMail': 'lucas.martin@uha.fr',
    'Password': 'hash_password_456'
  });

  int etudiant3 = await db.insert('Etudiant', {
    'Nom': 'El Fassi',
    'Prenom': 'Sarah',
    'eMail': 'sarah.elfassi@uha.fr',
    'Password': 'hash_password_789'
  });

  // Insertion des Matières
  int matiereMaths = await db.insert('Matiere', {'Nom': 'Algèbre Linéaire'});
  int matiereInfo = await db.insert('Matiere', {'Nom': 'Programmation Orientée Objet'});
  int matierePhysique = await db.insert('Matiere', {'Nom': 'Thermodynamique'});

  // Insertion des Salles
  int salleA = await db.insert('Salle', {'Nom': 'Salle TD 101'});
  int salleB = await db.insert('Salle', {'Nom': 'Bibliothèque (Box 3)'});
  int salleDiscord = await db.insert('Salle', {'Nom': 'En ligne (Discord)'});

  // --------------------------------------------------------
  // 2. TABLES D'ASSOCIATION DE NIVEAU 1
  // --------------------------------------------------------

  // Compétences des étudiants (EtudiantMatiere)
  await db.insert('EtudiantMatiere', {
    'EtudiantID': etudiant1,
    'MatiereID': matiereInfo,
  }, conflictAlgorithm: ConflictAlgorithm.ignore); // Alice est forte en Info

  await db.insert('EtudiantMatiere', {
    'EtudiantID': etudiant2,
    'MatiereID': matiereMaths,
  }, conflictAlgorithm: ConflictAlgorithm.ignore); // Lucas est fort en Maths

  // --------------------------------------------------------
  // 3. CRÉATION DES ÉVÉNEMENTS (Sessions & Demandes)
  // --------------------------------------------------------

  // Création d'une session d'entraide (Lucas donne un cours de Maths)
  int sessionMaths = await db.insert('Session', {
    'MatiereID': matiereMaths,
    'SalleID': salleA,
    'OrganisateurID': etudiant2, // Lucas organise
    'Date': '2026-06-10',
    'Heure_Debut': '14:00',
    'Heure_Fin': '16:00'
  });

  // Création d'une demande d'aide (Sarah a besoin d'aide en Physique)
  await db.insert('DemandeSession', {
    'EtudiantID': etudiant3, // Sarah demande
    'MatiereID': matierePhysique,
    'Titre': 'Bloquée sur le TP de Thermo',
    'Description': 'Je ne comprends pas le cycle de Carnot, quelqu\'un peut m\'aider ?'
  });

  // --------------------------------------------------------
  // 4. INTERACTION DES UTILISATEURS (Inscriptions, Messages, Notes)
  // --------------------------------------------------------

  // Inscription à la session (Alice et Sarah rejoignent le cours de Lucas)
  await db.insert('RejoindreSession', {
    'EtudiantID': etudiant1,
    'SessionID': sessionMaths,
    'Date': '2026-06-05',
    'Contenu': 'Super, j\'en ai bien besoin !'
  }, conflictAlgorithm: ConflictAlgorithm.ignore);

  await db.insert('RejoindreSession', {
    'EtudiantID': etudiant3,
    'SessionID': sessionMaths,
    'Date': '2026-06-06',
    'Contenu': 'Présente !'
  }, conflictAlgorithm: ConflictAlgorithm.ignore);

  // Évaluation (Alice met 5 étoiles à Lucas pour sa session de Maths)
  await db.insert('Evaluation', {
    'EvaluateurID': etudiant1,
    'EvalueID': etudiant2,
    'SessionID': sessionMaths,
    'Note': 5,
  }, conflictAlgorithm: ConflictAlgorithm.ignore);

  // Messagerie Privée (Lucas écrit à Sarah)
  await db.insert('Messagerie', {
    'ExpediteurID': etudiant2,
    'DestinataireID': etudiant3,
    'SessionID': null, // Message privé
    'Date': '2026-06-06 18:30',
    'Contenu': 'Salut Sarah, j\'ai vu ta demande en thermo, on peut se voir demain si tu veux !'
  });

  // Messagerie de Groupe (Message d'Alice dans le salon de la session de Maths)
  await db.insert('Messagerie', {
    'ExpediteurID': etudiant1,
    'DestinataireID': null, // Message de groupe
    'SessionID': sessionMaths,
    'Date': '2026-06-10 13:50',
    'Contenu': 'J\'arrive dans 10 minutes à la salle TD 101 !'
  });

  print('✅ Base de données initialisée avec succès avec les données de test !');
}