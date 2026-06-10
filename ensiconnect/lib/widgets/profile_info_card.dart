import 'package:flutter/material.dart';
import 'icon_tile.dart';

class ProfileInfoCard extends StatelessWidget {
  const ProfileInfoCard({
    super.key,
    required this.fullName,
    required this.email,
    required this.filiere,
    required this.promotion,
    required this.isEditing,
    required this.isOwnProfile,
    required this.onFiliereChanged,
    required this.onPromotionChanged,
  });

  final String fullName;
  final String email;
  final String filiere;
  final String promotion;
  final bool isEditing;
  final bool isOwnProfile;
  final ValueChanged<String?> onFiliereChanged;
  final ValueChanged<String?> onPromotionChanged;

  static const List<String> _filiereOptions = [
    'IR',
    'ASE',
    'GI',
    'MECANIQUE',
    'TEXTILE',
  ];

  static const List<String> _promotionOptions = [
    'CPB1',
    'CPB2',
    '1A',
    '2A',
    '3A',
  ];

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

  Widget _dropdownTile({
    required IconData icon,
    required String label,
    required String value,
    required List<String> options,
    required bool isDark,
    required Color iconColor,
    required ValueChanged<String?> onChanged,
  }) {
    final selectedValue = options.contains(value) ? value : null;

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
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color:
                        isDark ? Colors.grey.shade700 : const Color(0xFFE2E8F0),
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedValue,
                    hint: Text(
                      value.isEmpty ? "Choisir" : value,
                      style: TextStyle(
                        color:
                            isDark ? const Color(0xFFACB1BC) : Colors.black54,
                        fontSize: 14,
                      ),
                    ),
                    isExpanded: true,
                    dropdownColor:
                        isDark ? const Color(0xFF1E1E1E) : Colors.white,
                    icon: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: iconColor,
                    ),
                    items: options
                        .map(
                          (option) => DropdownMenuItem<String>(
                            value: option,
                            child: Text(
                              option,
                              style: TextStyle(
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: onChanged,
                  ),
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
        border:
            isDark ? Border.all(color: Colors.grey.shade800, width: 1) : null,
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
          if (isEditing && isOwnProfile)
            _dropdownTile(
              icon: Icons.school_outlined,
              label: "Filière",
              value: filiere,
              options: _filiereOptions,
              isDark: isDark,
              iconColor: const Color(0xFF66BB6A),
              onChanged: onFiliereChanged,
            )
          else
            _infoGridTile(
              icon: Icons.school_outlined,
              label: "Filière",
              value: filiere,
              isDark: isDark,
              iconColor: const Color(0xFF66BB6A),
            ),
          const SizedBox(height: 18),
          if (isEditing && isOwnProfile)
            _dropdownTile(
              icon: Icons.menu_book_outlined,
              label: "Promotion",
              value: promotion,
              options: _promotionOptions,
              isDark: isDark,
              iconColor: const Color(0xFFEF5350),
              onChanged: onPromotionChanged,
            )
          else
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
