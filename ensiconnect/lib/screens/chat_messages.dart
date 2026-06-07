import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import "../widgets/ensiconnect_app.dart";
import '../models/message.dart';
import '../models/conversation.dart';
import '../service/chat_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'chat.dart';

class ConversationPage extends StatefulWidget {
  final Conversation conversation;
  final String currentUserId;

  const ConversationPage({
    super.key,
    required this.conversation,
    required this.currentUserId,
  });

  @override
  State<ConversationPage> createState() => _ConversationPageState();
}

class _ConversationPageState extends State<ConversationPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final ChatService chatService = ChatService(); 

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }
    
  @override
  Widget build(BuildContext context) {
    //Savoir si la conversation est une conversation de groupe
    final bool isGroup = widget.conversation.name != null;

    // Nom de la conversation
    final otherUser = isGroup
                    ? widget.conversation.name!
                    : getOtherUser(widget.conversation.participants, widget.currentUserId);

    return Scaffold(
      resizeToAvoidBottomInset: true,

      appBar: AppBar(
        title: Text(otherUser),
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87,
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: chatService.getMessages(widget.conversation.id),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          WidgetsBinding.instance.addPostFrameCallback((_) {
            _scrollToBottom();
          });

          return ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(10),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;

              final msg = Message(
                senderId: data['senderId'],
                content: data['content'],
                createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
              );

              final isMe = msg.senderId == widget.currentUserId;

              return Align(
                alignment:
                    isMe ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isMe ?
                      Theme.of(context).brightness == Brightness.dark ?
                      EnsiConnectApp.ensisaBlue :
                      EnsiConnectApp.ensisaLightBlue :
                      Theme.of(context).brightness == Brightness.dark ?
                      const Color.fromARGB(255, 72, 72, 72) :
                      const Color.fromARGB(255, 209, 209, 209),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment:
                        isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                    children: [
                      if (isGroup && !isMe)    
                        Text(
                          msg.senderId,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (isGroup && !isMe)  const SizedBox(height: 4),
                      
                      Text(msg.content),
                      const SizedBox(height: 6),
                      
                      Text(
                        msg.createdAt != null
                            ? DateFormat('HH:mm').format(msg.createdAt!)
                            : '',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),  

      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Container(
            height: 61,
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark ? Colors.black87 : Colors.white,
              borderRadius: BorderRadius.circular(35.0),
              border: Border.all(
                color: Colors.grey,
                width: 2.0,
              ),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.face,
                    color: EnsiConnectApp.ensisaBlue,
                  ),
                  onPressed: () {},
                ),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "Votre message",
                      hintStyle: TextStyle(
                        color: EnsiConnectApp.ensisaBlue,
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.attach_file,
                    color: EnsiConnectApp.ensisaBlue,
                  ),
                  onPressed: () {},
                ),
                // Bouton d'envoi d'un message
                IconButton(
                  icon: const Icon(
                    Icons.send,
                    color: EnsiConnectApp.ensisaBlue,
                  ),
                  onPressed: () async {
                    final text = _controller.text.trim();

                    if(text.isEmpty) return;

                    await chatService.sendMessage(
                      conversationId : widget.conversation.id,
                      senderId : widget.currentUserId,
                      content : text,
                    );

                    _controller.clear();},
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 10),
        curve: Curves.easeOut,
      );
    }
  }
}
