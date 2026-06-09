import 'package:flutter/material.dart';
import '../service/chat_service.dart';
import '../models/conversation.dart';
import '../screens/chat_messages.dart';
import '../service/user_service.dart';
import '../widgets/custom_drawer.dart';

class ProfilPage extends StatefulWidget {
  final String? userId; // null = mon profil, non-null = profil public

  const ProfilPage({super.key, this.userId});

  // Getters sémantiques pour clarifier l'intention
  bool get isOwnProfile => userId == null;

  @override
  State<ProfilPage> createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  final UserServices _user = UserServices();
  final ChatService chatService = ChatService();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _descriptionController = TextEditingController();

  List<String> skillsOptions = [];
  List<String> skills = [];
  String? selectedSkill;
  bool isEditing = false;
  bool _loading = true;

  String currentUserId = "";
  String fullName = "";
  String email = "";
  String filiere = "";
  String promotion = "";
  int sessions = 0;
  double averageNote = 0.0;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final currentUser = await _user.getCurrentUser();

    // Si userId fourni → profil public, sinon → mon profil
    final user = widget.isOwnProfile
        ? currentUser
        : await _user.getUserById(widget.userId!);

    final options = await _user.getAllSkillsOptions();

    if (!mounted || user == null || currentUser == null) return;

    setState(() {
      currentUserId = currentUser.id;

      fullName = user.fullName;
      email = user.email;
      filiere = user.filiere;
      promotion = user.promotion;
      skills = List<String>.from(user.skills ?? []);
      _descriptionController.text = user.description ?? "";
      sessions = user.sessions ?? 0;
      averageNote = (user.averageNote ?? 0).toDouble();
      skillsOptions =
          options.map<String>((e) => e['name'].toString()).toSet().toList();
      _loading = false;
    });
  }

  Future<void> _toggleEdit() async {
    if (isEditing) {
      await _user.updateUserProfile(
        userId: currentUserId,
        description: _descriptionController.text,
        skills: skills,
        filiere: filiere,
        promotion: promotion,
      );
    }
    setState(() => isEditing = !isEditing);
  }

  void _addSkill() {
    if (selectedSkill != null && !skills.contains(selectedSkill)) {
      setState(() {
        skills.add(selectedSkill!);
        selectedSkill = null;
      });
    }
  }

  void _removeSkill(String skill) => setState(() => skills.remove(skill));

  String getInitials(String name) {
    if (name.trim().isEmpty) return "?";
    final parts = name.trim().split(" ");
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
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

  // ─── AppBar ────────────────────────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar(bool isDark) {
    if (widget.isOwnProfile) {
      // Mon profil : burger pour ouvrir le drawer
      return AppBar(
        title: const Text('Mon profil'),
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: isDark ? Colors.white : Colors.black87,
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
      );
    } else {
      // Profil public : flèche retour, pas de drawer
      return AppBar(
        title: Text(fullName.isNotEmpty ? fullName : 'Profil'),
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: isDark ? Colors.white : Colors.black87,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      );
    }
  }

  // ─── Actions selon le type de profil ──────────────────────────────────────

  Widget _buildProfileActions() {
    if (widget.isOwnProfile) {
      return ElevatedButton(
        onPressed: _toggleEdit,
        child: Text(isEditing ? "Sauvegarder" : "Modifier le profil"),
      );
    } else {
      return ElevatedButton.icon(
        icon: const Icon(Icons.chat),
        label: const Text("Envoyer un message"),
        onPressed: () async {
          final convoId = await chatService.getOrCreateConversation(
            participants: [currentUserId, widget.userId!],
          );
          if (!mounted) return;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ConversationPage(
                conversation: Conversation(
                  id: convoId,
                  participants: [currentUserId, widget.userId!],
                  messages: const [],
                  lastMessage: '',
                  lastMessageAt: null,
                  createdAt: null,
                  name: null,
                ),
                currentUserId: currentUserId,
              ),
            ),
          );
        },
      );
    }
  }

  // ─── Description ──────────────────────────────────────────────────────────

  Widget _buildDescription(bool isDark) {
    if (widget.isOwnProfile) {
      // Champ éditable
      return TextField(
        controller: _descriptionController,
        enabled: isEditing,
        maxLines: 3,
        decoration: const InputDecoration(
          hintText: "Décris-toi...",
          border: OutlineInputBorder(),
        ),
      );
    } else {
      // Texte en lecture seule, caché si vide
      final desc = _descriptionController.text.trim();
      if (desc.isEmpty) return const SizedBox.shrink();
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF111827) : Colors.blue.shade50,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "À propos",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(desc),
          ],
        ),
      );
    }
  }

  // ─── Skills ───────────────────────────────────────────────────────────────

  Widget _buildSkills(bool isDark) {
    if (skills.isEmpty && !widget.isOwnProfile) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF111827) : Colors.blue.shade50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Compétences",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: skills.map((skill) {
              return Chip(
                label: Text(skill),
                // Suppression uniquement sur mon profil en mode édition
                onDeleted: (widget.isOwnProfile && isEditing)
                    ? () => _removeSkill(skill)
                    : null,
              );
            }).toList(),
          ),
          // Ajout de compétence uniquement sur mon profil en mode édition
          if (widget.isOwnProfile && isEditing) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: selectedSkill,
                    hint: const Text("Ajouter une compétence"),
                    items: skillsOptions
                        .where((s) => !skills.contains(s))
                        .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                        .toList(),
                    onChanged: (v) => setState(() => selectedSkill = v),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.add_circle),
                  onPressed: _addSkill,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // ─── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      key: _scaffoldKey,
      // Drawer uniquement sur mon profil
      drawer: widget.isOwnProfile ? const CustomDrawer() : null,
      appBar: _buildAppBar(isDark),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),

              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.blue,
                child: Text(
                  getInitials(fullName),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              const SizedBox(height: 10),

              Text(
                fullName,
                style: const TextStyle(
                    fontSize: 22, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 15),

              _buildProfileActions(),

              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                      child: _statCard("Sessions", "$sessions", isDark)),
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

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF111827)
                      : Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Informations personnelles",
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Text("Email: $email"),
                    Text("Filière: $filiere"),
                    Text("Promotion: $promotion"),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              _buildDescription(isDark),

              const SizedBox(height: 20),

              _buildSkills(isDark),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}