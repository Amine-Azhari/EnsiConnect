import 'package:flutter/material.dart';
import 'main.dart'; // Pour accéder aux couleurs de l'application

// Modèle simple de donnée pour représenter une demande d'aide
class HelpRequest {
  final String authorName;
  final String subject;
  final String message;
  final String timeAgo;
  final bool isMe;

  HelpRequest({
    required this.authorName,
    required this.subject,
    required this.message,
    required this.timeAgo,
    this.isMe = false,
  });
}

// On déclare la liste à l'extérieur de la classe pour qu'elle devienne globale en mémoire.
// Ainsi, elle ne sera pas réinitialisée lorsqu'on quitte et revient sur la page.
final List<HelpRequest> globalRequests = [
    HelpRequest(
      authorName: "Alice Dupont",
      subject: "Mathématiques - Algèbre linéaire",
      message: "Bonjour, je bloque sur la diagonalisation des matrices. Quelqu'un pourrait m'expliquer la méthode pas à pas ?",
      timeAgo: "Il y a 2h",
    ),
    HelpRequest(
      authorName: "Lucas Martin",
      subject: "Programmation - C",
      message: "Je n'arrive pas à comprendre le fonctionnement des pointeurs et de l'allocation dynamique avec malloc(). Help svp !",
      timeAgo: "Il y a 5h",
    ),
  ];

class DemandeAidePage extends StatefulWidget {
  const DemandeAidePage({super.key});

  @override
  State<DemandeAidePage> createState() => _DemandeAidePageState();
}

class _DemandeAidePageState extends State<DemandeAidePage> {
  // Contrôleurs pour récupérer le texte des champs de création
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  // Fonction pour afficher la fenêtre d'ajout d'une nouvelle demande
  void _showCreateRequestModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Permet à la modal de remonter avec le clavier
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom, // Espace pour le clavier
            left: 20,
            right: 20,
            top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Nouvelle demande d'aide",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _subjectController,
                decoration: InputDecoration(
                  labelText: "Sujet (ex: Java - POO)",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _messageController,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: "Détaille ton besoin ici...",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: EnsiConnectApp.ensisaBlue,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    // Ajouter la demande uniquement si les champs sont remplis
                    if (_subjectController.text.isNotEmpty && _messageController.text.isNotEmpty) {
                      setState(() {
                        globalRequests.insert(
                          0, // Ajoute au début de la liste
                          HelpRequest(
                            authorName: "Ayoub Darkaoui", // À remplacer plus tard par l'utilisateur connecté
                            subject: _subjectController.text,
                            message: _messageController.text,
                            timeAgo: "À l'instant",
                            isMe: true,
                          ),
                        );
                      });
                      _subjectController.clear();
                      _messageController.clear();
                      Navigator.pop(context); // Fermer la modal
                    }
                  },
                  child: const Text("Publier ma demande", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Demandes d'aide", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: globalRequests.length,
        itemBuilder: (context, index) {
          final req = globalRequests[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            elevation: isDark ? 0 : 2,
            color: Theme.of(context).cardColor,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: isDark ? Colors.grey.shade800 : EnsiConnectApp.ensisaLightBlue,
                        child: Text(req.authorName[0], style: TextStyle(color: isDark ? Colors.white : EnsiConnectApp.ensisaBlue, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(req.authorName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            Text(req.timeAgo, style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade600, fontSize: 12)),
                          ],
                        ),
                      ),
                      if (req.isMe)
                        IconButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text("Supprimer la demande"),
                                content: const Text("Êtes-vous sûr de vouloir supprimer cette demande d'aide ?"),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text("Annuler"),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      setState(() {
                                        globalRequests.removeAt(index);
                                      });
                                      Navigator.pop(context);
                                    },
                                    child: const Text("Supprimer", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              ),
                            );
                          },
                          icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                          tooltip: "Supprimer",
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(req.subject, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 8),
                  Text(req.message, style: TextStyle(fontSize: 15, color: isDark ? Colors.grey.shade300 : Colors.black87, height: 1.4)),
                  if (!req.isMe) ...[
                    const SizedBox(height: 20),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // TODO : Action de navigation vers les messages / le chat de cet utilisateur
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Ouverture du chat avec ${req.authorName}..."))
                          );
                        },
                        icon: const Icon(Icons.chat_bubble_outline_rounded, size: 20),
                        label: const Text("Contacter", style: TextStyle(fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDark ? Colors.grey.shade800 : EnsiConnectApp.ensisaLightBlue,
                          foregroundColor: isDark ? Colors.lightBlueAccent : EnsiConnectApp.ensisaBlue,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        ),
                      ),
                    ),
                  ]
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateRequestModal,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("Nouvelle demande", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: EnsiConnectApp.ensisaBlue,
      ),
    );
  }
}