import 'package:flutter/material.dart';

import 'person_avatar.dart';

const Color _ensisaBlue = Color(0xFF0055A5);

// ─── 1. Section card ──────────────────────────────────────────────────────────

class SessionFormSection extends StatelessWidget {
  final Color cardColor;
  final List<Widget> children;

  const SessionFormSection({
    super.key,
    required this.cardColor,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...children,
        ],
      ),
    );
  }
}

// ─── 2. Picker tile ───────────────────────────────────────────────────────────

class SessionPickerTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? value;
  final String placeholder;
  final VoidCallback onTap;
  final bool isDark;

  const SessionPickerTile({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    required this.placeholder,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final hasValue = value != null;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 10),
        decoration: BoxDecoration(
          color: hasValue
              ? _ensisaBlue.withValues(alpha: 0.08)
              : (isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.grey.shade50),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: hasValue
                ? _ensisaBlue
                : (isDark ? Colors.white24 : Colors.grey.shade300),
            width: hasValue ? 1.6 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(icon, size: 16, color: hasValue ? _ensisaBlue : Colors.grey),
              const SizedBox(width: 6),
              Text(title,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: hasValue ? _ensisaBlue : Colors.grey,
                    letterSpacing: 0.3,
                  )),
            ]),
              const SizedBox(height: 3),
            Text(
              value ?? placeholder,
              style: TextStyle(
                fontSize: 13,
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
}

// ─── 3. Compteur de places ────────────────────────────────────────────────────

class SessionPlacesCounter extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;
  final bool isDark;

  const SessionPlacesCounter({
    super.key,
    required this.value,
    required this.onChanged,
    required this.isDark,
  });

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
              color: _ensisaBlue,
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
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: _ensisaBlue.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(7),
        ),
        child: Icon(icon, color: _ensisaBlue, size: 16),
      ),
    );
  }
}

// ─── 4. Tags grid ─────────────────────────────────────────────────────────────

class SessionTagsGrid extends StatelessWidget {
  final List<String> tagsDisponibles;
  final Set<String> tagsSelectionnes;
  final void Function(String tag) onToggle;
  final bool isDark;

  const SessionTagsGrid({
    super.key,
    required this.tagsDisponibles,
    required this.tagsSelectionnes,
    required this.onToggle,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: tagsDisponibles.map((tag) {
        final selected = tagsSelectionnes.contains(tag);
        return GestureDetector(
          onTap: () => onToggle(tag),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: selected ? _ensisaBlue : Colors.transparent,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: selected
                    ? _ensisaBlue
                    : (isDark ? Colors.white30 : Colors.grey.shade300),
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
}

// ─── 5. Header décoratif ──────────────────────────────────────────────────────

class SessionHeader extends StatelessWidget {
  const SessionHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_ensisaBlue, _ensisaBlue.withValues(alpha: 0.75)],
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
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child:
                const Icon(Icons.groups_rounded, color: Colors.white, size: 28),
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
}

// ─── 6. Badge public ──────────────────────────────────────────────────────────

class SessionPublicBadge extends StatelessWidget {
  final Color cardColor;

  const SessionPublicBadge({super.key, required this.cardColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.shade300.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
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
              Text(
                'Session publique',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: Colors.green.shade700,
                ),
              ),
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
}

// ─── 7. Salle dropdown ────────────────────────────────────────────────────────

class SessionSalleDropdown extends StatelessWidget {
  final List<String> salles;
  final bool loading;
  final String? value;
  final bool isDark;
  final void Function(String?) onChanged;

  const SessionSalleDropdown({
    super.key,
    required this.salles,
    required this.loading,
    required this.value,
    required this.isDark,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }
    return DropdownButtonFormField<String>(
      initialValue: value,
      hint: const Text('Choisir une salle', style: TextStyle(fontSize: 13)),
      style: TextStyle(
          fontSize: 14, color: isDark ? Colors.white : Colors.black87),
      dropdownColor: isDark ? const Color(0xFF2A2A2A) : Colors.white,
      icon: const Icon(Icons.keyboard_arrow_down_rounded, color: _ensisaBlue),
      decoration: InputDecoration(
        prefixIcon:
            const Icon(Icons.place_rounded, color: _ensisaBlue, size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              BorderSide(color: isDark ? Colors.white24 : Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _ensisaBlue, width: 1.8),
        ),
        filled: true,
        fillColor:
            isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade50,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
      ),
      validator: (v) => (v == null || v.isEmpty) ? 'Champ requis' : null,
      items: salles
          .map((s) => DropdownMenuItem(
              value: s, child: Text(s, style: const TextStyle(fontSize: 14))))
          .toList(),
      onChanged: onChanged,
    );
  }
}

// ─── 8. Recherche étudiants ───────────────────────────────────────────────────

class SessionEtudiantSearch extends StatelessWidget {
  final TextEditingController searchCtrl;
  final List<Map<String, dynamic>> resultats;
  final List<Map<String, dynamic>> etudiantsAjoutes;
  final bool searching;
  final bool isDark;
  final void Function(String) onSearch;
  final void Function(Map<String, dynamic>) onAjouter;
  final void Function(Map<String, dynamic>) onRetirer;

  const SessionEtudiantSearch({
    super.key,
    required this.searchCtrl,
    required this.resultats,
    required this.etudiantsAjoutes,
    required this.searching,
    required this.isDark,
    required this.onSearch,
    required this.onAjouter,
    required this.onRetirer,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: searchCtrl,
          onChanged: onSearch,
          decoration: InputDecoration(
            hintText: 'Rechercher un étudiant...',
            prefixIcon: const Icon(Icons.search_rounded, color: _ensisaBlue),
            suffixIcon: searching
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: _ensisaBlue),
                    ))
                : null,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                  color: isDark ? Colors.white24 : Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _ensisaBlue, width: 1.8),
            ),
            filled: true,
            fillColor:
                isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade50,
            contentPadding:
                const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
          ),
        ),
        if (resultats.isNotEmpty) ...[
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF2A2A2A) : Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: isDark ? Colors.white12 : Colors.grey.shade200),
            ),
            child: Column(
              children: resultats.map((e) {
                final dejaAjoute =
                    etudiantsAjoutes.any((a) => a['id'] == e['id']);
                return ListTile(
                  leading: PersonAvatar(
                    name: '${e['Prenom'] ?? ''} ${e['Nom'] ?? ''}',
                  ),
                  title: Text('${e['Prenom']} ${e['Nom']}',
                      style: const TextStyle(fontSize: 14)),
                  subtitle: Text(e['eMail'] ?? '',
                      style:
                          TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                  trailing: dejaAjoute
                      ? const Icon(Icons.check_circle_rounded,
                          color: Colors.green)
                      : IconButton(
                          icon: const Icon(Icons.add_circle_outline_rounded,
                              color: _ensisaBlue),
                          onPressed: () => onAjouter(e),
                        ),
                );
              }).toList(),
            ),
          ),
        ],
        if (etudiantsAjoutes.isNotEmpty) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: etudiantsAjoutes
                .map((e) => Chip(
                      avatar: PersonAvatar(
                        name: '${e['Prenom'] ?? ''} ${e['Nom'] ?? ''}',
                        radius: 12,
                        fontSize: 11,
                      ),
                      label: Text('${e['Prenom']} ${e['Nom']}',
                          style: const TextStyle(fontSize: 12)),
                      deleteIcon: const Icon(Icons.close, size: 16),
                      onDeleted: () => onRetirer(e),
                      backgroundColor: isDark
                          ? Colors.white12
                          : _ensisaBlue.withValues(alpha: 0.08),
                      side: BorderSide(color: _ensisaBlue.withValues(alpha: 0.3)),
                    ))
                .toList(),
          ),
        ],
      ],
    );
  }
}

