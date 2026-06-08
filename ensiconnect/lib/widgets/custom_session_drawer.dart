import 'package:flutter/material.dart';
import './ensiconnect_app.dart';

// ─── Widget compteur de places ─────────────────────────────────────────────

class PlacesCounter extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;
  final bool isDark;

  const PlacesCounter({
    super.key,
    required this.value,
    required this.onChanged,
    required this.isDark,
  });

  // static const Color EnsiConnectApp.ensisaBlue = Color(0xFF0055A5);

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
              color: EnsiConnectApp.ensisaBlue,
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
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: EnsiConnectApp.ensisaBlue.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: EnsiConnectApp.ensisaBlue, size: 18),
      ),
    );
  }
}