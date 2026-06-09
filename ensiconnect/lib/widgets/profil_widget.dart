import 'package:flutter/material.dart';

class ProfilWidget {
  final BuildContext context;

  ProfilWidget(this.context);

  bool get _isDark =>
      Theme.of(context).brightness == Brightness.dark;

  BoxDecoration cardDecoration() {
    return BoxDecoration(
      color: _isDark ? const Color(0xD90A111C) : Colors.white,
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

  // ================= STATS =================
  Widget statCard({required String title, required String value}) {
    return Container(
      constraints: const BoxConstraints(minHeight: 112),
      padding: const EdgeInsets.all(18),
      decoration: cardDecoration(),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: TextStyle(
              color: _isDark ? Colors.white : Colors.black87,
              fontSize: 34,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: TextStyle(
              color: _isDark ? const Color(0xFFACB1BC) : Colors.black54,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  // ================= CARD =================
  Widget profileCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: cardDecoration(),
      child: child,
    );
  }

  // ================= TITLE =================
  Widget sectionTitle(String title, {Widget? trailing}) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              color: _isDark ? Colors.white : Colors.black87,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        if (trailing != null) trailing,
      ],
    );
  }

  // ================= INFO =================
  Widget infoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
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
                      color: _isDark ? Colors.grey : Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value.isEmpty ? '-' : value,
                    style: TextStyle(
                      color: _isDark ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Divider(color: _isDark ? Colors.grey[800] : Colors.grey[300]),
      ],
    );
  }

  // ================= DESCRIPTION =================
  Widget descriptionBox({
    required TextEditingController controller,
    required bool isEditing,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: cardDecoration(),
      child: TextField(
        controller: controller,
        enabled: isEditing,
        maxLines: 4,
        style: TextStyle(
          color: _isDark ? Colors.white : Colors.black87,
          fontSize: 16,
        ),
        decoration: InputDecoration(
          hintText: "Décris-toi en quelques mots...",
          hintStyle: TextStyle(
            color: _isDark ? const Color(0xFFACB1BC) : Colors.black45,
          ),
          border: InputBorder.none,
        ),
      ),
    );
  }

  // ================= SKILLS =================
  Widget skillsBox({
    required List<String> skills,
    required bool isEditing,
    required List<String> options,
    required String? selectedSkill,
    required void Function(String?) onChanged,
    required VoidCallback onAdd,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Compétences",
            style: TextStyle(
              color: _isDark ? Colors.white : Colors.black87,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          if (isEditing) ...[
            DropdownButton<String>(
              value: selectedSkill,
              hint: const Text("Ajouter une compétence"),
              isExpanded: true,
              items: options
                  .map((e) => DropdownMenuItem(
                        value: e,
                        child: Text(e),
                      ))
                  .toList(),
              onChanged: onChanged,
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: onAdd,
              child: const Text("Ajouter"),
            ),
          ],

          const SizedBox(height: 10),

          Wrap(
            spacing: 8,
            children: skills
                .map(
                  (e) => Chip(
                    label: Text(e),
                    backgroundColor: _isDark
                        ? const Color(0xFF10243A)
                        : const Color(0xFFEAF4FF),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

// ================= ICON =================
class _IconTile extends StatelessWidget {
  final IconData icon;

  const _IconTile({required this.icon});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF102033) : const Color(0xFFEAF4FF),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(icon, color: const Color(0xFF248BFF)),
    );
  }
}