import 'package:flutter/material.dart';
import 'icon_tile.dart';

class ProfileSkillsCard extends StatefulWidget {
  const ProfileSkillsCard({
    super.key,
    required this.skills,
    required this.skillsOptions,
    required this.isEditing,
    required this.isOwnProfile,
    required this.selectedSkill,
    required this.onSkillChanged,
    required this.onAddSkill,
  });

  final List<String> skills;
  final List<String> skillsOptions;
  final bool isEditing;
  final bool isOwnProfile;
  final String? selectedSkill;
  final ValueChanged<String?> onSkillChanged;
  final VoidCallback onAddSkill;

  @override
  State<ProfileSkillsCard> createState() => _ProfileSkillsCardState();
}

class _ProfileSkillsCardState extends State<ProfileSkillsCard> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const IconTile(
                icon: Icons.lightbulb_outline_rounded,
                color: Color(0xFFE0A400),
              ),
              const SizedBox(width: 14),
              Text(
                "Compétences",
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          if (widget.isEditing && widget.isOwnProfile) ...[
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
                  value: (widget.selectedSkill != null &&
                          widget.skillsOptions.contains(widget.selectedSkill))
                      ? widget.selectedSkill
                      : null,
                  hint: Text(
                    widget.skills.isEmpty
                        ? "Aucune compétence"
                        : "Choisir une compétence",
                    style: const TextStyle(
                      color: Color(0xFFE0A400),
                      fontSize: 16,
                    ),
                  ),
                  dropdownColor: isDark ? const Color(0xFF07101C) : Colors.white,
                  icon: const Icon(
                    Icons.add_circle_rounded,
                    color: Color(0xFFE0A400),
                  ),
                  isExpanded: true,
                  items: widget.skillsOptions
                      .map((e) => DropdownMenuItem(
                            value: e,
                            child: Text(
                              e,
                              style: TextStyle(
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                          ))
                      .toList(),
                  onChanged: widget.onSkillChanged,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: widget.onAddSkill,
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFFE0A400),
                ),
                child: const Text("Ajouter"),
              ),
            ),
          ],
          if (widget.skills.isNotEmpty) ...[
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.skills
                  .map((skill) => Chip(
                        label: Text(skill),
                        labelStyle: TextStyle(
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                        backgroundColor: isDark
                            ? const Color(0xFF2B2512)
                            : const Color(0xFFFFF4C7),
                        side: const BorderSide(color: Color(0xFFFFD35A)),
                      ))
                  .toList(),
            ),
          ] else if (!widget.isEditing) ...[
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF2B2512) : const Color(0xFFFFF4C7),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const Icon(Icons.school_outlined, color: Color(0xFFE0A400), size: 20),
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
}