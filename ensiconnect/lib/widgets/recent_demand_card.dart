import 'package:flutter/material.dart';
import '../main.dart'; // Pour accéder aux couleurs de l'app

class RecentDemandCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String time;
  final IconData iconData;
  final Color iconColor;

  const RecentDemandCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.iconData,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final cardTitleColor = isDark ? Colors.white : Colors.black87;
    final cardSubtitleColor = isDark ? Colors.grey.shade300 : Colors.grey.shade700;
    final cardTimeColor = isDark ? Colors.grey.shade500 : Colors.black45;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: isDark ? Border.all(color: Colors.grey.shade800, width: 1) : null,
        boxShadow: isDark ? [] : [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey.shade800 : iconColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
              border: isDark ? Border.all(color: Colors.grey.shade700, width: 1) : null,
            ),
            child: Icon(iconData, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: cardTitleColor)),
                const SizedBox(height: 4),
                Text(subtitle, style: TextStyle(fontSize: 13, color: cardSubtitleColor, height: 1.3)),
                const SizedBox(height: 12),
                Text(time, style: TextStyle(fontSize: 11, color: cardTimeColor)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: EnsiConnectApp.ensisaLightBlue.withValues(alpha: isDark ? 0.2 : 1.0),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              "Nouveau",
              style: TextStyle(color: Colors.red, fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}