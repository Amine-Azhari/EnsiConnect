import 'package:flutter/material.dart';
import "./ensiconnect_app.dart";

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onIndexChanged;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onIndexChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 6.0,
      elevation: isDark ? 16 : 8,
      shadowColor: isDark ? Colors.black : Colors.black45,
      clipBehavior: Clip.antiAlias,
      color: isDark ? Colors.grey.shade900 : Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(context, Icons.home_rounded, "Accueil", 0),
            _buildNavItem(context, Icons.search_rounded, "Explorer", 1),
            const SizedBox(width: 44), // Espace au centre pour le gros bouton "+"
            _buildNavItem(context, Icons.chat_bubble_outline_rounded, "Messages", 2),
            _buildNavItem(context, Icons.person_outline_rounded, "Profil", 3),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, IconData icon, String label, int index) {
    final isSelected = currentIndex == index;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final color = isSelected
        ? (isDark ? Colors.lightBlueAccent : EnsiConnectApp.ensisaBlue)
        : (isDark ? Colors.grey.shade300 : Colors.grey.shade500);

    return InkWell(
      onTap: () => onIndexChanged(index),
      borderRadius: BorderRadius.circular(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 10, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, color: color)),
        ],
      ),
    );
  }
}