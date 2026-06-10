import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'service/firebase_options.dart';
import 'service/data_insert.dart';
import 'service/user_service.dart';
import "widgets/ensiconnect_app.dart";

void main() async {
  // Indispensable pour s'assurer que Flutter est prêt avant de lire le stockage
  WidgetsFlutterBinding.ensureInitialized();

  // initialisation de la BDD
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // On crée une instance du service et on lance l'insertion
  //final service = FirebaseDataService();
  //await service.initialiserDonneesDeTest();
  await UserServices().normalizeAverageNoteTypes();
  await UserServices().rebuildAverageNotesFromEvaluations();

  // On ouvre le stockage local
  final prefs = await SharedPreferences.getInstance();

  // On lit la valeur sauvegardée (si elle n'existe pas encore, on met true  par défaut)
  final isDarkSaved = prefs.getBool('isDarkMode') ?? true;

  // On applique la valeur sauvegardée à notre Notifier
  isDarkModeNotifier.value = isDarkSaved;

  runApp(const EnsiConnectApp());
}
