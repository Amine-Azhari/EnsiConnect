import 'package:flutter/material.dart';
import 'icon_tile.dart';

class ProfileInfoCard extends StatelessWidget {
  const ProfileInfoCard({
    super.key,
    required this.fullName,
    required this.email,
    required this.filiere,
    required this.promotion,
  });

  final String fullName;
  final String email;
  final String filiere;
  final String promotion;

  Widget _infoGridTile({
    required IconData icon,
    required String label,
    required String value,
    required bool isDark,
    required Color iconColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IconTile(icon: icon, color: iconColor),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value.isEmpty ? '-' : value,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isDark ? const Color(0xFFACB1BC) : Colors.black87,
                  fontSize: 14,
                  height: 1.25,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

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
          Text(
            "Informations personnelles",
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontSize: 19,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 22),
          _infoGridTile(
            icon: Icons.badge_outlined,
            label: "Nom",
            value: fullName,
            isDark: isDark,
            iconColor: const Color(0xFF7E57C2),
          ),
          const SizedBox(height: 18),
          _infoGridTile(
            icon: Icons.mail_outline_rounded,
            label: "Email",
            value: email,
            isDark: isDark,
            iconColor: const Color(0xFF42A5F5),
          ),
          const SizedBox(height: 18),
          _infoGridTile(
            icon: Icons.school_outlined,
            label: "Filière",
            value: filiere,
            isDark: isDark,
            iconColor: const Color(0xFF66BB6A),
          ),
          const SizedBox(height: 18),
          _infoGridTile(
            icon: Icons.menu_book_outlined,
            label: "Promotion",
            value: promotion,
            isDark: isDark,
            iconColor: const Color(0xFFEF5350),
          ),
        ],
      ),
    );
  }
}