import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import '../widgets/ensiconnect_app.dart';
import '../widgets/evaluation_dialog.dart';
import '../service/notification_evaluation_service.dart';

class NotificationScreen extends StatefulWidget {

  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {

  String? currentStudentId;
  bool _loadingUser = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
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
    if (mounted) setState(() => _loadingUser = false);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;

    if (_loadingUser) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (currentStudentId == null) {
      return const Scaffold(body: Center(child: Text("Utilisateur non trouvé.")));
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
        stream: NotificationEvaluationService().watchMyNotifications(currentStudentId!),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Erreur : ${snapshot.error}"));
          }
          final notifications = snapshot.data ?? [];

          if (notifications.isEmpty) {
            return const Center(child: Text("Aucune notification pour le moment"));
          }

          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notif = notifications[index];

              return ListTile(
                title: Text(
                  notif["message"] ?? "Notification sans message",
                  style: TextStyle(color: textColor),
                ),
                trailing: const Icon(Icons.star_border, color: Colors.amber),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => EvaluationDialog(
                      tutorId: notif["tutorId"] ?? "",
                      notificationId: notif["id"] ?? "", // 👈 On transmet l'ID ici !
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}