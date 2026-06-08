import 'package:flutter/material.dart';
import '../service/user_service.dart';
import '../widgets/custom_drawer.dart';
import '../widgets/custom_header.dart';

class ProfilPage extends StatefulWidget {
  final String? userId;

  const ProfilPage({super.key, this.userId});

  @override
  State<ProfilPage> createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  final UserServices _user = UserServices();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final TextEditingController _descriptionController = TextEditingController();

  // 🔥 skills options depuis Firestore (Matiere)
  List<Map<String, String>> skillsOptions = [];

  // 🔥 skills = IDs Firestore
  List<String> skills = [];
  String? selectedSkill;

  bool isEditing = false;

  String currentUserId = "";

  String fullName = "";
  String email = "";
  String filiere = "";
  String promotion = "";

  int sessions = 0;
  double averageNote = 0.0;

  bool get isOwnProfile =>
      widget.userId == null || widget.userId == currentUserId;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  // 🔥 LOAD DATA FIRESTORE
  Future<void> _loadUser() async {
    final user = widget.userId != null
        ? await _user.getUserById(widget.userId!)
        : await _user.getCurrentUser();

    final options = await _user.getAllSkillsOptions();

    if (!mounted || user == null) return;

    setState(() {
      // skills options (matières)
      skillsOptions = options.map((e) {
        return {
          'id': e['id'].toString(),
          'name': e['name'].toString(),
        };
      }).toList();

      // user data
      currentUserId = user.id;
      fullName = user.fullName;
      email = user.email;
      filiere = user.filiere;
      promotion = user.promotion;

      // skills = IDS
      skills = List<String>.from(user.skills ?? []);

      _descriptionController.text = user.description;

      sessions = user.sessions;
      averageNote = user.averageNote;
    });
  }

  // 🔥 SAVE PROFILE
  Future<void> _toggleEdit() async {
    if (!isOwnProfile) return;

    if (isEditing) {
      await _user.updateUserProfile(
        userId: currentUserId,
        description: _descriptionController.text,
        skills: skills,
        filiere: filiere,
        promotion: promotion,
      );
    }

    setState(() {
      isEditing = !isEditing;
    });
  }

  // 🔥 ADD SKILL
  void _addSkill() {
    if (!isOwnProfile) return;

    if (selectedSkill != null && !skills.contains(selectedSkill)) {
      setState(() {
        skills.add(selectedSkill!);
        selectedSkill = null;
      });
    }
  }

  // 🔥 CONVERT ID → NAME
  String getSkillName(String id) {
    final skill = skillsOptions.firstWhere(
      (e) => e['id'] == id,
      orElse: () => {'name': 'Inconnu'},
    );

    return skill['name'] ?? 'Inconnu';
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  String getInitials(String name) {
    if (name.trim().isEmpty) return "?";

    final parts = name.trim().split(" ");
    if (parts.length == 1) return parts[0][0].toUpperCase();

    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      key: _scaffoldKey,
      drawer: const CustomDrawer(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              if (isOwnProfile)
                CustomHeader(
                  onMenuPressed: () =>
                      _scaffoldKey.currentState?.openDrawer(),
                ),

              const SizedBox(height: 10),

              Center(
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.blue,
                  child: Text(
                    getInitials(fullName),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              Center(
                child: Text(
                  fullName,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(child: _statCard("Sessions", "$sessions", isDark)),
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

              const SizedBox(height: 20),

              TextField(
                controller: _descriptionController,
                enabled: isEditing && isOwnProfile,
                maxLines: 3,
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
                      items: skillsOptions.map((e) {
                        return DropdownMenuItem<String>(
                          value: e['id'],
                          child: Text(e['name'] ?? ''),
                        );
                      }).toList(),
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
                        .map((id) => Chip(label: Text(getSkillName(id))))
                        .toList(),
              ),
            ],
          ),
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
          Text(title),
        ],
      ),
    );
  }
}