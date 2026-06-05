import "../widgets/ensiconnect_app.dart";
import 'package:flutter/material.dart';
import '../widgets/custom_drawer.dart';
import '../widgets/custom_header.dart';
import '../models/message.dart';
import '../models/conversation.dart';

class ChatPage extends StatefulWidget{
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final String currentUserId = "user1";

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;

    return Scaffold(
      key: _scaffoldKey, 
      drawer: const CustomDrawer(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomHeader(
                onMenuPressed: () => _scaffoldKey.currentState?.openDrawer(),
              ),
              const SizedBox(height: 20),
              Text(
                "Vos messages",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor),
              ),
              const SizedBox(height: 10),

              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: conversations.length,
                itemBuilder: (context, index) {
                  final convo = conversations[index];

                  final otherUser = getOtherUser(convo.participants, currentUserId); 

                  return ListTile(
                    leading: CircleAvatar(
                      child: Text(otherUser[0].toUpperCase()),
                    ),
                    title: Text(otherUser),
                    subtitle: Text(convo.lastMessage),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ConversationPage(
                            conversation:convo,
                            currentUserId: currentUserId,
                          ),
                        ),
                      );
                    },
                  );
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}




final List<Conversation> conversations = [
  Conversation(
    id: "c1",
    participants: ["user1", "user2"],
    lastMessage: "Salut, ça va",
    lastMessageAt: DateTime.now().subtract(const Duration(minutes: 2)),
    createdAt: DateTime.now().subtract(const Duration(days: 1)),
    messages: [
      Message(
        senderId: "user2",
        content: "Salut !",
        createdAt: DateTime.now().subtract(const Duration(minutes: 10)),
      ),
      Message(
        senderId: "user1",
        content: "Salut, ça va",
        createdAt: DateTime.now().subtract(const Duration(minutes: 2)),
      ),
    ],
  ),

  Conversation(
    id: "c2",
    participants: ["user1", "user3"],
    lastMessage: "J'ai faim",
    lastMessageAt: DateTime.now().subtract(const Duration(hours: 1)),
    createdAt: DateTime.now().subtract(const Duration(days: 2)),
    messages: [
      Message(
        senderId: "user3",
        content: "Tu fais quoi ?",
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      Message(
        senderId: "user1",
        content: "Rien de spécial",
        createdAt: DateTime.now().subtract(const Duration(hours: 1, minutes: 30)),
      ),
      Message(
        senderId: "user3",
        content: "J'ai faim",
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
    ],
  ),

  Conversation(
    id: "c3",
    participants: ["user1", "user4"],
    lastMessage: ":) 👍",
    lastMessageAt: DateTime.now().subtract(const Duration(minutes: 30)),
    createdAt: DateTime.now().subtract(const Duration(days: 5)),
    messages: [
      Message(
        senderId: "user4",
        content: "On révise ensemble demain ?",
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      ),
      Message(
        senderId: "user1",
        content: "Oui carrément",
        createdAt: DateTime.now().subtract(const Duration(hours: 2, minutes: 30)),
      ),
      Message(
        senderId: "user4",
        content: ":) 👍",
        createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
      ),
    ],
  ),
];

String getOtherUser(List<String> participants, String currentUserId) {
  return participants.firstWhere(
    (p) => p != currentUserId,
    orElse: () => participants.first,
  );
}

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
    
  @override
  Widget build(BuildContext context) {
    final otherUser = getOtherUser(widget.conversation.participants, widget.currentUserId);

    return Scaffold(
      resizeToAvoidBottomInset: true,

      appBar: AppBar(
        title: Text(otherUser),
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87,
      ),

      body:ListView.builder(
        padding: const EdgeInsets.all(10),
        itemCount: widget.conversation.messages.length,
        itemBuilder: (context, index) {
          final msg = widget.conversation.messages[index];
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
                 Color.fromARGB(255, 72, 72, 72) :
                 Color.fromARGB(255, 209, 209, 209),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(msg.content),
            ),
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
                const Expanded(
                  child: TextField(
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
                IconButton(
                  icon: const Icon(
                    Icons.send,
                    color: EnsiConnectApp.ensisaBlue,
                  ),
                  onPressed: () {_controller.clear();},
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}