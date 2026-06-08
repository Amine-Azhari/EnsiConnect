import 'package:flutter/material.dart';

class EvaluationDialog extends StatefulWidget {
  final String sessionId;

  const EvaluationDialog({
    super.key, 
    required this.sessionId
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
    return AlertDialog(
      title: const Text('Évaluer la session'),
      content: Column(
        mainAxisSize: MainAxisSize.min, // Très important pour un popup !
        children: [
          const Text('Comment s\'est passée cette session ?'),
          const SizedBox(height: 16),
          // TODO: Ajouter tes étoiles cliquables ici (ex: Row avec des IconButton)
          TextField(
            controller: _commentController,
            decoration: const InputDecoration(
              hintText: 'Laissez un commentaire...',
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(), // Ferme sans rien faire
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: () {
            // TODO: Appeler ton service pour sauvegarder la note
            // EvaluationService().submitEvaluation(widget.sessionId, _rating, _commentController.text);
            Navigator.of(context).pop(); // Ferme le popup après l'envoi
          },
          child: const Text('Envoyer'),
        ),
      ],
    );
  }
}