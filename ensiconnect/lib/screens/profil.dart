import 'package:flutter/material.dart';
import '../services/auth_services.dart';

class ProfilPage extends StatefulWidget {
  const ProfilPage({super.key});

  @override
  State<ProfilPage> createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  final AuthServices _auth = AuthServices();

  final TextEditingController _descriptionController = TextEditingController();

  final List<String> options = [
    "Java",
    "Mathématiques",
    "Anglais",
    "Prog fonc",
  ];

  List<String> skills = [];
  String? selectedSkill;

  bool isEditing = false;

  String fullName = "";
  String email = "";

  int sessions = 12;
  double averageNote = 4.2;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await _auth.getCurrentUser();

    if (!mounted) return;

    setState(() {
      fullName = user?.fullName ?? "Utilisateur inconnu";
      email = user?.email ?? "";

      // ⚠️ fallback si ton modèle n’a pas encore ces champs
      skills = (user as dynamic).skills ?? [];
      _descriptionController.text = (user as dynamic).description ?? "";
    });
  }

  void _toggleEdit() async {
    if (isEditing) {
      // ⚠️ ICI on ne force aucune base de données
      // tu peux brancher Firebase plus tard
      debugPrint("SAVE:");
      debugPrint(_descriptionController.text);
      debugPrint(skills.toString());
    }

    if (!mounted) return;

    setState(() {
      isEditing = !isEditing;
    });
  }

  void _addSkill() {
    if (selectedSkill != null && !skills.contains(selectedSkill)) {
      setState(() {
        skills.add(selectedSkill!);
        selectedSkill = null;
      });
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Widget _infoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(16),
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
          Text("Email: $email"),
        ],
      ),
    );
  }

  Widget _statCard(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          Text(title),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 40),

            const CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage("https://picsum.photos/200"),
            ),

            const SizedBox(height: 15),

            Text(
              fullName,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: _toggleEdit,
              child: Text(isEditing ? "Sauvegarder" : "Modifier le profil"),
            ),

            const SizedBox(height: 20),

            _infoCard(),

            const SizedBox(height: 20),

            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Description",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),

            TextField(
              controller: _descriptionController,
              enabled: isEditing,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: "Décris-toi...",
              ),
            ),

            const SizedBox(height: 20),

            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Compétences",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),

            Row(
              children: [
                Expanded(
                  child: DropdownButton<String>(
                    value: selectedSkill,
                    hint: const Text("Choisir"),
                    isExpanded: true,
                    items: options
                        .map(
                          (e) => DropdownMenuItem(
                            value: e,
                            child: Text(e),
                          ),
                        )
                        .toList(),
                    onChanged: isEditing
                        ? (v) => setState(() => selectedSkill = v)
                        : null,
                  ),
                ),
                IconButton(
                  onPressed: isEditing ? _addSkill : null,
                  icon: const Icon(Icons.add),
                ),
              ],
            ),

            Wrap(
              spacing: 8,
              children: skills.isEmpty
                  ? [const Text("Aucune compétence")]
                  : skills
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

            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(child: _statCard("Sessions", "$sessions")),
                const SizedBox(width: 10),
                Expanded(
                  child: _statCard(
                    "Note moyenne",
                    averageNote.toStringAsFixed(1),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}