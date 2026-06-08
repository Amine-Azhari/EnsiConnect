import 'package:flutter/material.dart';
// import '../widgets/ensiconnect_app.dart';
import '../widgets/evaluation_dialog.dart';

class NotificationScreen extends StatefulWidget {

  const NotificationScreen({
    super.key,
    // required this.sessionId
  });

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {

  final List<Map<String, dynamic>> _notifications = [
    {"id": "1", "message": "Notez votre session de Math", "tutorId": "tuteur_math_123"},
  ];

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
      body: _notifications.isEmpty ?
      const Center(child: Text("Aucune notification pour le moment"))
      : ListView.builder(
        itemCount: _notifications.length,
        itemBuilder: (context, index) {
          final notif = _notifications[index];
          
          return ListTile(
            title: Text(notif["message"]),
            trailing: const Icon(Icons.star_border),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => EvaluationDialog(tutorId: notif["tutorId"]),
              );
            },
          );
        },
      ),
    );
  }
}