import 'package:flutter/material.dart';
import '../service/chat_service.dart';
import '../models/conversation.dart';
import '../screens/chat_messages.dart';
import '../service/user_service.dart';
import '../widgets/custom_drawer.dart';
import '../widgets/custom_header.dart';
import '../widgets/person_avatar.dart';

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
  String profilePictureUrl = '';

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
      profilePictureUrl = user.profilePictureUrl;

      skills = List<String>.from(user.skills);
      _descriptionController.text = user.description;

      sessions = user.sessions;
      averageNote = user.averageNote;

      skillsOptions =
          options.map<String>((e) => e['name'].toString()).toSet().toList();
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

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Widget _statCard({
    required String title,
    required String value,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      constraints: const BoxConstraints(minHeight: 112),
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontSize: 34,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isDark ? const Color(0xFFACB1BC) : Colors.black54,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BoxDecoration(
      color: isDark ? const Color(0xD90A111C) : Colors.white,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: const Color(0xFF248BFF), width: 1),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFF248BFF).withValues(alpha: 0.08),
          blurRadius: 26,
          spreadRadius: 1,
        ),
      ],
    );
  }

  Widget _profileCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: child,
    );
  }

  Widget _sectionTitle(String title, {Widget? trailing}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                width: 46,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFF248BFF),
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ],
          ),
        ),
        if (trailing != null) trailing,
      ],
    );
  }

  Widget _infoRow({
    required IconData icon,
    required String label,
    required String value,
    bool showDivider = true,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        Row(
          children: [
            _IconTile(icon: icon),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: isDark ? const Color(0xFFACB1BC) : Colors.black54,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    value.isEmpty ? '-' : value,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (showDivider) ...[
          const SizedBox(height: 16),
          Divider(
            color: isDark ? const Color(0xFF243142) : const Color(0xFFE2E8F0),
            height: 1,
          ),
          const SizedBox(height: 16),
        ],
      ],
    );
  }

  Widget _profileActionButton() {
    if (isOwnProfile) {
      return OutlinedButton.icon(
        onPressed: _toggleEdit,
        icon: Icon(
          isEditing ? Icons.save_outlined : Icons.edit_outlined,
          color: const Color(0xFF248BFF),
        ),
        label: Text(isEditing ? "Sauvegarder" : "Modifier le profil"),
        style: _outlinedActionStyle(),
      );
    }

    return OutlinedButton.icon(
      onPressed: () async {
        final convoId = await chatService.getOrCreateConversation(
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
      icon: const Icon(Icons.chat_bubble_outline_rounded),
      label: const Text("Envoyer un message"),
      style: _outlinedActionStyle(),
    );
  }

  ButtonStyle _outlinedActionStyle() {
    return OutlinedButton.styleFrom(
      foregroundColor: const Color(0xFF248BFF),
      side: const BorderSide(color: Color(0xFF248BFF)),
      minimumSize: const Size(248, 56),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      textStyle: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      key: _scaffoldKey,
      drawer: const CustomDrawer(),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 28),
            child: Column(
              children: [
                CustomHeader(
                  onMenuPressed: () {
                    _scaffoldKey.currentState?.openDrawer();
                  },
                ),
                const SizedBox(height: 20),
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF248BFF).withValues(alpha: 0.35),
                        blurRadius: 28,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: PersonAvatar(
                    name: fullName.isEmpty ? 'Profil' : fullName,
                    imageUrl: profilePictureUrl,
                    radius: 64,
                    fontSize: 44,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  fullName.isEmpty ? 'Profil' : fullName,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                    fontSize: 32,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 20),
                _profileActionButton(),
                const SizedBox(height: 30),
                Row(
                  children: [
                    Expanded(
                      child: _statCard(
                        title: "Sessions",
                        value: "$sessions",
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: _statCard(
                        title: "Note moyenne",
                        value: averageNote.toStringAsFixed(1),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                _profileCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionTitle("Informations personnelles"),
                      const SizedBox(height: 24),
                      _infoRow(
                        icon: Icons.mail_outline_rounded,
                        label: "Email",
                        value: email,
                      ),
                      _infoRow(
                        icon: Icons.school_outlined,
                        label: "Filière",
                        value: filiere,
                      ),
                      _infoRow(
                        icon: Icons.groups_outlined,
                        label: "Promotion",
                        value: promotion,
                        showDivider: false,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                _profileCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionTitle("À propos de moi"),
                      const SizedBox(height: 22),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.format_quote_rounded,
                            color: Color(0xFF248BFF),
                            size: 34,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: _descriptionController,
                              enabled: isEditing && isOwnProfile,
                              maxLines: 4,
                              minLines: 2,
                              style: TextStyle(
                                color: isDark ? Colors.white : Colors.black87,
                                fontSize: 16,
                              ),
                              decoration: InputDecoration(
                                hintText: "Décris-toi en quelques mots...",
                                hintStyle: TextStyle(
                                  color: isDark
                                      ? const Color(0xFFACB1BC)
                                      : Colors.black45,
                                  fontSize: 16,
                                ),
                                border: InputBorder.none,
                                isCollapsed: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                _profileCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionTitle(
                        "Compétences",
                        trailing: isEditing && isOwnProfile
                            ? TextButton.icon(
                                onPressed: _addSkill,
                                icon: const Icon(Icons.add_rounded, size: 24),
                                label: const Text("Ajouter"),
                                style: TextButton.styleFrom(
                                  foregroundColor: const Color(0xFF248BFF),
                                  textStyle: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              )
                            : null,
                      ),
                      if (isEditing && isOwnProfile) ...[
                        const SizedBox(height: 18),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF07101C)
                                : const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isDark
                                  ? const Color(0xFF243142)
                                  : const Color(0xFFE2E8F0),
                            ),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: (selectedSkill != null &&
                                      skillsOptions.contains(selectedSkill))
                                  ? selectedSkill
                                  : null,
                              hint: Text(
                                skills.isEmpty
                                    ? "Aucune compétence"
                                    : "Choisir une compétence",
                                style: TextStyle(
                                  color: isDark
                                      ? const Color(0xFFACB1BC)
                                      : Colors.black54,
                                  fontSize: 16,
                                ),
                              ),
                              dropdownColor: isDark
                                  ? const Color(0xFF07101C)
                                  : Colors.white,
                              icon: const Icon(
                                Icons.keyboard_arrow_down_rounded,
                                color: Color(0xFF248BFF),
                              ),
                              isExpanded: true,
                              items: skillsOptions
                                  .map(
                                    (e) => DropdownMenuItem(
                                      value: e,
                                      child: Text(
                                        e,
                                        style: TextStyle(
                                          color: isDark
                                              ? Colors.white
                                              : Colors.black87,
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (v) =>
                                  setState(() => selectedSkill = v),
                            ),
                          ),
                        ),
                      ],
                      if (skills.isNotEmpty) ...[
                        const SizedBox(height: 14),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: skills
                              .map(
                                (skill) => Chip(
                                  label: Text(skill),
                                  labelStyle: TextStyle(
                                    color:
                                        isDark ? Colors.white : Colors.black87,
                                  ),
                                  backgroundColor: isDark
                                      ? const Color(0xFF10243A)
                                      : const Color(0xFFEAF4FF),
                                  side: const BorderSide(
                                    color: Color(0xFF248BFF),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ] else if (!isEditing) ...[
                        const SizedBox(height: 14),
                        Text(
                          "Aucune compétence",
                          style: TextStyle(
                            color: isDark
                                ? const Color(0xFFACB1BC)
                                : Colors.black54,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _IconTile extends StatelessWidget {
  const _IconTile({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF102033) : const Color(0xFFEAF4FF),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF248BFF).withValues(
              alpha: isDark ? 0.10 : 0.08,
            ),
            blurRadius: 18,
          ),
        ],
      ),
      child: Icon(icon, color: const Color(0xFF248BFF), size: 30),
    );
  }
}
