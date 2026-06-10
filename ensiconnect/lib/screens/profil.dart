import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../service/chat_service.dart';
import '../models/conversation.dart';
import '../screens/chat_messages.dart';
import '../service/user_service.dart';
import '../widgets/custom_drawer.dart';
import '../widgets/custom_header.dart';
import '../widgets/person_avatar.dart';
import 'profile_comments_page.dart';

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
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>?
      _profileSubscription;

  final TextEditingController _descriptionController = TextEditingController();

  List<String> skillsOptions = [];
  List<String> skills = [];
  String? selectedSkill;

  bool isEditing = false;
  bool _isLoading = true;

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
  bool get _showLegacyProfileCards => false;

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
      _isLoading = false;
    });

    _profileSubscription?.cancel();
    _profileSubscription = FirebaseFirestore.instance
        .collection('Etudiant')
        .doc(profileUserId)
        .snapshots()
        .listen((doc) {
      final data = doc.data();
      if (!mounted || data == null) {
        return;
      }

      setState(() {
        sessions = (data['sessions'] is num)
            ? (data['sessions'] as num).toInt()
            : sessions;
        averageNote = (data['averageNote'] is num)
            ? (data['averageNote'] as num).toDouble()
            : averageNote;
      });
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
    _profileSubscription?.cancel();
    _descriptionController.dispose();
    super.dispose();
  }

  Widget _statCard({
    required String title,
    required String value,
    required IconData icon,
    required Color accentColor,
    VoidCallback? onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final card = Container(
      constraints: const BoxConstraints(minHeight: 128),
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          _IconTile(icon: icon, color: accentColor),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  title,
                  style: TextStyle(
                    color: isDark ? const Color(0xFFACB1BC) : Colors.black87,
                    fontSize: 15,
                    height: 1.2,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          if (onTap != null) ...[
            const SizedBox(width: 10),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: isDark ? const Color(0xFFACB1BC) : Colors.black45,
            ),
          ],
        ],
      ),
    );

    if (onTap == null) {
      return card;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: card,
      ),
    );
  }

  Widget _profileBadge({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: isDark
            ? color.withValues(alpha: 0.22)
            : color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: isDark ? 0.35 : 0.20),
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: isDark ? 0.10 : 0.08),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label.isEmpty ? '-' : label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoGridTile({
    required IconData icon,
    required String label,
    required String value,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const iconColor = Color(0xFF0B77E3);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _IconTile(icon: icon, color: iconColor),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value.isEmpty ? '-' : value,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isDark ? const Color(0xFFACB1BC) : Colors.black87,
                  fontSize: 14,
                  height: 1.25,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  BoxDecoration _cardDecoration() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BoxDecoration(
      color: isDark ? const Color(0xD90A111C) : Colors.white,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: isDark ? const Color(0xFF203047) : const Color(0xFFF1F4FA),
      ),
      boxShadow: [
        BoxShadow(
          color: isDark
              ? Colors.black.withValues(alpha: 0.18)
              : const Color(0xFF8FA5C7).withValues(alpha: 0.18),
          blurRadius: 24,
          offset: const Offset(0, 10),
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
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
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
    final iconColor = _quickActionColorForIcon(icon);

    return Column(
      children: [
        Row(
          children: [
            _IconTile(icon: icon, color: iconColor),
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

  Color _quickActionColorForIcon(IconData icon) {
    if (icon == Icons.person_rounded || icon == Icons.person_outline_rounded) {
      return const Color(0xFF7E57C2);
    }
    if (icon == Icons.mail_rounded || icon == Icons.mail_outline_rounded) {
      return const Color(0xFF42A5F5);
    }
    if (icon == Icons.school_rounded || icon == Icons.school_outlined) {
      return const Color(0xFF66BB6A);
    }
    if (icon == Icons.groups_outlined || icon == Icons.badge_outlined) {
      return const Color(0xFFEF5350);
    }
    return const Color(0xFF42A5F5);
  }

  Widget _profileActionButton() {
    if (isOwnProfile) {
      return OutlinedButton.icon(
        onPressed: _toggleEdit,
        icon: Icon(
          isEditing ? Icons.save_outlined : Icons.edit_outlined,
          color: Colors.white,
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

  Widget _profileHero() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark ? const Color(0xFF101A28) : Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF248BFF).withValues(alpha: 0.20),
                      blurRadius: 22,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: PersonAvatar(
                  name: fullName.isEmpty ? 'Profil' : fullName,
                  imageUrl: profilePictureUrl,
                  radius: 58,
                  fontSize: 40,
                ),
              ),
            ],
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fullName.isEmpty ? 'Profil' : fullName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                      fontSize: 25,
                      height: 1.05,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Flexible(
                        child: _profileBadge(
                          icon: Icons.computer_rounded,
                          label: filiere,
                          color: const Color(0xFFE0A400),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _profileBadge(
                        icon: Icons.school_rounded,
                        label: promotion,
                        color: const Color(0xFFE0A400),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _profileActionButton(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  ButtonStyle _outlinedActionStyle() {
    return OutlinedButton.styleFrom(
      foregroundColor: isOwnProfile ? Colors.white : const Color(0xFF0B77E3),
      backgroundColor:
          isOwnProfile ? const Color(0xFF0B77E3) : Colors.transparent,
      side: const BorderSide(color: Color(0xFF0B77E3)),
      minimumSize: const Size(0, 46),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      textStyle: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _aboutCard() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return _profileCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _IconTile(icon: Icons.person_outline_rounded),
              const SizedBox(width: 14),
              Expanded(child: _sectionTitle("À propos")),
            ],
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _descriptionController,
            enabled: isEditing && isOwnProfile,
            maxLines: 3,
            minLines: 1,
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontSize: 16,
            ),
            decoration: InputDecoration(
              hintText: "Décris-toi en quelques mots...",
              hintStyle: TextStyle(
                color: isDark ? const Color(0xFFACB1BC) : Colors.black45,
                fontSize: 16,
              ),
              border: InputBorder.none,
              isCollapsed: true,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }

  Widget _personalInfoCard() {
    return _profileCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _IconTile(
                icon: Icons.badge_outlined,
                color: const Color(0xFF0B77E3),
              ),
              const SizedBox(width: 14),
              Expanded(child: _sectionTitle("Informations personnelles")),
            ],
          ),
          const SizedBox(height: 22),
          _infoGridTile(
            icon: Icons.person_rounded,
            label: "Nom",
            value: fullName,
          ),
          const SizedBox(height: 18),
          _infoGridTile(
            icon: Icons.mail_rounded,
            label: "Email",
            value: email,
          ),
          const SizedBox(height: 18),
          _infoGridTile(
            icon: Icons.school_rounded,
            label: "Filière",
            value: filiere,
          ),
          const SizedBox(height: 18),
          _infoGridTile(
            icon: Icons.menu_book_rounded,
            label: "Promotion",
            value: promotion,
          ),
        ],
      ),
    );
  }

  Widget _skillsCard() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return _profileCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _IconTile(
                icon: Icons.lightbulb_outline_rounded,
                color: const Color(0xFFE0A400),
              ),
              const SizedBox(width: 14),
              Expanded(child: _sectionTitle("Compétences")),
            ],
          ),
          if (isEditing && isOwnProfile) ...[
            const SizedBox(height: 18),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: const Color(0xFFE0A400).withValues(alpha: 0.45),
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
                    style: const TextStyle(
                      color: Color(0xFFE0A400),
                      fontSize: 16,
                    ),
                  ),
                  dropdownColor:
                      isDark ? const Color(0xFF07101C) : Colors.white,
                  icon: const Icon(
                    Icons.add_circle_rounded,
                    color: Color(0xFFE0A400),
                  ),
                  isExpanded: true,
                  items: skillsOptions
                      .map(
                        (e) => DropdownMenuItem(
                          value: e,
                          child: Text(
                            e,
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => selectedSkill = v),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _addSkill,
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFFE0A400),
                ),
                child: const Text("Ajouter"),
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
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                      backgroundColor: isDark
                          ? const Color(0xFF2B2512)
                          : const Color(0xFFFFF4C7),
                      side: const BorderSide(color: Color(0xFFFFD35A)),
                    ),
                  )
                  .toList(),
            ),
          ] else if (!isEditing) ...[
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color:
                    isDark ? const Color(0xFF2B2512) : const Color(0xFFFFF4C7),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.school_outlined,
                    color: Color(0xFFE0A400),
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    "Aucune compétence",
                    style: TextStyle(
                      color: isDark ? const Color(0xFFFFE9A8) : Colors.black54,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      key: _scaffoldKey,
      drawer: widget.userId == null ? const CustomDrawer() : null,
      backgroundColor: isDark
          ? Theme.of(context).scaffoldBackgroundColor
          : const Color(0xFFF6F9FE),
      appBar: widget.userId == null
          ? null
          : AppBar(
              centerTitle: true,
              elevation: 0,
              backgroundColor: Colors.transparent,
            ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SizedBox(
                width: double.infinity,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 28),
                  child: Column(
                    children: [
                      if (isOwnProfile)
                        CustomHeader(
                          onMenuPressed: () {
                            _scaffoldKey.currentState?.openDrawer();
                          },
                        ),
                      const SizedBox(height: 18),
                      _profileHero(),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Expanded(
                            child: _statCard(
                              title: "Sessions\nréalisées",
                              value: "$sessions",
                              icon: Icons.calendar_month_rounded,
                              accentColor: const Color(0xFF0B77E3),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: _statCard(
                              title: "Note",
                              value: averageNote.toStringAsFixed(1),
                              icon: Icons.star_border_rounded,
                              accentColor: const Color(0xFFE0A400),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ProfileCommentsPage(
                                      profileUserId: profileUserId,
                                      profileName: fullName,
                                      averageNote: averageNote,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      _aboutCard(),
                      const SizedBox(height: 18),
                      _personalInfoCard(),
                      const SizedBox(height: 18),
                      _skillsCard(),
                      if (_showLegacyProfileCards) ...[
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
                                        color: isDark
                                            ? Colors.white
                                            : Colors.black87,
                                        fontSize: 16,
                                      ),
                                      decoration: InputDecoration(
                                        hintText:
                                            "Décris-toi en quelques mots...",
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
                                        icon: const Icon(Icons.add_rounded,
                                            size: 24),
                                        label: const Text("Ajouter"),
                                        style: TextButton.styleFrom(
                                          foregroundColor:
                                              const Color(0xFF248BFF),
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
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14),
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
                                              skillsOptions
                                                  .contains(selectedSkill))
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
                                            color: isDark
                                                ? Colors.white
                                                : Colors.black87,
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
                      ],
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
  const _IconTile({
    required this.icon,
    this.color = const Color(0xFF0B77E3),
  });

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        color: isDark
            ? color.withValues(alpha: 0.18)
            : color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: color.withValues(
              alpha: isDark ? 0.10 : 0.08,
            ),
            blurRadius: 18,
          ),
        ],
      ),
      child: Icon(icon, color: color, size: 30),
    );
  }
}
