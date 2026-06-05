import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/session.dart';
import '../service/auth_service.dart';

class SessionsDetailsPage extends StatefulWidget {
  const SessionsDetailsPage({super.key, required this.session});

  final Session session;

  @override
  State<SessionsDetailsPage> createState() => _SessionsDetailsPageState();
}

class _SessionsDetailsPageState extends State<SessionsDetailsPage> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final AuthServices _authServices = AuthServices();

  bool _isLoading = true;
  bool _isUpdating = false;
  bool _isRegistered = false;
  String? _registrationDocId;
  String? _currentStudentId;
  String? _errorMessage;

  String _matiereNom = 'Matière inconnue';
  String _salleNom = 'Salle inconnue';
  String _organisateurNom = 'Organisateur inconnu';

  @override
  void initState() {
    super.initState();
    _loadDetails();
  }

  Future<void> _loadDetails() async {
    try {
      final currentUser = await _authServices.getCurrentUser();
      final session = widget.session;

      final matiereNom = await _getDocumentName('Matiere', session.matiereId);
      final salleNom = await _getDocumentName('Salle', session.salleId);
      final organisateurNom = await _getStudentName(session.organisateurId);

      String? registrationDocId;
      var isRegistered = false;

      if (currentUser != null && session.id != null) {
        final registration = await _db
            .collection('RejoindreSession')
            .where('EtudiantID', isEqualTo: currentUser.id)
            .where('SessionID', isEqualTo: session.id)
            .limit(1)
            .get();

        isRegistered = registration.docs.isNotEmpty;
        registrationDocId = isRegistered ? registration.docs.first.id : null;
      }

      if (!mounted) return;

      setState(() {
        _currentStudentId = currentUser?.id;
        _matiereNom = matiereNom;
        _salleNom = salleNom;
        _organisateurNom = organisateurNom;
        _isRegistered = isRegistered;
        _registrationDocId = registrationDocId;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = 'Impossible de charger les details de la session.';
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

  Future<void> _toggleRegistration() async {
    final sessionId = widget.session.id;

    if (_currentStudentId == null || sessionId == null) {
      setState(() {
        _errorMessage = 'Connecte-toi pour t inscrire a cette session.';
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

        setState(() {
          _isRegistered = false;
          _registrationDocId = null;
        });
      } else {
        final created = await _db.collection('RejoindreSession').add({
          'EtudiantID': _currentStudentId,
          'SessionID': sessionId,
          'Date': DateTime.now().toIso8601String().split('T').first,
          'Contenu': '',
        });

        if (!mounted) return;

        setState(() {
          _isRegistered = true;
          _registrationDocId = created.id;
        });
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subtitleColor = isDark ? Colors.grey.shade400 : Colors.grey.shade700;
    final subjectColor = _getSubjectColor(_matiereNom, isDark);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Details de la session',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
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
                          _buildInfoGrid(
                            textColor,
                            subtitleColor,
                            subjectColor,
                          ),
                          const SizedBox(height: 22),
                          _buildDescription(textColor, subtitleColor),
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
                  _buildBottomButton(subjectColor),
                ],
              ),
            ),
    );
  }

  Widget _buildHeader(Color subjectColor) {
    final session = widget.session;
    final title = session.sujet.isNotEmpty ? session.sujet : _matiereNom;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: subjectColor,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoGrid(
    Color textColor,
    Color subtitleColor,
    Color subjectColor,
  ) {
    final session = widget.session;

    return Column(
      children: [
        _DetailRow(
          icon: Icons.calendar_today_rounded,
          label: 'Date',
          value: _formatDate(session.date),
          textColor: textColor,
          subtitleColor: subtitleColor,
          subjectColor: subjectColor,
        ),
        _DetailRow(
          icon: Icons.schedule_rounded,
          label: 'Heure',
          value: '${session.heureDebut} - ${session.heureFin}',
          textColor: textColor,
          subtitleColor: subtitleColor,
          subjectColor: subjectColor,
        ),
        _DetailRow(
          icon: Icons.location_on_outlined,
          label: 'Salle',
          value: _salleNom,
          textColor: textColor,
          subtitleColor: subtitleColor,
          subjectColor: subjectColor,
        ),
        _DetailRow(
          icon: Icons.person_outline_rounded,
          label: 'Organisateur',
          value: _organisateurNom,
          textColor: textColor,
          subtitleColor: subtitleColor,
          subjectColor: subjectColor,
        ),
      ],
    );
  }

  Widget _buildDescription(Color textColor, Color subtitleColor) {
    final description = widget.session.description.trim();

    return Column(
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
        Text(
          description.isEmpty
              ? 'Aucune description pour cette session.'
              : description,
          style: TextStyle(
            color: subtitleColor,
            fontSize: 14,
            height: 1.45,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomButton(Color subjectColor) {
    final buttonColor = _isRegistered ? Colors.redAccent : subjectColor;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      child: SizedBox(
        height: 54,
        child: ElevatedButton(
          onPressed: _isUpdating ? null : _toggleRegistration,
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
                : (_isRegistered ? 'Me desinscrire' : "S'inscrire"),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
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

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.textColor,
    required this.subtitleColor,
    required this.subjectColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color textColor;
  final Color subtitleColor;
  final Color subjectColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: subjectColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: subjectColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(color: subtitleColor, fontSize: 12),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
