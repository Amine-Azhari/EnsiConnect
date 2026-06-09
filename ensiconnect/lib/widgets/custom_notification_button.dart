import 'package:flutter/material.dart';

import '../screens/notification_screen.dart';
import '../service/notification_evaluation_service.dart';
import '../service/user_service.dart';

class CustomNotificationButton extends StatefulWidget {
  const CustomNotificationButton({super.key});

  @override
  State<CustomNotificationButton> createState() =>
      _CustomNotificationButtonState();
}

class _CustomNotificationButtonState extends State<CustomNotificationButton> {
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    final user = await UserServices().getCurrentUser();
    if (!mounted) {
      return;
    }
    setState(() {
      _currentUserId = user?.id;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade800 : Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border:
            isDark ? Border.all(color: Colors.grey.shade700, width: 1) : null,
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
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const NotificationScreen(),
            ),
          );
        },
        icon: Stack(
          clipBehavior: Clip.none,
          children: [
            Icon(Icons.notifications_none_rounded, color: textColor),
            if (_currentUserId != null)
              Positioned(
                right: -1,
                top: -1,
                child: StreamBuilder<List<Map<String, dynamic>>>(
                  stream: NotificationEvaluationService()
                      .watchMyNotifications(_currentUserId!),
                  builder: (context, snapshot) {
                    final hasNotifications =
                        (snapshot.data?.isNotEmpty ?? false);
                    if (!hasNotifications) {
                      return const SizedBox.shrink();
                    }

                    return Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDark
                              ? Colors.grey.shade800
                              : Theme.of(context).cardColor,
                          width: 1.5,
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
