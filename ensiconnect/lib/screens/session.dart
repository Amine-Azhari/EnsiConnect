import 'package:ensiconnect/service/user_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/session_widgets.dart';
import '../service/post_session_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/ensiconnect_app.dart';

// ─── Modèle léger ────────────────────────────────────────────────────────────

class SessionFormData {
  String titre;
  String? matiere;
  DateTime? date;
  TimeOfDay? heure;
  String lieu;
  int nbPlaces;
  List<String> tags;

  SessionFormData({
    this.titre = '',
    this.matiere,
    this.date,
    this.heure,
    this.lieu = '',
    this.nbPlaces = 2,
    this.tags = const [],
  });
}

// ─── Page principale ──────────────────────────────────────────────────────────

class PostSessionPage extends StatefulWidget {
  const PostSessionPage({super.key});

  @override
  State<PostSessionPage> createState() => _PostSessionPageState();
}

class _PostSessionPageState extends State<PostSessionPage>
    with SingleTickerProviderStateMixin {
  static const Color ensisaBlue = Color(0xFF0055A5);

  final _formKey = GlobalKey<FormState>();
  final _data = SessionFormData();
  final _service = PostSessionService();

  final _titreCtrl = TextEditingController();
  final _lieuCtrl = TextEditingController();

  final List<String> _tagsDisponibles = [
    'Informatique', 'Automatique et système embarqués', 'Mécanique', 'Textile',
    'Génie industriel',
  ];
  final Set<String> _tagsSelectionnes = {};

  final List<String> _matieres = [
    'Algorithme et systèmes de données', 'Programmation', 'Physique',
    'Automatique', 'Électronique', 'Réseau & Télécoms',
    'Mathématiques', 'Chimie', 'Autre',
  ];

  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  bool _submitting = false;

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
  }

  @override
  void dispose() {
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

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _data.date ?? now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: ColorScheme.fromSeed(seedColor: ensisaBlue),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _data.date = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _data.heure ?? TimeOfDay.now(),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: ColorScheme.fromSeed(seedColor: ensisaBlue),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _data.heure = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_data.date == null || _data.heure == null) {
      _showError('Veuillez sélectionner une date et une heure.');
      return;
    }
    _formKey.currentState!.save();
    _data.tags = _tagsSelectionnes.toList();

    setState(() => _submitting = true);

    try {
      await _service.creerSession(
        titre: _data.titre,
        matiere: _data.matiere,
        date: _data.date!,
        heureDebut: _toHHmm(_data.heure!),
        lieu: _data.lieu,
        nbPlaces: _data.nbPlaces,
        tags: _data.tags,
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
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
              children: [
                const SessionHeader(),
                const SizedBox(height: 24),

                SessionFormSection(
                  icon: Icons.menu_book_rounded,
                  label: 'Sujet',
                  cardColor: cardColor,
                  children: [
                    _buildTextField(
                      controller: _titreCtrl,
                      label: 'Titre de la session',
                      hint: 'ex. Révisions TD Algo',
                      icon: Icons.title,
                      isDark: isDark,
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Champ requis' : null,
                      onSaved: (v) => _data.titre = v!.trim(),
                    ),
                    const SizedBox(height: 14),
                    _buildDropdown(isDark),
                  ],
                ),
                const SizedBox(height: 16),

                SessionFormSection(
                  icon: Icons.calendar_today_rounded,
                  label: 'Quand ?',
                  cardColor: cardColor,
                  children: [
                    Row(children: [
                      Expanded(
                        child: SessionPickerTile(
                          icon: Icons.event,
                          title: 'Date',
                          value: _data.date != null ? _formatDate(_data.date!) : null,
                          placeholder: 'Choisir',
                          onTap: _pickDate,
                          isDark: isDark,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SessionPickerTile(
                          icon: Icons.access_time_rounded,
                          title: 'Heure',
                          value: _data.heure != null ? _formatTime(_data.heure!) : null,
                          placeholder: 'Choisir',
                          onTap: _pickTime,
                          isDark: isDark,
                        ),
                      ),
                    ]),
                  ],
                ),
                const SizedBox(height: 16),

                SessionFormSection(
                  icon: Icons.location_on_rounded,
                  label: 'Lieu',
                  cardColor: cardColor,
                  children: [
                    _buildTextField(
                      controller: _lieuCtrl,
                      label: 'Salle ou espace',
                      hint: 'ex. Bibliothèque – Salle B12',
                      icon: Icons.place_rounded,
                      isDark: isDark,
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Champ requis' : null,
                      onSaved: (v) => _data.lieu = v!.trim(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                SessionFormSection(
                  icon: Icons.people_rounded,
                  label: 'Places',
                  cardColor: cardColor,
                  children: [
                    Row(children: [
                      const Icon(Icons.people_alt_outlined, color: ensisaBlue, size: 20),
                      const SizedBox(width: 10),
                      const Text('Nombre de places :', style: TextStyle(fontSize: 14)),
                      const Spacer(),
                      SessionPlacesCounter(
                        value: _data.nbPlaces,
                        onChanged: (v) => setState(() => _data.nbPlaces = v),
                        isDark: isDark,
                      ),
                    ]),
                  ],
                ),
                const SizedBox(height: 16),

                SessionFormSection(
                  icon: Icons.label_rounded,
                  label: 'Tags',
                  cardColor: cardColor,
                  children: [
                    SessionTagsGrid(
                      tagsDisponibles: _tagsDisponibles,
                      tagsSelectionnes: _tagsSelectionnes,
                      onToggle: (tag) => setState(() {
                        _tagsSelectionnes.contains(tag)
                            ? _tagsSelectionnes.remove(tag)
                            : _tagsSelectionnes.add(tag);
                      }),
                      isDark: isDark,
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                SessionPublicBadge(cardColor: cardColor),
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
      backgroundColor: ensisaBlue,
      foregroundColor: Colors.white,
      elevation: 0,
      title: const Text(
        'Créer une session',
        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
      ),
      centerTitle: true,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      leading: IconButton(
        icon: const Icon(Icons.close_rounded),
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
      style: TextStyle(fontSize: 14, color: isDark ? Colors.white : Colors.black87),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: ensisaBlue, size: 20),
        labelStyle: const TextStyle(fontSize: 13),
        hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade400),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: isDark ? Colors.white24 : Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: ensisaBlue, width: 1.8),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        filled: true,
        fillColor: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade50,
        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
      ),
    );
  }

  Widget _buildDropdown(bool isDark) {
    return DropdownButtonFormField<String>(
      initialValue: _data.matiere,
      hint: const Text('Matière concernée', style: TextStyle(fontSize: 13)),
      style: TextStyle(fontSize: 14, color: isDark ? Colors.white : Colors.black87),
      dropdownColor: isDark ? const Color(0xFF2A2A2A) : Colors.white,
      icon: const Icon(Icons.keyboard_arrow_down_rounded, color: ensisaBlue),
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.school_rounded, color: ensisaBlue, size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: isDark ? Colors.white24 : Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: ensisaBlue, width: 1.8),
        ),
        filled: true,
        fillColor: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade50,
        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
      ),
      items: _matieres
          .map((m) => DropdownMenuItem(value: m, child: Text(m, style: const TextStyle(fontSize: 14))))
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
            backgroundColor: ensisaBlue,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            elevation: 4,
            shadowColor: ensisaBlue.withValues(alpha: 0.4),
          ),
          child: _submitting
              ? const SizedBox(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                )
              : const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_circle_outline_rounded, size: 20),
                    SizedBox(width: 10),
                    Text('Créer la session',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                  ],
                ),
        ),
      ),
    );
  }
}