import 'package:flutter/material.dart';

class QuickActionsGrid extends StatelessWidget {
  const QuickActionsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ActionItem(
          icon: Icons.school_outlined,
          label: "Demander\nune aide",
          color: const Color(0xFF7E57C2),
          onTap: () {
            Navigator.pushNamed(context, '/demande_aide');
          },
        ),
        ActionItem(
          icon: Icons.people_alt_outlined,
          label: "Trouver\nun tuteur",
          color: const Color(0xFF42A5F5),
          onTap: () {
            Navigator.pushNamed(context, '/user_search');
          },
        ),
        ActionItem(
          icon: Icons.calendar_today_rounded,
          label: "Sessions \nprevues",
          color: const Color(0xFFEF5350),
          onTap: () {
            Navigator.pushNamed(context, '/mes_sessions');
          },
        ),
        ActionItem(
          icon: Icons.bookmark_border_rounded,
          label: "Mes\nreservations",
          color: const Color(0xFF66BB6A),
          onTap: () {
            Navigator.pushNamed(context, '/mes_sessions_page_2');
          },
        ),
      ],
    );
  }
}

class ActionItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const ActionItem({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 65,
            height: 65,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(16),
              border: isDark
                  ? Border.all(color: Colors.grey.shade700, width: 1)
                  : null,
              boxShadow: isDark
                  ? []
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.grey.shade300 : Colors.black87,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
