class HelpRequest {
  final String? id;
  final String authorId;
  final String authorFirstName;
  final String authorLastName;
  final String subject;
  final String message;
  final DateTime? createdAt;
  final bool isMe;

  HelpRequest({
    this.id,
    required this.authorId,
    required this.authorFirstName,
    required this.authorLastName,
    required this.subject,
    required this.message,
    this.createdAt,
    this.isMe = false,
  });

  String get authorName {
    final fullName = '$authorFirstName $authorLastName'.trim();
    return fullName.isEmpty ? 'Utilisateur' : fullName;
  }

  String get timeAgo => _formatTimeAgo(createdAt);

  factory HelpRequest.fromMap(
    Map<String, dynamic> map, {
    String? id,
    bool isMe = false,
  }) {
    final createdAtRaw = map['CreatedAt'];
    DateTime? createdAt;
    if (createdAtRaw is DateTime) {
      createdAt = createdAtRaw;
    } else if (createdAtRaw != null && createdAtRaw.toString().isNotEmpty) {
      createdAt = DateTime.tryParse(createdAtRaw.toString());
    }

    return HelpRequest(
      id: id,
      authorId: map['OrganisateurId'] ?? '',
      authorFirstName: map['OrganisateurPrenom'] ?? '',
      authorLastName: map['OrganisateurNom'] ?? '',
      subject: map['Sujet'] ?? '',
      message: map['Description'] ?? '',
      createdAt: createdAt,
      isMe: isMe,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'OrganisateurId': authorId,
      'OrganisateurPrenom': authorFirstName,
      'OrganisateurNom': authorLastName,
      'Sujet': subject,
      'Description': message,
      'CreatedAt': createdAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
    };
  }

  static String _formatTimeAgo(DateTime? createdAt) {
    if (createdAt == null) {
      return 'Date inconnue';
    }

    final difference = DateTime.now().difference(createdAt);
    if (difference.inMinutes < 1) {
      return "À l'instant";
    }
    if (difference.inHours < 1) {
      return 'Il y a ${difference.inMinutes} min';
    }
    if (difference.inDays < 1) {
      return 'Il y a ${difference.inHours} h';
    }
    return 'Il y a ${difference.inDays} j';
  }
}
