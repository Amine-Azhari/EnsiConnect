import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../service/notification_evaluation_service.dart';
import '../service/session_service.dart';
import '../widgets/evaluation_dialog.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  String? currentStudentId;
  bool _loadingUser = true;

  Color _accentColor(bool isEvaluation) {
    return isEvaluation ? const Color(0xFFF4B400) : const Color(0xFF0F766E);
  }

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    await SessionService().cleanupOldSessions();

    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('user_email');
    if (email != null) {
      final studentResult = await FirebaseFirestore.instance
          .collection('Etudiant')
          .where('eMail', isEqualTo: email)
          .limit(1)
          .get();
      if (studentResult.docs.isNotEmpty && mounted) {
        setState(() {
          currentStudentId = studentResult.docs.first.id;
          _loadingUser = false;
        });
        return;
      }
    }
    if (mounted) {
      setState(() => _loadingUser = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subTextColor = isDark ? Colors.white70 : Colors.black54;
    final cardColor = Theme.of(context).cardColor;

    if (_loadingUser) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (currentStudentId == null) {
      return const Scaffold(
          body: Center(child: Text('Utilisateur non trouvé.')));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Notifications',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: NotificationEvaluationService()
            .watchMyNotifications(currentStudentId!),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erreur : ${snapshot.error}'));
          }

          final notifications = snapshot.data ?? [];
          if (notifications.isEmpty) {
            return const Center(
              child: Text('Aucune notification pour le moment'),
            );
          }

          final evaluationCount = notifications
              .where((notif) => notif['type'] == 'evaluation')
              .length;

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            itemCount: notifications.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                final totalCount = notifications.length;
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF0F766E),
                        Color(0xFF14B8A6),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0F766E).withValues(alpha: 0.22),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.notifications_active_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$totalCount notification${totalCount > 1 ? 's' : ''}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 21,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              evaluationCount > 0
                                  ? '$evaluationCount demande${evaluationCount > 1 ? 's' : ''} d\'évaluation en attente'
                                  : 'Consultez et traitez vos dernières alertes',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.88),
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }

              final notif = notifications[index - 1];
              final isEvaluation = notif['type'] == 'evaluation';
              final accentColor = _accentColor(isEvaluation);

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: accentColor.withValues(alpha: isDark ? 0.40 : 0.18),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color:
                          Colors.black.withValues(alpha: isDark ? 0.10 : 0.05),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(22),
                    onTap: isEvaluation
                        ? () {
                            showDialog(
                              context: context,
                              builder: (context) => EvaluationDialog(
                                tutorId: (notif['tutorId'] ?? '').toString(),
                                sessionId:
                                    (notif['sessionId'] ?? '').toString(),
                                notificationId: (notif['id'] ?? '').toString(),
                              ),
                            );
                          }
                        : null,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              color: accentColor.withValues(alpha: 0.14),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(
                              isEvaluation
                                  ? Icons.star_rounded
                                  : Icons.notifications_rounded,
                              color: accentColor,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        isEvaluation
                                            ? 'Evaluation demandée'
                                            : 'Nouvelle notification',
                                        style: TextStyle(
                                          color: textColor,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 5,
                                      ),
                                      decoration: BoxDecoration(
                                        color:
                                            accentColor.withValues(alpha: 0.12),
                                        borderRadius:
                                            BorderRadius.circular(999),
                                      ),
                                      child: Text(
                                        isEvaluation ? 'Action' : 'Info',
                                        style: TextStyle(
                                          color: accentColor,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  notif['message'] ??
                                      'Notification sans message',
                                  style: TextStyle(
                                    color: textColor,
                                    fontSize: 14,
                                    height: 1.4,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        isEvaluation
                                            ? 'Touchez pour ouvrir l\'évaluation'
                                            : 'Notification simple',
                                        style: TextStyle(
                                          color: subTextColor,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    if (isEvaluation)
                                      Icon(
                                        Icons.arrow_forward_rounded,
                                        color: accentColor,
                                        size: 18,
                                      )
                                    else
                                      IconButton(
                                        icon: const Icon(
                                          Icons.close_rounded,
                                          color: Colors.blueGrey,
                                        ),
                                        tooltip: 'Supprimer',
                                        onPressed: () async {
                                          final notificationId =
                                              (notif['id'] ?? '')
                                                  .toString()
                                                  .trim();
                                          if (notificationId.isEmpty) {
                                            return;
                                          }
                                          await NotificationEvaluationService()
                                              .deleteNotification(
                                                  notificationId);
                                        },
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
