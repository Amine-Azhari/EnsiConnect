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
    // Table des séances
    await db.execute('''
      CREATE TABLE Etudiant (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
      )
    ''');
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}