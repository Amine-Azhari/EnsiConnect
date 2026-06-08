import 'package:flutter/material.dart';
import '../service/chat_service.dart';
import '../models/conversation.dart';
import '../screens/chat_messages.dart';
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
  final ChatService chatService = ChatService();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final TextEditingController _descriptionController = TextEditingController();

  List<String> skillsOptions = [];
  List<String> skills = [];
  String? selectedSkill;

  bool isEditing = false;

  String currentUserId = "";
  String profileUserId = "";

  String fullName = "";
  String email = "";
  String filiere = "";
  String promotion = "";

  int sessions = 0;
  double averageNote = 0.0;

  bool get isOwnProfile => currentUserId == profileUserId;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final currentUser = await _user.getCurrentUser();

    final user = widget.userId != null
        ? await _user.getUserById(widget.userId!)
        : currentUser;

    final options = await _user.getAllSkillsOptions();

    if (!mounted || user == null || currentUser == null) return;

    setState(() {
      currentUserId = currentUser.id;
      profileUserId = user.id;

      fullName = user.fullName;
      email = user.email;
      filiere = user.filiere;
      promotion = user.promotion;

      skills = List<String>.from(user.skills ?? []);
      _descriptionController.text = user.description ?? "";

      sessions = user.sessions ?? 0;
      averageNote = (user.averageNote ?? 0).toDouble();

      skillsOptions = options
          .map<String>((e) => e['name'].toString())
          .toSet()
          .toList();
    });
  }

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

  void _addSkill() {
    if (!isOwnProfile) return;

    if (selectedSkill != null && !skills.contains(selectedSkill)) {
      setState(() {
        skills.add(selectedSkill!);
        selectedSkill = null;
      });
    }
  }

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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      key: _scaffoldKey,
      drawer: const CustomDrawer(),

      appBar: AppBar(
        title: Text(isOwnProfile ? 'Mon profil' : 'Profil'),
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor:
            Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : Colors.black87,

        leading: isOwnProfile
            ? IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () {
                  _scaffoldKey.currentState?.openDrawer();
                },
              )
            : IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height - 150,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [

                const SizedBox(height: 20),

                Center(
                  child: CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.blue.shade600,
                    child: Text(
                      getInitials(fullName),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
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

                if (!isOwnProfile)
                  Center(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.chat),
                      label: const Text("Envoyer un message"),
                      onPressed: () async {
                        final convoId =
                            await chatService.getOrCreateConversation(
                          participants: [
                            currentUserId,
                            widget.userId!,
                          ],
                        );

                        if (!mounted) return;

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ConversationPage(
                              conversation: Conversation(
                                id: convoId,
                                participants: [
                                  currentUserId,
                                  widget.userId!,
                                ],
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
                    ),
                  ),

                const SizedBox(height: 15),

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

                Container(
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
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text("Email: $email"),
                      Text("Filière: $filiere"),
                      Text("Promotion: $promotion"),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                TextField(
                  controller: _descriptionController,
                  enabled: isEditing && isOwnProfile,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: "Décris-toi...",
                  ),
                ),

                const SizedBox(height: 20),

                Row(
                  children: [
                    Expanded(
                      child: DropdownButton<String>(
                        value: (selectedSkill != null &&
                                skillsOptions.contains(selectedSkill))
                            ? selectedSkill
                            : null,
                        hint: const Text("Choisir"),
                        isExpanded: true,
                        items: skillsOptions
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
                      : skills.map((s) {
                          return Chip(
                            label: Text(s),
                            deleteIcon: (isEditing && isOwnProfile)
                                ? const Icon(Icons.close, size: 18)
                                : null,
                            onDeleted: (isEditing && isOwnProfile)
                                ? () {
                                    setState(() {
                                      skills.remove(s);
                                    });
                                  }
                                : null,
                          );
                        }).toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
