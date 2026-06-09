import 'package:flutter/material.dart';

import './ensiconnect_app.dart';
import '../service/notification_evaluation_service.dart';

class EvaluationDialog extends StatefulWidget {
  final String tutorId;
  final String sessionId;
  final String notificationId;

  const EvaluationDialog({
    super.key,
    required this.tutorId,
    required this.sessionId,
    required this.notificationId,
  });

  @override
  State<EvaluationDialog> createState() => _EvaluationDialogState();
}

class _EvaluationDialogState extends State<EvaluationDialog> {
  int _rating = 0;
  final _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AlertDialog(
      title: Text(
        'Evaluer le tuteur',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.white : Colors.black87,
        ),
      ),
      backgroundColor: isDark ? Colors.black87 : Colors.white,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 0; i < 5; i++)
                IconButton(
                  hoverColor: Colors.transparent,
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onPressed: () => setState(() => _rating = i + 1),
                  icon: Icon(
                    _rating >= (i + 1) ? Icons.star : Icons.star_rate_outlined,
                    color: EnsiConnectApp.ensisaBlue,
                    size: 32,
                  ),
                ),
            ],
          ),
          Text(
            'Comment s\'est passee cette session ?',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          TextField(
            controller: _commentController,
            minLines: 1,
            maxLines: 3,
            keyboardType: TextInputType.multiline,
            decoration: const InputDecoration(
              hintText: 'Laissez un commentaire...',
            ),
          ),
        ],
      ),
      actions: [
        ElevatedButton(
          onPressed: _rating > 0
              ? () async {
                  try {
                    await NotificationEvaluationService().submitEvaluation(
                      sessionId: widget.sessionId,
                      tutorId: widget.tutorId,
                      note: _rating,
                      commentaire: _commentController.text,
                    );

                    await NotificationEvaluationService()
                        .deleteNotification(widget.notificationId);

                    if (!context.mounted) {
                      return;
                    }
                    Navigator.of(context).pop();
                  } catch (e) {
                    debugPrint('Erreur lors de l\'evaluation : $e');
                  }
                }
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: EnsiConnectApp.ensisaBlue,
            foregroundColor: Colors.white,
            disabledBackgroundColor: Colors.grey.shade300,
          ),
          child: const Text(
            'Envoyer',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
