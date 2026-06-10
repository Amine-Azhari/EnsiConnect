import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/session_participant_avatar.dart';
import '../service/user_service.dart';
import '../widgets/session_detail_row.dart';
import '../widgets/session_section_card.dart';
import 'package:flutter/material.dart';
import '../widgets/ensiconnect_app.dart';
import '../models/session.dart';
import 'profil.dart';
import '../service/chat_service.dart';
import '../models/conversation.dart';
import 'chat_messages.dart';
import '../models/session_participant.dart';

class SessionsDetailsPage extends StatefulWidget {
  const SessionsDetailsPage({super.key, required this.session});

  final Session session;

  @override
  State<SessionsDetailsPage> createState() => _SessionsDetailsPageState();
}

class _SessionsDetailsPageState extends State<SessionsDetailsPage> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final UserServices _userServices = UserServices();

  bool _isLoading = true;
  bool _isUpdating = false;
  bool _isRegistered = false;
  String? _registrationDocId;
  String? _currentStudentId;
  String? _errorMessage;
  String? _conversationId;
  List<SessionParticipant> _participants = [];

  String _matiereNom = 'Matière inconnue';
  String _salleNom = 'Salle inconnue';
  String _organisateurNom = 'Organisateur inconnu';
  bool _sessionComplete = false;

  int _effectiveParticipantCount(List<SessionParticipant> participants) {
    final organizerId = widget.session.organisateurId;
    final includesOrganizer = organizerId.isNotEmpty &&
        participants.any((participant) => participant.id == organizerId);
    return participants.length + (includesOrganizer ? 0 : 1);
  }

  Future<void> _supprimerSession() async {
  final confirm = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Supprimer la session'),
      content: const Text('Cette action est irréversible. Confirmer la suppression ?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Annuler'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('Supprimer', style: TextStyle(color: Colors.redAccent)),
        ),
      ],
    ),
  );

  if (confirm != true) return;

  await _db.collection('Session').doc(widget.session.id).delete();

  if (!mounted) return;
  Navigator.of(context).pop();
}

  Future<void> _ouvrirChat() async {
    final currentUser = await UserServices().getCurrentUser();
    if (currentUser == null || widget.session.id == null) return;

    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ConversationPage(
          conversation: Conversation(
            id: _conversationId!,
            participants: _participants.map((p) => p.id).toList(),
            messages: const [],
            lastMessage: '',
            lastMessageAt: null,
            createdAt: null,
            name: widget.session.sujet,
          ),
          currentUserId: currentUser.id,
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadDetails();
  }

  Future<void> _loadDetails() async {
    try {
      final currentUser = await _userServices.getCurrentUser();
      final session = widget.session;

      final matiereNom = await _getDocumentName('Matiere', session.matiereId);
      final salleNom = await _getDocumentName('Salle', session.salleId);
      final organisateurNom = await _getStudentName(session.organisateurId);

      String? registrationDocId;
      var isRegistered = false;
      final participants = <SessionParticipant>[];
      final conversationId = session.conversationId;

      // APRÈS
      if (session.id != null) {
        // Participants ajoutés à la création
        final sessionDoc =
            await _db.collection('Session').doc(session.id).get();
        final sessionData = sessionDoc.data();
        final preInscrits =
            List<String>.from(sessionData?['Participants'] ?? []);

        final idsDejaAjoutes = <String>{};

        for (final etudiantId in preInscrits) {
          if (etudiantId.isEmpty) continue;
          idsDejaAjoutes.add(etudiantId);
          if (currentUser != null && etudiantId == currentUser.id) {
            isRegistered = true;
          }
          participants.add(await _getParticipant(etudiantId));
        }

        // Participants inscrits via RejoindreSession
        final registrations = await _db
            .collection('RejoindreSession')
            .where('SessionId', isEqualTo: session.id)
            .get();

        for (final registration in registrations.docs) {
          final etudiantId = registration.data()['EtudiantId'] ?? '';
          if (etudiantId.isEmpty || idsDejaAjoutes.contains(etudiantId)) continue;
          
            

          if (currentUser != null && etudiantId == currentUser.id) {
            isRegistered = true;
            registrationDocId = registration.id;
          }

          participants.add(await _getParticipant(etudiantId));
        }

        final nbPlaces = sessionDoc.data()?['NbPlaces'] ?? 0;
        _sessionComplete = _effectiveParticipantCount(participants) >= nbPlaces;
      }

      if (!mounted) return;

      setState(() {
        _currentStudentId = currentUser?.id;
        _matiereNom = matiereNom;
        _salleNom = salleNom;
        _organisateurNom = organisateurNom;
        _participants = participants;
        _isRegistered = isRegistered;
        _registrationDocId = registrationDocId;
        _isLoading = false;
        _conversationId = conversationId;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = 'Impossible de charger les détails de la session.';
        _isLoading = false;
      });
    }
  }

  Future<String> _getDocumentName(String collection, String id) async {
    final fallback =
        collection == 'Matiere' ? 'Matière inconnue' : 'Salle inconnue';

    if (id.isEmpty) return fallback;

    final doc = await _db.collection(collection).doc(id).get();
    final data = doc.data();
    return data?['Nom'] ?? fallback;
  }

  Future<String> _getStudentName(String id) async {
    if (id.isEmpty) return 'Organisateur inconnu';

    final doc = await _db.collection('Etudiant').doc(id).get();
    final data = doc.data();
    if (data == null) return 'Organisateur inconnu';

    final prenom = data['Prenom'] ?? '';
    final nom = data['Nom'] ?? '';
    final fullName = '$prenom $nom'.trim();
    return fullName.isEmpty ? 'Organisateur inconnu' : fullName;
  }

  Future<SessionParticipant> _getParticipant(String id) async {
    final doc = await _db.collection('Etudiant').doc(id).get();
    final data = doc.data();

    if (data == null) {
      return SessionParticipant(id: id, name: 'Étudiant inconnu');
    }

    final prenom = data['Prenom'] ?? '';
    final nom = data['Nom'] ?? '';
    final fullName = '$prenom $nom'.trim();

    return SessionParticipant(
      id: id,
      name: fullName.isEmpty ? 'Étudiant inconnu' : fullName,
      imageUrl: data['ProfilePictureUrl'],
    );
  }

  Future<void> _toggleRegistration() async {
    final sessionId = widget.session.id;
    final ChatService chatService = ChatService();

    final currentUser = await UserServices().getCurrentUser();
    if (currentUser == null || widget.session.id == null) return;

    if (_currentStudentId == null || sessionId == null) {
      setState(() {
        _errorMessage = "Connecte-toi pour t'inscrire a cette session.";
      });
      return;
    }

    setState(() {
      _isUpdating = true;
      _errorMessage = null;
    });

    try {
      if (_isRegistered && _registrationDocId != null) {
        await _db
            .collection('RejoindreSession')
            .doc(_registrationDocId)
            .delete();
        

        if (!mounted) return;

        chatService.deleteUserFromConversation(
          conversationId: _conversationId!,
          userId: currentUser.id,
        );

        setState(() {
          _isRegistered = false;
          _registrationDocId = null;
          _participants.removeWhere(
            (participant) => participant.id == _currentStudentId,
          );
          _sessionComplete = false;
        });
      } else {
        // Empêche l'organisateur de s'inscrire à sa propre session
        if (_currentStudentId == widget.session.organisateurId) {
          setState(() {
            _errorMessage =
                'Vous ne pouvez pas vous inscrire à votre propre session.';
            _isUpdating = false;
          });
          return;
        }
        // Vérifie le nombre de places
        final sessionDoc = await _db.collection('Session').doc(sessionId).get();
        final nbPlaces = sessionDoc.data()?['NbPlaces'] ?? 0;

        if (_effectiveParticipantCount(_participants) >= nbPlaces) {
          setState(() {
            _errorMessage = 'Cette session est complète.';
            _isUpdating = false;
          });
          return;
        }

        final created = await _db.collection('RejoindreSession').add({
          'EtudiantId': _currentStudentId,
          'SessionId': sessionId,
        });

        if (!mounted) return;

        chatService.addUserIntoConversation(
          conversationId: _conversationId!,
          userId: currentUser.id,
        );

        setState(() {
          _isRegistered = true;
          _registrationDocId = created.id;
        });

        await _loadDetails();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Action impossible pour le moment.';
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isUpdating = false);
      }
    }
  }

  void _openParticipantProfile(SessionParticipant participant) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProfilPage(userId: participant.id),
      ),
    );
  }

  void _openParticipantProfileFromSheet(SessionParticipant participant) {
    Navigator.pop(context);
    _openParticipantProfile(participant);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subtitleColor = isDark ? Colors.grey.shade400 : Colors.grey.shade700;
    final subjectColor = _getSubjectColor(_matiereNom, isDark);
  
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Détails de la session',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        actions: [ ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeader(subjectColor),
                          const SizedBox(height: 22),
                          _buildParticipantsSection(
                            textColor,
                            subtitleColor,
                            subjectColor,
                          ),
                          const SizedBox(height: 22),
                          _buildInfoCard(
                            textColor,
                            subtitleColor,
                            subjectColor,
                          ),
                          const SizedBox(height: 22),
                          _buildDescription(
                            textColor,
                            subtitleColor,
                            subjectColor,
                          ),
                          if (_errorMessage != null) ...[
                            const SizedBox(height: 18),
                            Text(
                              _errorMessage!,
                              style: const TextStyle(
                                color: Colors.redAccent,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  _buildBottomButton(),
                ],
              ),
            ),
    );
  }

  Widget _buildHeader(Color subjectColor) {
    final session = widget.session;
    final title = session.sujet.isNotEmpty ? session.sujet : _matiereNom;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final shouldShowSubject =
        _matiereNom.trim().toLowerCase() != title.trim().toLowerCase();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF121820) : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: subjectColor.withValues(alpha: isDark ? 0.28 : 0.18),
        ),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44,
            height: 4,
            decoration: BoxDecoration(
              color: subjectColor,
              borderRadius: BorderRadius.circular(99),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontSize: 23,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (shouldShowSubject) ...[
            const SizedBox(height: 6),
            Text(
              _matiereNom,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: subjectColor,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoCard(
    Color textColor,
    Color subtitleColor,
    Color subjectColor,
  ) {
    final session = widget.session;

    return SectionCard(
      child: Column(
        children: [
          DetailRow(
            icon: Icons.calendar_today_rounded,
            label: 'Date',
            value: _formatDate(session.date),
            textColor: textColor,
            subtitleColor: subtitleColor,
            subjectColor: subjectColor,
          ),
          DetailRow(
            icon: Icons.schedule_rounded,
            label: 'Heure',
            value: '${session.heureDebut} - ${session.heureFin}',
            textColor: textColor,
            subtitleColor: subtitleColor,
            subjectColor: subjectColor,
          ),
          DetailRow(
            icon: Icons.location_on_outlined,
            label: 'Salle',
            value: _salleNom,
            textColor: textColor,
            subtitleColor: subtitleColor,
            subjectColor: subjectColor,
          ),
          DetailRow(
            icon: Icons.person_outline_rounded,
            label: 'Organisateur',
            value: _organisateurNom,
            textColor: textColor,
            subtitleColor: subtitleColor,
            subjectColor: subjectColor,
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildParticipantsSection(
    Color textColor,
    Color subtitleColor,
    Color subjectColor,
  ) {
    final maxVisibleItems = _participants.length > 6 ? 5 : 6;
    final visibleParticipants = _participants.take(maxVisibleItems).toList();
    final hiddenParticipantsCount =
        _participants.length - visibleParticipants.length;

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: _participants.isEmpty ? null : _showParticipantsSheet,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF121820)
              : Colors.white,
          border: Border.all(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white10
                : Colors.black.withValues(alpha: 0.06),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.groups_rounded, color: subjectColor, size: 24),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Participants inscrits',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: subjectColor.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_participants.length}',
                    style: TextStyle(
                      color: subjectColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            if (_participants.isEmpty)
              Text(
                'Aucun participant inscrit pour le moment.',
                style: TextStyle(color: subtitleColor, fontSize: 14),
              )
            else
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (final participant in visibleParticipants) ...[
                      ParticipantAvatar(
                        participant: participant,
                        color: subjectColor,
                      ),
                      const SizedBox(width: 10),
                    ],
                    if (hiddenParticipantsCount > 0)
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: Colors.grey.shade700,
                        child: Text(
                          '+$hiddenParticipantsCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showParticipantsSheet() {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            itemCount: _participants.length,
            separatorBuilder: (_, __) => const Divider(height: 18),
            itemBuilder: (context, index) {
              final participant = _participants[index];

              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: ParticipantAvatar(
                  participant: participant,
                  color: EnsiConnectApp.ensisaBlue,
                ),
                title: Text(
                  participant.name,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                onTap: () => _openParticipantProfileFromSheet(participant),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildDescription(
    Color textColor,
    Color subtitleColor,
    Color subjectColor,
  ) {
    final description = widget.session.description.trim();

    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Description',
            style: TextStyle(
              color: textColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            width: 68,
            height: 4,
            decoration: BoxDecoration(
              color: subjectColor,
              borderRadius: BorderRadius.circular(99),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            description.isEmpty
                ? 'Aucune description pour cette session.'
                : description,
            style: TextStyle(
              color: description.isEmpty ? subtitleColor : textColor,
              fontSize: 15,
              height: 1.45,
              fontWeight:
                  description.isEmpty ? FontWeight.w700 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButton() {
    final isOrganisateur = _currentStudentId == widget.session.organisateurId;
    final buttonColor =
        _isRegistered ? Colors.redAccent : EnsiConnectApp.ensisaBlue;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      child: Row(
        children: [
          if (!isOrganisateur)
            Expanded(
              child: SizedBox(
                height: 54,
                child: ElevatedButton(
                  onPressed:
                      (_isUpdating || (_sessionComplete && !_isRegistered))
                          ? null
                          : _toggleRegistration,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: buttonColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    _isUpdating
                        ? 'Chargement...'
                        : (_isRegistered
                            ? 'Se désinscrire'
                            : (_sessionComplete
                                ? 'Session complète'
                                : "S'inscrire")),
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          if (!isOrganisateur && _isRegistered) const SizedBox(width: 12),
          if (_isRegistered || isOrganisateur) ...[
            if (!isOrganisateur) const SizedBox(width: 12),
            Expanded(
              child: SizedBox(
                height: 54,
                child: ElevatedButton(
                  onPressed: _ouvrirChat,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: EnsiConnectApp.ensisaBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.chat_bubble_outline_rounded),
                      SizedBox(width: 8),
                      Text('Chat', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ),
          ],
          if (isOrganisateur) ...[
            const SizedBox(width: 12),
            Expanded(
              child: SizedBox(
                height: 54,
                child: ElevatedButton(
                  onPressed: _supprimerSession,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.delete_outline_rounded),
                      SizedBox(width: 8),
                      Text('Supprimer', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(String rawDate) {
    try {
      final date = DateTime.parse(rawDate);
      final day = date.day.toString().padLeft(2, '0');
      final month = date.month.toString().padLeft(2, '0');
      return '$day/$month/${date.year}';
    } catch (_) {
      return rawDate.isEmpty ? 'Date inconnue' : rawDate;
    }
  }

  Color _getSubjectColor(String subject, bool isDark) {
    final List<MaterialColor> colors = [
      Colors.blue,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.green,
    ];
    final index = subject.hashCode.abs() % colors.length;
    return isDark ? colors[index].shade300 : colors[index].shade600;
  }
}
