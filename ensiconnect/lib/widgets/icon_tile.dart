
import 'package:flutter/material.dart';

class IconTile extends StatelessWidget {
  const IconTile({
    super.key,
    required this.icon,
    this.color = const Color(0xFF0B77E3),
  });

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(14),
        border:
            isDark ? Border.all(color: Colors.grey.shade700, width: 1) : null,
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: color.withValues(alpha: 0.18),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Icon(icon, color: Colors.white, size: 30),
    );
  }
}