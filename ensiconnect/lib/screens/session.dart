import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
  // Couleurs ENSISA
  static const Color ensisaBlue = Color(0xFF0055A5);
  static const Color ensisaLightBlue = Color(0xFFE6F0FA);
  static const Color accentOrange = Color(0xFFFF9800);

  final _formKey = GlobalKey<FormState>();
  final _data = SessionFormData();

  // Contrôleurs de texte
  final _titreCtrl = TextEditingController();
  final _lieuCtrl = TextEditingController();

  // Tags disponibles
  final List<String> _tagsDisponibles = [
    'Maths', 'Info', 'Physique', 'Chimie',
    'Électronique', 'Mécanique', 'Algo', 'Réseau',
  ];
  final Set<String> _tagsSelectionnes = {};

  // Matières
  final List<String> _matieres = [
    'Algorithmique', 'Bases de données', 'Physique ondulatoire',
    'Automatique', 'Électronique analogique', 'Réseau & Télécoms',
    'Mathématiques', 'Autre',
  ];

  // Animation d'entrée
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

  // ── Helpers ────────────────────────────────────────────────────────────────

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  String _formatTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}h${t.minute.toString().padLeft(2, '0')}';

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

    // TODO : appel Firebase ici
    await Future.delayed(const Duration(milliseconds: 800));

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

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final subtleColor = isDark ? Colors.white12 : Colors.black12;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: _buildAppBar(isDark),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SlideTransition(
          position: _slideAnim,
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
              children: [
                // En-tête décoratif
                _buildHeader(isDark),
                const SizedBox(height: 24),

                // Section Titre & Matière
                _buildSection(
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

                // Section Date & Heure
                _buildSection(
                  icon: Icons.calendar_today_rounded,
                  label: 'Quand ?',
                  cardColor: cardColor,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildPickerTile(
                            icon: Icons.event,
                            title: 'Date',
                            value: _data.date != null
                                ? _formatDate(_data.date!)
                                : null,
                            placeholder: 'Choisir',
                            onTap: _pickDate,
                            isDark: isDark,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildPickerTile(
                            icon: Icons.access_time_rounded,
                            title: 'Heure',
                            value: _data.heure != null
                                ? _formatTime(_data.heure!)
                                : null,
                            placeholder: 'Choisir',
                            onTap: _pickTime,
                            isDark: isDark,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Section Lieu
                _buildSection(
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

                // Section Nombre de places
                _buildSection(
                  icon: Icons.people_rounded,
                  label: 'Places',
                  cardColor: cardColor,
                  children: [_buildPlacesSelector(isDark)],
                ),
                const SizedBox(height: 16),

                // Section Tags
                _buildSection(
                  icon: Icons.label_rounded,
                  label: 'Tags',
                  cardColor: cardColor,
                  children: [_buildTagsGrid(isDark)],
                ),
                const SizedBox(height: 16),

                // Badge public
                _buildPublicBadge(cardColor, isDark),
              ],
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _buildFAB(),
    );
  }

  // ── AppBar ─────────────────────────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar(bool isDark) {
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

  // ── Header décoratif ───────────────────────────────────────────────────────

  Widget _buildHeader(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [ensisaBlue, ensisaBlue.withOpacity(0.75)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.groups_rounded, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nouvelle session publique',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Visible par tous les étudiants ENSISA',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Section card ───────────────────────────────────────────────────────────

  Widget _buildSection({
    required IconData icon,
    required String label,
    required Color cardColor,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(icon, color: ensisaBlue, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: ensisaBlue,
                letterSpacing: 0.4,
              ),
            ),
          ]),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  // ── TextField ──────────────────────────────────────────────────────────────

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
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
              color: isDark ? Colors.white24 : Colors.grey.shade300),
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
        contentPadding:
            const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
      ),
    );
  }

  // ── Dropdown matière ───────────────────────────────────────────────────────

  Widget _buildDropdown(bool isDark) {
    return DropdownButtonFormField<String>(
      value: _data.matiere,
      hint: const Text('Matière concernée', style: TextStyle(fontSize: 13)),
      style: TextStyle(
          fontSize: 14, color: isDark ? Colors.white : Colors.black87),
      dropdownColor: isDark ? const Color(0xFF2A2A2A) : Colors.white,
      icon: const Icon(Icons.keyboard_arrow_down_rounded, color: ensisaBlue),
      decoration: InputDecoration(
        prefixIcon:
            const Icon(Icons.school_rounded, color: ensisaBlue, size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
              color: isDark ? Colors.white24 : Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: ensisaBlue, width: 1.8),
        ),
        filled: true,
        fillColor: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade50,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
      ),
      items: _matieres
          .map((m) => DropdownMenuItem(value: m, child: Text(m, style: const TextStyle(fontSize: 14))))
          .toList(),
      onChanged: (v) => setState(() => _data.matiere = v),
    );
  }

  // ── Picker tile (date / heure) ─────────────────────────────────────────────

  Widget _buildPickerTile({
    required IconData icon,
    required String title,
    required String? value,
    required String placeholder,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    final hasValue = value != null;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: hasValue
              ? ensisaBlue.withOpacity(0.08)
              : (isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade50),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: hasValue ? ensisaBlue : (isDark ? Colors.white24 : Colors.grey.shade300),
            width: hasValue ? 1.6 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(icon, size: 16, color: hasValue ? ensisaBlue : Colors.grey),
              const SizedBox(width: 6),
              Text(title,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: hasValue ? ensisaBlue : Colors.grey,
                    letterSpacing: 0.3,
                  )),
            ]),
            const SizedBox(height: 4),
            Text(
              value ?? placeholder,
              style: TextStyle(
                fontSize: 14,
                fontWeight: hasValue ? FontWeight.w700 : FontWeight.w400,
                color: hasValue
                    ? (isDark ? Colors.white : Colors.black87)
                    : Colors.grey.shade400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Sélecteur de places ────────────────────────────────────────────────────

  Widget _buildPlacesSelector(bool isDark) {
    return Row(
      children: [
        const Icon(Icons.people_alt_outlined, color: ensisaBlue, size: 20),
        const SizedBox(width: 10),
        const Text('Nombre de places :', style: TextStyle(fontSize: 14)),
        const Spacer(),
        _PlacesCounter(
          value: _data.nbPlaces,
          onChanged: (v) => setState(() => _data.nbPlaces = v),
          isDark: isDark,
        ),
      ],
    );
  }

  // ── Tags ───────────────────────────────────────────────────────────────────

  Widget _buildTagsGrid(bool isDark) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _tagsDisponibles.map((tag) {
        final selected = _tagsSelectionnes.contains(tag);
        return GestureDetector(
          onTap: () => setState(() {
            selected
                ? _tagsSelectionnes.remove(tag)
                : _tagsSelectionnes.add(tag);
          }),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: selected ? ensisaBlue : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: selected ? ensisaBlue : (isDark ? Colors.white30 : Colors.grey.shade300),
              ),
            ),
            child: Text(
              tag,
              style: TextStyle(
                fontSize: 13,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                color: selected
                    ? Colors.white
                    : (isDark ? Colors.white70 : Colors.black87),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── Badge public ───────────────────────────────────────────────────────────

  Widget _buildPublicBadge(Color cardColor, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.shade300.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(Icons.public_rounded,
              color: Colors.green.shade700, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Session publique',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: Colors.green.shade700,
                  )),
              const SizedBox(height: 2),
              Text(
                'Visible et rejoignable par tous les étudiants ENSISA.',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      ]),
    );
  }

  // ── FAB Créer ──────────────────────────────────────────────────────────────

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
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
            elevation: 4,
            shadowColor: ensisaBlue.withOpacity(0.4),
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

// ─── Widget compteur de places ─────────────────────────────────────────────

class _PlacesCounter extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;
  final bool isDark;

  const _PlacesCounter({
    required this.value,
    required this.onChanged,
    required this.isDark,
  });

  static const Color ensisaBlue = Color(0xFF0055A5);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _btn(Icons.remove, () {
          if (value > 2) onChanged(value - 1);
        }),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 150),
          transitionBuilder: (child, anim) =>
              ScaleTransition(scale: anim, child: child),
          child: Text(
            '$value',
            key: ValueKey(value),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: ensisaBlue,
            ),
          ),
        ),
        _btn(Icons.add, () {
          if (value < 20) onChanged(value + 1);
        }),
      ],
    );
  }

  Widget _btn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: ensisaBlue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: ensisaBlue, size: 18),
      ),
    );
  }
}