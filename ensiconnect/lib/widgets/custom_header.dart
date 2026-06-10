import 'package:flutter/material.dart';
import 'custom_notification_button.dart';

class CustomHeader extends StatelessWidget {
  final VoidCallback onMenuPressed;

  const CustomHeader({
    super.key,
    required this.onMenuPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: onMenuPressed,
          icon: Icon(Icons.menu_rounded, color: textColor, size: 28),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
        const CustomNotificationButton(),
      ],
    );
  }
}
