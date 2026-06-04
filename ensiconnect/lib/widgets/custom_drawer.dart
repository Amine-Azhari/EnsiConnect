import 'package:flutter/material.dart';
import '../main.dart'; // Pour accéder à EnsiConnectApp.ensisaBlue
import '../models/user.dart'; // Pour le modèle User
import '../screens/setting_page.dart'; // Pour la navigation vers les paramètres

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    // On définit l'utilisateur actuel ici pour l'afficher dans l'en-tête
    const User currentUser = User(
      id: '1',
      firstName: 'Ayoubbb',
      lastName: 'Darka',
      email: 'ayoub.darkaoui@uha.fr',
      promotion: '1A',
      filiere: 'Informatique',
      role: 'Étudiant',
      profilePictureUrl: 'assets/images/pdp.png',
    );

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: EnsiConnectApp.ensisaBlue),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  backgroundImage: currentUser.profilePictureUrl != null
                      ? (currentUser.profilePictureUrl!.startsWith('http')
                          ? NetworkImage(currentUser.profilePictureUrl!) as ImageProvider
                          : AssetImage(currentUser.profilePictureUrl!))
                      : null,
                  child: currentUser.profilePictureUrl == null
                      ? Text(
                          '${currentUser.firstName[0]}${currentUser.lastName[0]}',
                          style: const TextStyle(fontSize: 24, color: EnsiConnectApp.ensisaBlue, fontWeight: FontWeight.bold),
                        )
                      : null,
                ),
                const SizedBox(height: 10),
                Text(
                  currentUser.fullName,
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  currentUser.email,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Paramètres'),
            onTap: () {
              Navigator.pop(context); // Ferme le Drawer
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingPage()), 
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text('Aide & Support'),
            onTap: () => Navigator.pop(context),
          ),
          Divider(color: isDark ? Colors.grey.shade800 : Colors.grey.shade300),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Déconnexion', style: TextStyle(color: Colors.red)),
            onTap: () {
              // Redirige vers la page d'authentification et vide la pile de navigation
              Navigator.pushNamedAndRemoveUntil(context, '/auth', (route) => false);
            },
          ),
        ],
      ),
    );
  }
}