import 'package:flutter/material.dart';
import "../widgets/ensiconnect_app.dart";
import '../models/help_request.dart';
import '../service/auth_service.dart';
import '../service/help_request_service.dart';

class DemandeAidePage extends StatefulWidget {
  const DemandeAidePage({super.key});

  @override
  State<DemandeAidePage> createState() => _DemandeAidePageState();
}

class _DemandeAidePageState extends State<DemandeAidePage> {
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  final AuthServices _authServices = AuthServices();
  final HelpRequestService _helpRequestService = HelpRequestService();

  @override
  void dispose() {
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _createRequest() async {
    final subject = _subjectController.text.trim();
    final message = _messageController.text.trim();

    if (subject.isEmpty || message.isEmpty) {
      return;
    }

    final currentUser = await _authServices.getCurrentUser();
    if (!mounted) return;

    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Utilisateur non connecté.")),
      );
      return;
    }

    await _helpRequestService.createRequest(
      HelpRequest(
        authorId: currentUser.id,
        authorFirstName: currentUser.firstName,
        authorLastName: currentUser.lastName,
        subject: subject,
        message: message,
        createdAt: DateTime.now(),
      ),
    );

    if (!mounted) return;

    _subjectController.clear();
    _messageController.clear();
    Navigator.pop(context);
  }

  void _showCreateRequestModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
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
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _messageController,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: "Détaille ton besoin ici...",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: EnsiConnectApp.ensisaBlue,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _createRequest,
                  child: const Text(
                    "Publier ma demande",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
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
        title: const Text(
          "Demandes d'aide",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: FutureBuilder(
        future: _authServices.getCurrentUser(),
        builder: (context, userSnapshot) {
          final currentUserId = userSnapshot.data?.id;

          return StreamBuilder<List<HelpRequest>>(
            stream: _helpRequestService.watchRequests(currentUserId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return const Center(
                  child: Text("Erreur de chargement des demandes d'aide."),
                );
              }

              final requests = snapshot.data ?? [];

              if (requests.isEmpty) {
                return const Center(
                  child: Text("Aucune demande d'aide pour le moment."),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: requests.length,
                itemBuilder: (context, index) {
                  final req = requests[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isDark
                            ? Colors.grey.shade800
                            : Colors.grey.shade200,
                        width: 1,
                      ),
                    ),
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
                                backgroundColor: isDark
                                    ? Colors.grey.shade800
                                    : EnsiConnectApp.ensisaLightBlue,
                                child: Text(
                                  req.authorName.isNotEmpty
                                      ? req.authorName[0]
                                      : '?',
                                  style: TextStyle(
                                    color: isDark
                                        ? Colors.white
                                        : EnsiConnectApp.ensisaBlue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      req.authorName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Text(
                                      req.timeAgo,
                                      style: TextStyle(
                                        color: isDark
                                            ? Colors.grey.shade400
                                            : Colors.grey.shade600,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (req.isMe)
                                IconButton(
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text(
                                          "Supprimer la demande",
                                        ),
                                        content: const Text(
                                          "Êtes-vous sûr de vouloir supprimer cette demande d'aide ?",
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            child: const Text("Annuler"),
                                          ),
                                          TextButton(
                                            onPressed: () async {
                                              final sessionId = req.id;
                                              if (sessionId != null) {
                                                await _helpRequestService
                                                    .deleteRequest(sessionId);
                                              }
                                              if (context.mounted) {
                                                Navigator.pop(context);
                                              }
                                            },
                                            child: const Text(
                                              "Supprimer",
                                              style: TextStyle(
                                                color: Colors.red,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                  icon: const Icon(
                                    Icons.delete_outline_rounded,
                                    color: Colors.redAccent,
                                  ),
                                  tooltip: "Supprimer",
                                ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            req.subject,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            req.message,
                            style: TextStyle(
                              fontSize: 15,
                              color: isDark
                                  ? Colors.grey.shade300
                                  : Colors.black87,
                              height: 1.4,
                            ),
                          ),
                          if (!req.isMe) ...[
                            const SizedBox(height: 20),
                            Align(
                              alignment: Alignment.centerRight,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        "Ouverture du chat avec ${req.authorName}...",
                                      ),
                                    ),
                                  );
                                },
                                icon: const Icon(
                                  Icons.chat_bubble_outline_rounded,
                                  size: 20,
                                ),
                                label: const Text(
                                  "Contacter",
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isDark
                                      ? Colors.grey.shade800
                                      : EnsiConnectApp.ensisaLightBlue,
                                  foregroundColor: isDark
                                      ? Colors.lightBlueAccent
                                      : EnsiConnectApp.ensisaBlue,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 12,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateRequestModal,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          "Nouvelle demande",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: EnsiConnectApp.ensisaBlue,
      ),
    );
  }
}
