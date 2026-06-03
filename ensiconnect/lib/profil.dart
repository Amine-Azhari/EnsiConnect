import 'package:flutter/material.dart';
import 'main.dart'; // pour EnsiConnectApp
import 'setting_page.dart'; // pour SettingPage


void main() {
  runApp(const MonApp());
}

class MonApp extends StatelessWidget {
  const MonApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ProfilPage(),
    );
  }
}

class ProfilPage extends StatelessWidget {
  const ProfilPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: EnsiConnectApp.ensisaBlue),
              child: Text(
                'EnsiConnect',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Paramètres'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingPage()),
                );
              },
            ),
          ],
        ),
      ),
    appBar: AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: const Text("Mon Profil"), // 👈 fixe au lieu de _getTitle()

      leading: Builder(
        builder: (context) => IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
        ),
      ),

      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_none),
          onPressed: () {},
        ),
      ],
    ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage('https://picsum.photos/200'),
              ),
            ),

            const SizedBox(height: 20),

            const Center(
              child: Text(
                'Ayoub le GOAT',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 10),

            const Center(
              child: Text(
                'Goat Flutter',
                style: TextStyle(color: Colors.grey),
              ),
            ),

            const SizedBox(height: 30),

            // 👇 DESCRIPTION
            const Text(
              'Description',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            const Padding(
              padding: EdgeInsets.only(right: 40),
              child: TextField(
                maxLines: 3,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Écris une description...',
                ),
              ),
            ),

            const SizedBox(height: 25),

            // 👇 SECTION JAVA
            const Text(
              'Java',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(5, (index) {
                return ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(45, 35),
                    padding: EdgeInsets.zero,
                  ),
                  child: Text('${index + 1}'),
                );
              }),
            ),

            const SizedBox(height: 30),

            // 👇 ACTIONS
            const Text(
              'Actions',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                ElevatedButton(
                  onPressed: () {},
                  child: const Text('Profil'),
                ),
                ElevatedButton(
                  onPressed: () {},
                  child: const Text('Messages'),
                ),
                ElevatedButton(
                  onPressed: () {},
                  child: const Text('Amis'),
                ),
                ElevatedButton(
                  onPressed: () {},
                  child: const Text('Paramètres'),
                ),
                ElevatedButton(
                  onPressed: () {},
                  child: const Text('Déconnexion'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}