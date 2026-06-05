class Message{
  final String senderId;
  final String content;
  final DateTime? createdAt;

  Message({
    required this.senderId,
    required this.content,
    this.createdAt,
  });
}