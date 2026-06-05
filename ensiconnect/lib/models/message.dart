class Message{
  final String senderId;
  final String content;
  final DateTime? createdAt;

  Message({
    required this.senderId,
    required this.content,
    this.createdAt,
  });

  @override
  static String formatTimeAgo(DateTime? createdAt) {
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