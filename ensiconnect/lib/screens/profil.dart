import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/profile_skills_card.dart';
import '../widgets/profile_info_card.dart';
import '../widgets/profile_about_card.dart';
import '../widgets/profile_stat_card.dart';
import '../widgets/icon_tile.dart';
import '../widgets/profile_hero.dart';
import 'package:flutter/material.dart';
import '../service/chat_service.dart';
import '../service/user_service.dart';
import '../widgets/custom_drawer.dart';
import '../widgets/custom_header.dart';
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
  int reviewsCount = 0;
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

    _loadReviewsCount();

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

  Future<void> _loadReviewsCount() async {
    final snapshots = await Future.wait([
      FirebaseFirestore.instance
          .collection('Evaluation')
          .where('tutorId', isEqualTo: profileUserId)
          .get(),
      FirebaseFirestore.instance
          .collection('Evaluation')
          .where('tutorID', isEqualTo: profileUserId)
          .get(),
    ]);

    final seenIds = <String>{};
    var count = 0;

    for (final snapshot in snapshots) {
      for (final doc in snapshot.docs) {
        if (!seenIds.add(doc.id)) continue;

        final comment = (doc.data()['Commentaire'] ?? '').toString().trim();
        if (comment.isNotEmpty) {
          count++;
        }
      }
    }

    if (!mounted) return;

    setState(() {
      reviewsCount = count;
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

  Widget _profileCard({required Widget child}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      // decoration: ProfileStatCard.cardDecoration(isDark, context),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: isDark ? Border.all(color: Colors.grey.shade800, width: 1) : null,
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
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
            IconTile(icon: icon, color: iconColor),
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
    if (icon == Icons.badge_outlined) {
      return const Color(0xFF7E57C2);
    }
    if (icon == Icons.menu_book_outlined || icon == Icons.menu_book_rounded) {
      return const Color(0xFFEF5350);
    }
    if (icon == Icons.groups_outlined) {
      return const Color(0xFFEF5350);
    }
    return const Color(0xFF42A5F5);
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
                      ProfileHero(
                        fullName: fullName,
                        filiere: filiere,
                        promotion: promotion,
                        profilePictureUrl: profilePictureUrl,
                        isOwnProfile: isOwnProfile,
                        isEditing: isEditing,
                        onActionPressed: _toggleEdit,
                        currentUserId: currentUserId,
                        profileUserId: profileUserId,
                        chatService: chatService,
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Expanded(
                            child: ProfileStatCard(
                              title: "Sessions\nréalisées",
                              value: "$sessions",
                              icon: Icons.calendar_month_rounded,
                              accentColor: const Color(0xFF0B77E3),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: ProfileStatCard(
                              title: "Avis",
                              value: averageNote.toStringAsFixed(1),
                              icon: Icons.star_border_rounded,
                              accentColor: const Color(0xFFE0A400),
                              subtitle: "($reviewsCount)",
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
                      ProfileAboutCard(
                        isEditing: isEditing,
                        isOwnProfile: isOwnProfile,
                        descriptionController: _descriptionController,
                      ),
                      const SizedBox(height: 18),
                      ProfileInfoCard(
                        fullName: fullName,
                        email: email,
                        filiere: filiere,
                        promotion: promotion,
                      ),
                      const SizedBox(height: 18),
                      ProfileSkillsCard(
                        skills: skills,
                        skillsOptions: skillsOptions,
                        isEditing: isEditing,
                        isOwnProfile: isOwnProfile,
                        selectedSkill: selectedSkill,
                        onSkillChanged: (v) => setState(() => selectedSkill = v),
                        onAddSkill: _addSkill,
                      ),
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
