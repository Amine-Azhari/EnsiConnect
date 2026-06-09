import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import "../widgets/ensiconnect_app.dart";
import '../models/message.dart';
import '../models/conversation.dart';
import '../service/chat_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'chat.dart';
import 'profil.dart';
import '../widgets/person_avatar.dart';
import '../models/user.dart';

class ConversationPage extends StatefulWidget {
  final Conversation conversation;
  final String currentUserId;

  String? otherUserName;

  ConversationPage({
    super.key,
    required this.conversation,
    required this.currentUserId,
    this.otherUserName,
  });

  @override
  State<ConversationPage> createState() => _ConversationPageState();
}

class _ConversationPageState extends State<ConversationPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final ChatService chatService = ChatService();

  String? otherUserName;

  final Map<String, String> _userNamesCache = {};

  @override
  void initState() {
    super.initState();

    _loadOtherUserName();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  @override
  Widget build(BuildContext context) {
    //Savoir si la conversation est une conversation de groupe
    final bool isGroup = widget.conversation.name != null;

    return Scaffold(
      resizeToAvoidBottomInset: true,

      
      

      appBar: AppBar(
        actions: [
          if (isGroup)
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'members') {
                  showModalBottomSheet(
                    context: context,
                    builder: (context) {
                      final participants = widget.conversation.participants;

                      return ListView.separated(
                        separatorBuilder: (context, index) => const Divider(height: 18),
                        padding: EdgeInsets.only(top:10),
                        itemCount: participants.length,
                        itemBuilder: (context, index){
                           final id = participants[index];
                          
                          return FutureBuilder<User?>(
                            future: chatService.getUserById(id),
                            builder: (context, snapshot) {
                              final user = snapshot.data;
                              if (!snapshot.hasData) {
                                return const ListTile(
                                  title: Text("Chargement..."),
                                );
                              }
                              if (user?.id != widget.currentUserId){
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ProfilPage(
                                          userId: user!.id,                                
                                        ),
                                      ),
                                    );
                                  },
                                  child: ListTile(
                                    leading: PersonAvatar(
                                      name: user?.fullName ?? id,
                                    ),
                                    title: Text(user?.fullName ?? id),
                                  ),
                                );
                              }
                              else { 
                                return ListTile(
                                  leading: PersonAvatar(
                                    name: user?.fullName ?? id,
                                  ),
                                  title: Text('Vous ('+(user?.fullName ?? id)+')'),
                                );
                              }
                            },
                          );
                        }
                      );
                    },
                  );
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem(
                  value: 'members',
                  child: Text('Voir les membres'),
                ),
              ],
            ),
        ],
        title: Row(
          children: [

            // Nom de la conversation
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    otherUserName ?? '',
                  ),
                ],
              )
            ),
            

            // Photo de profil si conversation normale
            if(!isGroup) 
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProfilPage(
                        userId: getOtherUser(widget.conversation.participants, widget.currentUserId),                                
                      ),
                    ),
                  );
                },
                child:PersonAvatar(
                  name: otherUserName ?? '?',
                ),
              ),

            // Liste des personnes dans la conversation
            
          ],
        ),

        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: Theme.of(context).brightness == Brightness.dark
            ? Colors.white
            : Colors.black87,
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
                senderId: data['SenderId'],
                content: data['Content'],
                createdAt: (data['CreatedAt'] as Timestamp?)?.toDate(),
              );

              final isMe = msg.senderId == widget.currentUserId;

              return Align(
                  alignment:
                      isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Photo de profil qui redirige vers le profil
                        if (isGroup && !isMe)
                          FutureBuilder<String>(
                            future: data['Name'] != null
                                ? Future.value(data['Name'])
                                : getUserName(msg.senderId),
                            builder: (context, snapshot) {
                              final name = snapshot.data ?? '?';
                              return Padding(
                                padding: const EdgeInsets.only(top: 15),
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ProfilPage(
                                          userId: msg.senderId,
                                        ),
                                      ),
                                    );
                                  },
                                  child: PersonAvatar(
                                    name: name,
                                  ),
                                ),
                              );
                            },
                          ),
                        if (isGroup && !isMe)
                          const Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 5, vertical: 5)),

                        ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.7,
                          ),
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isMe
                                  ? Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? EnsiConnectApp.ensisaBlue
                                      : EnsiConnectApp.ensisaLightBlue
                                  : Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? const Color.fromARGB(255, 72, 72, 72)
                                      : const Color.fromARGB(
                                          255, 209, 209, 209),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: isMe
                                  ? CrossAxisAlignment.end
                                  : CrossAxisAlignment.start,
                              children: [
                                if (isGroup && !isMe)
                                  FutureBuilder<String>(
                                    future: data['Name'] != null
                                        ? Future.value(data['Name'])
                                        : getUserName(msg.senderId),
                                    builder: (context, snapshot) {
                                      final name = snapshot.data ?? '?';
                                      return Text(
                                        name,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      );
                                    },
                                  ),
                                if (isGroup && !isMe) const SizedBox(height: 4),
                                Text(msg.content),
                                const SizedBox(height: 6),
                                Text(
                                  msg.createdAt != null
                                      ? DateFormat('HH:mm')
                                          .format(msg.createdAt!)
                                      : '',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                        )
                      ]));
            },
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            left: 15,
            right: 15,
            top: 15,
            bottom: MediaQuery.of(context).viewInsets.bottom + 15,
          ),
          child: Container(
            height: 61,
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.black87
                  : Colors.white,
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
                    Icons.attach_file,
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
                // Bouton d'envoi d'un message
                IconButton(
                  icon: const Icon(
                    Icons.send,
                    color: EnsiConnectApp.ensisaBlue,
                  ),
                  onPressed: () async {
                    final text = _controller.text.trim();

                    if (text.isEmpty) return;

                    await chatService.sendMessage(
                      conversationId: widget.conversation.id,
                      senderId: widget.currentUserId,
                      content: text,
                    );

                    _controller.clear();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _scrollToBottom() async {
    await Future.delayed(const Duration(milliseconds: 100));

    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 10),
        curve: Curves.easeOut,
      );
    }
  }

  // Charger le nom de la conversation
  Future<void> _loadOtherUserName() async {
    final convo = widget.conversation;

    if (convo.name != null) {
      setState(() {
        otherUserName = convo.name;
      });
      return;
    }
    final otherId = getOtherUser(
      convo.participants,
      widget.currentUserId,
    );
    final user = await chatService.getUserById(otherId);
    if (!mounted) return;
    setState(() {
      otherUserName = user?.fullName ?? otherId;
    });
  }

  Future<String> getUserName(String userId) async {
    if (_userNamesCache.containsKey(userId)) {
      return _userNamesCache[userId]!;
    }

    final user = await chatService.getUserById(userId);

    final name = user?.fullName ?? userId;

    _userNamesCache[userId] = name;

    return name;
  }
}
