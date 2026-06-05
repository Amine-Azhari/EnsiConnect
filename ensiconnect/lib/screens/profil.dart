import 'package:flutter/material.dart';
import '../service/user_service.dart';
import '../widgets/custom_drawer.dart';
import '../widgets/custom_header.dart';

class ProfilPage extends StatefulWidget {
  final String? userId; // 👈 profil consulté (optionnel)

  const ProfilPage({super.key, this.userId});

  @override
  State<ProfilPage> createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  final UserServices _user = UserServices();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

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

  String currentUserId = "";

  String fullName = "";
  String email = "";

  String filiere = "";
  String promotion = "";

  // ✅ NOUVEAU : depuis Firestore
  int sessions = 0;
  double averageNote = 0.0;

  bool get isOwnProfile =>
      widget.userId == null || widget.userId == currentUserId;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await _user.getCurrentUser();

    if (!mounted) return;

    if (user == null) {
      setState(() {
        fullName = "Utilisateur inconnu";
        email = "";
      });
      return;
    }

    setState(() {
      currentUserId = user.id;

      fullName = user.fullName;
      email = user.email;

      filiere = user.filiere;
      promotion = user.promotion;

      skills = user.skills;
      _descriptionController.text = user.description;

      // ✅ AJOUT ICI
      sessions = user.sessions;
      averageNote = user.averageNote;
    });
  }

  Future<void> _toggleEdit() async {
    if (!isOwnProfile) return;

    if (isEditing) {
      await _auth.updateUserProfile(
        userId: currentUserId,
        description: _descriptionController.text,
        skills: skills,
        filiere: filiere,
        promotion: promotion,
      );
    }

    if (!mounted) return;

    setState(() {
      isEditing = !isEditing;
    });
  }

  void _addSkill() {
    if (!isOwnProfile) return;

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

  Widget _infoCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF111827) : Colors.blue.shade50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: DefaultTextStyle(
        style: TextStyle(
          fontSize: 16,
          color: isDark ? Colors.white : Colors.black,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Informations personnelles",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 12),

            Text("Nom: $fullName"),
            Text("Email: $email"),
            Text("Filière: $filiere"),
            Text("Promotion: $promotion"),
          ],
        ),
      ),
    );
  }

  Widget _statCard(String title, String value, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF111827) : Colors.blue.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            title,
            style: TextStyle(
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      key: _scaffoldKey,
      drawer: const CustomDrawer(),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              CustomHeader(
                onMenuPressed: () =>
                    _scaffoldKey.currentState?.openDrawer(),
              ),

              const SizedBox(height: 10),

              const Center(
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: NetworkImage('https://picsum.photos/200'),
                ),
              ),

              const SizedBox(height: 10),

              Center(
                child: Text(
                  fullName,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 10),

              if (isOwnProfile)
                Center(
                  child: ElevatedButton(
                    onPressed: _toggleEdit,
                    child: Text(
                      isEditing ? "Sauvegarder" : "Modifier le profil",
                    ),
                  ),
                ),

              const SizedBox(height: 20),

              _infoCard(isDark),

              const SizedBox(height: 20),

              const Text(
                "Description",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),

              TextField(
                controller: _descriptionController,
                enabled: isEditing && isOwnProfile,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: "Décris-toi...",
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                "Compétences",
                style: TextStyle(fontWeight: FontWeight.bold),
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
                      onChanged: isEditing && isOwnProfile
                          ? (v) => setState(() => selectedSkill = v)
                          : null,
                    ),
                  ),
                  IconButton(
                    onPressed: isEditing && isOwnProfile ? _addSkill : null,
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
                            onDeleted: isEditing && isOwnProfile
                                ? () => setState(() => skills.remove(s))
                                : null,
                          ),
                        )
                        .toList(),
              ),

              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: _statCard("Sessions", "$sessions", isDark),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _statCard(
                      "Note moyenne",
                      averageNote.toStringAsFixed(1),
                      isDark,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}