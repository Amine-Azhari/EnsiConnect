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
    final surfaceColor =
        isDark ? Colors.grey.shade800 : Theme.of(context).cardColor;

    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
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
                right: -6,
                top: -8,
                child: StreamBuilder<List<Map<String, dynamic>>>(
                  stream: NotificationEvaluationService()
                      .watchMyNotifications(_currentUserId!),
                  builder: (context, snapshot) {
                    final count = snapshot.data?.length ?? 0;
                    if (count == 0) {
                      return const SizedBox.shrink();
                    }

                    final badgeText = count > 9 ? '9+' : '$count';
                    final hasSeveralNotifications = count > 1;

                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      padding: EdgeInsets.symmetric(
                        horizontal: hasSeveralNotifications ? 6 : 0,
                        vertical: hasSeveralNotifications ? 3 : 0,
                      ),
                      constraints: BoxConstraints(
                        minWidth: hasSeveralNotifications ? 22 : 12,
                        minHeight: hasSeveralNotifications ? 22 : 12,
                      ),
                      decoration: BoxDecoration(
                        color: hasSeveralNotifications
                            ? const Color(0xFFE53935)
                            : const Color(0xFFFF6B6B),
                        borderRadius: BorderRadius.circular(
                          hasSeveralNotifications ? 999 : 12,
                        ),
                        border: Border.all(color: surfaceColor, width: 1.8),
                        boxShadow: [
                          BoxShadow(
                            color:
                                const Color(0xFFE53935).withValues(alpha: 0.28),
                            blurRadius: 14,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          hasSeveralNotifications ? badgeText : '',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            height: 1,
                          ),
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
