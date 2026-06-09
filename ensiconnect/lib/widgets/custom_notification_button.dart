import 'package:flutter/material.dart';
import '../screens/profil.dart';
import '../screens/notification_screen.dart';

class CustomNotificationButton extends StatelessWidget {
  final String userId;

  const CustomNotificationButton({
    super.key,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade800 : Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: isDark
            ? Border.all(color: Colors.grey.shade700, width: 1)
            : null,
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: IconButton(
        onPressed: () {
          Navigator.of(context).push(
            PageRouteBuilder(
              pageBuilder: (_, __, ___) =>
                  ProfilPage(userId: userId),
              transitionDuration: Duration.zero,
              reverseTransitionDuration: Duration.zero,
            ),
          );
        },
        icon: Icon(Icons.notifications_none_rounded, color: textColor),
      ),
    );
  }
}