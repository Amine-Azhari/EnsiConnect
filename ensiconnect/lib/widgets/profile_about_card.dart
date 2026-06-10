import 'icon_tile.dart';
import 'package:flutter/material.dart';

class ProfileAboutCard extends StatelessWidget {
  const ProfileAboutCard({
    super.key,
    required this.isEditing,
    required this.isOwnProfile,
    required this.descriptionController,
  });

  final bool isEditing;
  final bool isOwnProfile;
  final TextEditingController descriptionController;

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
              const IconTile(icon: Icons.person_outline_rounded),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  "À propos",
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          TextField(
            controller: descriptionController,
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

}