import 'package:flutter/material.dart';
import "./ensiconnect_app.dart";
import '../models/user.dart';
import '../screens/setting_page.dart';
import '../service/user_service.dart';
import '../service/auth_service.dart';
import '../screens/profil.dart';

class CustomDrawer extends StatelessWidget {
  final String? currentUserId; 

  const CustomDrawer({
    super.key,
    this.currentUserId,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Drawer(
      child: FutureBuilder<User?>(
        future: UserServices().getCurrentUser(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final currentUser = snapshot.data ??
              const User(
                id: 'unknown',
                firstName: 'Invité',
                lastName: '',
                email: '',
              );

          return ListView(
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
                      backgroundColor: Colors.blue.shade600,
                      child: Text(
                        currentUser.initials.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      currentUser.fullName.trim().isEmpty
                          ? 'Utilisateur'
                          : currentUser.fullName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
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
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProfilPage(
                        userId: currentUserId ?? currentUser.id,
                      ),
                    ),
                  );
                },
              ),

              ListTile(
                leading: const Icon(Icons.help_outline),
                title: const Text('Aide & Support'),
                onTap: () => Navigator.pop(context),
              ),

              Divider(
                color: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
              ),

              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text(
                  'Déconnexion',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () async {
                  await AuthServices().logout();
                  if (context.mounted) {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/auth',
                      (route) => false,
                    );
                  }
                },
              ),
            ],
          );
        },
      ),
    );
  }
}