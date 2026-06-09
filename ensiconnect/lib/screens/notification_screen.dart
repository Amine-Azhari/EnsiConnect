import 'package:flutter/material.dart';
// import '../widgets/ensiconnect_app.dart';
import '../widgets/evaluation_dialog.dart';
import '../service/notification_evaluation_service.dart';

class NotificationScreen extends StatefulWidget {

  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {

  late Future<List<Map<String, dynamic>>?> _notificationsFuture;

  @override
  void initState() {
    super.initState();
    _notificationsFuture = NotificationEvaluationService().getNotificationsCurrentUser();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Notifications',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>?>(
        future: _notificationsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text("BUG : ${snapshot.error}"),
            );
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(
              child: Text("Impossible de charger vos données (Profil introuvable ou déconnecté)."),
            );
          }

          final notifications = snapshot.data!;

          if (notifications.isEmpty) {
            return const Center(
              child: Text("Aucune notification pour le moment"),
            );
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