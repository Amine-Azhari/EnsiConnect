class Conversation {
  final String id;
  final List<String> participants;
  final String lastMessage;
  final DateTime? lastMessageAt;
  final DateTime? createdAt;

  Conversation({
    required this.id,
    required this.participants,
    required this.lastMessage,
    this.lastMessageAt,
    this.createdAt,
  });
}