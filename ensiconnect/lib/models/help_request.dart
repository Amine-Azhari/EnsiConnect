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