import 'package:flutter/material.dart';
import "../widgets/ensiconnect_app.dart";

class CreditPage extends StatelessWidget {
  const CreditPage({super.key});

  static const List<Map<String, String>> membres = [
    {"prenom": "Ayoub", "nom": "Darkaoui"},
    {"prenom": "Amine", "nom": "El Azhari"},
    {"prenom": "Romain", "nom": "Fontaine"},
    {"prenom": "Zyad", "nom": "Idelkaid"},
    {"prenom": "Alexis", "nom": "Miras"},
    {"prenom": "Chloé", "nom": "Ribeiro"},
    {"prenom": "Nolann", "nom": "Wickers"},
    {"prenom": "Adam", "nom": "Zekari"},
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final cardColor = Theme.of(context).cardColor;
    final accentColor = isDark ? EnsiConnectApp.ensisaBlue : EnsiConnectApp.backgroundlightColor;

    return Scaffold(
      appBar: AppBar(
        title: const Text('À propos'),
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: textColor,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundColor: Colors.white,
                  child: Image(
                    image: const AssetImage('assets/images/icon-192.png'),
                    width: 100,
                    height: 100,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "EnsiConnect",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textColor),
                ),
                const SizedBox(height: 4),
              ],
            ),
          ),

          const SizedBox(height: 28),

          Text("CRÉÉE PAR",
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey.shade500, letterSpacing: 1.2),
          ),
          const SizedBox(height: 8),

          ...membres.map((membre) => Card(
            color: cardColor,
            margin: const EdgeInsets.only(bottom: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: accentColor,
                child: Text(
                  "${membre["prenom"]![0]}${membre["nom"]![0]}",
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              title: Text("${membre["prenom"]} ${membre["nom"]}",
                style: TextStyle(fontWeight: FontWeight.w600, color: textColor),
              ),
            ),
          )),

          const SizedBox(height: 24),

          Text("INFORMATIONS",
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey.shade500, letterSpacing: 1.2),
          ),
          const SizedBox(height: 8),

          Card(
            color: cardColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                _infoTile(Icons.apartment, "École", "ENSISA", textColor),
                const Divider(height: 1, indent: 56),
                _infoTile(Icons.calendar_today, "Année", "2025 - 2026", textColor),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoTile(IconData icon, String label, String value, Color textColor) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey.shade500),
      title: Text(label, style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
      trailing: Text(value, style: TextStyle(fontWeight: FontWeight.w600, color: textColor)),
    );
  }
}