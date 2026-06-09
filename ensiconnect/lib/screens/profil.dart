import 'package:flutter/material.dart';

import '../service/chat_service.dart';
import '../models/conversation.dart';
import '../screens/chat_messages.dart';
import '../service/user_service.dart';
import '../widgets/custom_drawer.dart';
import '../widgets/custom_header.dart';
import '../widgets/person_avatar.dart';
import '../widgets/profil_widget.dart';

class ProfilPage extends StatefulWidget {
  final String? userId;

  const ProfilPage({super.key, this.userId});

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
  bool _isLoading = true;

  String currentUserId = "";
  String fullName = "";
  String email = "";
  String filiere = "";
  String promotion = "";
  String profilePictureUrl = '';

  int sessions = 0;
  double averageNote = 0.0;

  late ProfilWidget ui;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    ui = ProfilWidget(context);
  }

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final currentUser = await _user.getCurrentUser();

    final user = widget.isOwnProfile
        ? currentUser
        : await _user.getUserById(widget.userId!);

    final options = await _user.getAllSkillsOptions();

    if (!mounted) return;

    if (user == null || currentUser == null) {
      setState(() => _isLoading = false);
      return;
    }

    setState(() {
      currentUserId = currentUser.id;
      fullName = user.fullName;
      email = user.email;
      filiere = user.filiere;
      promotion = user.promotion;
      profilePictureUrl = user.profilePictureUrl;

      skills = List<String>.from(user.skills);
      _descriptionController.text = user.description;

      sessions = user.sessions;
      averageNote = user.averageNote;

      skillsOptions =
          options.map<String>((e) => e['name'].toString()).toSet().toList();

      _isLoading = false;
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

  void _removeSkill(String skill) {
    setState(() => skills.remove(skill));
  }

  Future<void> _openChat() async {
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
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      key: _scaffoldKey,

      /// Drawer seulement sur ton profil
      drawer: widget.isOwnProfile ? const CustomDrawer() : null,

      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      /// 🔥 APPBAR = flèche retour sur profils publics
      appBar: widget.isOwnProfile
          ? null
          : AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              centerTitle: true,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),
            ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 28),
          child: Column(
            children: [
              if (widget.isOwnProfile)
                CustomHeader(
                  onMenuPressed: () =>
                      _scaffoldKey.currentState?.openDrawer(),
                ),

              const SizedBox(height: 20),

              PersonAvatar(
                name: fullName.isEmpty ? "Profil" : fullName,
                imageUrl: profilePictureUrl,
                radius: 64,
                fontSize: 44,
              ),

              const SizedBox(height: 18),

              Text(
                fullName.isEmpty ? "Profil" : fullName,
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                  fontSize: 32,
                ),
              ),

              const SizedBox(height: 20),

              /// ACTION BUTTON
              widget.isOwnProfile
                  ? OutlinedButton(
                      onPressed: _toggleEdit,
                      child: Text(isEditing ? "Sauvegarder" : "Modifier"),
                    )
                  : OutlinedButton.icon(
                      onPressed: _openChat,
                      icon: const Icon(Icons.chat_bubble_outline),
                      label: const Text("Envoyer un message"),
                    ),

              const SizedBox(height: 30),

              Row(
                children: [
                  Expanded(
                    child: ui.statCard(
                      title: "Sessions",
                      value: "$sessions",
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: ui.statCard(
                      title: "Note moyenne",
                      value: averageNote.toStringAsFixed(1),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              /// INFOS
              ui.profileCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ui.sectionTitle("Informations personnelles"),
                    const SizedBox(height: 20),
                    ui.infoRow(
                      icon: Icons.mail_outline,
                      label: "Email",
                      value: email,
                    ),
                    ui.infoRow(
                      icon: Icons.school_outlined,
                      label: "Filière",
                      value: filiere,
                    ),
                    ui.infoRow(
                      icon: Icons.groups,
                      label: "Promotion",
                      value: promotion,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              /// DESCRIPTION
              ui.profileCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ui.sectionTitle("À propos"),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _descriptionController,
                      enabled: isEditing,
                      maxLines: 4,
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: "Décris-toi...",
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              /// SKILLS
              ui.profileCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ui.sectionTitle("Compétences"),
                    const SizedBox(height: 12),

                    if (isEditing) ...[
                      DropdownButton<String>(
                        value: selectedSkill,
                        hint: const Text("Ajouter une compétence"),
                        isExpanded: true,
                        items: skillsOptions
                            .map((e) => DropdownMenuItem(
                                  value: e,
                                  child: Text(e),
                                ))
                            .toList(),
                        onChanged: (v) =>
                            setState(() => selectedSkill = v),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: _addSkill,
                        child: const Text("Ajouter"),
                      ),
                      const SizedBox(height: 12),
                    ],

                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: skills.map((skill) {
                        return Chip(
                          label: Text(skill),
                          onDeleted: isEditing
                              ? () => _removeSkill(skill)
                              : null,
                          deleteIcon: isEditing
                              ? const Icon(Icons.close, size: 18)
                              : null,
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}