import 'package:flutter/material.dart';

class ProfilWidget {
  static BoxDecoration cardDecoration(bool isDark) {
    return BoxDecoration(
      color: isDark ? const Color(0xD90A111C) : Colors.white,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: const Color(0xFF248BFF), width: 1),
    );
  }

  static Widget statCard({
    required bool isDark,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: cardDecoration(isDark),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: TextStyle(
              color: isDark ? Colors.grey : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  static Widget profileCard({
    required bool isDark,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: cardDecoration(isDark),
      child: child,
    );
  }

  static Widget sectionTitle({
    required bool isDark,
    required String title,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: 40,
          height: 4,
          color: const Color(0xFF248BFF),
        ),
      ],
    );
  }

  static Widget infoRow({
    required bool isDark,
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF248BFF)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(
                      color: isDark ? Colors.grey : Colors.black54,
                    )),
                Text(value,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black,
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}