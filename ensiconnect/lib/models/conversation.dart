import 'package:ensiconnect/models/message.dart';

class Conversation {
  final String id;
  final List<String> participants;
  final List<Message> messages;
  final String lastMessage;
  final DateTime? lastMessageAt;
  final DateTime? createdAt;

  Conversation({
    required this.id,
    required this.participants,
    required this.messages,
    required this.lastMessage,
    this.lastMessageAt,
    this.createdAt,
  });
}