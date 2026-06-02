import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'menu_principal.dart';
import 'splash_screen.dart';
import 'setting_page.dart';

// On garde le notifier global
final ValueNotifier<bool> isDarkModeNotifier = ValueNotifier<bool>(false);

// 2. MODIFIE LE MAIN POUR QU'IL SOIT ASYNCHRONE (async)
void main() async {
  // Indispensable pour s'assurer que Flutter est prêt avant de lire le stockage
  WidgetsFlutterBinding.ensureInitialized();
  
  // On ouvre le stockage local
  final prefs = await SharedPreferences.getInstance();
  
  // On lit la valeur sauvegardée (si elle n'existe pas encore, on met false par défaut)
  final isDarkSaved = prefs.getBool('isDarkMode') ?? false;
  
  // On applique la valeur sauvegardée à notre Notifier
  isDarkModeNotifier.value = isDarkSaved;

  runApp(const EnsiConnectApp());
}