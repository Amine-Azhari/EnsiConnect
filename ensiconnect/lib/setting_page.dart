import 'package:flutter/material.dart';
import 'main.dart'; // Accès au notifier global isDarkModeNotifier
import 'package:shared_preferences/shared_preferences.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paramètres'),
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          const Text(
            "Affichage",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ValueListenableBuilder<bool>(
              valueListenable: isDarkModeNotifier,
              builder: (context, isDarkMode, child) {
                return SwitchListTile(
                  title: const Text('Mode Sombre'),
                  subtitle: const Text("Change le thème de l'application."),
                  secondary: Icon(
                    isDarkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                    color: isDarkMode ? Colors.amber : Colors.blue,
                  ),
                  value: isDarkMode,
                  // Fonction asynchrone propre pour appliquer et sauvegarder en même temps
                  onChanged: (bool value) async { 
                    isDarkModeNotifier.value = value;
                    
                    // Écriture du choix dans la mémoire interne du téléphone
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setBool('isDarkMode', value);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}