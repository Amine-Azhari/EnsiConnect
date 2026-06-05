import 'package:flutter/material.dart';
import '../main.dart'; // pour EnsiConnectApp
import 'setting_page.dart'; // pour SettingPage
import '../widgets/custom_drawer.dart';
import '../widgets/custom_notification_button.dart';


class ProfilPage extends StatefulWidget {
  const ProfilPage({super.key});

  @override
  State<ProfilPage> createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  final List<String> skills = [];

  final TextEditingController _filiereController = TextEditingController();
  final TextEditingController _anneeController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  final List<String> options = [
    "Java",
    "Mathématiques",
    "Anglais",
    "Prog fonc",
  ];

  String? selectedSkill;
  bool isEditing = false;

  String fullName = "Nom depuis DB";
  String uhaAddress = "Adresse UHA depuis DB";
  bool isConnected = true;
  String memberSince = "2025";

  int sessions = 12;
  double averageNote = 4.2;

  void _addSkill() {
    if (selectedSkill != null && !skills.contains(selectedSkill)) {
      setState(() {
        skills.add(selectedSkill!);
        selectedSkill = null;
      });
    }
  }

  void _toggleEdit() {
    setState(() {
      isEditing = !isEditing;
    });
  }

  @override
  void dispose() {
    _filiereController.dispose();
    _anneeController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Widget _infoCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0D1B2A) : Colors.blue.shade50,
        borderRadius: BorderRadius.circular(16),
        border: isDark ? Border.all(color: Colors.white10) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Informations personnelles",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text("Nom: $fullName"),
          Text("Adresse UHA: $uhaAddress"),
          Row(
            children: [
              const Text("Statut: "),
              Icon(
                Icons.circle,
                size: 10,
                color: isConnected ? Colors.green : Colors.red,
              ),
              const SizedBox(width: 5),
              Text(isConnected ? "Connecté" : "Déconnecté"),
            ],
          ),
          Text("Membre depuis: $memberSince"),
        ],
      ),
    );
  }

  Widget _statsCard(bool isDark) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF14213D) : Colors.blue.shade100,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Text(
                  "$sessions",
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                const Text("Sessions"),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF14213D) : Colors.blue.shade100,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Text(
                  averageNote.toStringAsFixed(1),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                const Text("Note moyenne /5"),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = isDark ? const Color(0xFF0A0F1C) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subtitleColor = isDark ? Colors.grey.shade400 : Colors.grey.shade700;

    return Scaffold(
      backgroundColor: bgColor,
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
                  MaterialPageRoute(
                    builder: (context) => const SettingPage(),
                  ),
                );
              },
            ),
          ],
        ),
      ),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text("Mon Profil"),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu_rounded),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            child: IconButton(
              icon: const Icon(Icons.notifications_none_rounded),
              onPressed: () {},
            ),
          ),
        ],
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: NetworkImage('https://picsum.photos/200'),
                ),
              ),

              const SizedBox(height: 20),

              Center(
                child: Text(
                  'Ayoub le GOAT',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ),

              const SizedBox(height: 10),

              Center(
                child: Text(
                  'Goat Flutter',
                  style: TextStyle(color: subtitleColor),
                ),
              ),

              const SizedBox(height: 20),

              Center(
                child: ElevatedButton(
                  onPressed: _toggleEdit,
                  child: Text(
                    isEditing
                        ? "Terminer modification"
                        : "Modifier votre profil",
                  ),
                ),
              ),

              const SizedBox(height: 15),

              _infoCard(isDark),
              const SizedBox(height: 15),
              _statsCard(isDark),

              const SizedBox(height: 25),

              const Text("Filière"),
              TextField(controller: _filiereController),

              const SizedBox(height: 10),

              const Text("Année"),
              TextField(controller: _anneeController),

              const SizedBox(height: 10),

              const Text("Description"),
              TextField(
                controller: _descriptionController,
                maxLines: 3,
              ),

              const SizedBox(height: 20),

              const Text("Compétences"),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: selectedSkill,
                      items: options
                          .map((e) => DropdownMenuItem(
                                value: e,
                                child: Text(e),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedSkill = value;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: _addSkill,
                    child: const Text("+"),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              Wrap(
                children: skills
                    .map((s) => Chip(
                          label: Text(s),
                          onDeleted: () {
                            setState(() {
                              skills.remove(s);
                            });
                          },
                        ))
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}