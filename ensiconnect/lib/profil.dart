import 'package:flutter/material.dart';
import 'main.dart'; // pour EnsiConnectApp
import 'setting_page.dart'; // pour SettingPage

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

  // ======================
  // DONNÉES (DB SIMULÉE)
  // ======================
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

  Widget _infoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade900,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Informations personnelles",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text("Nom: $fullName", style: const TextStyle(color: Colors.white)),
          Text("Adresse UHA: $uhaAddress",
              style: const TextStyle(color: Colors.white)),
          Row(
            children: [
              const Text("Statut: ", style: TextStyle(color: Colors.white)),
              Icon(
                Icons.circle,
                size: 10,
                color: isConnected ? Colors.green : Colors.red,
              ),
              const SizedBox(width: 5),
              Text(
                isConnected ? "Connecté" : "Déconnecté",
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
          Text("Membre depuis: $memberSince",
              style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }

  Widget _statsCard() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade800,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Text(
                  "$sessions",
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  "Sessions",
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade800,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Text(
                  averageNote.toStringAsFixed(1),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  "Note moyenne /5",
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

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

              const Center(
                child: Text(
                  'Ayoub le GOAT',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),

              const SizedBox(height: 10),

              const Center(
                child: Text(
                  'Goat Flutter',
                  style: TextStyle(color: Colors.grey),
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

              _infoCard(),
              const SizedBox(height: 15),
              _statsCard(),

              const SizedBox(height: 25),

              const Text(
                'Filière',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              TextField(
                controller: _filiereController,
                enabled: isEditing,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                'Année',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              TextField(
                controller: _anneeController,
                enabled: isEditing,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                'Description',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              TextField(
                controller: _descriptionController,
                enabled: isEditing,
                maxLines: 3,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                'Ajouter une compétence',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),

              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: selectedSkill,
                      items: options
                          .map(
                            (e) => DropdownMenuItem(
                              value: e,
                              child: Text(e),
                            ),
                          )
                          .toList(),
                      onChanged: isEditing
                          ? (value) {
                              setState(() {
                                selectedSkill = value;
                              });
                            }
                          : null,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: isEditing ? _addSkill : null,
                    child: const Text("+"),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              Wrap(
                children: skills
                    .map(
                      (s) => Chip(
                        label: Text(s),
                        onDeleted: isEditing
                            ? () => setState(() => skills.remove(s))
                            : null,
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}