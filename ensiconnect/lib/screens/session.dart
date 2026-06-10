import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/session_widgets.dart';
import '../service/post_session_service.dart';
import '../widgets/ensiconnect_app.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../service/user_service.dart';

// ─── Modèle léger ────────────────────────────────────────────────────────────

class SessionFormData {
  String description;
  String titre;
  String? matiere;
  DateTime? date;
  TimeOfDay? heure;
  TimeOfDay? heureFin;
  String lieu;
  int nbPlaces;
  List<String> tags;

  SessionFormData({
    this.description = '',
    this.titre = '',
    this.matiere,
    this.date,
    this.heure,
    this.heureFin,
    this.lieu = '',
    this.nbPlaces = 2,
    this.tags = const [],
  });
}

class _TimeRangeSelection {
  const _TimeRangeSelection({
    required this.start,
    required this.end,
  });

  final TimeOfDay start;
  final TimeOfDay end;
}

// ─── Page principale ──────────────────────────────────────────────────────────

class PostSessionPage extends StatefulWidget {
  const PostSessionPage({super.key});

  @override
  State<PostSessionPage> createState() => _PostSessionPageState();
}

class _PostSessionPageState extends State<PostSessionPage>
    with SingleTickerProviderStateMixin {
  // static const Color ensisaBlue = Color(0xFF0055A5);

  final _descriptionCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _data = SessionFormData();
  final _service = PostSessionService();

  final _titreCtrl = TextEditingController();
  final _lieuCtrl = TextEditingController();

  final List<String> _matieres = [
    'Algorithme et systèmes de données',
    'Programmation',
    'Physique',
    'Automatique',
    'Électronique',
    'Réseau & Télécoms',
    'Mathématiques',
    'Chimie',
    'Autre',
  ];

  final Set<String> _tagsSelectionnes = {};

  final _searchCtrl = TextEditingController();
  List<Map<String, dynamic>> _resultatsRecherche = [];
  final List<Map<String, dynamic>> _etudiantsAjoutes = [];
  bool _searching = false;

  List<String> _salles = [];
  List<String> _sallesFiltrees = [];
  final _salleCtrl = TextEditingController();
  bool _sallesLoading = true;
  bool _salleSelectionnee = false;

  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  bool _submitting = false;

  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));
    _animCtrl.forward();
    _chargerSalles();
    UserServices().getCurrentUser().then((user) {
      setState(() => _currentUserId = user?.id);
    });
  }

  @override
  void dispose() {
    _salleCtrl.dispose();
    _descriptionCtrl.dispose();
    _searchCtrl.dispose();
    _animCtrl.dispose();
    _titreCtrl.dispose();
    _lieuCtrl.dispose();
    super.dispose();
  }

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  String _formatTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}h${t.minute.toString().padLeft(2, '0')}';

  String _toHHmm(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  DateTime _dateTimeFromTime(TimeOfDay time) {
    final baseDate = _data.date ?? DateTime.now();
    return DateTime(
      baseDate.year,
      baseDate.month,
      baseDate.day,
      time.hour,
      time.minute,
    );
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _data.date ?? now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme:
              ColorScheme.fromSeed(seedColor: EnsiConnectApp.ensisaBlue),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _data.date = picked);
  }

  Future<void> _pickTimeRange() async {
    final initialStart = _data.heure ?? const TimeOfDay(hour: 8, minute: 0);
    final defaultEndDateTime =
        _dateTimeFromTime(initialStart).add(const Duration(hours: 1));
    final initialEnd =
        _data.heureFin ?? TimeOfDay.fromDateTime(defaultEndDateTime);

    DateTime selectedStart = _dateTimeFromTime(initialStart);
    DateTime selectedEnd = _dateTimeFromTime(initialEnd);
    if (!selectedEnd.isAfter(selectedStart)) {
      selectedEnd = selectedStart.add(const Duration(hours: 1));
    }

    final result = await showModalBottomSheet<_TimeRangeSelection>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        final isDark = Theme.of(sheetContext).brightness == Brightness.dark;
        final textColor = isDark ? Colors.white : Colors.black87;
        final sheetColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
        final subTextColor = isDark ? Colors.white70 : Colors.black54;

        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              decoration: BoxDecoration(
                color: sheetColor,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 42,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.withValues(alpha: 0.35),
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Choisir la plage horaire',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Sélectionne l\'heure de début et l\'heure de fin.',
                      style: TextStyle(
                        color: subTextColor,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildCupertinoTimeField(
                      context: context,
                      label: 'Début',
                      value: selectedStart,
                      onChanged: (newValue) {
                        setSheetState(() {
                          selectedStart = newValue;
                          if (!selectedEnd.isAfter(selectedStart)) {
                            selectedEnd =
                                selectedStart.add(const Duration(minutes: 30));
                          }
                        });
                      },
                    ),
                    const SizedBox(height: 14),
                    _buildCupertinoTimeField(
                      context: context,
                      label: 'Fin',
                      value: selectedEnd,
                      minimumDate:
                          selectedStart.add(const Duration(minutes: 30)),
                      onChanged: (newValue) {
                        setSheetState(() {
                          selectedEnd = newValue;
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.of(sheetContext).pop(),
                            child: const Text('Annuler'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(sheetContext).pop(
                                _TimeRangeSelection(
                                  start: TimeOfDay.fromDateTime(selectedStart),
                                  end: TimeOfDay.fromDateTime(selectedEnd),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: EnsiConnectApp.ensisaBlue,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Valider'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    if (result == null) return;

    setState(() {
      _data.heure = result.start;
      _data.heureFin = result.end;
    });
  }

  Widget _buildCupertinoTimeField({
    required BuildContext context,
    required String label,
    required DateTime value,
    required ValueChanged<DateTime> onChanged,
    DateTime? minimumDate,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final cardColor =
        isDark ? const Color(0xFF121212) : const Color(0xFFF6F7FB);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: EnsiConnectApp.ensisaBlue.withValues(alpha: 0.16),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: EnsiConnectApp.ensisaBlue,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 120,
            child: CupertinoTheme(
              data: CupertinoThemeData(
                brightness: isDark ? Brightness.dark : Brightness.light,
                textTheme: CupertinoTextThemeData(
                  dateTimePickerTextStyle: TextStyle(
                    color: textColor,
                    fontSize: 20,
                  ),
                ),
              ),
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.time,
                use24hFormat: true,
                minuteInterval: 15,
                initialDateTime: value,
                minimumDate: minimumDate,
                onDateTimeChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_data.date == null || _data.heure == null) {
      _showError('Veuillez sélectionner une date et une heure.');
      return;
    }

    final maxOtherParticipants = _data.nbPlaces - 1;
    if (_etudiantsAjoutes.length > maxOtherParticipants) {
      _showError(
        'Avec ${_data.nbPlaces} place(s), vous pouvez ajouter au maximum $maxOtherParticipants autre(s) participant(s).',
      );
      return;
    }

    if (_data.heureFin != null) {
      final startMinutes = _data.heure!.hour * 60 + _data.heure!.minute;
      final endMinutes = _data.heureFin!.hour * 60 + _data.heureFin!.minute;

      if (endMinutes <= startMinutes) {
        _showError("L'heure de fin doit être après l'heure de début.");
        return;
      }
    }

    _formKey.currentState!.save();
    _data.tags = _tagsSelectionnes.toList();

    setState(() => _submitting = true);

    try {
      await _service.creerSession(
        description: _data.description,
        titre: _data.titre,
        matiere: _data.matiere,
        date: _data.date!,
        heureDebut: _toHHmm(_data.heure!),
        heureFin: _data.heureFin != null ? _toHHmm(_data.heureFin!) : null,
        lieu: _data.lieu,
        nbPlaces: _data.nbPlaces,
        tags: _data.tags,
        participants: _etudiantsAjoutes.map((e) => e['id'] as String).toList(),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _submitting = false);
      _showError('Erreur lors de la création : $e');
      return;
    }

    if (!mounted) return;
    setState(() => _submitting = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(children: [
          const Icon(Icons.check_circle, color: Colors.white),
          const SizedBox(width: 10),
          Expanded(child: Text('Session « ${_data.titre} » créée !')),
        ]),
        backgroundColor: Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
    Navigator.of(context).pop();
  }

  Future<void> _chargerSalles() async {
    final snap = await FirebaseFirestore.instance.collection('Salle').get();
    setState(() {
      _salles = snap.docs.map((d) => d['Nom'] as String).toList();
      _sallesFiltrees = [];
      _sallesLoading = false;
    });
  }

  Future<void> _rechercherEtudiants(String query) async {
    if (query.trim().isEmpty) {
      setState(() => _resultatsRecherche = []);
      return;
    }
    setState(() => _searching = true);
    final snap = await FirebaseFirestore.instance.collection('Etudiant').get();
    final q = query.toLowerCase();
    setState(() {
      _resultatsRecherche = snap.docs
          .where((doc) {
            final prenom = (doc['Prenom'] ?? '').toString().toLowerCase();
            final nom = (doc['Nom'] ?? '').toString().toLowerCase();
            return (prenom.contains(q) || nom.contains(q)) &&
                doc.id != _currentUserId;
          })
          .map((doc) => {'id': doc.id, ...doc.data()})
          .toList();
      _searching = false;
    });
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _filtrerSalles(String query) {
    setState(() {
      _salleSelectionnee = false;
      _data.lieu = '';
      if (query.trim().isEmpty) {
        _sallesFiltrees = [];
      } else {
        _sallesFiltrees = _salles
            .where((s) => s.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: _buildAppBar(),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SlideTransition(
          position: _slideAnim,
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 88),
              children: [
                SessionFormSection(
                  cardColor: cardColor,
                  children: [
                    _buildTextField(
                      controller: _titreCtrl,
                      label: 'Titre de la session',
                      hint: 'ex. Révisions TD Algo',
                      icon: Icons.title,
                      isDark: isDark,
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Champ requis'
                          : null,
                      onSaved: (v) => _data.titre = v!.trim(),
                    ),
                    const SizedBox(height: 14),
                    _buildDropdown(isDark),
                  ],
                ),
                const SizedBox(height: 12),
                SessionFormSection(
                  cardColor: cardColor,
                  children: [
                    TextFormField(
                      controller: _descriptionCtrl,
                      maxLength: 200,
                      maxLines: 3,
                      onSaved: (v) => _data.description = v?.trim() ?? '',
                      style: TextStyle(
                          fontSize: 14,
                          color: isDark ? Colors.white : Colors.black87),
                      decoration: InputDecoration(
                        hintText: 'Décris le contenu de la session...',
                        hintStyle: TextStyle(
                            fontSize: 13, color: Colors.grey.shade400),
                        counterStyle: TextStyle(
                            color: isDark ? Colors.white54 : Colors.black45),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                BorderSide(color: Colors.grey.shade300)),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                              color: isDark
                                  ? Colors.white24
                                  : Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                              color: EnsiConnectApp.ensisaBlue, width: 1.8),
                        ),
                        filled: true,
                        fillColor: isDark
                            ? Colors.white.withValues(alpha: 0.05)
                            : Colors.grey.shade50,
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 14),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SessionFormSection(
                  cardColor: cardColor,
                  children: [
                    SessionPickerTile(
                      icon: Icons.event,
                      title: 'Date',
                      value:
                          _data.date != null ? _formatDate(_data.date!) : null,
                      placeholder: 'Choisir',
                      onTap: _pickDate,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 8),
                    SessionPickerTile(
                      icon: Icons.schedule_rounded,
                      title: 'Plage horaire',
                      value: _data.heure != null && _data.heureFin != null
                          ? '${_formatTime(_data.heure!)} - ${_formatTime(_data.heureFin!)}'
                          : null,
                      placeholder: 'Choisir début et fin',
                      onTap: _pickTimeRange,
                      isDark: isDark,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SessionFormSection(
                  cardColor: cardColor,
                  children: [
                    TextFormField(
                      controller: _salleCtrl,
                      onChanged: _filtrerSalles,
                      validator: (v) =>
                          _data.lieu.isEmpty ? 'Champ requis' : null,
                      style: TextStyle(
                          fontSize: 14,
                          color: isDark ? Colors.white : Colors.black87),
                      decoration: InputDecoration(
                        hintText: 'Rechercher une salle...',
                        hintStyle: TextStyle(
                            fontSize: 13, color: Colors.grey.shade400),
                        prefixIcon: const Icon(Icons.place_rounded,
                            color: EnsiConnectApp.ensisaBlue, size: 20),
                        suffixIcon: _sallesLoading
                            ? const Padding(
                                padding: EdgeInsets.all(12),
                                child: SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2)))
                            : _salleSelectionnee
                                ? IconButton(
                                    icon: const Icon(Icons.close, size: 18),
                                    onPressed: () => setState(() {
                                      _salleCtrl.clear();
                                      _sallesFiltrees = [];
                                      _salleSelectionnee = false;
                                      _data.lieu = '';
                                    }),
                                  )
                                : null,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                BorderSide(color: Colors.grey.shade300)),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                              color: isDark
                                  ? Colors.white24
                                  : Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                              color: EnsiConnectApp.ensisaBlue, width: 1.8),
                        ),
                        filled: true,
                        fillColor: isDark
                            ? Colors.white.withValues(alpha: 0.05)
                            : Colors.grey.shade50,
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 14),
                      ),
                    ),
                    if (_sallesFiltrees.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF2A2A2A)
                              : Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: isDark
                                  ? Colors.white12
                                  : Colors.grey.shade200),
                        ),
                        child: Column(
                          children: _sallesFiltrees
                              .map((salle) => ListTile(
                                    leading: const Icon(
                                        Icons.meeting_room_rounded,
                                        color: EnsiConnectApp.ensisaBlue,
                                        size: 20),
                                    title: Text(salle,
                                        style: const TextStyle(fontSize: 14)),
                                    onTap: () => setState(() {
                                      _data.lieu = salle;
                                      _salleCtrl.text = salle;
                                      _sallesFiltrees = [];
                                      _salleSelectionnee = true;
                                    }),
                                  ))
                              .toList(),
                        ),
                      ),
                    ],
                    if (_salleSelectionnee)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Row(children: [
                          const Icon(Icons.check_circle_rounded,
                              color: Colors.green, size: 16),
                          const SizedBox(width: 6),
                          Text('Salle sélectionnée',
                              style: TextStyle(
                                  fontSize: 12, color: Colors.green.shade700)),
                        ]),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                SessionFormSection(
                  cardColor: cardColor,
                  children: [
                    Row(children: [
                      const Icon(Icons.people_alt_outlined,
                          color: EnsiConnectApp.ensisaBlue, size: 20),
                      const SizedBox(width: 8),
                      const Text('Nombre de places :',
                          style: TextStyle(fontSize: 13)),
                      const Spacer(),
                      SessionPlacesCounter(
                        value: _data.nbPlaces,
                        onChanged: (v) => setState(() => _data.nbPlaces = v),
                        isDark: isDark,
                      ),
                    ]),
                  ],
                ),
                const SizedBox(height: 12),
                SessionFormSection(
                  cardColor: cardColor,
                  children: [
                    SessionEtudiantSearch(
                      searchCtrl: _searchCtrl,
                      resultats: _resultatsRecherche,
                      etudiantsAjoutes: _etudiantsAjoutes,
                      searching: _searching,
                      isDark: isDark,
                      onSearch: _rechercherEtudiants,
                      onAjouter: (e) {
                        final maxOtherParticipants = _data.nbPlaces - 1;
                        if (_etudiantsAjoutes.length >= maxOtherParticipants) {
                          _showError(
                            'Cette session a ${_data.nbPlaces} places au total',
                          );
                          return;
                        }
                        setState(() {
                          _etudiantsAjoutes.add(e);
                          _resultatsRecherche = [];
                          _searchCtrl.clear();
                        });
                      },
                      onRetirer: (e) =>
                          setState(() => _etudiantsAjoutes.remove(e)),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _buildFAB(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: EnsiConnectApp.ensisaBlue,
      foregroundColor: Colors.white,
      elevation: 0,
      title: const Text(
        // ← ici
        'Créer une session',
        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
      ),
      centerTitle: true,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded),
        onPressed: () => Navigator.of(context).pop(),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required bool isDark,
    String? Function(String?)? validator,
    void Function(String?)? onSaved,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      onSaved: onSaved,
      style: TextStyle(
          fontSize: 14, color: isDark ? Colors.white : Colors.black87),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: EnsiConnectApp.ensisaBlue, size: 20),
        labelStyle: const TextStyle(fontSize: 13),
        hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade400),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              BorderSide(color: isDark ? Colors.white24 : Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: EnsiConnectApp.ensisaBlue, width: 1.8),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        filled: true,
        fillColor:
            isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade50,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
      ),
    );
  }

  Widget _buildDropdown(bool isDark) {
    return DropdownButtonFormField<String>(
      initialValue: _data.matiere,
      hint: const Text('Matière concernée', style: TextStyle(fontSize: 13)),
      style: TextStyle(
          fontSize: 14, color: isDark ? Colors.white : Colors.black87),
      dropdownColor: isDark ? const Color(0xFF2A2A2A) : Colors.white,
      icon: const Icon(Icons.keyboard_arrow_down_rounded,
          color: EnsiConnectApp.ensisaBlue),
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.school_rounded,
            color: EnsiConnectApp.ensisaBlue, size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              BorderSide(color: isDark ? Colors.white24 : Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: EnsiConnectApp.ensisaBlue, width: 1.8),
        ),
        filled: true,
        fillColor:
            isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade50,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
      ),
      items: _matieres
          .map((m) => DropdownMenuItem(
              value: m, child: Text(m, style: const TextStyle(fontSize: 14))))
          .toList(),
      onChanged: (v) => setState(() => _data.matiere = v),
    );
  }

  Widget _buildFAB() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        width: double.infinity,
        height: 54,
        child: ElevatedButton(
          onPressed: _submitting ? null : _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: EnsiConnectApp.ensisaBlue,
            foregroundColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            elevation: 4,
            shadowColor: EnsiConnectApp.ensisaBlue.withValues(alpha: 0.4),
          ),
          child: _submitting
              ? const SizedBox(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(
                      strokeWidth: 2.5, color: Colors.white),
                )
              : const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_circle_outline_rounded, size: 20),
                    SizedBox(width: 10),
                    Text('Créer la session',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w700)),
                  ],
                ),
        ),
      ),
    );
  }
}
